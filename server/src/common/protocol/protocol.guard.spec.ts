import type { ExecutionContext, HttpException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ANCHOR_PROTOCOL_HEADER, ProtocolGuard } from './protocol.guard';
import {
  ANCHOR_PROTOCOL,
  MIN_ANCHOR_PROTOCOL,
  SUPPORTED_PROTOCOLS,
} from './protocol.constants';

const UPGRADE_REQUIRED = 426;

const guard = (skipped = false) => {
  const reflector = new Reflector();
  jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(skipped);
  return new ProtocolGuard(reflector);
};

const contextWith = (
  header?: string | string[],
  type: 'http' | 'ws' = 'http',
): ExecutionContext =>
  ({
    getType: () => type,
    getHandler: () => undefined,
    getClass: () => undefined,
    switchToHttp: () => ({
      getRequest: () => ({
        headers:
          header === undefined ? {} : { [ANCHOR_PROTOCOL_HEADER]: header },
      }),
    }),
  }) as unknown as ExecutionContext;

const refusalFrom = (header: string | string[]) => {
  try {
    guard().canActivate(contextWith(header));
  } catch (error) {
    return error as HttpException;
  }
  throw new Error('expected the guard to refuse');
};

describe('ProtocolGuard', () => {
  it('allows a request with no protocol header', () => {
    expect(guard().canActivate(contextWith())).toBe(true);
  });

  it('allows every protocol the server advertises', () => {
    for (let p = MIN_ANCHOR_PROTOCOL; p <= ANCHOR_PROTOCOL; p++) {
      expect(guard().canActivate(contextWith(`${p}`))).toBe(true);
    }
  });

  it('refuses a newer client as SERVER_OUTDATED', () => {
    const error = refusalFrom(`${ANCHOR_PROTOCOL + 1}`);

    expect(error.getStatus()).toBe(UPGRADE_REQUIRED);
    expect(error.getResponse()).toMatchObject({ code: 'SERVER_OUTDATED' });
  });

  it('refuses a retired protocol as APP_OUTDATED', () => {
    const error = refusalFrom(`${MIN_ANCHOR_PROTOCOL - 1}`);

    expect(error.getStatus()).toBe(UPGRADE_REQUIRED);
    expect(error.getResponse()).toMatchObject({ code: 'APP_OUTDATED' });
  });

  it('refuses a malformed header rather than trusting it', () => {
    expect(refusalFrom('not-a-number').getResponse()).toMatchObject({
      code: 'APP_OUTDATED',
    });
  });

  it('reads the first value when the header is repeated', () => {
    expect(
      guard().canActivate(contextWith([`${ANCHOR_PROTOCOL}`, 'junk'])),
    ).toBe(true);
  });

  it('tells the client which protocols would work', () => {
    expect(refusalFrom('0').getResponse()).toMatchObject({
      protocols: SUPPORTED_PROTOCOLS,
    });
  });

  it('lets an exempt route through on an unservable protocol', () => {
    expect(guard(true).canActivate(contextWith('0'))).toBe(true);
  });

  it('ignores contexts that are not http', () => {
    expect(guard().canActivate(contextWith('0', 'ws'))).toBe(true);
  });
});
