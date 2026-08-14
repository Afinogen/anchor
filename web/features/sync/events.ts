const eventsPath = "/api/sync/events";

// The server sends a keep-alive every 25s; a longer gap means it has died.
const heartbeatTimeoutMs = 60_000;
const minRetryDelayMs = 1_000;
const maxRetryDelayMs = 60_000;

export interface SyncEventsOptions {
  onSync: () => void;
  onReconnect: () => void;
  getToken: () => string | null;
  refreshToken: () => Promise<boolean>;
  fetchFn?: typeof fetch;
  sleep?: (ms: number) => Promise<void>;
  random?: () => number;
  heartbeatMs?: number;
}

export interface SyncEventStream {
  close: () => void;
}

const wait = (ms: number) =>
  new Promise<void>((resolve) => setTimeout(resolve, ms));

// Holds a connection open and calls back whenever the server says something
// changed. The message names no entity, so the caller refetches what it needs.
export function connectSyncEvents(options: SyncEventsOptions): SyncEventStream {
  const {
    onSync,
    onReconnect,
    getToken,
    refreshToken,
    fetchFn = fetch,
    sleep = wait,
    random = Math.random,
    heartbeatMs = heartbeatTimeoutMs,
  } = options;

  let closed = false;
  let wasOpen = false;
  let attempt = 0;
  let controller: AbortController | null = null;

  function request(): Promise<Response> {
    const token = getToken();
    return fetchFn(eventsPath, {
      cache: "no-store",
      signal: controller?.signal,
      headers: {
        Accept: "text/event-stream",
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
    });
  }

  async function read(body: ReadableStream<Uint8Array>): Promise<void> {
    const reader = body.getReader();
    const decoder = new TextDecoder();
    let buffer = "";
    let event = "";
    let watchdog = setTimeout(() => controller?.abort(), heartbeatMs);

    try {
      for (;;) {
        const { done, value } = await reader.read();
        if (done) return;

        // A connection that never carries anything keeps backing off.
        attempt = 0;
        clearTimeout(watchdog);
        watchdog = setTimeout(() => controller?.abort(), heartbeatMs);

        buffer += decoder.decode(value, { stream: true });
        for (
          let newline = buffer.indexOf("\n");
          newline >= 0;
          newline = buffer.indexOf("\n")
        ) {
          const line = buffer.slice(0, newline).trimEnd();
          buffer = buffer.slice(newline + 1);

          if (line.startsWith("event:")) {
            event = line.slice("event:".length).trim();
          } else if (line === "") {
            if (event === "sync") onSync();
            event = "";
          }
        }
      }
    } finally {
      clearTimeout(watchdog);
      void reader.cancel().catch(() => {});
    }
  }

  async function open(): Promise<boolean> {
    controller = new AbortController();
    try {
      let response = await request();
      if (response.status === 401 && (await refreshToken())) {
        response = await request();
      }

      // A server without the endpoint never pushes; the caller still polls.
      if (response.status === 404) return false;
      if (!response.ok || !response.body) return true;

      if (wasOpen) onReconnect();
      wasOpen = true;

      await read(response.body);
      return true;
    } catch {
      return true;
    } finally {
      controller = null;
    }
  }

  function nextDelay(): number {
    const backoff = Math.min(minRetryDelayMs * 2 ** attempt, maxRetryDelayMs);
    attempt = Math.min(attempt + 1, 6);
    // ±25% jitter.
    return Math.round(backoff * (0.75 + random() * 0.5));
  }

  async function loop(): Promise<void> {
    while (!closed) {
      if (!(await open())) return;
      if (closed) return;
      await sleep(nextDelay());
    }
  }

  void loop();

  return {
    close() {
      closed = true;
      controller?.abort();
    },
  };
}
