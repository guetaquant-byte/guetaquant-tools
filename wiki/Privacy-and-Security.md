# Privacy & Security

Gueta Quant's Trading Journal is **local-first by design**, and the open-source repo exists to make that verifiable.

## Core claims (and how to verify them)

| Claim | How to verify (5 minutes) |
|---|---|
| Journal core makes **zero external network requests** | DevTools → Network while logging trades: only same-origin requests; `performance.getEntriesByType('resource')` shows no third-party hosts |
| Trade data stored locally, encrypted | DevTools → Application → IndexedDB: `gueta_trades_vault` is AES-256-GCM ciphertext; key never leaves the device |
| Journal works fully offline | Airplane mode test: core journaling/metrics/export work 100% |
| AI is **opt-in only** | Nothing is sent until you click Analyze/Chat; UI shows consent + payload preview + "IA: Nube (opt-in)" badge; Local-Only Mode blocks all AI calls |

Full protocol: `docs/audit-protocol.md` (portal) + `docs/ZERO_KNOWLEDGE_PRIVACY_AUDIT.md` (this repo).

## Network manifest

`public/network-manifest.json` (portal) lists every allowed network origin — currently only `guetaquant.com` + the documented API paths (`/api/insights`, `/api/chat`, `/api/verify-pro`). The service worker enforces this for the journal scope: any third-party request from `/journal/*` is blocked and logged.

## AI layer (explicit, honest scope)

- The **core journal is 100% local**. "Zero data leaves your device" = **true for the core**.
- **AI Analyzer / AI Companion are opt-in cloud**: on your click, a subset of trade history (symbol, type, entry/exit, P&L, notes) is sent to **Google Gemini** via `guetaquant.com/api/*`.
- This is disclosed in the UI (consent banner + payload preview), on the site ([privacidad-ia](https://guetaquant.com/privacidad-ia/)), and in this repo.
- "The AI never sees your data" would be **false by design** — we never claim it.

## Security artifacts

| Artifact | Location |
|---|---|
| Threat model (STRIDE-lite) | `docs/THREAT_MODEL.md` (portal) |
| Vulnerability disclosure (SLA) | `SECURITY.md` (repo) + `security.txt` (site) |
| SBOM (CycloneDX, ECMA-424) | generated via `scripts/generate_sbom.mjs` (portal) |
| Zero-knowledge audit protocol | `docs/ZERO_KNOWLEDGE_PRIVACY_AUDIT.md` (repo) |

## Compliance

- **Colombia:** Ley 1581 de 2012 (habeas data, SIC) — consent, rights, RNBD registration; Ley 1480 de 2011 — truthful advertising.
- **EU (if applicable):** GDPR consent basis, DPIA for AI processing, SCCs for Google transfer.
- Report issues: `security@guetaquant.com` — Critical 24h/72h, High 48h/7d, Medium 72h/14d, Low 7d/30d.
