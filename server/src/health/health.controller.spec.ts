import { HealthController } from './health.controller';
import {
  ANCHOR_PROTOCOL,
  SUPPORTED_PROTOCOLS,
} from '../common/protocol/protocol.constants';

describe('HealthController', () => {
  it('reports the app identity, version and servable protocols', () => {
    const body = new HealthController().check();

    expect(body).toMatchObject({ status: 'ok', app: 'anchor' });
    expect(body.version).toEqual(expect.any(String));
    expect(Date.parse(body.timestamp)).not.toBeNaN();
  });

  it('advertises the protocols clients are gated on', () => {
    expect(new HealthController().check().protocols).toEqual(
      SUPPORTED_PROTOCOLS,
    );
    expect(SUPPORTED_PROTOCOLS).toContain(ANCHOR_PROTOCOL);
  });
});
