import Delta from "quill-delta";
import { describe, expect, it } from "vitest";
import type { QuillDelta, QuillOp } from "./quill";
import { createChecklistSortDelta } from "./quill-checklist";
import {
  dateGroupBounds,
  dateGroupedItems,
  dateHeaderKey,
  dateHeaderOps,
  formatDateKey,
  parseDateHeaderText,
  sortableDateKey,
} from "./quill-checklist-dates";
import type { DeltaLine } from "./quill-lines";

/** A line from its text and newline attributes. */
function line(text: string, attributes?: Record<string, unknown>): DeltaLine {
  const contentOps: QuillOp[] = text ? [{ insert: text }] : [];
  return {
    contentOps,
    newlineOp: attributes
      ? { insert: "\n", attributes: attributes as QuillOp["attributes"] }
      : { insert: "\n" },
  };
}

describe("formatDateKey", () => {
  it("pads day and month to two digits", () => {
    expect(formatDateKey(new Date(2026, 7, 9))).toBe("09.08.2026");
    expect(formatDateKey(new Date(2026, 11, 31))).toBe("31.12.2026");
  });
});

describe("parseDateHeaderText", () => {
  it("reads the bare form", () => {
    expect(parseDateHeaderText("30.08.2026")).toBe("30.08.2026");
  });

  it("reads the hand-written dashed form", () => {
    expect(parseDateHeaderText("----- 29.08.2026 -------")).toBe("29.08.2026");
  });

  it("normalises one-digit day and month", () => {
    expect(parseDateHeaderText("9.8.2026")).toBe("09.08.2026");
  });

  it("ignores surrounding whitespace", () => {
    expect(parseDateHeaderText("  30.08.2026  ")).toBe("30.08.2026");
  });

  it("rejects anything else", () => {
    expect(parseDateHeaderText("")).toBeNull();
    expect(parseDateHeaderText("купить шины 30.08.2026")).toBeNull();
    expect(parseDateHeaderText("30.08.26")).toBeNull();
    expect(parseDateHeaderText("- 30.08.2026 -")).toBeNull();
  });
});

describe("dateHeaderKey", () => {
  it("accepts a plain top-level date line", () => {
    expect(dateHeaderKey(line("30.08.2026"))).toBe("30.08.2026");
  });

  it("rejects a list line", () => {
    expect(dateHeaderKey(line("30.08.2026", { list: "checked" }))).toBeNull();
    expect(dateHeaderKey(line("30.08.2026", { list: "bullet" }))).toBeNull();
  });

  it("rejects an indented line", () => {
    expect(dateHeaderKey(line("30.08.2026", { indent: 1 }))).toBeNull();
  });

  it("rejects a line mixing an embed with date-shaped text", () => {
    const embedLine: DeltaLine = {
      contentOps: [{ insert: { image: "x" } }, { insert: "30.08.2026" }],
      newlineOp: { insert: "\n" },
    };
    expect(dateHeaderKey(embedLine)).toBeNull();
  });
});

describe("dateHeaderOps", () => {
  it("writes the date in bold followed by a newline", () => {
    expect(dateHeaderOps("30.08.2026")).toEqual([
      { insert: "30.08.2026", attributes: { bold: true } },
      { insert: "\n" },
    ]);
  });
});

describe("sortableDateKey", () => {
  it("orders keys chronologically as strings", () => {
    const keys = ["29.08.2026", "31.12.2025", "01.09.2026"];
    expect(
      [...keys].sort((a, b) =>
        sortableDateKey(a).localeCompare(sortableDateKey(b)),
      ),
    ).toEqual(["31.12.2025", "29.08.2026", "01.09.2026"]);
  });
});

/** Lines from (text, listType) pairs; listType null = plain paragraph. */
function lines(items: [string, string | null][]): DeltaLine[] {
  return items.map(([text, list]) => line(text, list ? { list } : undefined));
}

/** Lines from (text, listType, indent) triples. */
function docLines(items: [string, string | null, number?][]): DeltaLine[] {
  return items.map(([text, list, indent]) => {
    const attributes = {
      ...(list ? { list } : {}),
      ...(indent ? { indent } : {}),
    };
    return line(text, Object.keys(attributes).length ? attributes : undefined);
  });
}

describe("dateGroupBounds", () => {
  it("covers a plain contiguous checklist", () => {
    const doc = lines([
      ["intro", null],
      ["a", "unchecked"],
      ["b", "checked"],
      ["outro", null],
    ]);
    expect(dateGroupBounds(doc, 1)).toEqual([1, 2]);
  });

  it("extends over a date header followed by a checklist line", () => {
    const doc = lines([
      ["a", "unchecked"],
      ["30.08.2026", null],
      ["b", "checked"],
    ]);
    expect(dateGroupBounds(doc, 0)).toEqual([0, 2]);
  });

  it("extends over the hand-written dashed form", () => {
    const doc = lines([
      ["a", "unchecked"],
      ["----- 29.08.2026 -------", null],
      ["b", "checked"],
    ]);
    expect(dateGroupBounds(doc, 0)).toEqual([0, 2]);
  });

  it("stops before a trailing header with no checklist line under it", () => {
    const doc = lines([
      ["a", "unchecked"],
      ["30.08.2026", null],
      ["some note", null],
    ]);
    expect(dateGroupBounds(doc, 0)).toEqual([0, 0]);
  });

  it("stops at a foreign paragraph", () => {
    const doc = lines([
      ["a", "unchecked"],
      ["some note", null],
      ["b", "checked"],
    ]);
    expect(dateGroupBounds(doc, 0)).toEqual([0, 0]);
  });

  it("walks up from a line below a header", () => {
    const doc = lines([
      ["a", "unchecked"],
      ["30.08.2026", null],
      ["b", "checked"],
    ]);
    expect(dateGroupBounds(doc, 2)).toEqual([0, 2]);
  });
});

describe("dateGroupedItems", () => {
  it("creates today's header for the toggled item", () => {
    const doc = docLines([
      ["a", "unchecked"],
      ["b", "checked"],
    ]);
    expect(dateGroupedItems(doc, 0, 1, 1, "30.08.2026")).toEqual([
      { line: 0 },
      { header: "30.08.2026" },
      { line: 1 },
    ]);
  });

  it("reuses an existing header for the same day", () => {
    const doc = docLines([
      ["a", "unchecked"],
      ["30.08.2026", null],
      ["b", "checked"],
      ["c", "checked"],
    ]);
    // c is toggled today; b already sits under today's header.
    expect(dateGroupedItems(doc, 0, 3, 3, "30.08.2026")).toEqual([
      { line: 0 },
      { line: 1 },
      { line: 2 },
      { line: 3 },
    ]);
  });

  it("keeps the hand-written header text as is", () => {
    const doc = docLines([
      ["----- 29.08.2026 -------", null],
      ["b", "checked"],
      ["a", "unchecked"],
    ]);
    expect(dateGroupedItems(doc, 0, 2, 2, "29.08.2026")).toEqual([
      { line: 2 },
      { line: 0 },
      { line: 1 },
    ]);
  });

  it("puts the toggled block last within its date", () => {
    const doc = docLines([
      ["30.08.2026", null],
      ["b", "checked"],
      ["c", "checked"],
    ]);
    expect(dateGroupedItems(doc, 0, 2, 1, "30.08.2026")).toEqual([
      { line: 0 },
      { line: 2 },
      { line: 1 },
    ]);
  });

  it("orders dates newest first, under the unchecked items", () => {
    const doc = docLines([
      ["29.08.2026", null],
      ["old", "checked"],
      ["a", "unchecked"],
      ["new", "checked"],
    ]);
    expect(dateGroupedItems(doc, 0, 3, 3, "30.08.2026")).toEqual([
      { line: 2 },
      { header: "30.08.2026" },
      { line: 3 },
      { line: 0 },
      { line: 1 },
    ]);
  });

  it("drops a header left with nothing under it", () => {
    const doc = docLines([
      ["a", "unchecked"],
      ["29.08.2026", null],
      ["b", "unchecked"],
    ]);
    // b was just unchecked; its header has nothing left.
    expect(dateGroupedItems(doc, 0, 2, 2, "30.08.2026")).toEqual([
      { line: 0 },
      { line: 2 },
    ]);
  });

  it("keeps undated checked items as a tail below every date", () => {
    const doc = docLines([
      ["a", "unchecked"],
      ["stale", "checked"],
      ["fresh", "checked"],
    ]);
    expect(dateGroupedItems(doc, 0, 2, 2, "30.08.2026")).toEqual([
      { line: 0 },
      { header: "30.08.2026" },
      { line: 2 },
      { line: 1 },
    ]);
  });

  it("moves nested children with their parent, in document order", () => {
    const doc = docLines([
      ["parent", "checked"],
      ["child b", "checked", 1],
      ["child a", "unchecked", 1],
      ["other", "unchecked"],
    ]);
    expect(dateGroupedItems(doc, 0, 3, 0, "30.08.2026")).toEqual([
      { line: 3 },
      { header: "30.08.2026" },
      { line: 0 },
      { line: 1 },
      { line: 2 },
    ]);
  });
});

/** A document from (text, listType, indent) triples. */
function doc(items: [string, string | null, number?][]): QuillDelta {
  const ops: QuillOp[] = [];
  for (const [text, list, indent] of items) {
    if (text) ops.push({ insert: text });
    const attributes = {
      ...(list ? { list } : {}),
      ...(indent ? { indent } : {}),
    };
    ops.push({
      insert: "\n",
      ...(Object.keys(attributes).length ? { attributes } : {}),
    });
  }
  return { ops };
}

/** Position of the newline of line [index]. */
function newlineOffset(
  items: [string, string | null, number?][],
  index: number,
) {
  let offset = 0;
  for (let i = 0; i < index; i++) offset += items[i][0].length + 1;
  return offset + items[index][0].length;
}

/** Apply a move delta and read back (text, listType, bold) per line. */
function applied(base: QuillDelta, move: QuillDelta | null) {
  expect(move).not.toBeNull();
  const result = new Delta(base.ops as never).compose(
    new Delta((move as QuillDelta).ops as never),
  );
  const out: [string, string | null, boolean][] = [];
  let text = "";
  let bold = false;
  for (const op of result.ops as QuillOp[]) {
    const insert = typeof op.insert === "string" ? op.insert : "";
    const parts = insert.split("\n");
    for (let i = 0; i < parts.length; i++) {
      if (parts[i]) {
        text += parts[i];
        if (op.attributes?.bold) bold = true;
      }
      if (i < parts.length - 1) {
        out.push([
          text,
          (op.attributes?.list as string | undefined) ?? null,
          bold,
        ]);
        text = "";
        bold = false;
      }
    }
  }
  return out;
}

describe("createChecklistSortDelta with dates", () => {
  it("writes today's header in bold above the checked item", () => {
    const items: [string, string | null][] = [
      ["a", "unchecked"],
      ["b", "checked"],
    ];
    const base = doc(items);
    const move = createChecklistSortDelta(
      newlineOffset(items, 1),
      base,
      "30.08.2026",
    );
    expect(applied(base, move)).toEqual([
      ["a", "unchecked", false],
      ["30.08.2026", null, true],
      ["b", "checked", false],
    ]);
  });

  it("removes a header left empty by unchecking", () => {
    const items: [string, string | null][] = [
      ["a", "unchecked"],
      ["30.08.2026", null],
      ["b", "unchecked"],
    ];
    const base = doc(items);
    const move = createChecklistSortDelta(
      newlineOffset(items, 2),
      base,
      "31.08.2026",
    );
    expect(applied(base, move)).toEqual([
      ["a", "unchecked", false],
      ["b", "unchecked", false],
    ]);
  });

  it("leaves the document alone when it is already laid out", () => {
    const items: [string, string | null][] = [
      ["a", "unchecked"],
      ["30.08.2026", null],
      ["b", "checked"],
    ];
    const move = createChecklistSortDelta(
      newlineOffset(items, 2),
      doc(items),
      "30.08.2026",
    );
    expect(move).toBeNull();
  });

  it("falls back to plain sorting without a date", () => {
    const items: [string, string | null][] = [
      ["a", "checked"],
      ["b", "unchecked"],
    ];
    const base = doc(items);
    const move = createChecklistSortDelta(newlineOffset(items, 0), base);
    expect(applied(base, move)).toEqual([
      ["b", "unchecked", false],
      ["a", "checked", false],
    ]);
  });

  it("falls back to plain sorting for a nested item", () => {
    const items: [string, string | null, number?][] = [
      ["parent", "unchecked"],
      ["child a", "checked", 1],
      ["child b", "unchecked", 1],
    ];
    const base = doc(items);
    const move = createChecklistSortDelta(
      newlineOffset(items, 1),
      base,
      "30.08.2026",
    );
    expect(applied(base, move)).toEqual([
      ["parent", "unchecked", false],
      ["child b", "unchecked", false],
      ["child a", "checked", false],
    ]);
  });
});
