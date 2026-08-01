export const locales = ["en", "ru"] as const;

export type Locale = (typeof locales)[number];

export const defaultLocale: Locale = "en";

export const localeNames: Record<Locale, string> = {
  en: "English",
  ru: "Русский",
};

export function isLocale(value: unknown): value is Locale {
  return typeof value === "string" && locales.includes(value as Locale);
}

/**
 * Resolve a browser language string (e.g. "ru-RU", "en-US") to a supported
 * locale. Falls back to {@link defaultLocale} when nothing matches.
 */
export function detectLocale(navigatorLanguage: string | undefined): Locale {
  if (!navigatorLanguage) {
    return defaultLocale;
  }
  const normalized = navigatorLanguage.toLowerCase();
  const match = locales.find((locale) => normalized.startsWith(locale));
  return match ?? defaultLocale;
}
