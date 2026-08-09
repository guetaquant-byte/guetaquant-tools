# Security Disclosure Policy — Gueta Quant

*Last updated: 2026-08-09*

## Reporting a vulnerability

We take the security of our users' trading data seriously. If you believe you have found a security vulnerability in any Gueta Quant product (website, Trading Journal, open-source tools), please report it privately:

- **Email:** `security@guetaquant.com`
- **GitHub:** Use the repository's **Private Vulnerability Reporting** feature (Security → Report a vulnerability) on `guetaquant-byte/guetaquant-tools` or `guetaquant-byte/guetaquant-portal`.
- **PGP encryption:** Request our key via email before sending sensitive details (or use the GitHub private channel, which is end-to-end encrypted).

## Our commitments (SLA)

| Severity | Initial response | Fix target |
|---|---|---|
| Critical | 24h | 72h |
| High | 48h | 7 days |
| Medium | 72h | 14 days |
| Low | 7 days | 30 days |

## Scope

- `guetaquant.com` (all routes, including `/journal/app/`)
- `guetaquant-byte/guetaquant-tools` (MQL4/5, Pine v6, cTrader C#)
- The Trading Journal SPA (local storage, IndexedDB encryption, AI payload handling)

## Out of scope (known and accepted)

- The **AI layer is opt-in and cloud-based by design**: when the user clicks Analyze/Chat, trade data is sent to Google Gemini via `guetaquant.com/api/*`. This is disclosed in the UI and in our privacy documentation; it is not a vulnerability.
- Standard phishing/social engineering against non-guetaquant.com domains.
- Rate-limit abuse of public endpoints (report only if it leads to data exposure).

## Our stance (no-scam, no-exfiltration)

We will never include hidden telemetry, data-selling, or undisclosed data collection in our core journal (it is local-first and verifiable — see [ZERO_KNOWLEDGE_PRIVACY_AUDIT.md](https://github.com/guetaquant-byte/guetaquant-tools/blob/main/docs/ZERO_KNOWLEDGE_PRIVACY_AUDIT.md)). If you find code that contradicts this, it is a Critical vulnerability — report it.

## Acknowledgments

We will publicly thank valid reporters (with permission) in the repository CHANGELOG and on guetaquant.com/security.
