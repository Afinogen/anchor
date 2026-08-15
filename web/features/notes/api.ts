import { getAccessToken } from "@/features/auth/store";
import { api } from "@/lib/api/client";
import type { SaveOutcome } from "./save-queue";
import type {
  CreateNoteDto,
  Note,
  NoteAttachment,
  NoteShare,
  NoteSharePermission,
  UpdateNoteDto,
  UserSearchResult,
} from "./types";

interface NotesQueryParams {
  search?: string;
  tagId?: string;
}

export async function getNotes(params?: NotesQueryParams): Promise<Note[]> {
  const searchParams = new URLSearchParams();
  if (params?.search) searchParams.set("search", params.search);
  if (params?.tagId) searchParams.set("tagId", params.tagId);

  const queryString = searchParams.toString();
  const url = queryString ? `api/notes?${queryString}` : "api/notes";

  return api.get(url).json<Note[]>();
}

export async function getNote(id: string): Promise<Note> {
  return api.get(`api/notes/${id}`).json<Note>();
}

export async function createNote(data: CreateNoteDto): Promise<Note> {
  return api.post("api/notes", { json: data }).json<Note>();
}

function isWorthAnotherTry(httpStatus: number): boolean {
  return httpStatus >= 500 || httpStatus === 408 || httpStatus === 429;
}

export async function saveNote(
  id: string,
  data: UpdateNoteDto,
): Promise<SaveOutcome> {
  const response = await api
    .patch(`api/notes/${id}`, { json: data, throwHttpErrors: false })
    .catch(() => null);

  if (!response) {
    return { status: "failed", httpStatus: null, retryable: true };
  }

  if (response.status === 409) {
    const body = await response.json<{ serverNote: Note }>();
    return { status: "conflict", serverNote: body.serverNote };
  }

  if (!response.ok) {
    return {
      status: "failed",
      httpStatus: response.status,
      retryable: isWorthAnotherTry(response.status),
    };
  }

  return { status: "saved", note: await response.json<Note>() };
}

// Sent while the page is closing; it carries no base version, so the text on
// screen wins.
export function flushNoteUpdate(id: string, data: UpdateNoteDto): void {
  const token = getAccessToken();

  void fetch(`/api/notes/${id}`, {
    method: "PATCH",
    keepalive: true,
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: JSON.stringify(data),
  }).catch(() => {});
}

export async function deleteNote(id: string): Promise<void> {
  await api.delete(`api/notes/${id}`);
}

export async function getTrashedNotes(): Promise<Note[]> {
  return api.get("api/notes/trash").json<Note[]>();
}

export async function restoreNote(id: string): Promise<Note> {
  return api.patch(`api/notes/${id}/restore`).json<Note>();
}

export async function permanentDeleteNote(id: string): Promise<void> {
  await api.delete(`api/notes/${id}/permanent`);
}

export async function getArchivedNotes(): Promise<Note[]> {
  return api.get("api/notes/archive").json<Note[]>();
}

export async function archiveNote(id: string): Promise<Note> {
  return api
    .patch(`api/notes/${id}`, { json: { isArchived: true } })
    .json<Note>();
}

export async function unarchiveNote(id: string): Promise<Note> {
  return api
    .patch(`api/notes/${id}`, { json: { isArchived: false } })
    .json<Note>();
}

const BULK_NOTE_IDS_PER_REQUEST = 200;

async function inBulkBatches(
  noteIds: string[],
  send: (batch: string[]) => Promise<{ count: number }>,
): Promise<{ count: number }> {
  let count = 0;
  for (let i = 0; i < noteIds.length; i += BULK_NOTE_IDS_PER_REQUEST) {
    const result = await send(noteIds.slice(i, i + BULK_NOTE_IDS_PER_REQUEST));
    count += result.count;
  }
  return { count };
}

export async function bulkDeleteNotes(
  noteIds: string[],
): Promise<{ count: number }> {
  return inBulkBatches(noteIds, (batch) =>
    api
      .post("api/notes/bulk/delete", { json: { noteIds: batch } })
      .json<{ count: number }>(),
  );
}

export async function bulkArchiveNotes(
  noteIds: string[],
): Promise<{ count: number }> {
  return inBulkBatches(noteIds, (batch) =>
    api
      .post("api/notes/bulk/archive", { json: { noteIds: batch } })
      .json<{ count: number }>(),
  );
}

export async function bulkPinNotes(
  noteIds: string[],
  isPinned: boolean,
): Promise<{ count: number }> {
  return inBulkBatches(noteIds, (batch) =>
    api
      .post("api/notes/bulk/pin", { json: { noteIds: batch, isPinned } })
      .json<{ count: number }>(),
  );
}

export async function bulkAddTagsToNotes(
  noteIds: string[],
  tagIds: string[],
): Promise<{ count: number }> {
  return inBulkBatches(noteIds, (batch) =>
    api
      .post("api/notes/bulk/tags", { json: { noteIds: batch, tagIds } })
      .json<{ count: number }>(),
  );
}

// Sharing APIs
export async function shareNote(
  noteId: string,
  sharedWithUserId: string,
  permission: NoteSharePermission,
): Promise<NoteShare> {
  return api
    .post(`api/notes/${noteId}/shares`, {
      json: { sharedWithUserId, permission },
    })
    .json<NoteShare>();
}

export async function getNoteShares(noteId: string): Promise<NoteShare[]> {
  return api.get(`api/notes/${noteId}/shares`).json<NoteShare[]>();
}

export async function updateNoteSharePermission(
  noteId: string,
  shareId: string,
  permission: NoteSharePermission,
): Promise<NoteShare> {
  return api
    .patch(`api/notes/${noteId}/shares/${shareId}`, { json: { permission } })
    .json<NoteShare>();
}

export async function revokeShare(
  noteId: string,
  shareId: string,
): Promise<{ success: boolean }> {
  return api
    .delete(`api/notes/${noteId}/shares/${shareId}`)
    .json<{ success: boolean }>();
}

export async function searchUsers(query: string): Promise<UserSearchResult[]> {
  if (!query || query.trim().length < 2) {
    return [];
  }
  return api
    .get("api/users/search", {
      searchParams: { q: query.trim() },
    })
    .json<UserSearchResult[]>();
}

export async function getRecentContacts(): Promise<UserSearchResult[]> {
  return api.get("api/users/recent-contacts").json<UserSearchResult[]>();
}

export async function uploadAttachment(
  noteId: string,
  file: File,
): Promise<NoteAttachment> {
  const formData = new FormData();
  formData.append("file", file);

  return api
    .post(`api/notes/${noteId}/attachments`, { body: formData })
    .json<NoteAttachment>();
}

export async function getNoteAttachments(
  noteId: string,
): Promise<NoteAttachment[]> {
  return api.get(`api/notes/${noteId}/attachments`).json<NoteAttachment[]>();
}

export async function fetchAttachmentBlob(
  noteId: string,
  attachmentId: string,
): Promise<Blob> {
  const response = await api.get(
    `api/notes/${noteId}/attachments/${attachmentId}`,
  );
  return response.blob();
}

export async function deleteAttachment(
  noteId: string,
  attachmentId: string,
): Promise<{ success: boolean }> {
  return api
    .delete(`api/notes/${noteId}/attachments/${attachmentId}`)
    .json<{ success: boolean }>();
}

export async function reorderAttachments(
  noteId: string,
  orderedIds: string[],
): Promise<NoteAttachment[]> {
  return api
    .patch(`api/notes/${noteId}/attachments/reorder`, { json: { orderedIds } })
    .json<NoteAttachment[]>();
}
