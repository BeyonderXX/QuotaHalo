# Authentication

QuotaHalo does not authenticate with OpenAI directly.

The app delegates authentication to the official local Codex installation. This keeps the widget small and avoids storing user secrets.

## How It Works

1. The user signs in with Codex:

```bash
codex login
```

2. Codex stores credentials in its own supported credential store.

3. QuotaHalo starts:

```bash
codex app-server --stdio
```

4. The widget sends two local JSON-RPC messages:

```json
{ "id": 1, "method": "initialize", "params": { "...": "..." } }
```

```json
{ "id": 2, "method": "account/rateLimits/read" }
```

5. The Codex app-server returns a quota snapshot containing fields such as:

```text
primary.usedPercent
primary.windowDurationMins
primary.resetsAt
secondary.usedPercent
secondary.windowDurationMins
secondary.resetsAt
planType
```

For Codex, `primary.windowDurationMins = 300` is the 5-hour window, and `secondary.windowDurationMins = 10080` is the weekly window.

## What This App Does Not Do

- It does not ask for an OpenAI API key.
- It does not read or print Codex tokens.
- It does not write credentials.
- It does not implement a separate OpenAI OAuth or ChatGPT login flow.
- It does not send quota data to a third-party service.

## Login Modes

Use ChatGPT login when possible:

```bash
codex login
```

API-key-only login may be useful for API workflows, but it may not expose ChatGPT/Codex account rate limits through `account/rateLimits/read`.

## Failure Modes

Quota reading can fail when:

- Codex is not installed.
- Codex is not logged in.
- The local Codex app-server protocol changes.
- Network access required by Codex is unavailable.
- Account rate limits are not exposed for the current login mode.

When this happens, the widget falls back to manual JSON:

```text
~/Library/Application Support/QuotaHalo/usage.json
```

## Privacy

`--print-quota` prints the normalized quota model only. It does not print access tokens, refresh tokens, API keys, cookies, or credential file contents.
