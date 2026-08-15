# Gueta Quant — Motor Vectorizado de Backtesting en Python
**Python Vectorized Backtester & Volume Profile Engine**

Módulo cuantitativo en Python para validación vectorial de estrategias, cálculo de Volume Profile (POC, VAH, VAL) y análisis de robustez mediante permutaciones de Monte Carlo.

---

## 📦 Instalación

```bash
pip install -r requirements.txt
```

---

## 🚀 Uso Rápido (Quickstart)

```python
import pandas as pd
from gq_backtest import VectorizedBacktester, VolumeProfileEngine, MonteCarloSimulator

# 1. Backtesting Vectorial
df = pd.read_csv("data.csv")  # Requiere columnas 'close' y 'signal'
engine = VectorizedBacktester(initial_capital=10_000.0, commission_per_lot=7.0, slippage_points=5.0)
results = engine.run(df)

print(f"Sharpe Ratio: {results.sharpe_ratio}")
print(f"Max Drawdown: {results.max_drawdown_pct}%")
print(f"Profit Factor: {results.profit_factor}")

# 2. Perfil de Volumen (Auction Market Theory)
vp = VolumeProfileEngine(value_area_pct=0.70, num_bins=50)
levels = vp.calculate(df, price_col="close", volume_col="volume")
print(f"POC: {levels['poc']} | VAH: {levels['vah']} | VAL: {levels['val']}")

# 3. Simulación de Monte Carlo
mc = MonteCarloSimulator(iterations=1000)
risk_profile = mc.simulate(df["strat_returns"].dropna().tolist())
print(f"Max Drawdown P95: {risk_profile['p95_max_drawdown_pct']}%")
```

---

## 🧪 Pruebas Unitarias

```bash
pytest python/test_gq_backtest.py -v
```

---

*© 2026 Gueta Quant — Educational use under AGPLv3*
