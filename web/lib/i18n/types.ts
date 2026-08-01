import type { en } from "./locales/en";

/**
 * A translation value is either a plain string or a pluralization object with
 * `one`/`other` forms. Interpolation placeholders use the `{name}` syntax.
 */
export type TranslationValue = string | { one: string; other: string };

/**
 * Widen the literal types produced by `as const` in the English source so that
 * other locales only have to match the shape (string/plural leaves), not the
 * exact English text.
 */
type Widen<T> = T extends string
  ? string
  : T extends { one: string; other: string }
    ? { one: string; other: string }
    : { [K in keyof T]: Widen<T[K]> };

export type Dictionary = Widen<typeof en>;

type DotPaths<T> = {
  [K in keyof T & string]: T[K] extends TranslationValue
    ? K
    : T[K] extends object
      ? `${K}.${DotPaths<T[K]>}`
      : never;
}[keyof T & string];

export type TranslationKey = DotPaths<Dictionary>;

export type TranslationVars = Record<string, string | number>;
