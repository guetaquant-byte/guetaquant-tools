# Changelog

*Mirror of the repo `CHANGELOG.md` (Keep a Changelog style).*

## [0.9.0] — 2026-08-09 — Audit-driven hardening

**Fixed (critical):**
- **MQL4 compile fixes** — 6 `.mq4` files no longer use MQL5-only API (`indicator_plots`, 3-arg `SetIndexBuffer`, `PlotIndexSetInteger`): GQ_ATR_Stop_Loss, GQ_Ichimoku_Cloud, GQ_Market_Structure, GQ_RSI_Pro, GQ_Support_Resistance, GQ_Volume_Profile. Also fixed MQL4 series-indexing (buffer/array index 0 = oldest bar) — use `iHigh`/`iTime` or `ArraySetAsSeries`.
- **GQ_Volume_Profile (mq4 + mq5)** — mirrored row-binning fixed: POC/VAH/VAL now at correct prices; off-by-one lookback; forming-bar excluded (repaint); div-by-zero guard; dead code removed.
- **GQ_Order_Flow_CVD, GQ_MACD_Pro, GQ_RSI_Pro (Pine)** — divergence detection was dead code (`ta.pivot*[1]` always `na`); rewrote with var-tracked consecutive-pivot comparison.
- **cTrader:**
  - GQ_DCA_Recovery — level-0 limit-order flood fixed (pending-order guard); drawdown guard cancels pendings.
  - GQ_Trailing_Stop_Manager — partial closes drained positions every tick; one-shot per-level flags.
  - GQ_Grid_Scalper — drawdown guard now cancels pending orders (grid no longer refills past max loss).
  - GQ_Trend_Follower — did not compile (`Indicators.SuperTrend` → `Supertrend`, `Result` → `UpTrend/DownTrend`).
  - GQ_Position_Sizer_cBot — `Thickness(8,6)` → `Thickness(8,6,8,6)`.
- **GQ_Market_Structure (mq4 + mq5)** — out-of-bounds array reads capped; BOS fires once (transition) instead of every bar; mq5 temporal inversion fixed (iterate downward with series arrays).
- **GQ_SuperTrend (mq4 + mq5)** — truncated window + constant ATR → full 200-bar recursion with per-bar ATR.
- **GQ_Ichimoku_Cloud (mq5)** — double Senkou shift removed (cloud displaced 52 bars).

**Added:**
- CI: `compile-mql.yml` (Windows + MetaEditor), `static-checks.yml` (parity + README claims, negation-aware)
- `scripts/check_mql_parity.py`, `scripts/check_readme_claims.py`, `scripts/claim_exceptions.json`
- `SECURITY.md` (disclosure SLA), `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `docs/QA_STANDARD.md`
- README: repo-status section, honest tool descriptions, corrected magic numbers

**Docs:**
- `ZERO_KNOWLEDGE_PRIVACY_AUDIT.md` — explicit AI-layer scope section (ES/EN), FAQ corrected
- README "CERO comunicación" claims scoped to core journal (AI is opt-in cloud, disclosed)

## [0.8.x] — 2026-07-26 — Initial public release

44 tool files across MQL4/MQL5, Pine Script v6, cTrader C#; bilingual READMEs; zero-knowledge privacy audit; AGPLv3.
