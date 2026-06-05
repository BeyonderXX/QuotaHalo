# Security Policy

## Reporting

If you find a security issue, please open a private security advisory on GitHub if available, or contact the maintainer privately before public disclosure.

## Credential Handling

QuotaHalo should never:

- Ask for OpenAI API keys
- Store OpenAI or Codex tokens
- Print credentials
- Upload quota data or account metadata to third-party services

Authentication is delegated to the local Codex installation.
