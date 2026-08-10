import type { Prisma } from 'src/generated/prisma/client';
import { SyncEntityType, SyncOp } from 'src/generated/prisma/enums';
import {
  SyncEmitterService,
  SyncEmission,
  noteEmissions,
  pinEmission,
} from './sync-emitter.service';
import { asSyncEvents, createMockSyncEvents } from '../../test/sync-mocks';

/**
 * Seq block allocation and assignment, per-call dedup, sorted lock order, and
 * the removeNote cleanup. next_sync_seq itself is pinned by the e2e infra
 * suite.
 */
describe('SyncEmitterService', () => {
  let service: SyncEmitterService;
  let syncEvents: ReturnType<typeof createMockSyncEvents>;
  let seqByUser: Map<string, bigint>;
  let upserts: Array<{
    where: {
      recipientUserId_entityType_entityId: {
        recipientUserId: string;
        entityType: SyncEntityType;
        entityId: string;
      };
    };
    create: SyncEmission & { seq: bigint };
    update: { op: SyncOp; seq: bigint };
  }>;

  const queryRaw = jest.fn(
    (_strings: TemplateStringsArray, uid: string, n: number) => {
      const last = (seqByUser.get(uid) ?? 0n) + BigInt(n);
      seqByUser.set(uid, last);
      return Promise.resolve([{ seq: last }]);
    },
  );

  const changeLogUpsert = jest.fn((args: (typeof upserts)[number]) => {
    upserts.push(args);
    return Promise.resolve({});
  });

  const changeLogDeleteMany = jest.fn().mockResolvedValue({ count: 0 });

  const tx = {
    $queryRaw: queryRaw,
    changeLog: { upsert: changeLogUpsert, deleteMany: changeLogDeleteMany },
  } as unknown as Prisma.TransactionClient;

  beforeEach(() => {
    syncEvents = createMockSyncEvents();
    service = new SyncEmitterService(asSyncEvents(syncEvents));
    seqByUser = new Map();
    upserts = [];
    jest.clearAllMocks();
  });

  it('allocates one contiguous seq block per recipient', async () => {
    const recipients = await service.emit(tx, [
      ...noteEmissions(['user-a'], 'note-1'),
      ...noteEmissions(['user-a'], 'note-2'),
      pinEmission('user-a', 'note-1', true),
    ]);

    expect(recipients).toEqual(['user-a']);
    expect(queryRaw).toHaveBeenCalledTimes(1);
    expect(upserts.map((u) => u.create.seq)).toEqual([1n, 2n, 3n]);
  });

  it('dedupes same-entity emissions within a call, keeping the last op', async () => {
    await service.emit(tx, [
      ...noteEmissions(['user-a'], 'note-1', SyncOp.upsert),
      ...noteEmissions(['user-a'], 'note-1', SyncOp.remove),
    ]);

    expect(upserts).toHaveLength(1);
    expect(upserts[0].create.op).toBe(SyncOp.remove);
  });

  it('takes recipient seq blocks in sorted order for a stable lock order', async () => {
    await service.emit(tx, [
      ...noteEmissions(['user-c', 'user-a', 'user-b'], 'note-1'),
    ]);

    expect(queryRaw.mock.calls.map((call) => call[1])).toEqual([
      'user-a',
      'user-b',
      'user-c',
    ]);
  });

  it('re-stamps an existing entity row with a fresh seq on update', async () => {
    await service.emit(tx, noteEmissions(['user-a'], 'note-1'));
    await service.emit(tx, noteEmissions(['user-a'], 'note-1'));

    expect(upserts[1].update.seq).toBe(2n);
    expect(upserts[1].where.recipientUserId_entityType_entityId).toEqual({
      recipientUserId: 'user-a',
      entityType: SyncEntityType.note,
      entityId: 'note-1',
    });
  });

  it('removeNote drops the pin/attachments index rows and folds extras into one emit', async () => {
    await service.removeNote(
      tx,
      ['user-b'],
      'note-1',
      noteEmissions(['user-a'], 'note-1'),
    );

    expect(changeLogDeleteMany).toHaveBeenCalledWith({
      where: {
        recipientUserId: { in: ['user-b'] },
        entityId: 'note-1',
        entityType: { in: [SyncEntityType.pin, SyncEntityType.attachments] },
      },
    });
    const ops = new Map(
      upserts.map((u) => [u.create.recipientUserId, u.create.op]),
    );
    expect(ops.get('user-b')).toBe(SyncOp.remove);
    expect(ops.get('user-a')).toBe(SyncOp.upsert);
    // One emit call: both recipients' blocks allocated in the same sorted pass.
    expect(queryRaw.mock.calls.map((call) => call[1])).toEqual([
      'user-a',
      'user-b',
    ]);
  });

  it('emits nothing and touches no locks for an empty emission list', async () => {
    const recipients = await service.emit(tx, []);

    expect(recipients).toEqual([]);
    expect(queryRaw).not.toHaveBeenCalled();
    expect(changeLogUpsert).not.toHaveBeenCalled();
  });

  it("schedules a poke with each recipient's last allocated seq", async () => {
    await service.emit(tx, [
      ...noteEmissions(['user-a'], 'note-1'),
      ...noteEmissions(['user-a'], 'note-2'),
      ...noteEmissions(['user-b'], 'note-1'),
    ]);

    expect(syncEvents.schedulePoke).toHaveBeenCalledWith(
      new Map([
        ['user-a', 2n],
        ['user-b', 1n],
      ]),
    );
  });

  it('schedules an empty poke map for an empty emission list', async () => {
    await service.emit(tx, []);

    expect(syncEvents.schedulePoke).toHaveBeenCalledWith(new Map());
  });
});
