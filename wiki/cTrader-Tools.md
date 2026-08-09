# cTrader Tools

11 cBots in `ctrader/` (C#). Compile with Visual Studio + the cTrader Automate SDK, or paste into the cTrader Algo editor. CI runs static checks; actual compilation happens in cTrader Automate.

## Tool list

| Tool | Type | Status |
|---|---|---|
| GQ_Position_Sizer_cBot | Position sizing panel | fixed — `Thickness` compile error resolved |
| GQ_Trend_Follower | Trend-following bot (EMA + Supertrend) | **fixed** — did not compile (`Indicators.Supertrend`, `UpTrend/DownTrend`) |
| GQ_Breakout_Orb | Opening-range breakout | beta — day-1 range edge (session filter needed) |
| GQ_Grid_Scalper | Grid bot | **fixed** — drawdown guard now cancels pending orders (was: grid refills past max loss) |
| GQ_Mean_Reversion | Mean-reversion bot | ✅ sound (volume clamps) |
| GQ_Divergence_Scanner | Divergence scanner | beta — counts per-bar duplicates; hidden-label wording fixed |
| GQ_Trailing_Stop_Manager | Trailing stop manager | **fixed** — partial closes were draining positions every tick (one-shot flags) |
| GQ_DCA_Recovery | DCA basket recovery | **fixed** — level-0 order flood (pending-order guard) |
| GQ_Session_Scalper | Session scalper | ✅ sound — overnight-session edge documented |
| GQ_Multi_Symbol_Scanner | Multi-symbol scanner | ✅ sound |
| GQ_Risk_Manager | Portfolio risk monitor | ✅ sound — partial-reduction recompute edge documented |

## Risk warnings (read before running any bot)

- **Grid, DCA, and trailing bots involve real money risk.** Max-loss guards exist and now cancel pending orders — but they are last-resort circuit breakers, not guarantees. Test in demo first, always.
- **GQ_Grid_Scalper / GQ_DCA_Recovery:** multiple open positions amplify drawdown; the guard triggers on account equity percentage — keep `MaxDrawdown` conservative.
- **GQ_Trailing_Stop_Manager:** partial closes fire **once per level per position** (fixed) — verify behavior in demo.
- **GQ_Breakout_Orb:** on the first bar after attach, the "opening range" may include history or the first bar only — wait for a fresh session.
- All bots are **educational**; no recommendation to run them live.
