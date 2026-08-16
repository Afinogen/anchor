import type { SortBy, SortOrder } from "@/features/preferences";
import type { Note } from "./types";

export type SortableNote = Pick<
  Note,
  "id" | "title" | "createdAt" | "updatedAt"
>;

export const compareNotes =
  (sortBy: SortBy, sortOrder: SortOrder) =>
  (a: SortableNote, b: SortableNote) => {
    let comparison = 0;
    if (sortBy === "title") {
      comparison = a.title.localeCompare(b.title);
    } else if (sortBy === "updatedAt") {
      comparison =
        new Date(a.updatedAt).getTime() - new Date(b.updatedAt).getTime();
    } else if (sortBy === "createdAt") {
      comparison =
        new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime();
    }

    const ordered = sortOrder === "asc" ? comparison : -comparison;
    if (ordered !== 0) return ordered;
    return a.id < b.id ? 1 : a.id > b.id ? -1 : 0;
  };
