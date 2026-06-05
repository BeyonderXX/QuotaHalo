# Contributing

Thanks for helping improve QuotaHalo.

## Local Setup

See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) for the full development workflow.

## Pull Requests

Please keep changes focused. Good PRs include:

- A short description of the user-visible behavior
- Screenshots or preview images for UI changes
- Notes about macOS and Codex versions tested
- Any known limitations

## UI Guidelines

- Keep the widget compact and glanceable.
- Prefer system symbols over custom assets.
- Keep English as the default language.
- Add Simplified Chinese text for new visible strings.
- Avoid adding dependencies unless they remove meaningful complexity.

## Authentication Guidelines

Do not add code that reads, stores, logs, or transmits OpenAI/Codex credentials. The app should continue delegating authentication to the official Codex CLI/app-server.
