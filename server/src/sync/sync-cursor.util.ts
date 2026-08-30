import { BadRequestException } from '@nestjs/common';

export const SNAPSHOT_PHASES = [
  'tags',
  'notes',
  'attachments',
  'pins',
] as const;
export type SnapshotPhase = (typeof SNAPSHOT_PHASES)[number];

export type SyncCursor =
  | { mode: 'delta'; seq: bigint }
  | {
      mode: 'snapshot';
      phase: SnapshotPhase;
      afterId: string | null;
      capturedSeq: bigint;
    };

interface DeltaCursorWire {
  v: 3;
  m: 'd';
  s: string;
}

interface SnapshotCursorWire {
  v: 3;
  m: 's';
  p: SnapshotPhase;
  a: string | null;
  c: string;
}

export function encodeCursor(cursor: SyncCursor): string {
  const wire: DeltaCursorWire | SnapshotCursorWire =
    cursor.mode === 'delta'
      ? { v: 3, m: 'd', s: cursor.seq.toString() }
      : {
          v: 3,
          m: 's',
          p: cursor.phase,
          a: cursor.afterId,
          c: cursor.capturedSeq.toString(),
        };
  return Buffer.from(JSON.stringify(wire)).toString('base64url');
}

export function decodeCursor(raw: string): SyncCursor {
  let wire: unknown;
  try {
    wire = JSON.parse(Buffer.from(raw, 'base64url').toString('utf8'));
  } catch {
    throw new BadRequestException('Malformed sync cursor');
  }

  if (typeof wire !== 'object' || wire === null) {
    throw new BadRequestException('Malformed sync cursor');
  }
  const record = wire as Record<string, unknown>;
  if (record.v !== 3) {
    throw new BadRequestException('Malformed sync cursor');
  }

  if (record.m === 'd') {
    return { mode: 'delta', seq: parseSeq(record.s) };
  }

  if (record.m === 's') {
    const phase = record.p;
    if (!SNAPSHOT_PHASES.includes(phase as SnapshotPhase)) {
      throw new BadRequestException('Malformed sync cursor');
    }
    const afterId = record.a;
    if (afterId !== null && typeof afterId !== 'string') {
      throw new BadRequestException('Malformed sync cursor');
    }
    return {
      mode: 'snapshot',
      phase: phase as SnapshotPhase,
      afterId,
      capturedSeq: parseSeq(record.c),
    };
  }

  throw new BadRequestException('Malformed sync cursor');
}

function parseSeq(value: unknown): bigint {
  if (typeof value !== 'string' || !/^\d+$/.test(value)) {
    throw new BadRequestException('Malformed sync cursor');
  }
  return BigInt(value);
}
