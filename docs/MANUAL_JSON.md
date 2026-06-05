# Manual JSON Fallback

QuotaHalo normally reads quota data from the local Codex app-server. If Codex is unavailable, not logged in, or changes its app-server protocol, the widget can read a local fallback file instead.

Open the fallback file from the app menu:

```text
Open Manual JSON
```

Fallback path:

```text
~/Library/Application Support/QuotaHalo/usage.json
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

The manual file is only a fallback. It does not log in to Codex and it does not change your real quota.
