import { BadRequestException } from '@nestjs/common';
import { decodeCursor, encodeCursor, SyncCursor } from './sync-cursor.util';

describe('sync cursor', () => {
  it('round-trips a delta cursor', () => {
    const cursor: SyncCursor = { mode: 'delta', seq: 12345678901234567890n };
    expect(decodeCursor(encodeCursor(cursor))).toEqual(cursor);
  });

  it('round-trips every snapshot phase with and without a keyset id', () => {
    for (const phase of ['tags', 'notes', 'attachments', 'pins'] as const) {
      for (const afterId of [null, 'entity-42']) {
        const cursor: SyncCursor = {
          mode: 'snapshot',
          phase,
          afterId,
          capturedSeq: 99n,
        };
        expect(decodeCursor(encodeCursor(cursor))).toEqual(cursor);
      }
    }
  });

  it('rejects garbage, wrong versions, and tampered fields', () => {
    const cases = [
      'not-base64!!!',
      Buffer.from('"just a string"').toString('base64url'),
      Buffer.from('{"v":2,"m":"d","s":"1"}').toString('base64url'),
      Buffer.from('{"v":3,"m":"x","s":"1"}').toString('base64url'),
      Buffer.from('{"v":3,"m":"d","s":"-1"}').toString('base64url'),
      Buffer.from('{"v":3,"m":"d","s":"abc"}').toString('base64url'),
      Buffer.from('{"v":3,"m":"s","p":"shares","a":null,"c":"1"}').toString(
        'base64url',
      ),
      Buffer.from('{"v":3,"m":"s","p":"tags","a":7,"c":"1"}').toString(
        'base64url',
      ),
    ];
    for (const raw of cases) {
      expect(() => decodeCursor(raw)).toThrow(BadRequestException);
    }
  });
});
