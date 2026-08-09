# Roadmap

*Status: 2026-08-09 · After the audit-driven hardening pass. Kill criteria are stated up front — if a gate fails, we ship the smaller honest thing.*

## Wave 1 — Fix & verify (weeks 1–4) ✅ mostly done

| Item | Status |
|---|---|
| MQL4 compile fixes (6 files, MQL5-only API removed) | ✅ shipped |
| Volume Profile binning mirror fix (POC/VAH/VAL correct) | ✅ shipped |
| Divergence dead-code fixes (CVD/MACD/RSI var-tracked pivots) | ✅ shipped |
| cTrader critical fixes (DCA flood, trailing drain, grid guard, Supertrend API, Thickness) | ✅ shipped |
| CI: compile-mql (Windows) + static-checks (parity + claims) | ✅ shipped — **verify first Windows run on GitHub** |
| README truth-alignment (tool status, magic numbers, no unbacked claims) | ✅ shipped |
| Golden-value test framework (`tests/golden/`, Python reference impl) | ⏳ planned |
| Per-tool verification cards in READMEs | ⏳ planned |

**Kill criterion:** if >6 of 44 tools can't pass compile+golden gates in 4 weeks → ship 4 flagships as "verified", label the rest "beta/educational" honestly.

## Wave 2 — Proof & trust (weeks 5–8)

- Golden-value tests for the 4 flagship tools (Volume Profile, Position Sizer, Market Structure, Order Flow CVD)
- "No-Repaint & QA Standard" published as site article + per-tool cards
- Publish walk-forward + out-of-sample validation for the 72%/80% backtest claims (or downgrade to "educational interpretation" permanently)
- MT5 auto-sync bridge for the journal (manual import exists; sync is the pain point competitors exploit)

## Wave 3 — Community & depth (weeks 9–13)

- CONTRIBUTING-driven first external PRs; respond <48h
- GitHub Discussions enabled; good-first-issue labels
- Open-source Python quant package (`py-market-profile` extensions, vectorized backtester) — the institutional-grade evidence play
- 10-deep-tools positioning: merge/retire weak tools, keep each flagship with a hub page

## Always

- Every claim ships with a source or "our own estimate, unverified" label
- No silent threshold-softening after a near-pass
- Security issues reported via SECURITY.md (SLA: Critical 24h/72h)

See [Changelog](Changelog) for what shipped.
