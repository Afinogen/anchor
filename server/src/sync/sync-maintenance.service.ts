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
    const rows = await this.prisma.$queryRaw<{ count: bigint }[]>`
      WITH doomed AS (
        DELETE FROM "ChangeLog"
        WHERE "op" = 'remove' AND "updatedAt" < ${cutoff}
        RETURNING "recipientUserId", "seq"
      ),
      advanced AS (
        UPDATE "SyncState" s
        SET "prunedThroughSeq" = GREATEST(s."prunedThroughSeq", d."maxSeq")
        FROM (
          SELECT "recipientUserId", MAX("seq") AS "maxSeq"
          FROM doomed
          GROUP BY "recipientUserId"
        ) d
        WHERE s."userId" = d."recipientUserId"
        RETURNING s."userId"
      )
      SELECT count(*)::bigint AS count FROM doomed`;

    return { prunedChangeLogCount: Number(rows[0].count) };
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
