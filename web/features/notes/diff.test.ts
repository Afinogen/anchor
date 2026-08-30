import { describe, expect, it } from "vitest";
import { diffNoteContent } from "./diff";
import type { QuillOp } from "./quill";

interface Line {
  text: string;
  attributes?: Record<string, unknown>;
}

const doc = (...lines: (string | Line)[]) => {
  const ops: QuillOp[] = [];
  for (const line of lines) {
    const { text, attributes }: Line =
      typeof line === "string" ? { text: line } : line;
    if (text) ops.push({ insert: text });
    ops.push({
      insert: "\n",
      ...(attributes ? { attributes } : {}),
    });
  }
  return JSON.stringify({ ops });
};

const marks = (content: string, against: string) =>
  diffNoteContent(content, against).lines.map((line) => [line.kind, line.text]);

describe("diffNoteContent", () => {
  it("marks nothing when the text is the same", () => {
    const content = doc("milk", "eggs");

    expect(diffNoteContent(content, content)).toMatchObject({
      added: 0,
      removed: 0,
    });
    expect(marks(content, content)).toEqual([
      ["same", "milk"],
      ["same", "eggs"],
    ]);
  });

  it("marks a line that came later", () => {
    expect(marks(doc("milk"), doc("milk", "eggs"))).toEqual([
      ["same", "milk"],
      ["added", "eggs"],
    ]);
  });

  it("marks a line that went away", () => {
    expect(marks(doc("milk", "eggs"), doc("eggs"))).toEqual([
      ["removed", "milk"],
      ["same", "eggs"],
    ]);
  });

  it("reads a rewritten line as the old one out and the new one in", () => {
    expect(
      marks(doc("milk", "eggs", "bread"), doc("milk", "cheese", "bread")),
    ).toEqual([
      ["same", "milk"],
      ["removed", "eggs"],
      ["added", "cheese"],
      ["same", "bread"],
    ]);
  });

  it("keeps the untouched lines around a change in place", () => {
    const diff = diffNoteContent(
      doc("a", "b", "c", "d", "e"),
      doc("a", "b", "x", "d", "e"),
    );

    expect(diff).toMatchObject({ added: 1, removed: 1 });
    expect(diff.lines.filter((line) => line.kind === "same")).toHaveLength(4);
  });

  it("sees a ticked box as a change", () => {
    const diff = diffNoteContent(
      doc({ text: "milk", attributes: { list: "unchecked" } }),
      doc({ text: "milk", attributes: { list: "checked" } }),
    );

    expect(diff).toMatchObject({ added: 1, removed: 1 });
    expect(diff.lines.map((line) => line.listType)).toEqual([
      "unchecked",
      "checked",
    ]);
  });

  it("sees a line moved a level deeper as a change", () => {
    expect(
      diffNoteContent(
        doc({ text: "milk", attributes: { list: "bullet" } }),
        doc({ text: "milk", attributes: { list: "bullet", indent: 1 } }),
      ),
    ).toMatchObject({ added: 1, removed: 1 });
  });

  it("sees a line turned into a heading as a change", () => {
    expect(
      diffNoteContent(
        doc("groceries"),
        doc({ text: "groceries", attributes: { header: 2 } }),
      ),
    ).toMatchObject({ added: 1, removed: 1 });
  });

  it("carries a line's formatting through for drawing", () => {
    const diff = diffNoteContent(
      doc({ text: "milk", attributes: { header: 1 } }),
      doc({ text: "milk", attributes: { header: 1 } }),
    );

    expect(diff.lines[0]).toMatchObject({ kind: "same", header: 1 });
    expect(diff.lines[0].ops).toEqual([{ insert: "milk" }]);
  });

  it("reads a bolded word as the same line", () => {
    const diff = diffNoteContent(
      doc("milk and eggs"),
      JSON.stringify({
        ops: [
          { insert: "milk and " },
          { insert: "eggs", attributes: { bold: true } },
          { insert: "\n" },
        ],
      }),
    );

    expect(diff).toMatchObject({ added: 0, removed: 0 });
  });

  it("treats an empty note as everything added", () => {
    expect(diffNoteContent(null, doc("milk", "eggs"))).toMatchObject({
      added: 2,
      removed: 0,
    });
  });

  it("ignores blank lines", () => {
    const diff = diffNoteContent(doc("milk", "", "eggs"), doc("milk", "eggs"));

    expect(diff).toMatchObject({ added: 0, removed: 0 });
    expect(diff.lines).toHaveLength(2);
  });
});
