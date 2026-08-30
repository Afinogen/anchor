import { Module } from '@nestjs/common';
import { APP_FILTER, APP_GUARD } from '@nestjs/core';
import { ConfigModule } from '@nestjs/config';
import * as path from 'path';
import {
  AcceptLanguageResolver,
  HeaderResolver,
  I18nModule,
  QueryResolver,
} from 'nestjs-i18n';
import { configurations } from './config/configuration';
import { validate } from './config/env.validation';
import { GlobalExceptionFilter } from './common/filters/global-exception.filter';
import { ProtocolGuard } from './common/protocol/protocol.guard';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { NotesModule } from './notes/notes.module';
import { TagsModule } from './tags/tags.module';
import { SyncApiModule } from './sync/sync-api.module';
import { TasksModule } from './tasks/tasks.module';
import { HealthModule } from './health/health.module';
import { AdminModule } from './admin/admin.module';
import { SettingsModule } from './settings/settings.module';
import { UsersModule } from './users/users.module';
import { ImportExportModule } from './import-export/import-export.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      cache: true,
      validate,
      load: configurations,
    }),
    I18nModule.forRoot({
      fallbackLanguage: 'en',
      loaderOptions: {
        path: path.join(__dirname, '/i18n/'),
        watch: true,
      },
      resolvers: [
        new QueryResolver(['lang']),
        new HeaderResolver(['x-lang']),
        AcceptLanguageResolver,
      ],
    }),
    PrismaModule,
    AuthModule,
    NotesModule,
    TagsModule,
    SyncApiModule,
    TasksModule,
    HealthModule,
    AdminModule,
    SettingsModule,
    UsersModule,
    ImportExportModule,
  ],
  providers: [
    {
      provide: APP_FILTER,
      useClass: GlobalExceptionFilter,
    },
    {
      provide: APP_GUARD,
      useClass: ProtocolGuard,
    },
  ],
})
export class AppModule {}
