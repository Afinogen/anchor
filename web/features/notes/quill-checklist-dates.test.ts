import { describe, expect, it } from "vitest";
import type { QuillOp } from "./quill";
import {
  dateGroupBounds,
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
