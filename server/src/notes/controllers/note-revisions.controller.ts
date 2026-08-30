import {
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { NoteHistoryService } from '../services/note-history.service';
import { ListNoteRevisionsDto } from '../dto/list-note-revisions.dto';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { AuthGuard } from '../../auth/auth.guard';

@Controller('api/notes/:noteId/revisions')
@UseGuards(AuthGuard)
export class NoteRevisionsController {
  constructor(private readonly noteHistoryService: NoteHistoryService) {}

  @Get()
  list(
    @CurrentUser('id') userId: string,
    @Param('noteId') noteId: string,
    @Query() query: ListNoteRevisionsDto,
  ) {
    return this.noteHistoryService.list(userId, noteId, query);
  }

  @Get(':id')
  findOne(
    @CurrentUser('id') userId: string,
    @Param('noteId') noteId: string,
    @Param('id') revisionId: string,
  ) {
    return this.noteHistoryService.findOne(userId, noteId, revisionId);
  }

  @Post(':id/restore')
  @HttpCode(HttpStatus.OK)
  restore(
    @CurrentUser('id') userId: string,
    @Param('noteId') noteId: string,
    @Param('id') revisionId: string,
  ) {
    return this.noteHistoryService.restore(userId, noteId, revisionId);
  }
}
