"""
Gueta Quant — Vectorized Python Backtester & Volume Profile Engine
===================================================================
A high-performance, vectorized backtesting and volume profile toolkit.
Designed for quantitative research, strategy validation, and risk analysis.

License: AGPLv3
Copyright (c) 2026 Gueta Quant.
Educational use under SFC Colombia Decreto 2555 de 2010.
"""

from dataclasses import dataclass

import numpy as np
import pandas as pd


@dataclass
class BacktestResult:
    """Quantitative summary of strategy backtest performance."""

    total_trades: int
    win_rate_pct: float
    profit_factor: float
    sharpe_ratio: float
    sortino_ratio: float
    calmar_ratio: float
    max_drawdown_pct: float
    cagr_pct: float
    total_return_pct: float
    expectancy_usd: float
    equity_curve: pd.Series
    drawdown_series: pd.Series


class VectorizedBacktester:
    """
    Vectorized Quantitative Backtester.
    Computes performance metrics with realistic slippage and commission accounting.
    """

    def __init__(
        self,
        initial_capital: float = 10_000.0,
        commission_per_lot: float = 7.0,  # $7 USD round turn
        slippage_points: float = 5.0,     # 0.5 pips default
        point_value: float = 1.0,         # Value per point
        risk_free_rate: float = 0.045     # 4.5% annual risk-free rate
    ):
        self.initial_capital = initial_capital
        self.commission_per_lot = commission_per_lot
        self.slippage_points = slippage_points
        self.point_value = point_value
        self.risk_free_rate = risk_free_rate

    def run(
        self,
        df: pd.DataFrame,
        signal_col: str = "signal",
        price_col: str = "close",
        lot_size: float = 1.0
    ) -> BacktestResult:
        """
        Executes a vectorized backtest on a OHLCV DataFrame with discrete signals (1=Long, -1=Short, 0=Flat).
        """
        data = df.copy()
        if signal_col not in data.columns or price_col not in data.columns:
            raise ValueError(f"Columns '{signal_col}' and '{price_col}' must be present in DataFrame.")

        # Compute raw returns
        data["returns"] = data[price_col].pct_change().fillna(0.0)
        data["position"] = data[signal_col].shift(1).fillna(0.0)

        # Detect position changes for commission & slippage calculation
        data["trade_occurred"] = (data["position"] != data["position"].shift(1)).fillna(False)

        # Slippage penalty per trade as a fraction of price
        slippage_cost_fraction = (self.slippage_points * 0.00001) / data[price_col]
        data["slippage_cost"] = np.where(data["trade_occurred"], slippage_cost_fraction, 0.0)

        # Strategy returns after slippage
        data["strat_returns"] = (data["position"] * data["returns"]) - data["slippage_cost"]

        # Cumulative equity curve
        data["equity"] = self.initial_capital * (1.0 + data["strat_returns"]).cumprod()

        # Deduct fixed commissions
        commission_cost = data["trade_occurred"].astype(float) * self.commission_per_lot * lot_size
        data["equity"] = data["equity"] - commission_cost.cumsum()

        # Running maximum and drawdown
        data["peak"] = data["equity"].cummax()
        data["drawdown"] = (data["equity"] - data["peak"]) / data["peak"]
        max_drawdown_pct = float(abs(data["drawdown"].min()) * 100.0) if len(data) > 0 else 0.0

        # Returns summary
        total_return_pct = float(((data["equity"].iloc[-1] - self.initial_capital) / self.initial_capital) * 100.0)

        # Annualized metrics (assuming daily data, 252 bars/year)
        n_bars = max(1, len(data))
        years = max(1 / 252, n_bars / 252.0)
        cagr_pct = float(((data["equity"].iloc[-1] / self.initial_capital) ** (1.0 / years) - 1.0) * 100.0) if data["equity"].iloc[-1] > 0 else -100.0

        # Sharpe & Sortino ratios
        daily_rf = (1.0 + self.risk_free_rate) ** (1.0 / 252.0) - 1.0
        excess_returns = data["strat_returns"] - daily_rf
        std_dev = data["strat_returns"].std()
        sharpe_ratio = float(excess_returns.mean() / std_dev * np.sqrt(252)) if std_dev > 0 else 0.0

        downside_returns = data["strat_returns"][data["strat_returns"] < 0]
        downside_std = downside_returns.std()
        sortino_ratio = float(excess_returns.mean() / downside_std * np.sqrt(252)) if downside_std > 0 else 0.0

        calmar_ratio = float(cagr_pct / max_drawdown_pct) if max_drawdown_pct > 0 else 0.0

        # Trade-level statistics
        trade_returns = data.loc[data["trade_occurred"], "strat_returns"]
        winning_trades = trade_returns[trade_returns > 0]
        losing_trades = trade_returns[trade_returns < 0]

        total_trades = len(trade_returns)
        win_rate_pct = float(len(winning_trades) / total_trades * 100.0) if total_trades > 0 else 0.0
        gross_profit = float(winning_trades.sum()) if len(winning_trades) > 0 else 0.0
        gross_loss = float(abs(losing_trades.sum())) if len(losing_trades) > 0 else 1e-6
        profit_factor = float(gross_profit / gross_loss) if gross_loss > 0 else (99.0 if gross_profit > 0 else 0.0)

        expectancy_usd = float((data["equity"].iloc[-1] - self.initial_capital) / total_trades) if total_trades > 0 else 0.0

        return BacktestResult(
            total_trades=total_trades,
            win_rate_pct=round(win_rate_pct, 2),
            profit_factor=round(profit_factor, 2),
            sharpe_ratio=round(sharpe_ratio, 2),
            sortino_ratio=round(sortino_ratio, 2),
            calmar_ratio=round(calmar_ratio, 2),
            max_drawdown_pct=round(max_drawdown_pct, 2),
            cagr_pct=round(cagr_pct, 2),
            total_return_pct=round(total_return_pct, 2),
            expectancy_usd=round(expectancy_usd, 2),
            equity_curve=data["equity"],
            drawdown_series=data["drawdown"]
        )


class VolumeProfileEngine:
    """
    Auction Market Theory (AMT) Volume Profile Engine.
    Computes Point of Control (POC), Value Area High (VAH), and Value Area Low (VAL).
    """

    def __init__(self, value_area_pct: float = 0.70, num_bins: int = 50):
        self.value_area_pct = value_area_pct
        self.num_bins = num_bins

    def calculate(
        self,
        df: pd.DataFrame,
        price_col: str = "close",
        volume_col: str = "volume"
    ) -> dict[str, float]:
        """
        Calculates POC, VAH, and VAL from price and volume data.
        """
        if price_col not in df.columns or volume_col not in df.columns:
            raise ValueError(f"Columns '{price_col}' and '{volume_col}' required in DataFrame.")

        prices = df[price_col].values
        volumes = df[volume_col].values

        if len(prices) == 0:
            return {"poc": 0.0, "vah": 0.0, "val": 0.0, "total_volume": 0.0}

        min_p, max_p = prices.min(), prices.max()
        if min_p == max_p:
            return {"poc": float(min_p), "vah": float(min_p), "val": float(min_p), "total_volume": float(volumes.sum())}

        # Discretize price levels into bins
        bins = np.linspace(min_p, max_p, self.num_bins + 1)
        bin_indices = np.digitize(prices, bins) - 1
        bin_indices = np.clip(bin_indices, 0, self.num_bins - 1)

        # Aggregate volume per price bin
        vol_per_bin = np.zeros(self.num_bins)
        np.add.at(vol_per_bin, bin_indices, volumes)

        # Point of Control (POC): Price level of maximum traded volume
        poc_bin_idx = int(np.argmax(vol_per_bin))
        poc_price = float((bins[poc_bin_idx] + bins[poc_bin_idx + 1]) / 2.0)

        # Value Area (70% standard deviation of total volume)
        total_vol = float(vol_per_bin.sum())
        target_va_vol = total_vol * self.value_area_pct

        cum_vol = vol_per_bin[poc_bin_idx]
        low_idx = poc_bin_idx
        high_idx = poc_bin_idx

        while cum_vol < target_va_vol and (low_idx > 0 or high_idx < self.num_bins - 1):
            next_low_vol = vol_per_bin[low_idx - 1] if low_idx > 0 else -1.0
            next_high_vol = vol_per_bin[high_idx + 1] if high_idx < self.num_bins - 1 else -1.0

            if next_high_vol >= next_low_vol and high_idx < self.num_bins - 1:
                high_idx += 1
                cum_vol += vol_per_bin[high_idx]
            elif low_idx > 0:
                low_idx -= 1
                cum_vol += vol_per_bin[low_idx]
            elif high_idx < self.num_bins - 1:
                high_idx += 1
                cum_vol += vol_per_bin[high_idx]
            else:
                break

        vah_price = float((bins[high_idx] + bins[high_idx + 1]) / 2.0)
        val_price = float((bins[low_idx] + bins[low_idx + 1]) / 2.0)

        return {
            "poc": round(poc_price, 4),
            "vah": round(vah_price, 4),
            "val": round(val_price, 4),
            "total_volume": round(total_vol, 2)
        }


class MonteCarloSimulator:
    """
    Monte Carlo Resampling Simulator for Robustness Testing.
    Simulates sequence permutation to estimate 95th/99th percentile Drawdown.
    """

    def __init__(self, iterations: int = 1_000, seed: int | None = 42):
        self.iterations = iterations
        self.seed = seed

    def simulate(self, trade_returns: list[float], initial_capital: float = 10_000.0) -> dict[str, float]:
        """
        Runs Monte Carlo permutations on a sequence of trade returns.
        """
        if not trade_returns:
            return {"p95_max_drawdown_pct": 0.0, "p99_max_drawdown_pct": 0.0, "median_return_pct": 0.0}

        rng = np.random.default_rng(self.seed)
        returns_arr = np.array(trade_returns)
        mdd_list = []
        final_returns = []

        for _ in range(self.iterations):
            sampled = rng.permutation(returns_arr)
            equity = initial_capital * np.cumprod(1.0 + sampled)
            peak = np.maximum.accumulate(equity)
            dd = (equity - peak) / peak
            mdd = np.abs(np.min(dd)) * 100.0
            mdd_list.append(mdd)
            final_returns.append((equity[-1] - initial_capital) / initial_capital * 100.0)

        return {
            "p95_max_drawdown_pct": round(float(np.percentile(mdd_list, 95)), 2),
            "p99_max_drawdown_pct": round(float(np.percentile(mdd_list, 99)), 2),
            "median_return_pct": round(float(np.median(final_returns)), 2)
        }
