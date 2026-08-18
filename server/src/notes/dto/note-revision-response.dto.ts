import type { RevisionCause } from 'src/generated/prisma/enums';

interface RevisionAuthor {
  id: string;
  name: string;
  email: string;
  profileImage?: string | null;
}

export class NoteRevisionSummaryDto {
  id: string;
  noteId: string;
  version: number;
  title: string;
  cause: RevisionCause;
  createdAt: string;
  author: RevisionAuthor | null;
}

export class NoteRevisionDto extends NoteRevisionSummaryDto {
  content: string | null;
}

export class NoteRevisionPageDto {
  revisions: NoteRevisionSummaryDto[];
  nextCursor: string | null;
}

interface RevisionRow {
  id: string;
  noteId: string;
  version: number;
  title: string;
  content: string | null;
  cause: RevisionCause;
  createdAt: Date;
  author: RevisionAuthor | null;
}

export const toRevisionSummary = (
  revision: RevisionRow,
): NoteRevisionSummaryDto => ({
  id: revision.id,
  noteId: revision.noteId,
  version: revision.version,
  title: revision.title,
  cause: revision.cause,
  createdAt: revision.createdAt.toISOString(),
  author: revision.author,
});

export const toRevision = (revision: RevisionRow): NoteRevisionDto => ({
  ...toRevisionSummary(revision),
  content: revision.content,
});
