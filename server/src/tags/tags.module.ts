import { Module } from '@nestjs/common';
import { TagsService } from './tags.service';
import { TagsController } from './tags.controller';
import { AuthModule } from '../auth/auth.module';
import { SyncModule } from '../sync/sync.module';

@Module({
  imports: [AuthModule, SyncModule],
  controllers: [TagsController],
  providers: [TagsService],
  exports: [TagsService],
})
export class TagsModule {}
