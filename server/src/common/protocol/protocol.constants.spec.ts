import {
  ANCHOR_PROTOCOL,
  MIN_ANCHOR_PROTOCOL,
  SUPPORTED_PROTOCOLS,
} from './protocol.constants';

describe('protocol constants', () => {
  it('advertises an ascending range from the oldest served to the current', () => {
    expect(MIN_ANCHOR_PROTOCOL).toBeLessThanOrEqual(ANCHOR_PROTOCOL);
    expect(SUPPORTED_PROTOCOLS[0]).toBe(MIN_ANCHOR_PROTOCOL);
    expect(SUPPORTED_PROTOCOLS.at(-1)).toBe(ANCHOR_PROTOCOL);
    expect(SUPPORTED_PROTOCOLS).toEqual(
      [...SUPPORTED_PROTOCOLS].sort((a, b) => a - b),
    );
    expect(SUPPORTED_PROTOCOLS).toHaveLength(
      ANCHOR_PROTOCOL - MIN_ANCHOR_PROTOCOL + 1,
    );
  });
});
