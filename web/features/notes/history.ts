import { format, isSameDay, type Locale as DateFnsLocale } from "date-fns";
import type { TranslationKey } from "@/lib/i18n";
import type {
  Note,
  NoteRevisionAuthor,
  NoteRevisionCause,
  NoteRevisionPage,
  NoteRevisionSummary,
} from "./types";

export const CURRENT_ENTRY_ID = "current";

/**
 * Wording and date formats for the history UI. Optional everywhere so these
 * helpers stay pure functions usable from tests; without it the English
 * wording and formats are used.
 */
export interface HistoryFormat {
  t: (key: TranslationKey) => string;
  locale?: DateFnsLocale;
}

function word(fmt: HistoryFormat | undefined, key: TranslationKey, en: string) {
  return fmt ? fmt.t(key) : en;
}

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

export function revisionLabel(
  cause: NoteRevisionCause,
  fmt?: HistoryFormat,
): string {
  if (!fmt) return labels[cause];
  return fmt.t(`notes.history.cause.${cause}` as TranslationKey);
}

export function revisionHint(
  cause: NoteRevisionCause,
  fmt?: HistoryFormat,
): string | null {
  if (hints[cause] === null) return null;
  if (!fmt) return hints[cause];
  return fmt.t(`notes.history.hint.${cause}` as TranslationKey);
}

export function revisionAuthorName(
  entry: { author: NoteRevisionAuthor | null },
  currentUserId: string | null,
  fmt?: HistoryFormat,
): string {
  if (!entry.author) return word(fmt, "notes.history.someone", "Someone");
  return entry.author.id === currentUserId
    ? word(fmt, "notes.history.you", "You")
    : entry.author.name;
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

export function revisionTime(
  entry: { createdAt: string },
  fmt?: HistoryFormat,
): string {
  return timeOfDay(new Date(entry.createdAt), fmt);
}

function timeOfDay(date: Date, fmt?: HistoryFormat): string {
  return format(date, word(fmt, "notes.history.timeFormat", "h:mm a"), {
    locale: fmt?.locale,
  });
}

export function revisionDayTime(
  entry: { createdAt: string },
  now: Date = new Date(),
  fmt?: HistoryFormat,
): string {
  const date = new Date(entry.createdAt);
  const day = dayLabel(date, now, fmt);
  const time = timeOfDay(date, fmt);
  return fmt
    ? fmt.t("notes.history.dayAtTime").replace("{day}", day).replace("{time}", time)
    : `${day} at ${time}`;
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
  fmt?: HistoryFormat,
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

    days.push({ key, label: dayLabel(date, now, fmt), entries: [entry] });
  }

  return days;
}

function dayLabel(date: Date, now: Date, fmt?: HistoryFormat): string {
  if (isSameDay(date, now)) return word(fmt, "notes.history.today", "Today");

  const yesterday = new Date(now);
  yesterday.setDate(yesterday.getDate() - 1);
  if (isSameDay(date, yesterday)) {
    return word(fmt, "notes.history.yesterday", "Yesterday");
  }

  return format(date, word(fmt, "notes.history.dateFormat", "MMMM d, yyyy"), {
    locale: fmt?.locale,
  });
}
