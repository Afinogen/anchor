import { Controller, Get } from '@nestjs/common';
import * as path from 'path';
import * as fs from 'fs';
import { SUPPORTED_PROTOCOLS } from '../common/protocol/protocol.constants';
import { SkipProtocolGate } from '../common/protocol/skip-protocol-gate.decorator';

@Controller('api/health')
@SkipProtocolGate()
export class HealthController {
  @Get()
  check() {
    // Read version from package.json
    // Works in both npm scripts and direct node execution (Docker)
    let version: string | undefined;
    try {
      const packageJsonPath = path.join(process.cwd(), 'package.json');
      const packageJson = JSON.parse(
        fs.readFileSync(packageJsonPath, 'utf8'),
      ) as { version?: string };
      version = packageJson.version;
    } catch {
      // Fallback to npm_package_version if package.json read fails
      version = process.env.npm_package_version;
    }

    return {
      status: 'ok',
      app: 'anchor',
      version,
      protocols: SUPPORTED_PROTOCOLS,
      timestamp: new Date().toISOString(),
    };
  }
}
