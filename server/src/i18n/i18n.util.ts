import { I18nContext } from 'nestjs-i18n';

/**
 * Translate a message key using the current request's locale (resolved from the
 * `Accept-Language` header). Falls back to the key when no i18n context is
 * available (e.g. outside the request lifecycle). Use in services/guards so
 * exception messages are localized without injecting I18nService everywhere.
 */
export function t(key: string, args?: Record<string, unknown>): string {
  const i18n = I18nContext.current();
  if (!i18n) {
    return key;
  }
  return i18n.t(key, { args });
}
