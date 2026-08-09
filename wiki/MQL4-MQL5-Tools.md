# MQL4 / MQL5 Tools

22 files = 11 tools × (MQL4 + MQL5). All MQL4 files pass the no-MQL5-API parity gate; compile verification runs on GitHub Actions (Windows + MetaEditor) — see the `compile-mql` workflow status on the repo.

## Install

1. Open MetaEditor (MT4 or MT5).
2. Copy the `.mq4` (MT4) or `.mq5` (MT5) file into `MQL4/Indicators` or `MQL5/Indicators` (EAs go to `Experts`).
3. Compile (F7) — or download the prebuilt `.ex4/.ex5` from the CI workflow artifacts.

## Tool list

| Tool | Type | MQL4 | MQL5 | Status |
|---|---|---|---|---|
| GQ_ATR_Stop_Loss | Indicator (trailing line) | ✓ compile | ✓ compile | beta (golden test pending) |
| GQ_Bollinger_Reversion | EA | ✓ | ✓ | beta |
| GQ_Ichimoku_Cloud | Indicator | ✓ (series-indexing fixed) | ✓ (double-shift fixed) | beta |
| GQ_MACD_Trader | EA | ✓ | ✓ | beta |
| GQ_Market_Structure | Indicator (BOS/CHoCH) | ✓ (OOB fixed) | ✓ (temporal fix) | beta — price-action heuristics, not institutional flow |
| GQ_Position_Sizer | Indicator/panel | ✓ | ✓ | **most mature** — math verified, handle hygiene exemplary |
| GQ_RSI_Pro | Indicator (cross + divergence) | ✓ | ✓ (divergence rewritten) | beta |
| GQ_SuperTrend | EA | ✓ (recursion fixed) | ✓ (per-bar ATR) | beta |
| GQ_Support_Resistance | Indicator | ✓ (label anchor fixed) | ✓ | beta |
| GQ_Trend_Follow | EA | ✓ | ✓ | beta |
| GQ_Volume_Profile | Indicator (POC/VA) | ✓ (binning fixed) | ✓ (prices aligned) | beta — OHLC heuristic, not tick-accurate |

## Notes

- **Magic numbers:** 1001 (SuperTrend), 1002 (MACD), 1004 (Bollinger), 1005 (Trend Follow) — the README table now matches the code.
- **Position Sizer math:** `lots = risk$ / (stopTicks × tickValue)` with ATR×multiplier stop; guard for `lotStep = 0`; on very small accounts the min-lot clamp can exceed the configured risk — check the panel before trading.
- **Volume Profile:** distributes each candle's full volume across its price range (close-price approximation). In FX, feed volume ≠ global volume. POC/VAH/VAL are zone estimates, not institutional order data.
- **Market Structure:** swings are computed on confirmed bars; BOS fires once per break. CHoCH is drawn as structural change in Pine; MQL version covers BOS.
- All tools are **educational** — no live-trading recommendation, no signals.
