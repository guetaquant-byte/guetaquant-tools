# Repository Overview

**guetaquant-tools** — open-source quantitative trading tools by Gueta Quant: **44 tool files across 3 platforms** (MQL4/MQL5, Pine Script v6, cTrader C#), plus bilingual documentation and a verifiable privacy audit.

## What's in the repo

| Platform | Files | Tools |
|---|---|---|
| `mql/` | 22 (11 × MQL4 + MQL5) | Position Sizer, SuperTrend, MACD Trader, Bollinger Reversion, Trend Follow, RSI Pro, ATR Stop Loss, Market Structure, Ichimoku, Support & Resistance, Volume Profile |
| `pinescript/` | 11 | Volume Profile, SuperTrend, VWAP Standard, Anchored VWAP, RSI Pro, MACD Pro, Bollinger Bands, Market Structure, Order Flow CVD, Support & Resistance, MTF Trend Matrix |
| `ctrader/` | 11 | Position Sizer, Trend Follower, Breakout ORB, Grid Scalper, Mean Reversion, Divergence Scanner, Trailing Stop Manager, DCA Recovery, Session Scalper, Multi-Symbol Scanner, Risk Manager |
| `docs/` | 2 | `ZERO_KNOWLEDGE_PRIVACY_AUDIT.md`, `QA_STANDARD.md` |

## Philosophy

**Statistics + Code + Risk + Simulation.** Education-first, retail-appropriate: tools are honest about what they do and don't do (e.g., Market Structure = price-action heuristics on swings, **not** institutional order-flow; Volume Profile = volume distribution heuristics, **not** FX order-book data).

## Repo status (2026-08-09)

- ✅ **All 22 MQL files compile-clean gate** (MQL4 files free of MQL5-only API — enforced by CI parity script)
- ✅ **CI**: `compile-mql.yml` (Windows + MetaEditor) + `static-checks.yml` (parity + README claims gates)
- 🧪 **Golden-value tests**: planned (`tests/golden/`)
- 📜 **License**: AGPLv3
- 🔒 **Privacy**: local-first journal, zero external requests in core (see [Privacy & Security](Privacy-and-Security))

## Repository layout

```
guetaquant-tools/
├── mql/            # MQL4 + MQL5 (11 tools, paired .mq4/.mq5)
├── pinescript/     # Pine Script v6 (.pb)
├── ctrader/        # cTrader C# (.cs)
├── docs/           # QA_STANDARD.md, ZERO_KNOWLEDGE_PRIVACY_AUDIT.md
├── scripts/        # check_mql_parity.py, check_readme_claims.py
├── .github/        # workflows + issue templates
├── SECURITY.md     # disclosure policy
├── CONTRIBUTING.md
└── LICENSE         # AGPLv3
```

## Status per tool

See the per-platform pages ([MQL4/MQL5](MQL4-MQL5-Tools), [Pine Script v6](Pine-Script-v6-Tools), [cTrader](cTrader-Tools)) for per-tool verification cards: compiles ✓ / golden-tested / repaint-documented / beta.
