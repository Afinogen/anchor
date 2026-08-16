import { AsyncLocalStorage } from 'node:async_hooks';
import { Inject, Injectable } from '@nestjs/common';
import type { ConfigType } from '@nestjs/config';
import { PrismaClient } from '../generated/prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { DatabaseConfig } from '../config/configuration';

type AnyTransaction = (arg: unknown, options?: unknown) => Promise<unknown>;

@Injectable()
export class PrismaService extends PrismaClient {
  private readonly commitHooks = new AsyncLocalStorage<Array<() => void>>();

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
    this.patchTransactionForCommitHooks();
  }

  // Runs the hook once the surrounding transaction commits; a rollback
  // discards it. Outside a transaction the write is already durable, so the
  // hook runs immediately.
  afterCommit(hook: () => void): void {
    const hooks = this.commitHooks.getStore();
    if (hooks) {
      hooks.push(hook);
    } else {
      hook();
    }
  }

  // Interactive $transaction callbacks run inside an AsyncLocalStorage scope
  // collecting afterCommit hooks, which flush once the transaction resolves.
  // Patched on the instance: the Prisma runtime may define $transaction as an
  // own property.
  private patchTransactionForCommitHooks(): void {
    const original = this.$transaction.bind(this) as AnyTransaction;
    const patched: AnyTransaction = async (arg, options) => {
      if (typeof arg !== 'function') {
        return original(arg, options);
      }
      const hooks: Array<() => void> = [];
      const result = await this.commitHooks.run(hooks, () =>
        original(arg, options),
      );
      for (const hook of hooks) {
        hook();
      }
      return result;
    };
    this.$transaction = patched as unknown as PrismaClient['$transaction'];
  }
}
