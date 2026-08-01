"use client";

import {
  createContext,
  type ReactNode,
  useCallback,
  useContext,
  useEffect,
  useMemo,
} from "react";
import { usePreferencesStore } from "@/features/preferences";
import { defaultLocale, detectLocale, type Locale } from "./config";
import { dictionaries } from "./locales";
import type {
  TranslationKey,
  TranslationValue,
  TranslationVars,
} from "./types";

interface I18nContextValue {
  locale: Locale;
  setLocale: (locale: Locale) => void;
  t: (key: TranslationKey, vars?: TranslationVars) => string;
}

const I18nContext = createContext<I18nContextValue | null>(null);

function lookup(
  dictionary: Record<string, unknown>,
  key: string,
): TranslationValue | undefined {
  const value = key
    .split(".")
    .reduce<unknown>(
      (acc, part) =>
        acc && typeof acc === "object"
          ? (acc as Record<string, unknown>)[part]
          : undefined,
      dictionary,
    );
  if (typeof value === "string") {
    return value;
  }
  if (
    value &&
    typeof value === "object" &&
    "other" in (value as Record<string, unknown>)
  ) {
    return value as TranslationValue;
  }
  return undefined;
}

function interpolate(template: string, vars?: TranslationVars): string {
  if (!vars) {
    return template;
  }
  return template.replace(/\{(\w+)\}/g, (match, name) =>
    name in vars ? String(vars[name]) : match,
  );
}

/**
 * Resolve a translation key against the active locale, falling back to English
 * and finally to the raw key. Supports `{name}` interpolation and `count`-based
 * pluralization (`{ one, other }` shapes).
 */
export function translate(
  locale: Locale,
  key: TranslationKey,
  vars?: TranslationVars,
): string {
  const value =
    lookup(dictionaries[locale], key) ??
    lookup(dictionaries[defaultLocale], key);

  if (value === undefined) {
    return key;
  }

  if (typeof value === "string") {
    return interpolate(value, vars);
  }

  const count = typeof vars?.count === "number" ? vars.count : undefined;
  const form = count === 1 ? value.one : value.other;
  return interpolate(form, vars);
}

export function I18nProvider({ children }: { children: ReactNode }) {
  const locale = usePreferencesStore((state) => state.locale);
  const setLocale = usePreferencesStore((state) => state.setLocale);

  // First-run auto-detection: resolve the browser language when no locale has
  // been persisted yet, then fall back to English.
  useEffect(() => {
    if (locale === null) {
      const detected =
        typeof navigator !== "undefined"
          ? detectLocale(navigator.language)
          : defaultLocale;
      setLocale(detected);
    }
  }, [locale, setLocale]);

  const activeLocale = locale ?? defaultLocale;

  // Keep the document language attribute in sync for a11y and SEO.
  useEffect(() => {
    if (typeof document !== "undefined") {
      document.documentElement.lang = activeLocale;
    }
  }, [activeLocale]);

  const t = useCallback(
    (key: TranslationKey, vars?: TranslationVars) =>
      translate(activeLocale, key, vars),
    [activeLocale],
  );

  const value = useMemo(
    () => ({ locale: activeLocale, setLocale, t }),
    [activeLocale, setLocale, t],
  );

  return <I18nContext.Provider value={value}>{children}</I18nContext.Provider>;
}

export function useTranslation(): I18nContextValue {
  const context = useContext(I18nContext);
  if (!context) {
    throw new Error("useTranslation must be used within an I18nProvider");
  }
  return context;
}
