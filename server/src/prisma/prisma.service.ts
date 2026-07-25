import { Inject, Injectable } from '@nestjs/common';
import type { ConfigType } from '@nestjs/config';
import { PrismaClient } from '../generated/prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { DatabaseConfig } from '../config/configuration';

@Injectable()
export class PrismaService extends PrismaClient {
  constructor(
    @Inject(DatabaseConfig.KEY)
    databaseConfig: ConfigType<typeof DatabaseConfig>,
  ) {
    const adapter = new PrismaPg({
      connectionString: databaseConfig.url,
    });
    super({
      adapter,
      omit: {
        user: {
          password: true,
        },
      },
    });
  }
}
