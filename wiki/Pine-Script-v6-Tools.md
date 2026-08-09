# Pine Script v6 Tools

11 TradingView indicators in `pinescript/` (`//@version=6`). No offline compiler exists for Pine — CI performs structural linting + the parity/claims gates; final compilation happens when you add the script in TradingView.

## Install

1. TradingView → Pine Editor.
2. Paste the `.pb` content, or open the file from the repo.
3. Save → Add to chart.

## Tool list

| Tool | What it does | Status |
|---|---|---|
| GQ_Volume_Profile.mini | 24-bin volume profile, POC, value area, HV/LV histogram | beta — redraw purge added; OHLC heuristic |
| GQ_SuperTrend | Standard SuperTrend (hand-rolled, verified bar-by-bar) | ✅ sound |
| GQ_VWAP_Standard | Running VWAP + std bands | ✅ sound |
| GQ_Anchored_VWAP | Multi-anchor VWAP (timestamp/bar-index/swing) | fixed — anchor now fires on `time >= timestamp` |
| GQ_RSI_Pro | RSI + **regular/hidden divergence (rewritten — real swing comparison)** | fixed |
| GQ_MACD_Pro | MACD + zero-cross + divergence | fixed (divergence was dead code) |
| GQ_Bollinger_Bands | Bands + squeeze/%B | ✅ sound |
| GQ_Market_Structure | BOS/CHoCH shapes, FVG + OB boxes | fixed — box purge + BOS latch + 500-box cap |
| GQ_Order_Flow_CVD | Cumulative Volume Delta + divergence | fixed — divergence now fires (var-tracked pivots) |
| GQ_Support_Resistance | S/R levels from pivots | cleaned — removed broken label delete |
| GQ_MTF_Trend_Matrix | Multi-timeframe trend matrix | fixed — `lookahead_off` |

## Key notes

- **Divergence bug (fixed):** `ta.pivotlow/high` return `na` except on the confirmation bar, so `pivot[1]` comparisons were always false. All divergence tools now track the previous pivot with `var`.
- **Repainting:** FVG/OB boxes and pivots update only on confirmed bars; the mini Volume Profile recomputes on `barstate.islast` (purges previous drawings — no accumulation).
- **CVD** uses `volume × (close−open)/(high−low)` as a delta proxy — it is a range-position heuristic, not real order-flow data; documented on the script.
- Recommended: verify signals with the 3-minute repaint test ([Quality Standard](Quality-Standard-QA)) before relying on them.
