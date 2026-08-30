import type { PreviewLine, QuillOp } from "./quill";
import { parseStoredContent } from "./quill";
import { deltaToLines, getLineText, indentOf } from "./quill-lines";

export type DiffKind = "same" | "added" | "removed";

export type LineBlock = "blockquote" | "code" | null;

export interface FormattedLine extends PreviewLine {
  ops: QuillOp[];
  header: number | null;
  block: LineBlock;
}

export interface DiffLine extends FormattedLine {
  kind: DiffKind;
}

export interface ContentDiff {
  lines: DiffLine[];
  added: number;
  removed: number;
}

const MAX_DIFF_CELLS = 1_000_000;

function listTypeOf(value: unknown): PreviewLine["listType"] {
  return value === "checked" ||
    value === "unchecked" ||
    value === "ordered" ||
    value === "bullet"
    ? value
    : null;
}

function headerOf(value: unknown): number | null {
  return value === 1 || value === 2 || value === 3 ? value : null;
}

function blockOf(attributes: Record<string, unknown> | undefined): LineBlock {
  if (attributes?.blockquote) return "blockquote";
  if (attributes?.["code-block"]) return "code";
  return null;
}

function contentLines(content: string | null | undefined): FormattedLine[] {
  return deltaToLines(parseStoredContent(content).ops)
    .map((line) => ({
      text: getLineText(line).trim(),
      listType: listTypeOf(line.newlineOp.attributes?.list),
      indent: indentOf(line),
      ops: line.contentOps,
      header: headerOf(line.newlineOp.attributes?.header),
      block: blockOf(line.newlineOp.attributes),
    }))
    .filter((line) => line.text.length > 0);
}

function keyOf(line: FormattedLine): string {
  return [
    line.listType ?? "",
    line.header ?? "",
    line.block ?? "",
    line.indent,
    line.text,
  ].join(" ");
}

export function diffNoteContent(
  before: string | null | undefined,
  after: string | null | undefined,
): ContentDiff {
  const a = contentLines(before);
  const b = contentLines(after);
  const aKeys = a.map(keyOf);
  const bKeys = b.map(keyOf);

  let head = 0;
  while (head < a.length && head < b.length && aKeys[head] === bKeys[head]) {
    head++;
  }

  let tail = 0;
  while (
    tail < a.length - head &&
    tail < b.length - head &&
    aKeys[a.length - 1 - tail] === bKeys[b.length - 1 - tail]
  ) {
    tail++;
  }

  const lines: DiffLine[] = a
    .slice(0, head)
    .map((line) => ({ ...line, kind: "same" as const }));

  lines.push(
    ...diffMiddle(
      a.slice(head, a.length - tail),
      b.slice(head, b.length - tail),
      aKeys.slice(head, a.length - tail),
      bKeys.slice(head, b.length - tail),
    ),
  );

  for (const line of b.slice(b.length - tail)) {
    lines.push({ ...line, kind: "same" });
  }

  return {
    lines,
    added: lines.filter((line) => line.kind === "added").length,
    removed: lines.filter((line) => line.kind === "removed").length,
  };
}

function diffMiddle(
  a: FormattedLine[],
  b: FormattedLine[],
  aKeys: string[],
  bKeys: string[],
): DiffLine[] {
  const removed = a.map((line) => ({ ...line, kind: "removed" as const }));
  const added = b.map((line) => ({ ...line, kind: "added" as const }));

  if (a.length === 0) return added;
  if (b.length === 0) return removed;
  if ((a.length + 1) * (b.length + 1) > MAX_DIFF_CELLS) {
    return [...removed, ...added];
  }

  const width = b.length + 1;
  const lcs = new Uint32Array((a.length + 1) * width);
  for (let i = a.length - 1; i >= 0; i--) {
    for (let j = b.length - 1; j >= 0; j--) {
      lcs[i * width + j] =
        aKeys[i] === bKeys[j]
          ? lcs[(i + 1) * width + j + 1] + 1
          : Math.max(lcs[(i + 1) * width + j], lcs[i * width + j + 1]);
    }
  }

  const lines: DiffLine[] = [];
  let i = 0;
  let j = 0;
  while (i < a.length && j < b.length) {
    if (aKeys[i] === bKeys[j]) {
      lines.push({ ...a[i], kind: "same" });
      i++;
      j++;
    } else if (lcs[(i + 1) * width + j] >= lcs[i * width + j + 1]) {
      lines.push(removed[i]);
      i++;
    } else {
      lines.push(added[j]);
      j++;
    }
  }
  lines.push(...removed.slice(i), ...added.slice(j));

  return lines;
}
