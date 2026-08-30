import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { NotesModule } from '../notes/notes.module';
import { SyncModule } from './sync.module';
import { SyncController } from './sync.controller';
import { SyncEventsController } from './sync-events.controller';
import { SyncService } from './sync.service';
import { SyncApplyService } from './sync-apply.service';
import { SyncFeedService } from './sync-feed.service';
import { SyncHydratorService } from './sync-hydrator.service';

// Split from SyncModule so the endpoint can use NotesModule while the entity
// modules keep importing the leaf SyncModule without a cycle.
@Module({
  imports: [AuthModule, NotesModule, SyncModule],
  controllers: [SyncController, SyncEventsController],
  providers: [
    SyncService,
    SyncApplyService,
    SyncFeedService,
    SyncHydratorService,
  ],
})
export class SyncApiModule {}
