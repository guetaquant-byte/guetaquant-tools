"""
Unit Tests for Gueta Quant Python Backtester & Volume Profile Engine
====================================================================
"""

import pandas as pd
import pytest

from gq_backtest import MonteCarloSimulator, VectorizedBacktester, VolumeProfileEngine


def test_vectorized_backtester_metrics():
    # Construct 100 days of mock price data with trending signals
    dates = pd.date_range("2026-01-01", periods=100, freq="D")
    prices = [100.0]
    for i in range(1, 100):
        prices.append(prices[-1] * (1.01 if i % 2 == 1 else 0.995))

    signals = [1 if i % 4 < 2 else 0 for i in range(100)]
    df = pd.DataFrame({"close": prices, "signal": signals}, index=dates)

    engine = VectorizedBacktester(initial_capital=10_000.0, commission_per_lot=0.0, slippage_points=0.0)
    result = engine.run(df)

    assert result.total_trades > 0
    assert result.equity_curve is not None
    assert len(result.equity_curve) == 100
    assert isinstance(result.sharpe_ratio, float)
    assert isinstance(result.max_drawdown_pct, float)
    assert result.max_drawdown_pct >= 0.0


def test_volume_profile_poc_and_value_area():
    # Construct synthetic price & volume data with heavy volume at price 150
    prices = [100.0, 150.0, 150.0, 150.0, 200.0]
    volumes = [10.0, 100.0, 150.0, 100.0, 20.0]
    df = pd.DataFrame({"close": prices, "volume": volumes})

    vp_engine = VolumeProfileEngine(value_area_pct=0.70, num_bins=20)
    res = vp_engine.calculate(df)

    assert res["poc"] > 140.0 and res["poc"] < 160.0
    assert res["vah"] >= res["poc"]
    assert res["val"] <= res["poc"]
    assert res["total_volume"] == 380.0


def test_monte_carlo_resampling():
    returns = [0.02, -0.01, 0.015, -0.005, 0.03, -0.02, 0.01, -0.01]
    mc = MonteCarloSimulator(iterations=500, seed=42)
    res = mc.simulate(returns, initial_capital=10_000.0)

    assert "p95_max_drawdown_pct" in res
    assert "p99_max_drawdown_pct" in res
    assert res["p99_max_drawdown_pct"] >= res["p95_max_drawdown_pct"]


if __name__ == "__main__":
    pytest.main(["-v", __file__])
