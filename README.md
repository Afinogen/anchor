<div align="center">

<img src="https://raw.githubusercontent.com/zhfahim/anchor/main/web/public/icons/anchor_icon.png" alt="Anchor" width="120" height="120">

# Anchor — Russian localization fork

**An offline first, self hostable note taking application — now in Russian**

[![Version](https://img.shields.io/badge/version-0.16.0-blue.svg?style=for-the-badge)](https://github.com/Afinogen/anchor/tree/i18n)
[![Upstream](https://img.shields.io/badge/upstream-ZhFahim%2Fanchor%20v0.16.0-lightgrey.svg?style=for-the-badge)](https://github.com/ZhFahim/anchor)
[![Languages](https://img.shields.io/badge/UI-English%20%7C%20%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9-success.svg?style=for-the-badge)](#localization)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg?style=for-the-badge)](LICENSE)

**English** · [Русский](README.ru.md)

</div>

> ### 🇷🇺 This is a fork of [ZhFahim/anchor](https://github.com/ZhFahim/anchor) that adds a full Russian translation
>
> The web client, the API messages and the Android app are translated end to end.
> Upstream is English-only and did not take the translation, so it lives here.
> Everything else — features, data model, sync protocol — is upstream code.
>
> **Русская версия Anchor** — заметки и задачи на своём сервере, с полностью
> переведённым интерфейсом: веб, сообщения сервера и Android-приложение.
> Как поставить и что переведено — см. [README.ru.md](README.ru.md).

Anchor focuses on speed, privacy, simplicity, and reliability across mobile and web. Notes are stored locally, editable offline, and synced across devices when online.

## Differences from upstream

| Change | Why |
| --- | --- |
| **Russian localization** of web, server and mobile | The point of this fork — see [Localization](#localization) |
| i18n asset path fix in the server build (`outDir: dist/src`) | Without it `nestjs-i18n` finds no catalogs inside the image and returns raw keys like `auth.invalidCredentials` |
| Optional `ALPINE_MIRROR` build argument | `dl-cdn.alpinelinux.org` is unreachable from some networks and `apk add` kills the build |
| Download link for the Android APK on the login page | Shown only when an APK is mounted into `web/public/apk` |

That is the whole diff: five commits on top of upstream `v0.16.0`. There are no
feature changes, no schema changes and no telemetry.

Bugs in Anchor itself belong [upstream](https://github.com/ZhFahim/anchor/issues).
Translation problems belong [here](https://github.com/Afinogen/anchor/issues).

## Features

- **Localization** - Full English and Russian UI, server messages and mobile app *(fork only)*
- **Rich Text Editor** - Create and edit notes with powerful formatting (bold, italic, underline, headings, lists, checkboxes)
- **Offline First** - All edits work offline with local database
- **Note Sharing** - Share notes with other users (viewer or editor)
- **Note History** - Read earlier versions of a note and put one back
- **Tags System** - Organize notes with custom tags and colors
- **Attachments** - Attach images and audio to notes
- **Note Backgrounds** - Customize notes with solid colors and patterns
- **Pin Notes** - Pin important notes for quick access
- **Archive Notes** - Archive notes for later reference
- **Search** - Search notes locally by title or content
- **Trash** - Soft delete notes with recovery period
- **Automatic Sync** - Sync changes across devices when online
- **Import & Export** - Export your full library, and import it back or bring notes in from Google Keep
- **Home Screen Widget** - Quick access to your notes from the Android home screen
- **Admin Panel** - User management, registration control, and system statistics
- **OIDC Authentication** - Sign in with OpenID Connect providers (Pocket ID, Authelia, Keycloak, etc.)

## Localization

| Platform | Languages | How the language is chosen |
| --- | --- | --- |
| Web | English, Русский | Browser language on first run, then **Settings → Language**; the choice is stored per browser |
| Server (errors, e-mails, API messages) | English, Русский | `?lang=ru`, header `X-Lang: ru`, or `Accept-Language`; falls back to English |
| Android app | English, Русский | Device locale, or the EN/RU button on the login and server-setup screens |

Where the strings live:

- **web** — `web/lib/i18n/locales/{en,ru}.ts`, hook `useTranslation()`.
  The `TranslationKey` type is derived from the English dictionary, so a missing
  key is a **build error**, not a blank label at runtime.
- **server** — `nestjs-i18n`, JSON per namespace in `server/src/i18n/{en,ru}/`
  (`auth`, `notes`, `tags`, `admin`, `import`, `oidc`, `settings`).
- **mobile** — Flutter `gen-l10n`, ARB files `mobile/lib/l10n/app_{en,ru}.arb`,
  accessed as `context.l10n.<key>`.

Adding a language: copy the `en` catalog in all three places, register the locale
in `web/lib/i18n/config.ts` and in `mobile/lib/l10n/`, then run
`cd web && pnpm build` — the build will list every key you missed.

Pure helper functions take the locale as an **optional** parameter with an English
fallback, so upstream tests keep passing unchanged and merges stay small.

**Not translated yet:** the attachment upload zone in the web client
(`web/features/notes/components/attachments/attachment-upload-zone.tsx`).

## Screenshots

Screenshots are upstream's and show the English UI; the layout is identical in Russian.

### Web App

<div align="center">
  <img src="https://raw.githubusercontent.com/zhfahim/anchor/main/.github/assets/screenshot-web-light.png" alt="Web Light Mode" width="45%">
  <img src="https://raw.githubusercontent.com/zhfahim/anchor/main/.github/assets/screenshot-web-dark.png" alt="Web Dark Mode" width="45%">
</div>

### Mobile App

<div align="center">
  <img src="https://raw.githubusercontent.com/zhfahim/anchor/main/.github/assets/screenshot-mobile-light.jpg" alt="Mobile Light Mode" width="20%">
  <img src="https://raw.githubusercontent.com/zhfahim/anchor/main/.github/assets/screenshot-mobile-dark.jpg" alt="Mobile Dark Mode" width="20%">
</div>

## Self Hosting With Docker

> There is no pre-built image for this fork. `ghcr.io/zhfahim/anchor` is the
> upstream image and it is **English-only** — build from this branch instead.

1. **Clone this fork and build:**

   ```bash
   git clone -b i18n https://github.com/Afinogen/anchor.git
   cd anchor
   docker compose up -d
   ```

   `docker-compose.yml` builds the image from source and starts it on port 3000
   with an embedded PostgreSQL in the `anchor_data` volume.

2. **If `apk add` fails during the build**, your network cannot reach the Alpine
   CDN. Pass a mirror:

   ```bash
   docker build --build-arg ALPINE_MIRROR=https://mirror.yandex.ru/mirrors/alpine \
     -t anchor:0.16.0-i18n .
   ```

3. **Access the app:**
   Open http://localhost:3000

4. **(Optional) Configure environment:**
   Add environment variables to the `environment` section of the compose file.
   Most users can skip this step — defaults work out of the box.

   | Variable | Required | Default | Description |
   |----------|----------|---------|-------------|
   | `APP_URL` | No | `http://localhost:3000` | Base URL where Anchor is served |
   | `JWT_SECRET` | No | (auto-generated) | Auth token secret. Min 16 characters when set |
   | `DATA_DIR` | No | `/data` | Root directory for persisted uploads |
   | `CORS_ORIGINS` | No | (allow all) | Comma-separated allowlist of CORS origins |
   | `PG_HOST` | No | (empty) | External Postgres host (leave empty for embedded) |
   | `PG_PORT` | No | `5432` | Postgres port |
   | `PG_USER` | No | `anchor` | Postgres username |
   | `PG_PASSWORD` | No | `password` | Postgres password |
   | `PG_DATABASE` | No | `anchor` | Database name |
   | `USER_SIGNUP` | No | (not set) | Sign up mode: `disabled`, `enabled`, or `review`. If not set, admins can control it via the admin panel |
   | `OIDC_ENABLED` | No | — | Enable OIDC authentication |
   | `OIDC_PROVIDER_NAME` | No | `"OIDC Provider"` | Display name for the login button |
   | `OIDC_ISSUER_URL` | When OIDC enabled | — | Base URL of your OIDC provider |
   | `OIDC_CLIENT_ID` | When OIDC enabled | — | OIDC client ID |
   | `OIDC_CLIENT_SECRET` | No | — | OIDC client secret. Omit for public client (PKCE) |
   | `DISABLE_INTERNAL_AUTH` | No | `false` | Hide local login form when OIDC is enabled (OIDC-only mode) |

### Verifying the translation

Localization only breaks in the built image, never in dev mode — check it there:

```bash
curl -H "Accept-Language: ru" http://localhost:3000/api/... # expect Russian text, not keys like auth.invalidCredentials
```

## Mobile App

Upstream [releases](https://github.com/ZhFahim/anchor/releases) ship the English
app. For the Russian one, build it from this branch:

```bash
cd mobile
flutter build apk --release            # or --split-per-abi for smaller files
```

Drop the result into `web/public/apk/` (mount it into the container as
`/app/web/public/apk`) and the login page shows a download link for
`anchor-arm64-v8a.apk` automatically.

> **The app and the server must be updated together.** Since 0.16 they have to
> agree on `X-Anchor-Protocol` (currently `3`); a mismatch is answered with
> HTTP 426 and sync stops.

## OIDC Authentication

Anchor supports OpenID Connect (OIDC) authentication for simplified credential management and streamlined multi-user deployments.

### Features

- Support for standard OIDC providers (Pocket ID, Authelia, Authentik, Keycloak, etc.)
- Configuration via environment variables or admin settings UI
- OIDC only mode: disable local username/password login
- Support for public OIDC clients (PKCE, no client secret required)
- Auto create users on first login (if user signup is not disabled)
- Auto link existing users by email

### Configuration

#### Mobile app and Public client

If you want to use OIDC in the mobile app, configure Anchor as a **Public client** (PKCE, no client secret) in your OIDC provider. Add this redirect URI in your OIDC provider:

```
anchor://oidc/callback
```

#### Required Callback URL (Web)

When configuring your OIDC provider for web login, add this callback/redirect URL:

```
{APP_URL}/api/auth/oidc/callback
```

For example, if your Anchor instance is at `https://notes.example.com`, the callback URL would be:

```
https://notes.example.com/api/auth/oidc/callback
```

#### Environment Variables

Configure OIDC via environment variables in your `docker-compose.yml`. Pocket ID example:

```yaml
services:
  anchor:
    build: .
    environment:
      - OIDC_ENABLED=true
      - OIDC_PROVIDER_NAME=Pocket ID
      - OIDC_ISSUER_URL=https://pocketid.example.com
      - OIDC_CLIENT_ID=your-client-id
      - OIDC_CLIENT_SECRET=your-client-secret # Optional for public clients
      - DISABLE_INTERNAL_AUTH=false
      - APP_URL=https://notes.example.com
```

#### Admin UI Configuration

Alternatively, configure OIDC via the admin panel (Settings → OIDC Authentication) when the three env vars are not all set.

## Troubleshooting & Collecting Logs

Anchor never collects any data. When you need to report a bug, you can collect logs yourself and share them with the maintainer.

**Mobile app**

1. Reproduce the issue.
2. Open Settings → View Logs.
3. Tap the **Export** button at the bottom, then share the saved `.log` file in your bug report.

> Sensitive values are stripped before anything is written to the log file. This includes authorization headers, passwords, tokens, refresh tokens, secrets, and email addresses, which are always replaced with `***`.

Logs are stored locally on the device only (rolling, ~2 MB max).

## Keeping up with upstream

The fork tracks upstream by **merge**, not rebase, so history stays usable:

```bash
git fetch upstream && git merge upstream/main
```

Then run everything before pushing: `flutter analyze` and `flutter test` in
`mobile/`, `pnpm build && pnpm test` in `server/`, and `pnpm exec tsc --noEmit`,
`pnpm test --run`, `pnpm build` in `web/`. Finally grep for `t(` calls that a
conflict may have resolved in upstream's favour.

## Roadmap

Upstream's planned features:

- Reminders and notifications
- Real-time collaboration

## Tech Stack

- **Backend**: Nest.js, PostgreSQL, Prisma
- **Mobile**: Flutter
- **Web**: Next.js, TypeScript

## Contributing

New languages and fixes to existing translations are welcome here; everything else
is better sent upstream, where it benefits all users.

1. Fork the repository
2. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature
   ```
3. Make your changes
4. Ensure builds pass and code is linted:
   - Web: `cd web && pnpm build && pnpm check`
   - Server: `cd server && pnpm build && pnpm check`
5. Commit changes:
   ```bash
   git commit -m "Describe your change"
   ```
6. Push and create a Pull Request

### Code style

Linting and formatting are enforced in CI and by a pre-commit hook
(`.githooks/pre-commit`) that checks staged files.
Running `pnpm install` in either `web` or `server`
enables the hook automatically (via the `prepare` script). To enable it manually:

```bash
git config core.hooksPath .githooks
```

Before committing, fix issues with `pnpm check:fix` in the relevant project.

## Support

Anchor is written by [ZhFahim](https://github.com/ZhFahim). If you find it useful,
support the original author:

[<img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy me a coffee" height="60">](https://www.buymeacoffee.com/zahid)

## License

This project is licensed under the GNU Affero General Public License v3.0 (AGPL v3) - see the [LICENSE](LICENSE) file for details.
