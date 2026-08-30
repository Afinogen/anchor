import { beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("@/lib/api/client", () => ({
  api: { post: vi.fn() },
}));

import { api } from "@/lib/api/client";
import {
  bulkAddTagsToNotes,
  bulkArchiveNotes,
  bulkDeleteNotes,
  bulkPinNotes,
} from "./api";

type BulkBody = { noteIds: string[]; tagIds?: string[]; isPinned?: boolean };

const post = vi.mocked(api.post);

function sentBodies(): BulkBody[] {
  return post.mock.calls.map((call) => (call[1] as { json: BulkBody }).json);
}

const noteIds = (count: number) =>
  Array.from({ length: count }, (_, index) => `note-${index}`);

describe("bulk note actions", () => {
  beforeEach(() => {
    post.mockReset();
    post.mockImplementation(
      (_url: unknown, options: unknown) =>
        ({
          json: () =>
            Promise.resolve({
              count: (options as { json: BulkBody }).json.noteIds.length,
            }),
        }) as ReturnType<typeof api.post>,
    );
  });

  it("sends a single request when the selection fits one batch", async () => {
    expect(await bulkDeleteNotes(noteIds(200))).toEqual({ count: 200 });
    expect(post).toHaveBeenCalledTimes(1);
  });

  it("splits a larger selection and sums the counts", async () => {
    expect(await bulkArchiveNotes(noteIds(450))).toEqual({ count: 450 });

    expect(sentBodies().map((body) => body.noteIds.length)).toEqual([
      200, 200, 50,
    ]);
  });

  it("repeats the pin flag and the tag ids on every batch", async () => {
    await bulkPinNotes(noteIds(250), true);
    expect(sentBodies().every((body) => body.isPinned === true)).toBe(true);

    post.mockClear();
    await bulkAddTagsToNotes(noteIds(250), ["tag-1"]);
    expect(sentBodies().every((body) => body.tagIds?.[0] === "tag-1")).toBe(
      true,
    );
  });

  it("sends nothing for an empty selection", async () => {
    expect(await bulkDeleteNotes([])).toEqual({ count: 0 });
    expect(post).not.toHaveBeenCalled();
  });
});
