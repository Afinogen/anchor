import { Module } from '@nestjs/common';
import { SyncEmitterService } from './sync-emitter.service';
import { SyncEventsService } from './sync-events.service';
import { NoteRevisionsService } from './note-revisions.service';
import { SyncMaintenanceService } from './sync-maintenance.service';

@Module({
  providers: [
    SyncEmitterService,
    SyncEventsService,
    NoteRevisionsService,
    SyncMaintenanceService,
  ],
  exports: [
    SyncEmitterService,
    SyncEventsService,
    NoteRevisionsService,
    SyncMaintenanceService,
  ],
})
export class SyncModule {}
