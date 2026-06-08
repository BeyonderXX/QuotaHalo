# Repository Discovery Checklist

Use this checklist to make QuotaHalo easier to find and easier to understand.

## GitHub Repository Settings

Set the repository description:

```text
Glassy macOS desktop widget for tracking Codex 5-hour and weekly usage limits.
```

Add repository topics:

```text
codex
openai-codex
chatgpt
macos
swift
swiftui
desktop-widget
menu-bar
quota
usage-limits
glassmorphism
```

Add a website link:

```text
https://github.com/BeyonderXX/QuotaHalo/releases/latest/download/QuotaHalo.app.zip
```

Use this stable latest-release URL instead of any `untagged-*` asset URL.

Upload a social preview image:

```text
assets/preview-en.png
```

## Release Settings

Use semantic versions:

```text
v0.1.0
v0.1.1
v0.2.0
```

Use a clear release title:

```text
QuotaHalo v0.1.0
```

Attach this asset:

```text
QuotaHalo.app.zip
```

Before uploading the asset, sign and notarize it. See [docs/DISTRIBUTION.md](DISTRIBUTION.md).

## README First Screen

The first screen should answer:

- What is it?
- Who is it for?
- What does it show?
- Can I download it now?
- Is it safe with my OpenAI/Codex credentials?

## Search Phrases To Include Naturally

- Codex usage widget
- Codex quota widget
- macOS desktop widget
- ChatGPT Codex usage limits
- OpenAI Codex quota
- 5-hour Codex limit
- weekly Codex limit

Avoid keyword stuffing. Put these phrases in headings, intro copy, release notes, and issue labels when they are natural.

## Fast Comprehension

For people landing from search, keep these visible near the top:

- Product screenshot
- One-line value proposition
- Download link
- 5-hour quota
- Weekly quota
- No token storage
- English/Chinese support

Keep developer setup, build commands, release packaging, icon details, and fallback JSON examples in `docs/` so the root README stays focused on first-time users.
