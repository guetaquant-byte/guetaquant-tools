# Contributing

Thanks for wanting to contribute! This repository is education-first and honesty-first. Before you open a PR, please follow the gates below — they're enforced by CI anyway.

## Per-platform notes

### MQL4 / MQL5 (`mql/`)
- Tools ship as **paired twins**: every `.mq4` has an equivalent `.mq5`. Keep them in sync.
- **MQL4 files must NOT use MQL5-only API**: no `#property indicator_plots`, no 3-arg `SetIndexBuffer(..., INDICATOR_DATA)`, no `PlotIndexSetInteger`, no `CopyBuffer`. CI (`scripts/check_mql_parity.py`) fails otherwise.
- MQL4 arrays are **non-series by default** (index 0 = oldest bar). If you read `high[0]`/`time[0]` expecting the current bar, use `iHigh(_Symbol,_Period,0)`/`iTime(...)` or `ArraySetAsSeries`.
- Handle hygiene (MQL5): check `INVALID_HANDLE`, release in `OnDeinit`, verify `CopyBuffer` results.

### Pine Script v6 (`pinescript/`)
- All files must start `//@version=6`.
- **No lookahead**: `request.security(..., lookahead = barmerge.lookahead_off)` unless deliberately documented.
- Signals fire on confirmed bars (`barstate.isconfirmed`); if not, state the repaint behavior in the script description.
- Pivot comparison bug to avoid: `ta.pivotlow/pivothigh` return `na` except on the confirmation bar — compare pivots via `var`-tracked previous values, not `x[1]`.

### cTrader C# (`ctrader/`)
- Verify API signatures against the cTrader reference (e.g., `Indicators.Supertrend(period, mult)` — casing matters; `Thickness(left, top, right, bottom)`).
- **Risk-critical bots** (grid/DCA/trailing): must have max-loss guards that also cancel pending orders, and one-shot per-level actions (no per-tick repeat).

## PR checklist

- [ ] `python3 scripts/check_mql_parity.py` passes
- [ ] `python3 scripts/check_readme_claims.py` passes (update `scripts/claim_exceptions.json` deliberately if a new feature backs a claim)
- [ ] Golden-value test added for the changed math (planned framework) — or stated as pending
- [ ] Repaint statement updated on the tool's README section
- [ ] No claim added that the code doesn't implement
- [ ] License header / SFC educational disclaimer intact

## Reporting issues

Use the issue templates (bug report includes MT4/MT5 build number; feature request includes platform). Security issues: see [SECURITY.md](https://github.com/guetaquant-byte/guetaquant-tools/blob/main/SECURITY.md) — report privately.
