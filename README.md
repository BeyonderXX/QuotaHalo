# QuotaHalo

![macOS](https://img.shields.io/badge/macOS-13%2B-black)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-blue)
![Codex](https://img.shields.io/badge/Codex-usage%20widget-00d4ff)

**QuotaHalo is a glassy macOS desktop widget for tracking Codex usage limits at a glance.**

It shows your **5-hour** and **weekly** Codex quota windows, including remaining percentage and reset time, without asking for API keys or storing OpenAI tokens.

[Download QuotaHalo.app.zip](https://github.com/BeyonderXX/QuotaHalo/releases/latest/download/QuotaHalo.app.zip) · [中文说明](README.zh-CN.md) · [Authentication model](docs/AUTHENTICATION.md)

Keywords: `Codex usage`, `Codex quota`, `macOS widget`, `desktop widget`, `glass widget`, `ChatGPT Codex`, `OpenAI Codex`

## Preview

| English | Simplified Chinese |
| --- | --- |
| ![English preview](assets/preview-en.png) | ![Chinese preview](assets/preview-zh-Hans.png) |

## What It Does

- Shows 5-hour Codex quota remaining and reset time.
- Shows weekly Codex quota remaining and reset time.
- Runs as a compact transparent glass widget on the macOS desktop.
- Supports English and Simplified Chinese.
- Uses the official local Codex login/app-server flow.
- Does not ask for, store, print, or upload OpenAI credentials.

The widget reads the two Codex quota windows exposed by the local Codex app-server:

- 5-hour remaining quota and reset time
- Weekly remaining quota and reset time

The app is intentionally small: no account database, no token storage, no network client of its own. It starts the installed `codex` executable locally and asks its app-server for `account/rateLimits/read`.

> Unofficial project. Not affiliated with OpenAI.

Generate a preview image locally:

```bash
swift run QuotaHalo --render-preview /tmp/codex-quota-preview.png --language en
```

## Icon Guide

| Icon | English UI | 中文 UI | Meaning |
| --- | --- | --- | --- |
| `sparkles` | Codex | Codex | Product/app identity |
| `clock.fill` | Every 5h | 每 5 小时 | The 5-hour Codex quota window |
| `calendar` | Weekly | 每周 | The weekly Codex quota window |
| `bolt.fill` | Status ring | 状态环 | Fast quota/status signal |
| `checkmark.seal.fill` | Codex app-server | Codex app-server | Quota was read successfully |

## Requirements

- macOS 13 or later
- Codex installed locally
- Codex logged in with ChatGPT auth

Command Line Tools or Xcode are only required when building from source.

## No-Terminal Install

For normal users, the intended flow is:

1. Download [`QuotaHalo.app.zip`](https://github.com/BeyonderXX/QuotaHalo/releases/latest/download/QuotaHalo.app.zip) from GitHub Releases.
2. Unzip it.
3. Drag `QuotaHalo.app` to `Applications`.
4. Double-click the app.
5. Use the menu bar item `Setup...` if Codex is not installed or not logged in.

No Terminal commands are required for this release-install path.

If macOS blocks the first launch because the app is unsigned, right-click the app and choose `Open`. For public releases, maintainers should notarize the app to avoid this extra step.

## No-Terminal Login

The app still uses the official Codex login, but users do not need to type commands manually:

1. Open the menu bar item.
2. Choose `Setup...`.
3. Click `Open Codex App` or `Start Codex Login`.
4. Finish the official Codex login flow.
5. Click `Refresh Quota`.

`Start Codex Login` opens a small Terminal window that runs the official `codex login` command for the user. This app never asks for, stores, or prints tokens.

Check Codex login:

```bash
codex login status
```

If you are not logged in:

```bash
codex login
```

ChatGPT login is recommended for quota reading. API-key-only logins may not expose ChatGPT/Codex account rate limits.

## Step-by-Step

### For Release Users

1. Download [`QuotaHalo.app.zip`](https://github.com/BeyonderXX/QuotaHalo/releases/latest/download/QuotaHalo.app.zip) from Releases.
2. Drag the app to `Applications`.
3. Double-click it.
4. Open `Setup...` from the menu bar if the widget says it cannot read quota.

### For Developers

1. Clone the project:

```bash
git clone https://github.com/BeyonderXX/QuotaHalo.git
cd QuotaHalo
```

2. Verify Codex is installed and logged in:

```bash
command -v codex
codex login status
```

3. Run from source:

```bash
swift run QuotaHalo
```

4. Print the raw normalized quota snapshot:

```bash
swift run QuotaHalo --print-quota
```

5. Build a `.app` bundle:

```bash
scripts/build-app.sh
```

The bundle is created at:

```text
dist/QuotaHalo.app
```

6. Open the app:

```bash
open dist/QuotaHalo.app
```

7. Optional: install as a login item:

```bash
scripts/install-launch-agent.sh
```

## Authentication

This app does not implement OpenAI authentication directly.

Instead, it relies on the official local Codex installation:

1. You log in with `codex login`.
2. Codex stores credentials in its own supported location.
3. QuotaHalo starts `codex app-server --stdio`.
4. The app-server returns a redacted quota snapshot through `account/rateLimits/read`.

See [docs/AUTHENTICATION.md](docs/AUTHENTICATION.md) for details.

## Language

Default language: English.

Supported UI languages:

- English
- Simplified Chinese

Use the menu bar item:

```text
Language -> English / 中文
```

The selection is stored in macOS `UserDefaults`.

## Manual Fallback JSON

If Codex is not logged in, unavailable, or changes its app-server protocol, the widget can read:

```text
~/Library/Application Support/QuotaHalo/usage.json
```

Open it from the menu:

```text
Open Manual JSON
```

Example:

```json
{
  "fiveHour": {
    "remainingPercent": 72,
    "resetAt": "2026-06-06T00:00:00+08:00"
  },
  "weekly": {
    "remainingPercent": 91,
    "resetAt": "2026-06-11T09:00:00+08:00"
  },
  "limitName": "Codex",
  "planType": "pro",
  "source": "manual usage.json"
}
```

## Development

Build:

```bash
swift build
```

Run:

```bash
swift run QuotaHalo
```

Release bundle:

```bash
scripts/build-app.sh
```

Release zip for GitHub Releases:

```bash
scripts/package-release.sh
```

The build script keeps SwiftPM and clang caches inside `.build/` to avoid writing to user cache directories in restricted environments.

## Notes

- The Codex app-server protocol is local and may change across Codex releases.
- If quota reading fails, the widget falls back to manual JSON rather than failing open.
- No secrets are printed by `--print-quota`; it only emits the normalized quota model.

## License

MIT. See [LICENSE](LICENSE).
