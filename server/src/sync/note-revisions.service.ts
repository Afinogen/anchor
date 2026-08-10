import { Injectable } from '@nestjs/common';
import type { Prisma } from 'src/generated/prisma/client';
import { RevisionCause } from 'src/generated/prisma/enums';
import { REVISION_COLLAPSE_WINDOW_MS } from './sync.constants';

export interface PriorNoteContent {
  id: string;
  title: string;
  content: string | null;
  version: number;
}

@Injectable()
export class NoteRevisionsService {
  // Preserves the content a write is about to replace. Consecutive edits by
  // the same author collapse, but never across authors: one user's rapid saves
  // must not erase the trace of another's content.
  async recordEdit(
    tx: Prisma.TransactionClient,
    prior: PriorNoteContent,
    authorUserId: string,
  ): Promise<void> {
    const newest = await tx.noteRevision.findFirst({
      where: { noteId: prior.id },
      orderBy: { createdAt: 'desc' },
      select: { cause: true, authorUserId: true, createdAt: true },
    });

    if (
      newest &&
      newest.cause === RevisionCause.edit &&
      newest.authorUserId === authorUserId &&
      Date.now() - newest.createdAt.getTime() < REVISION_COLLAPSE_WINDOW_MS
    ) {
      return;
    }

    await tx.noteRevision.create({
      data: {
        noteId: prior.id,
        version: prior.version,
        title: prior.title,
        content: prior.content,
        authorUserId,
        cause: RevisionCause.edit,
      },
    });
  }

  // Preserves the payload of a rejected write. Never collapsed: this is
  // exactly the content that would otherwise be lost.
  async recordConflict(
    db: Prisma.TransactionClient,
    rejected: RejectedNoteContent,
    authorUserId: string,
  ): Promise<void> {
    await db.noteRevision.create({
      data: {
        noteId: rejected.noteId,
        version: rejected.baseVersion ?? 0,
        title: rejected.title,
        content: rejected.content,
        authorUserId,
        cause: RevisionCause.conflict,
      },
    });
  }
}

export interface RejectedNoteContent {
  noteId: string;
  title: string;
  content: string | null;
  baseVersion?: number;
}
