// Successive edits by the same author collapse into one revision within this
// window, so autosave doesn't flood the history.
export const REVISION_COLLAPSE_WINDOW_MS = 10 * 60 * 1000;

export const MIN_SYNC_LIMIT = 1;
export const MAX_SYNC_LIMIT = 500;
export const DEFAULT_SYNC_LIMIT = 200;
export const MAX_SYNC_CHANGES = 200;

// Bounds how many recorded versions ride on one note change.
export const MAX_SYNC_NOTE_REVISIONS = 20;

export const CHANGELOG_REMOVE_RETENTION_DAYS = 90;

export const CHANGELOG_UPSERT_CHUNK_SIZE = 500;

export const NOTE_REVISION_RETENTION_DAYS = 90;
export const NOTE_REVISION_CAP_PER_NOTE = 200;

// Pings keep proxies from timing out an idle stream (client watchdogs allow
// ~60s). Streams close at the max age so the client reconnects with a fresh
// token, and the per-user cap bounds fan-out.
export const SYNC_EVENTS_PING_INTERVAL_MS = 25 * 1000;
export const SYNC_EVENTS_MAX_STREAM_AGE_MS = 60 * 60 * 1000;
export const MAX_SYNC_EVENT_STREAMS_PER_USER = 8;
