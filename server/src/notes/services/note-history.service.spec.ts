import { NotFoundException } from '@nestjs/common';
import { NoteHistoryService } from './note-history.service';
import { NoteAccessService } from './note-access.service';
import { PrismaService } from '../../prisma/prisma.service';
import { NoteState, RevisionCause } from 'src/generated/prisma/enums';
import {
  createMockSyncEmitter,
  createMockNoteRevisions,
  asSyncEmitter,
  asNoteRevisions,
} from '../../../test/sync-mocks';

describe('NoteHistoryService', () => {
  const NOTE_ID = 'note-1';
  const USER = 'user-1';

  interface Revision {
    id: string;
    noteId: string;
    version: number;
    title: string;
    content: string | null;
    cause: RevisionCause;
    createdAt: Date;
    author: { id: string; name: string; email: string } | null;
  }

  let revisions: Revision[];
  let note: {
    id: string;
    title: string;
    content: string | null;
    version: number;
    createdAt: Date;
    updatedAt: Date;
  };
  let access: { hasAccess: boolean; isOwner: boolean; state?: NoteState };
  let service: NoteHistoryService;
  let emitter: ReturnType<typeof createMockSyncEmitter>;
  let noteRevisions: ReturnType<typeof createMockNoteRevisions>;

  const revisionFindMany = ({
    take,
    cursor,
    skip,
  }: {
    take: number;
    cursor?: { id: string };
    skip?: number;
  }) => {
    const ordered = [...revisions].sort(
      (a, b) => b.createdAt.getTime() - a.createdAt.getTime(),
    );
    const from = cursor
      ? ordered.findIndex((r) => r.id === cursor.id) + (skip ?? 0)
      : 0;
    return Promise.resolve(ordered.slice(from, from + take));
  };

  const revisionFindFirst = ({
    where,
  }: {
    where: { id: string; noteId: string };
  }) =>
    Promise.resolve(
      revisions.find((r) => r.id === where.id && r.noteId === where.noteId) ??
        null,
    );

  const noteUpdate = ({
    data,
  }: {
    data: { title: string; content: string | null };
  }) => {
    note = { ...note, ...data, version: note.version + 1 };
    return Promise.resolve(note);
  };

  const prismaMock = {
    noteRevision: { findMany: revisionFindMany, findFirst: revisionFindFirst },
    note: {
      findUniqueOrThrow: () => Promise.resolve(note),
      update: noteUpdate,
    },
    $transaction: (fn: (tx: unknown) => Promise<unknown>) => fn(prismaMock),
  };

  const accessMock = {
    ensureNoteAccess: jest.fn(() => {
      if (!access.hasAccess) {
        throw new NotFoundException('Note not found');
      }
      return Promise.resolve(access);
    }),
    ensureNoteIsActive: jest.fn().mockResolvedValue(undefined),
  };

  const revisionAt = (
    id: string,
    minutesAgo: number,
    over: Partial<Revision> = {},
  ) => ({
    id,
    noteId: NOTE_ID,
    version: 1,
    title: 'groceries',
    content: `content ${id}`,
    cause: RevisionCause.edit,
    createdAt: new Date(Date.now() - minutesAgo * 60_000),
    author: { id: USER, name: 'Ada', email: 'ada@example.com' },
    ...over,
  });

  beforeEach(() => {
    revisions = [];
    note = {
      id: NOTE_ID,
      title: 'groceries',
      content: 'milk',
      version: 4,
      createdAt: new Date('2026-08-01T00:00:00.000Z'),
      updatedAt: new Date('2026-08-02T00:00:00.000Z'),
    };
    access = { hasAccess: true, isOwner: true, state: NoteState.active };
    emitter = createMockSyncEmitter();
    noteRevisions = createMockNoteRevisions();
    jest.clearAllMocks();

    service = new NoteHistoryService(
      prismaMock as unknown as PrismaService,
      accessMock as unknown as NoteAccessService,
      asSyncEmitter(emitter),
      asNoteRevisions(noteRevisions),
    );
  });

  describe('list', () => {
    it('returns newest first without content', async () => {
      revisions = [revisionAt('r-old', 20), revisionAt('r-new', 1)];

      const page = await service.list(USER, NOTE_ID, {});

      expect(page.revisions.map((r) => r.id)).toEqual(['r-new', 'r-old']);
      expect(page.revisions[0]).not.toHaveProperty('content');
      expect(page.nextCursor).toBeNull();
    });

    it('hands back a cursor only while more remain', async () => {
      revisions = [
        revisionAt('r-1', 1),
        revisionAt('r-2', 2),
        revisionAt('r-3', 3),
      ];

      const first = await service.list(USER, NOTE_ID, { limit: 2 });
      expect(first.revisions.map((r) => r.id)).toEqual(['r-1', 'r-2']);
      expect(first.nextCursor).toBe('r-2');

      const second = await service.list(USER, NOTE_ID, {
        limit: 2,
        cursor: first.nextCursor!,
      });
      expect(second.revisions.map((r) => r.id)).toEqual(['r-3']);
      expect(second.nextCursor).toBeNull();
    });

    it('keeps conflict revisions in the same timeline', async () => {
      revisions = [
        revisionAt('r-edit', 5),
        revisionAt('r-lost', 1, { cause: RevisionCause.conflict }),
      ];

      const page = await service.list(USER, NOTE_ID, {});

      expect(page.revisions.map((r) => [r.id, r.cause])).toEqual([
        ['r-lost', RevisionCause.conflict],
        ['r-edit', RevisionCause.edit],
      ]);
    });

    it('is kept from viewers, who never saw what the note dropped', async () => {
      await service.list(USER, NOTE_ID, {});

      expect(accessMock.ensureNoteAccess).toHaveBeenCalledWith(
        USER,
        NOTE_ID,
        'editor',
      );
    });

    it('hides the history of a tombstoned note', async () => {
      access = { hasAccess: true, isOwner: true, state: NoteState.deleted };

      await expect(service.list(USER, NOTE_ID, {})).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('findOne', () => {
    it('carries the content of the revision', async () => {
      revisions = [revisionAt('r-1', 1)];

      await expect(
        service.findOne(USER, NOTE_ID, 'r-1'),
      ).resolves.toMatchObject({ id: 'r-1', content: 'content r-1' });
    });

    it('will not read a revision of another note', async () => {
      revisions = [revisionAt('r-1', 1, { noteId: 'note-2' })];

      await expect(service.findOne(USER, NOTE_ID, 'r-1')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('restore', () => {
    it('puts the old content back and keeps the replaced content', async () => {
      revisions = [
        revisionAt('r-1', 30, { title: 'shopping', content: 'eggs' }),
      ];

      const restored = await service.restore(USER, NOTE_ID, 'r-1');

      expect(noteRevisions.recordRestore).toHaveBeenCalledWith(
        prismaMock,
        expect.objectContaining({ title: 'groceries', content: 'milk' }),
        USER,
      );
      expect(restored).toMatchObject({
        title: 'shopping',
        content: 'eggs',
        version: 5,
      });
    });

    it('tells every recipient the note changed', async () => {
      revisions = [revisionAt('r-1', 30, { content: 'eggs' })];
      emitter.noteRecipients.mockResolvedValue([USER, 'user-2']);

      await service.restore(USER, NOTE_ID, 'r-1');

      expect(emitter.emit).toHaveBeenCalledWith(prismaMock, [
        {
          recipientUserId: USER,
          entityType: 'note',
          entityId: NOTE_ID,
          op: 'upsert',
        },
        {
          recipientUserId: 'user-2',
          entityType: 'note',
          entityId: NOTE_ID,
          op: 'upsert',
        },
      ]);
    });

    it('does nothing when the revision matches what the note already says', async () => {
      revisions = [
        revisionAt('r-1', 30, { title: 'groceries', content: 'milk' }),
      ];

      const restored = await service.restore(USER, NOTE_ID, 'r-1');

      expect(noteRevisions.recordRestore).not.toHaveBeenCalled();
      expect(emitter.emit).not.toHaveBeenCalled();
      expect(restored).toMatchObject({ version: 4 });
    });

    it('needs editor permission and an active note', async () => {
      revisions = [revisionAt('r-1', 30, { content: 'eggs' })];

      await service.restore(USER, NOTE_ID, 'r-1');

      expect(accessMock.ensureNoteAccess).toHaveBeenCalledWith(
        USER,
        NOTE_ID,
        'editor',
      );
      expect(accessMock.ensureNoteIsActive).toHaveBeenCalledWith(NOTE_ID);
    });

    it('will not restore a revision of another note', async () => {
      revisions = [revisionAt('r-1', 30, { noteId: 'note-2' })];

      await expect(service.restore(USER, NOTE_ID, 'r-1')).rejects.toThrow(
        NotFoundException,
      );
    });
  });
});
