import { SetMetadata } from '@nestjs/common';

export const SKIP_PROTOCOL_GATE = 'skipProtocolGate';

export const SkipProtocolGate = () => SetMetadata(SKIP_PROTOCOL_GATE, true);
