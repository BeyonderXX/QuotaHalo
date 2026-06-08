# No-Terminal User Flow

This document describes the intended non-developer flow.

## Install

1. Download the latest [`QuotaHalo.app.zip`](https://github.com/BeyonderXX/QuotaHalo/releases/latest/download/QuotaHalo.app.zip) from GitHub Releases.
2. Unzip it.
3. Drag `QuotaHalo.app` to `Applications`.
4. Double-click it.

No Terminal command is required.

Stable download URL:

```text
https://github.com/BeyonderXX/QuotaHalo/releases/latest/download/QuotaHalo.app.zip
```

Do not use `untagged-*` release asset URLs. They are temporary GitHub asset paths, not public download addresses.

## Login

The widget does not implement its own OpenAI login. It opens the official Codex login flow instead.

1. Click the menu bar icon.
2. Choose `Setup...`.
3. Click `Open Codex App` if Codex is already installed.
4. Click `Start Codex Login` if the quota cannot be read yet.
5. Finish the official Codex login flow.
6. Return to the widget and click `Refresh Quota`.

`Start Codex Login` opens Terminal to run `codex login` for the user. Users do not need to type the command themselves, and this app still never stores tokens.

## Maintainer Checklist

To make the no-terminal flow smooth for users:

- Publish `QuotaHalo.app.zip` in GitHub Releases.
- Sign and notarize the app before publishing.
- Include screenshots in the release notes.
- Link to `README.md`, `README.zh-CN.md`, and `docs/AUTHENTICATION.md`.
