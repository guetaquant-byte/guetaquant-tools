# Backtest Methodology

How Gueta Quant reports backtest results — because a number without a method is fiction.

## Minimum methodology appendix (every published backtest)

1. **Data source + provider** — where the OHLCV came from, exact instrument, survivorship-free statement (include dead/expired instruments where relevant).
2. **Sample period** — exact dates, regime coverage.
3. **Costs** — spread (pips/points), commission, slippage (fixed or proportional), swap for FX.
4. **Execution assumptions** — bar-close vs next-bar-open; repaint-free signal source.
5. **Sample size** — number of trades, average trades/year, distinct periods.
6. **Validation** — IS/OOS split, walk-forward windows, number of parameter sets tested (multiple-testing honesty).
7. **Per-trade stats** — best/worst trade, expectancy, max drawdown, profit factor, avg holding time.

## Honesty rules

- Every historical figure is labeled **"hypothetical backtest"** — never "expected returns".
- **"Past performance is not indicative of future results."** — universal boilerplate.
- A positive expectancy over N trades **does not prove an edge** — significance, out-of-sample, costs and regime stability are required. We publish this as explicit text on the site (see `gestion-riesgo-trading`).
- In decentralized FX there is **no centralized order book** — Volume Profile distributes available feed volume as a proxy; we say so.

## Reference standard

Bailey, Borwein, López de Prado & Zhu (2014), *Pseudo-Mathematics and Financial Charlatanism* — PSR, MinTRL, multiple-testing control, out-of-sample validation. Our educational content references these concepts; we do not claim institutional-grade research output without reproducible evidence.

## Current published claims (with methodology notes)

- VAL/VAH Breakout USDCOP: 72% continuation (2023–2025 daily data, hypothetical, no costs) — methodology note on the site page.
- POC Mean Reversion: 80% (same dataset/caveats).
- ATR multiplier comparison: EURUSD 2024–2025, hypothetical.

These are **educational interpretations** until walk-forward + out-of-sample validation is published (roadmap).
