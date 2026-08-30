import type { QuillOp } from "./quill";
import {
  blockEndIndex,
  type DeltaLine,
  getLineText,
  indentOf,
  isCheckedLine,
  isChecklistLine,
} from "./quill-lines";

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

/**
 * Bounds `[start, end]` of the checklist group containing [lineIndex]: the run
 * of checklist lines around it, extended over date headers that are directly
 * followed by a checklist line. A trailing header belongs to the text below,
 * not to the group.
 */
export function dateGroupBounds(
  lines: DeltaLine[],
  lineIndex: number,
): [number, number] {
  let start = lineIndex;
  while (start > 0) {
    if (isChecklistLine(lines[start - 1])) {
      start--;
      continue;
    }
    if (
      dateHeaderKey(lines[start - 1]) !== null &&
      isChecklistLine(lines[start])
    ) {
      start--;
      continue;
    }
    break;
  }

  let end = lineIndex;
  while (end < lines.length - 1) {
    if (isChecklistLine(lines[end + 1])) {
      end++;
      continue;
    }
    if (
      dateHeaderKey(lines[end + 1]) !== null &&
      end + 2 < lines.length &&
      isChecklistLine(lines[end + 2])
    ) {
      end++;
      continue;
    }
    break;
  }

  return [start, end];
}

/** An item of the rebuilt group: an existing line, or a header to write. */
export type GroupItem = { line: number } | { header: string };

type Block = { start: number; end: number };

/**
 * Target contents of the group [groupStart..groupEnd] after the block at
 * [toggledIndex] was toggled: unchecked blocks first, then date sections
 * newest first, then checked blocks that never had a header. The toggled
 * block is dated [today] and sits last within its section.
 *
 * Children of a block keep their document order — a toggle at the top level
 * has no business reshuffling nesting the user did not touch.
 */
export function dateGroupedItems(
  lines: DeltaLine[],
  groupStart: number,
  groupEnd: number,
  toggledIndex: number,
  today: string,
): GroupItem[] {
  const unchecked: Block[] = [];
  const dated = new Map<string, Block[]>();
  const undated: Block[] = [];
  /** Existing header line per date key, so its text survives untouched. */
  const headerLine = new Map<string, number>();
  let toggled: Block | null = null;
  let currentDate: string | null = null;

  for (let i = groupStart; i <= groupEnd; ) {
    const header = dateHeaderKey(lines[i]);
    if (header !== null) {
      currentDate = header;
      if (!headerLine.has(header)) headerLine.set(header, i);
      i++;
      continue;
    }

    const block: Block = { start: i, end: blockEndIndex(lines, i, groupEnd) };
    if (i === toggledIndex) {
      toggled = block;
    } else if (isCheckedLine(lines[i])) {
      if (currentDate === null) {
        undated.push(block);
      } else {
        const section = dated.get(currentDate) ?? [];
        section.push(block);
        dated.set(currentDate, section);
      }
    } else {
      unchecked.push(block);
    }
    i = block.end + 1;
  }

  if (toggled) {
    if (isCheckedLine(lines[toggled.start])) {
      const section = dated.get(today) ?? [];
      section.push(toggled);
      dated.set(today, section);
    } else {
      unchecked.push(toggled);
    }
  }

  const items: GroupItem[] = [];
  const pushBlock = (block: Block) => {
    for (let i = block.start; i <= block.end; i++) items.push({ line: i });
  };

  for (const block of unchecked) pushBlock(block);

  const keys = [...dated.keys()].sort((a, b) =>
    sortableDateKey(b).localeCompare(sortableDateKey(a)),
  );
  for (const key of keys) {
    const source = headerLine.get(key);
    items.push(source === undefined ? { header: key } : { line: source });
    for (const block of dated.get(key) as Block[]) pushBlock(block);
  }

  for (const block of undated) pushBlock(block);

  return items;
}
