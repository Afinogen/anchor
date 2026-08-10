import type { Prisma } from 'src/generated/prisma/client';
import { RevisionCause } from 'src/generated/prisma/enums';
import { NoteRevisionsService } from './note-revisions.service';
import { REVISION_COLLAPSE_WINDOW_MS } from './sync.constants';

describe('NoteRevisionsService.recordEdit', () => {
  let service: NoteRevisionsService;
  let newest: {
    cause: RevisionCause;
    authorUserId: string | null;
    createdAt: Date;
  } | null;

  const revisionFindFirst = jest.fn(() => Promise.resolve(newest));
  const revisionCreate = jest.fn().mockResolvedValue({});

  const tx = {
    noteRevision: { findFirst: revisionFindFirst, create: revisionCreate },
  } as unknown as Prisma.TransactionClient;

  const prior = {
    id: 'note-1',
    title: 'Old title',
    content: 'old content',
    version: 3,
  };

  beforeEach(() => {
    service = new NoteRevisionsService();
    newest = null;
    jest.clearAllMocks();
  });

  it('preserves the replaced content as an edit revision', async () => {
    await service.recordEdit(tx, prior, 'author-1');

    expect(revisionCreate).toHaveBeenCalledWith({
      data: {
        noteId: 'note-1',
        version: 3,
        title: 'Old title',
        content: 'old content',
        authorUserId: 'author-1',
        cause: RevisionCause.edit,
      },
    });
  });

  it('collapses a same-author edit inside the autosave window', async () => {
    newest = {
      cause: RevisionCause.edit,
      authorUserId: 'author-1',
      createdAt: new Date(Date.now() - 1000),
    };

    await service.recordEdit(tx, prior, 'author-1');

    expect(revisionCreate).not.toHaveBeenCalled();
  });

  it('never collapses across authors', async () => {
    newest = {
      cause: RevisionCause.edit,
      authorUserId: 'author-2',
      createdAt: new Date(Date.now() - 1000),
    };

    await service.recordEdit(tx, prior, 'author-1');

    expect(revisionCreate).toHaveBeenCalledTimes(1);
  });

  it('writes again once the collapse window has passed', async () => {
    newest = {
      cause: RevisionCause.edit,
      authorUserId: 'author-1',
      createdAt: new Date(Date.now() - REVISION_COLLAPSE_WINDOW_MS - 1000),
    };

    await service.recordEdit(tx, prior, 'author-1');

    expect(revisionCreate).toHaveBeenCalledTimes(1);
  });

  it('does not collapse onto a conflict revision', async () => {
    newest = {
      cause: RevisionCause.conflict,
      authorUserId: 'author-1',
      createdAt: new Date(Date.now() - 1000),
    };

    await service.recordEdit(tx, prior, 'author-1');

    expect(revisionCreate).toHaveBeenCalledTimes(1);
  });

  it('recordConflict always writes, even right after another revision', async () => {
    newest = {
      cause: RevisionCause.edit,
      authorUserId: 'author-1',
      createdAt: new Date(Date.now() - 1000),
    };

    await service.recordConflict(
      tx,
      { noteId: 'note-1', title: 'rejected', content: 'lost', baseVersion: 2 },
      'author-1',
    );

    expect(revisionCreate).toHaveBeenCalledWith({
      data: {
        noteId: 'note-1',
        version: 2,
        title: 'rejected',
        content: 'lost',
        authorUserId: 'author-1',
        cause: RevisionCause.conflict,
      },
    });
  });

  it('recordConflict stamps version 0 when the client had no base', async () => {
    await service.recordConflict(
      tx,
      { noteId: 'note-1', title: 'rejected', content: null },
      'author-1',
    );

    expect(revisionCreate).toHaveBeenCalledWith({
      data: {
        noteId: 'note-1',
        version: 0,
        title: 'rejected',
        content: null,
        authorUserId: 'author-1',
        cause: RevisionCause.conflict,
      },
    });
  });
});
