import type { TransformedNote } from '../../notes/utils/note-transformer.util';
import type { AttachmentResponseDto } from '../../notes/dto/attachment-response.dto';
import type { Tag } from 'src/generated/prisma/client';

export interface SyncTagPayload {
  id: string;
  name: string;
  color: string | null;
  version: number;
  createdAt: string;
  updatedAt: string;
}

export const toSyncTagPayload = (tag: Tag): SyncTagPayload => ({
  id: tag.id,
  name: tag.name,
  color: tag.color,
  version: tag.version,
  createdAt: tag.createdAt.toISOString(),
  updatedAt: tag.updatedAt.toISOString(),
});

// seq is a string: BigInt doesn't survive JSON. Snapshot entries carry seq "0".
export interface SyncFeedEntry {
  seq: string;
  entityType: 'note' | 'tag' | 'pin' | 'attachments';
  entityId: string;
  op: 'upsert' | 'remove';
  note?: TransformedNote;
  tag?: SyncTagPayload;
  attachments?: AttachmentResponseDto[];
}

// `denied` is final and the client drops the change; `failed` is transient and
// the client keeps it queued.
export type SyncApplyStatus = 'applied' | 'conflict' | 'denied' | 'failed';

export interface SyncApplyResult {
  type: 'note' | 'tag' | 'pin';
  id: string;
  status: SyncApplyStatus;
  version?: number;
  // The copy the client must adopt. For a tag name collision it carries a
  // different id: a merge instruction.
  serverCopy?: TransformedNote | SyncTagPayload;
}

export interface SyncFeedPage {
  entries: SyncFeedEntry[];
  nextCursor: string | null;
  hasMore: boolean;
  resetRequired?: boolean;
}

export interface SyncResponse extends SyncFeedPage {
  protocol: 3;
  results: SyncApplyResult[];
}
