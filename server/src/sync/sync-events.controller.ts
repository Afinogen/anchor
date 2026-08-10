import {
  Controller,
  Header,
  MessageEvent,
  Sse,
  UseGuards,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { AuthGuard } from '../auth/auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { SyncEventsService } from './sync-events.service';

@Controller('api/sync')
@UseGuards(AuthGuard)
export class SyncEventsController {
  constructor(private readonly syncEvents: SyncEventsService) {}

  // The JWT is checked at connect and then trusted for the stream's lifetime,
  // bounded by the max stream age.
  @Sse('events')
  @Header('X-Accel-Buffering', 'no')
  events(@CurrentUser('id') userId: string): Observable<MessageEvent> {
    return this.syncEvents.stream(userId);
  }
}
