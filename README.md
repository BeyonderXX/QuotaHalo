# QuotaHalo

![macOS](https://img.shields.io/badge/macOS-13%2B-black)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-blue)
![Codex](https://img.shields.io/badge/Codex-usage%20widget-00d4ff)

**QuotaHalo is a glassy macOS desktop widget for tracking Codex usage limits at a glance.**

It shows your **5-hour** and **weekly** Codex quota windows, including remaining percentage and reset time, without asking for API keys or storing OpenAI tokens.

[Download QuotaHalo.app.zip](https://github.com/BeyonderXX/QuotaHalo/releases/latest/download/QuotaHalo.app.zip) · [中文说明](README.zh-CN.md) · [Authentication](docs/AUTHENTICATION.md)

Keywords: `Codex usage`, `Codex quota`, `macOS widget`, `desktop widget`, `glass widget`, `ChatGPT Codex`, `OpenAI Codex`

## Preview

| English | Simplified Chinese |
| --- | --- |
| ![English preview](assets/preview-en.png) | ![Chinese preview](assets/preview-zh-Hans.png) |

## Install

1. Download [`QuotaHalo.app.zip`](https://github.com/BeyonderXX/QuotaHalo/releases/latest/download/QuotaHalo.app.zip).
2. Unzip it.
3. Drag `QuotaHalo.app` to `Applications`.
4. Double-click `QuotaHalo.app`.

If macOS blocks the first launch because the app is unsigned, right-click the app and choose `Open`.

If macOS says the app is damaged, the downloaded build was not signed and notarized for public distribution. See [docs/DISTRIBUTION.md](docs/DISTRIBUTION.md).

## Login

QuotaHalo uses your local Codex login. No API key is needed.

1. Open the QuotaHalo menu bar item.
2. Choose `Setup...`.
3. Click `Open Codex App` or `Start Codex Login`.
4. Finish the official Codex login flow.
5. Click `Refresh Quota`.

`Start Codex Login` may open a small Terminal window to run the official `codex login` command for you. You do not need to type commands manually.

## What It Shows

- 5-hour Codex quota remaining.
- 5-hour quota reset time.
- Weekly Codex quota remaining.
- Weekly quota reset time.
- Compact transparent glass widget on the macOS desktop.
- English and Simplified Chinese UI.

## Privacy

QuotaHalo is intentionally small:

- It does not ask for an OpenAI API key.
- It does not read, store, print, or upload OpenAI/Codex credentials.
- It starts the local `codex app-server --stdio` process and reads a quota snapshot from `account/rateLimits/read`.

Read [docs/AUTHENTICATION.md](docs/AUTHENTICATION.md) for the full authentication model.

> Unofficial project. Not affiliated with OpenAI.

## More Docs

- [No-terminal user flow](docs/NO_TERMINAL.md)
- [Authentication](docs/AUTHENTICATION.md)
- [Distribution and notarization](docs/DISTRIBUTION.md)
- [Manual JSON fallback](docs/MANUAL_JSON.md)
- [Developer guide](docs/DEVELOPMENT.md)
- [Icon guide](docs/ICON_GUIDE.md)
- [Repository discovery checklist](docs/REPO_DISCOVERY.md)

## Requirements

- macOS 13 or later.
- Codex installed locally.
- Codex logged in with ChatGPT auth.

## Language

Default language: English.

Use the menu bar item:

```text
Language -> English / 中文
```

## License

MIT. See [LICENSE](LICENSE).
