import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RevisionCause } from 'src/generated/prisma/enums';
import {
  CHANGELOG_REMOVE_RETENTION_DAYS,
  NOTE_REVISION_CAP_PER_NOTE,
  NOTE_REVISION_RETENTION_DAYS,
} from './sync.constants';

@Injectable()
export class SyncMaintenanceService {
  constructor(private prisma: PrismaService) {}

  // Upsert rows are the index itself and live forever; only remove rows age
  // out. prunedThroughSeq advances with them, so a cursor that never saw a
  // pruned removal gets resetRequired instead of keeping a deleted entity.
  async pruneChangeLog(retentionDays = CHANGELOG_REMOVE_RETENTION_DAYS) {
    const cutoff = daysAgo(retentionDays);
    const recipients = await this.prisma.$queryRaw<
      { recipientUserId: string }[]
    >`
      SELECT DISTINCT "recipientUserId" FROM "ChangeLog"
      WHERE "op" = 'remove' AND "updatedAt" < ${cutoff}`;

    let prunedChangeLogCount = 0;
    for (const { recipientUserId } of recipients) {
      prunedChangeLogCount += await this.prisma.$transaction(async (tx) => {
        // A zero-length block consumes no seq; it takes the SyncState row lock.
        await tx.$queryRaw`SELECT next_sync_seq(${recipientUserId}::text, 0::int)`;

        const rows = await tx.$queryRaw<
          { count: bigint; maxSeq: bigint | null }[]
        >`
          WITH doomed AS (
            DELETE FROM "ChangeLog"
            WHERE "recipientUserId" = ${recipientUserId}
              AND "op" = 'remove'
              AND "updatedAt" < ${cutoff}
            RETURNING "seq"
          )
          SELECT count(*)::bigint AS "count", MAX("seq") AS "maxSeq" FROM doomed`;

        const { count, maxSeq } = rows[0];
        if (maxSeq !== null) {
          await tx.$executeRaw`
            UPDATE "SyncState"
            SET "prunedThroughSeq" = GREATEST("prunedThroughSeq", ${maxSeq.toString()}::bigint)
            WHERE "userId" = ${recipientUserId}`;
        }
        return Number(count);
      });
    }

    return { prunedChangeLogCount };
  }

  async pruneNoteRevisions(
    retentionDays = NOTE_REVISION_RETENTION_DAYS,
    capPerNote = NOTE_REVISION_CAP_PER_NOTE,
  ) {
    const cutoff = daysAgo(retentionDays);

    const aged = await this.prisma.noteRevision.deleteMany({
      where: { cause: RevisionCause.edit, createdAt: { lt: cutoff } },
    });

    // Newest-first cap per note, sparing recent conflict revisions: they hold
    // content someone lost.
    const capped = await this.prisma.$executeRaw`
      DELETE FROM "NoteRevision"
      WHERE "id" IN (
        SELECT "id" FROM (
          SELECT
            "id",
            "cause",
            "createdAt",
            ROW_NUMBER() OVER (
              PARTITION BY "noteId"
              ORDER BY "createdAt" DESC, "id" DESC
            ) AS rn
          FROM "NoteRevision"
        ) ranked
        WHERE rn > ${capPerNote}
          AND NOT ("cause" = 'conflict' AND "createdAt" >= ${cutoff})
      )`;

    return { agedEditRevisionCount: aged.count, cappedRevisionCount: capped };
  }
}

const daysAgo = (days: number) => {
  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - days);
  return cutoff;
};
