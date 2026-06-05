# Development

This guide is for developers who want to run, debug, build, or package QuotaHalo from source.

For normal installation, use the root [README.md](../README.md).

## Requirements

- macOS 13 or later.
- Swift 5.9 or later.
- Codex installed locally.
- Codex logged in with ChatGPT auth.

## Clone

```bash
git clone https://github.com/BeyonderXX/QuotaHalo.git
cd QuotaHalo
```

## Check Codex

```bash
command -v codex
codex login status
```

If Codex is not logged in:

```bash
codex login
```

## Run From Source

```bash
swift run QuotaHalo
```

Print the normalized quota snapshot:

```bash
swift run QuotaHalo --print-quota
```

Generate a preview image:

```bash
swift run QuotaHalo --render-preview /tmp/quota-halo-preview.png --language en
swift run QuotaHalo --render-preview /tmp/quota-halo-preview-zh.png --language zh-Hans
```

## Build

Build the Swift package:

```bash
swift build
```

Build a `.app` bundle:

```bash
scripts/build-app.sh
```

The bundle is created at:

```text
dist/QuotaHalo.app
```

Open the built app:

```bash
open dist/QuotaHalo.app
```

## Package A Release

```bash
scripts/package-release.sh
```

The release zip is created at:

```text
dist/QuotaHalo.app.zip
```

Upload that file to GitHub Releases with the asset name:

```text
QuotaHalo.app.zip
```

## Optional Login Item

Install QuotaHalo as a login item:

```bash
scripts/install-launch-agent.sh
```

## Build Cache

The build script keeps SwiftPM and clang caches inside `.build/` to avoid writing to user cache directories in restricted environments.

## Notes

- The Codex app-server protocol is local and may change across Codex releases.
- If quota reading fails, the widget falls back to manual JSON rather than failing open.
- `--print-quota` prints the normalized quota model only. It does not print access tokens, refresh tokens, API keys, cookies, or credential file contents.
