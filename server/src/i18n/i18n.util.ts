import * as fs from 'fs';
import * as path from 'path';
import { I18nContext } from 'nestjs-i18n';

/** English namespaces, read once and used when there is no request context. */
let fallbackCatalog: Record<string, unknown> | null = null;

function catalog(): Record<string, unknown> {
  if (fallbackCatalog) return fallbackCatalog;

  const dir = path.join(__dirname, 'en');
  const loaded: Record<string, unknown> = {};
  try {
    for (const file of fs.readdirSync(dir)) {
      if (!file.endsWith('.json')) continue;
      const namespace = path.basename(file, '.json');
      loaded[namespace] = JSON.parse(
        fs.readFileSync(path.join(dir, file), 'utf8'),
      ) as unknown;
    }
  } catch {
    // No catalog on disk; t() then falls back to returning the key.
  }
  fallbackCatalog = loaded;
  return loaded;
}

function lookup(key: string): string | null {
  let node: unknown = catalog();
  for (const part of key.split('.')) {
    if (typeof node !== 'object' || node === null) return null;
    node = (node as Record<string, unknown>)[part];
  }
  return typeof node === 'string' ? node : null;
}

/**
 * Translate a message key using the current request's locale (resolved from the
 * `Accept-Language` header). Use in services/guards so exception messages are
 * localized without injecting I18nService everywhere.
 *
 * Outside the request lifecycle (background jobs, unit tests) there is no i18n
 * context, so the English wording is read straight off disk — a raw key would
 * otherwise leak into logs and responses.
 */
export function t(key: string, args?: Record<string, unknown>): string {
  const i18n = I18nContext.current();
  if (i18n) {
    return i18n.t(key, { args });
  }

  const template = lookup(key);
  if (template === null) return key;
  if (!args) return template;

  return template.replace(/\{(\w+)\}/g, (match: string, name: string) =>
    name in args ? String(args[name]) : match,
  );
}
