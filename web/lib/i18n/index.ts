export {
  defaultLocale,
  detectLocale,
  isLocale,
  type Locale,
  localeNames,
  locales,
} from "./config";
export { I18nProvider, translate, useTranslation } from "./context";
export { dictionaries } from "./locales";
export type {
  Dictionary,
  TranslationKey,
  TranslationVars,
} from "./types";
