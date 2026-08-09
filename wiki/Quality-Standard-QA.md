# Quality Standard (QA)

*Defined in `docs/QA_STANDARD.md` (repo). This page is the summary.*

Every tool in this repository must eventually pass a **verification card** before being labeled "verified". Nothing ships on vibes.

## 1. Repaint taxonomy (TradingView-aligned)

Per TradingView's repainting documentation, most indicators repaint in some form. Production discipline is **classification, not denial**:

| Category | Meaning | Our rule |
|---|---|---|
| Acceptable | Signal plotted on confirmed data; may shift slightly as data confirms | Documented per tool |
| Potentially misleading | Uses unconfirmed bar data (e.g., forming bar) | Must be disclosed in the tool's description |
| Unacceptable | History changes after the fact (lookahead) | **Never shipped** — CI parity gate rejects lookahead patterns |
| Unavoidable | E.g., pivots that only confirm after N bars | Documented + alert semantics stated |

## 2. No-lookahead rules

- Decisions only on **confirmed** data: `barstate.isconfirmed` in Pine, closed-bar logic in MQL.
- Strategy tests must run with `calc_on_every_tick=false` so results match plotted signals.
- `request.security()` calls use `lookahead = barmerge.lookahead_off` (MTF matrix).
- Pivot-type signals are plotted **at confirmation bar**, never at the pivot bar.

## 3. The 3-minute repaint test

1. Load indicator on a chart, screenshot the last 20–30 bars.
2. Let 5–10 bars close.
3. Compare: any signal that moved, disappeared, or appeared = repaint. Record the result on the tool's verification card.

## 4. Golden-value tests (planned)

- Reference implementation of each indicator's core math in Python (`tests/golden/`).
- Hand-computed expected values on a fixed OHLCV fixture.
- Cross-check MQL4 = MQL5 = Pine outputs against the reference within tolerance.

## 5. Verification card template

| Field | Example |
|---|---|
| Tool | GQ_Volume_Profile.mq5 |
| Platforms | MQL5 (✓ compile) |
| Repaint status | Tested 2026-08-09: no-repaint (bar 0 excluded) |
| Alert semantics | Fires on bar close |
| Golden test | Pending |
| Known limits | OHLC-based volume distribution; not tick-accurate |

## 6. CI gates

- `check_mql_parity.py`: no MQL5-only API in `.mq4`; every `.mq4` has a `.mq5` twin; all Pine files `//@version=6`.
- `check_readme_claims.py`: every tool named in READMEs has a source file; overclaim phrases blocked unless backed by code (negation-aware: "no order-flow institucional" is a valid disclaimer).
