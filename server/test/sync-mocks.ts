import { SyncEmitterService } from '../src/sync/sync-emitter.service';
import { SyncEventsService } from '../src/sync/sync-events.service';
import { NoteRevisionsService } from '../src/sync/note-revisions.service';

// Emitter/revisions doubles for service unit tests, which assert service
// behaviour rather than ChangeLog contents.
export function createMockSyncEmitter() {
  return {
    emit: jest.fn().mockResolvedValue([]),
    noteRecipients: jest.fn().mockResolvedValue([]),
    notesRecipients: jest.fn().mockResolvedValue(new Map<string, string[]>()),
    removeNote: jest.fn().mockResolvedValue([]),
    removeNotes: jest.fn().mockResolvedValue([]),
  };
}

export type MockSyncEmitter = ReturnType<typeof createMockSyncEmitter>;

export const asSyncEmitter = (mock: MockSyncEmitter) =>
  mock as unknown as SyncEmitterService;

export function createMockSyncEvents() {
  return {
    schedulePoke: jest.fn(),
    poke: jest.fn(),
  };
}

export type MockSyncEvents = ReturnType<typeof createMockSyncEvents>;

export const asSyncEvents = (mock: MockSyncEvents) =>
  mock as unknown as SyncEventsService;

export function createMockNoteRevisions() {
  return {
    recordEdit: jest.fn().mockResolvedValue(undefined),
    recordConflict: jest.fn().mockResolvedValue(undefined),
  };
}

export type MockNoteRevisions = ReturnType<typeof createMockNoteRevisions>;

export const asNoteRevisions = (mock: MockNoteRevisions) =>
  mock as unknown as NoteRevisionsService;
