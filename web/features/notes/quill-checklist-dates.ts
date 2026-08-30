import type { QuillOp } from "./quill";
import { type DeltaLine, getLineText, indentOf } from "./quill-lines";

/** Bare `DD.MM.YYYY` — the form this module writes. */
const BARE_DATE = /^(\d{1,2})\.(\d{1,2})\.(\d{4})$/;
/** Hand-written divider: `----- DD.MM.YYYY -------`. */
const DASHED_DATE = /^-{2,}\s*(\d{1,2})\.(\d{1,2})\.(\d{4})\s*-{2,}$/;

/** `DD.MM.YYYY` of a local date. Locale-independent on purpose: clients in
 * different languages must produce the same key for the same day. */
export function formatDateKey(date: Date): string {
  const day = String(date.getDate()).padStart(2, "0");
  const month = String(date.getMonth() + 1).padStart(2, "0");
  return `${day}.${month}.${date.getFullYear()}`;
}

/**
 * Normalised `DD.MM.YYYY` key of a header text, or null when the text is not
 * a date header. Recognition is by text alone — bold is cosmetic and applied
 * only on write, so hand-written dividers count as headers too.
 */
export function parseDateHeaderText(text: string): string | null {
  const trimmed = text.trim();
  const match = BARE_DATE.exec(trimmed) ?? DASHED_DATE.exec(trimmed);
  if (!match) return null;
  const [, day, month, year] = match;
  return `${day.padStart(2, "0")}.${month.padStart(2, "0")}.${year}`;
}

/** Key of the date header on [line], or null when the line is not one. */
export function dateHeaderKey(line: DeltaLine): string | null {
  if (line.newlineOp.attributes?.list !== undefined) return null;
  if (indentOf(line) !== 0) return null;
  return parseDateHeaderText(getLineText(line));
}

/** Ops of a freshly written header: the date in bold, then the newline. */
export function dateHeaderOps(key: string): QuillOp[] {
  return [{ insert: key, attributes: { bold: true } }, { insert: "\n" }];
}

/** `YYYYMMDD` — a key that compares chronologically as a string. */
export function sortableDateKey(key: string): string {
  const [day, month, year] = key.split(".");
  return `${year}${month}${day}`;
}
