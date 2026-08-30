import { describe, expect, it, vi } from "vitest";
import {
  connectSyncEvents,
  type SyncEventStream,
  type SyncEventsOptions,
} from "./events";

function openChannel(init?: RequestInit) {
  let controller!: ReadableStreamDefaultController<Uint8Array>;
  const encoder = new TextEncoder();
  const stream = new ReadableStream<Uint8Array>({
    start(streamController) {
      controller = streamController;
    },
  });

  init?.signal?.addEventListener("abort", () => {
    try {
      controller.error(new Error("aborted"));
    } catch {
      // Already finished.
    }
  });

  return {
    response: new Response(stream, { status: 200 }),
    send: (text: string) => controller.enqueue(encoder.encode(text)),
    end: () => controller.close(),
  };
}

// Answers with the given statuses first, then holds a channel open.
function channels(statuses: number[] = []) {
  const opened: Array<ReturnType<typeof openChannel>> = [];
  const fetchFn = vi.fn((_url: string, init?: RequestInit) => {
    const status = statuses.shift();
    if (status) {
      return Promise.resolve(new Response("", { status }));
    }
    const channel = openChannel(init);
    opened.push(channel);
    return Promise.resolve(channel.response);
  });
  return { opened, fetchFn: fetchFn as unknown as typeof fetch };
}

function responses(...statuses: number[]) {
  return vi.fn(() => {
    const status = statuses.shift() ?? 500;
    return Promise.resolve(new Response("", { status }));
  }) as unknown as typeof fetch;
}

function connect(options: Partial<SyncEventsOptions>): SyncEventStream {
  return connectSyncEvents({
    onSync: () => {},
    onReconnect: () => {},
    getToken: () => "token",
    refreshToken: () => Promise.resolve(false),
    sleep: () => new Promise<void>((resolve) => setTimeout(resolve, 0)),
    random: () => 0.5,
    ...options,
  } as SyncEventsOptions);
}

describe("connectSyncEvents", () => {
  it("starts a sync when the server says something changed", async () => {
    const onSync = vi.fn();
    const { opened, fetchFn } = channels();
    const stream = connect({ fetchFn, onSync });

    await vi.waitFor(() => expect(opened).toHaveLength(1));
    opened[0].send('event: sync\ndata: {"seq":"7"}\n\n');

    await vi.waitFor(() => expect(onSync).toHaveBeenCalledTimes(1));
    stream.close();
  });

  it("reads a message split across chunks", async () => {
    const onSync = vi.fn();
    const { opened, fetchFn } = channels();
    const stream = connect({ fetchFn, onSync });

    await vi.waitFor(() => expect(opened).toHaveLength(1));
    opened[0].send("event: sy");
    opened[0].send("nc\ndata: 1\n");
    opened[0].send("\n");

    await vi.waitFor(() => expect(onSync).toHaveBeenCalledTimes(1));
    stream.close();
  });

  it("ignores keep-alives", async () => {
    const onSync = vi.fn();
    const { opened, fetchFn } = channels();
    const stream = connect({ fetchFn, onSync });

    await vi.waitFor(() => expect(opened).toHaveLength(1));
    opened[0].send("event: ping\ndata:\n\n");
    opened[0].send("event: sync\ndata:\n\n");

    await vi.waitFor(() => expect(onSync).toHaveBeenCalledTimes(1));
    stream.close();
  });

  it("pulls after reconnecting, not on the first connection", async () => {
    const onReconnect = vi.fn();
    const { opened, fetchFn } = channels();
    const stream = connect({ fetchFn, onReconnect });

    await vi.waitFor(() => expect(opened).toHaveLength(1));
    expect(onReconnect).not.toHaveBeenCalled();

    opened[0].end();
    await vi.waitFor(() => expect(onReconnect).toHaveBeenCalledTimes(1));
    stream.close();
  });

  it("reconnects when the keep-alives stop", async () => {
    const { opened, fetchFn } = channels();
    const stream = connect({ fetchFn, heartbeatMs: 20 });

    await vi.waitFor(() => expect(opened.length).toBeGreaterThan(1));
    stream.close();
  });

  it("gives up when the server has no push channel", async () => {
    const fetchFn = responses(404);
    const stream = connect({ fetchFn });

    await vi.waitFor(() => expect(fetchFn).toHaveBeenCalledTimes(1));
    await new Promise((resolve) => setTimeout(resolve, 10));

    expect(fetchFn).toHaveBeenCalledTimes(1);
    stream.close();
  });

  it("refreshes the token once and retries", async () => {
    const refreshToken = vi.fn(() => Promise.resolve(true));
    const { opened, fetchFn } = channels([401]);
    const stream = connect({ fetchFn, refreshToken });

    await vi.waitFor(() => expect(opened).toHaveLength(1));
    expect(fetchFn).toHaveBeenCalledTimes(2);
    expect(refreshToken).toHaveBeenCalledTimes(1);
    stream.close();
  });

  it("waits longer between each failed attempt", async () => {
    const delays: number[] = [];
    let stream: SyncEventStream | undefined;

    stream = connect({
      fetchFn: responses(500, 500, 500),
      sleep: (ms) => {
        delays.push(ms);
        if (delays.length >= 3) stream?.close();
        return Promise.resolve();
      },
    });

    await vi.waitFor(() => expect(delays).toHaveLength(3));
    expect(delays).toEqual([1000, 2000, 4000]);
  });

  it("keeps backing off when a connection carries nothing", async () => {
    const delays: number[] = [];
    let stream: SyncEventStream | undefined;
    const fetchFn = vi.fn((_url: string, init?: RequestInit) => {
      const channel = openChannel(init);
      channel.end();
      return Promise.resolve(channel.response);
    }) as unknown as typeof fetch;

    stream = connect({
      fetchFn,
      sleep: (ms) => {
        delays.push(ms);
        if (delays.length >= 3) stream?.close();
        return new Promise<void>((resolve) => setTimeout(resolve, 0));
      },
    });

    await vi.waitFor(() => expect(delays).toHaveLength(3));
    expect(delays).toEqual([1000, 2000, 4000]);
  });

  it("stops connecting once closed", async () => {
    const { opened, fetchFn } = channels();
    const stream = connect({ fetchFn });

    await vi.waitFor(() => expect(opened).toHaveLength(1));
    stream.close();
    await new Promise((resolve) => setTimeout(resolve, 10));

    expect(opened).toHaveLength(1);
  });
});
