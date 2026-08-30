import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { NotesService } from '../notes/services/notes.service';
import { TagsService } from '../tags/tags.service';
import { PrismaService } from '../prisma/prisma.service';
import { SyncMaintenanceService } from '../sync/sync-maintenance.service';

@Injectable()
export class TasksService {
  private readonly logger = new Logger(TasksService.name);

  constructor(
    private readonly notesService: NotesService,
    private readonly tagsService: TagsService,
    private readonly prisma: PrismaService,
    private readonly syncMaintenance: SyncMaintenanceService,
  ) {}

  // Run daily at 2:00 AM to clean up expired refresh tokens
  @Cron(CronExpression.EVERY_DAY_AT_2AM)
  async handleExpiredTokenCleanup() {
    this.logger.log('Starting scheduled expired refresh token cleanup...');

    try {
      const result = await this.prisma.refreshToken.deleteMany({
        where: {
          expiresAt: {
            lt: new Date(),
          },
        },
      });

      this.logger.log(
        `Expired token cleanup completed. Deleted ${result.count} expired refresh tokens.`,
      );
    } catch (error) {
      this.logger.error('Expired token cleanup failed:', error);
    }
  }

  // Run daily at 3:00 AM to clean up trash and purge old tombstones
  @Cron(CronExpression.EVERY_DAY_AT_3AM)
  async handleTrashCleanup() {
    this.logger.log('Starting scheduled trash cleanup...');

    try {
      // First: auto-delete notes that have been in trash for more than 30 days
      const trashResult = await this.notesService.autoDeleteExpiredTrash(30);

      // Then: purge tombstones older than 30 days
      const notesResult = await this.notesService.purgeTombstones(30);
      const tagsResult = await this.tagsService.purgeTombstones(30);

      this.logger.log(
        `Tombstone purge completed. Converted ${trashResult.convertedCount} trashed notes to tombstones. Purged ${notesResult.purgedNotesCount} notes, ${notesResult.purgedSharesCount} shares, and ${tagsResult.purgedTagsCount} tags.`,
      );
    } catch (error) {
      this.logger.error('Tombstone purge failed:', error);
    }
  }

  // Run daily at 4:00 AM to prune the sync feed index and note history
  @Cron(CronExpression.EVERY_DAY_AT_4AM)
  async handleSyncMaintenance() {
    this.logger.log('Starting scheduled sync maintenance...');

    try {
      const changeLog = await this.syncMaintenance.pruneChangeLog();
      const revisions = await this.syncMaintenance.pruneNoteRevisions();

      this.logger.log(
        `Sync maintenance completed. Pruned ${changeLog.prunedChangeLogCount} changelog remove rows, ` +
          `${revisions.agedEditRevisionCount} aged edit revisions, and ${revisions.cappedRevisionCount} over-cap revisions.`,
      );
    } catch (error) {
      this.logger.error('Sync maintenance failed:', error);
    }
  }
}
