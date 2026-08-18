import { format, isSameDay } from "date-fns";
import type {
  Note,
  NoteRevisionAuthor,
  NoteRevisionCause,
  NoteRevisionPage,
  NoteRevisionSummary,
} from "./types";

export const CURRENT_ENTRY_ID = "current";

export interface TimelineEntry {
  id: string;
  createdAt: string;
  title: string;
  author: NoteRevisionAuthor | null;
  revision: NoteRevisionSummary | null;
}

export interface TimelineDay {
  key: string;
  label: string;
  entries: TimelineEntry[];
}

const labels: Record<NoteRevisionCause, string> = {
  edit: "Earlier version",
  conflict: "Not saved",
  restore: "Before a restore",
};

const hints: Record<NoteRevisionCause, string | null> = {
  edit: null,
  conflict: "Not saved. The note had already changed.",
  restore: "What the note said before a restore.",
};

const authorColors = [
  "bg-sky-500/20 text-sky-600 dark:text-sky-400",
  "bg-violet-500/20 text-violet-600 dark:text-violet-400",
  "bg-emerald-500/20 text-emerald-600 dark:text-emerald-400",
  "bg-amber-500/20 text-amber-600 dark:text-amber-400",
  "bg-rose-500/20 text-rose-600 dark:text-rose-400",
  "bg-teal-500/20 text-teal-600 dark:text-teal-400",
];

const unknownAuthorColor = "bg-muted text-muted-foreground";

export function revisionLabel(cause: NoteRevisionCause): string {
  return labels[cause];
}

export function revisionHint(cause: NoteRevisionCause): string | null {
  return hints[cause];
}

export function revisionAuthorName(
  entry: { author: NoteRevisionAuthor | null },
  currentUserId: string | null,
): string {
  if (!entry.author) return "Someone";
  return entry.author.id === currentUserId ? "You" : entry.author.name;
}

export function revisionAuthorInitial(
  author: NoteRevisionAuthor | null,
): string {
  return author?.name.trim().charAt(0).toUpperCase() || "?";
}

export function revisionAuthorColor(author: NoteRevisionAuthor | null): string {
  if (!author) return unknownAuthorColor;

  let hash = 0;
  for (const char of author.id) {
    hash = (hash + char.charCodeAt(0)) % authorColors.length;
  }
  return authorColors[hash];
}

export function revisionTime(entry: { createdAt: string }): string {
  return format(new Date(entry.createdAt), "h:mm a");
}

export function revisionDayTime(
  entry: { createdAt: string },
  now: Date = new Date(),
): string {
  const date = new Date(entry.createdAt);
  return `${dayLabel(date, now)} at ${format(date, "h:mm a")}`;
}

export function historyHasMultipleAuthors(
  revisions: NoteRevisionSummary[],
): boolean {
  const authors = new Set(
    revisions.map((revision) => revision.author?.id ?? "unknown"),
  );
  return authors.size > 1;
}

export function canRestoreRevisions(note: Note | null): boolean {
  if (!note) return false;
  return note.state === "active" && note.permission !== "viewer";
}

export function revisionsFromPages(
  pages: NoteRevisionPage[] | undefined,
): NoteRevisionSummary[] {
  return pages?.flatMap((page) => page.revisions) ?? [];
}

export function timelineEntries(
  revisions: NoteRevisionSummary[],
): TimelineEntry[] {
  return revisions.map((revision) => ({
    id: revision.id,
    createdAt: revision.createdAt,
    title: revision.title,
    author: revision.author,
    revision,
  }));
}

export function currentTimelineEntry(note: Note | null): TimelineEntry | null {
  if (!note) return null;
  return {
    id: CURRENT_ENTRY_ID,
    createdAt: note.updatedAt,
    title: note.title,
    author: null,
    revision: null,
  };
}

export function comparisonTargetId(
  revisions: NoteRevisionSummary[],
  revisionId: string,
): string | null {
  const index = revisions.findIndex((revision) => revision.id === revisionId);
  if (index < 0 || revisions[index].cause === "conflict") return null;

  for (let i = index - 1; i >= 0; i--) {
    if (revisions[i].cause !== "conflict") return revisions[i].id;
  }
  return null;
}

export function groupTimelineByDay(
  entries: TimelineEntry[],
  now: Date = new Date(),
): TimelineDay[] {
  const days: TimelineDay[] = [];

  for (const entry of entries) {
    const date = new Date(entry.createdAt);
    const key = format(date, "yyyy-MM-dd");
    const last = days[days.length - 1];

    if (last?.key === key) {
      last.entries.push(entry);
      continue;
    }

    days.push({ key, label: dayLabel(date, now), entries: [entry] });
  }

  return days;
}

function dayLabel(date: Date, now: Date): string {
  if (isSameDay(date, now)) return "Today";

  const yesterday = new Date(now);
  yesterday.setDate(yesterday.getDate() - 1);
  if (isSameDay(date, yesterday)) return "Yesterday";

  return format(date, "MMMM d, yyyy");
}
