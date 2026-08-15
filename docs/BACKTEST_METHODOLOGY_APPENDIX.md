# 🇨🇴 Anexo Metodológico de Backtesting Cuantitativo (ES)
**Gueta Quant Open-Source Standards — 2026 Sovereign Quantitative Edition**

---

## 1. Declaración Regulatoria y Marco Legal (SFC Colombia)

> **AVISO LEGAL OBLIGATORIO (Decreto 2555 de 2010 & Ley 964 de 2005):**  
> Todo dato de rendimiento histórico, métrica cuantitativa, gráfico o código publicado por Gueta Quant tiene una finalidad **exclusivamente académica y educativa**. Las simulaciones de rendimiento pasado y los modelos de backtesting **NO garantizan ni son indicativos de rendimientos futuros**. Gueta Quant no presta servicios de asesoría financiera, intermediación de valores, gestión de carteras ni emisión de señales de inversión.

---

## 2. Protocolo de Integridad de Datos (Primary Data Feeds)

Todos los resultados de backtesting publicados en nuestros artículos y herramientas cuantitativas provienen de datos históricos de grado institucional bajo las siguientes directrices:

1. **Calidad de Ticks (99.9% Modeling Quality):**
   - Datos de tick reales sin interpolación artificial (proveedores: LMAX Exchange, Dukascopy Swiss ECN y Darwinex Zero-Markup Raw Feeds).
   - Inclusión de variación real del spread en cada milisegundo (floating spread).
2. **Sincronización Multi-Temporal:**
   - Alineación temporal estricta con hora estándar UTC o Nueva York (EST/EDT) para evitar desajustes en aperturas y cierres de sesión de Londres/Nueva York.
3. **Control de Sesgo de Supervivencia (Survivorship Bias):**
   - Inclusión de pares y contratos deslistados o modificados durante el horizonte evaluado.

---

## 3. Modelo de Fricción de Mercado y Costos de Ejecución

Un backtest sin costos de ejecución es ficción teórica. Todos los modelos de Gueta Quant integran por defecto:

| Componente de Costo | Parámetro Aplicado | Justificación Metodológica |
|---|---|---|
| **Comisión de Corretaje** | **$3.50 USD / lote por lado** ($7.00 USD ida y vuelta) | Tasa estándar de cuenta Raw/ECN institucional. |
| **Slippage (Deslizamiento)** | **0.3 a 1.2 pips** según liquidez del activo | Simulación de latencia de red (20–100 ms) y profundidad de libro. |
| **Spread Dinámico** | Spread real flotante + recargo de 0.2 pips en rollover | Modela la ampliación de horquilla durante el cambio de sesión bancaria (5:00 PM EST). |
| **Swap / Rollover** | Tasa interbancaria diaria + multiplicador x3 los miércoles | Modela el costo real de mantenimiento nocturno de posiciones apalancadas. |

---

## 4. Criterios de Muestreo y Validación Multi-Régimen

Para que un resultado de backtest sea publicado por Gueta Quant, la muestra debe cumplir obligatoriamente:

1. **Tamaño Muestral Mínimo:** $N \ge 300$ operaciones cerradas independientes para garantizar significancia estadística ($p < 0.01$).
2. **Prueba a Través de 3 Regímenes Macroeconómicos:**
   - **Régimen de Alta Volatilidad / Crisis:** Crisis COVID-19 y choques de liquidez (2020–2021).
   - **Régimen de Tendencia / Endurecimiento Monetario:** Ciclo alcista de tasas de la Reserva Federal y fortaleza del DXY (2022–2023).
   - **Régimen de Rango / Desinflación:** Consolidación macroeconómica y rotación institucional (2024–2026).
3. **División Out-of-Sample (OOS):**
   - 70% de datos históricos para calibración y optimización in-sample (IS).
   - 30% de datos reservados estrictamente para validación ciega fuera de muestra (OOS).

---

## 5. Batería de Métricas Cuantitativas y Robustez

Los reportes cuantitativos de Gueta Quant evalúan la distribución de retornos mediante métricas robustas:

### Métricas de Retorno Ajustado por Riesgo
- **Sharpe Ratio Anualizado:** $S = \frac{\mathbb{E}[R_p - R_f]}{\sigma_p} \cdot \sqrt{252}$ (Tasa libre de riesgo $R_f = 4.5\%$).
- **Sortino Ratio:** Evalúa únicamente la volatilidad a la baja (downside semi-deviation): $\text{Sortino} = \frac{\mathbb{E}[R_p - R_f]}{\sigma_{\text{down}}}$.
- **Calmar Ratio:** $\text{Calmar} = \frac{\text{CAGR}}{|\text{Max Drawdown}|}$.
- **Profit Factor:** $\text{PF} = \frac{\sum \text{Ganancias Brutas}}{\sum |\text{Pérdidas Brutas}|}$.

### Métricas de Resistencia y Cola (Tail-Risk)
- **Max Drawdown (MDD):** Máxima caída porcentual de capital pico a valle.
- **Deflated Sharpe Ratio (DSR):** Ajuste de Bailey & López de Prado para penalizar el número de ensayos y evitar la minería de datos (data snooping).
- **Simulaciones Monte Carlo (1,000 iteraciones):** Reordenamiento aleatorio de operaciones para estimar el Drawdown al percentil 95% y la probabilidad teórica de ruina.

---

## 6. Reproducibilidad de Código Abierto

Todos los algoritmos e indicadores asociados a estos análisis se encuentran disponibles en este repositorio:
- MetaTrader 4 / MetaTrader 5: `mql/`
- TradingView: `pinescript/`
- cTrader Automate: `ctrader/`
- Motor Vectorizado Python: `python/`

---
---

# 🇬🇧 Quantitative Backtest Methodology Appendix (EN)
**Gueta Quant Open-Source Standards — 2026 Sovereign Quantitative Edition**

---

## 1. Regulatory & Legal Disclosure (SFC Colombia)

> **MANDATORY LEGAL NOTICE (Decreto 2555 de 2010 & Ley 964 de 2005):**  
> All historical performance data, quantitative metrics, charts, and code published by Gueta Quant are strictly for **academic and educational purposes only**. Past performance simulations and backtesting models **DO NOT guarantee and are NOT indicative of future results**. Gueta Quant does not provide financial advisory services, broker intermediation, asset management, or trade signaling.

---

## 2. Data Integrity Protocol (Primary Data Feeds)

All backtest metrics published across our articles and toolkits originate from institutional-grade historical data governed by the following rules:

1. **Tick Modeling Quality (99.9%):**
   - Real tick-by-tick data without artificial interpolation (providers: LMAX Exchange, Dukascopy Swiss ECN, and Darwinex Zero-Markup Raw Feeds).
   - Real millisecond floating spread variance included.
2. **Multi-Timeframe Synchronization:**
   - Strict alignment to UTC or New York time (EST/EDT) to eliminate session overlap distortions across London and New York market opens.
3. **Survivorship Bias Mitigation:**
   - Continuous inclusion of delisted pairs, changed contract specifications, and historical liquidity shocks.

---

## 3. Market Friction Model & Execution Costs

A backtest without execution costs is theoretical fiction. All Gueta Quant models include realistic market friction:

| Cost Component | Applied Value | Methodological Rationale |
|---|---|---|
| **Brokerage Commission** | **$3.50 USD / lot per side** ($7.00 USD round turn) | Standard institutional Raw/ECN account rate. |
| **Slippage** | **0.3 to 1.2 pips** based on instrument liquidity | Simulates network latency (20–100 ms) and order book depth exhaustion. |
| **Dynamic Spread** | Real floating spread + 0.2 pip buffer at rollover | Models spread widening during the 5:00 PM EST daily bank rollover window. |
| **Swap / Financing** | Daily interbank rate + 3x multiplier on Wednesdays | Accurately models overnight leverage holding costs. |

---

## 4. Sampling Constraints & Multi-Regime Validation

To qualify for publication by Gueta Quant, the backtested sample must satisfy:

1. **Minimum Sample Size:** $N \ge 300$ independent closed trades to guarantee statistical significance ($p < 0.01$).
2. **Testing Across 3 Macroeconomic Regimes:**
   - **High Volatility / Liquidity Shock Regime:** COVID-19 shock and aftermath (2020–2021).
   - **Trending / Rate Hike Cycle Regime:** Federal Reserve tightening cycle and DXY rally (2022–2023).
   - **Range-Bound / Disinflation Regime:** Macroeconomic consolidation and institutional rotation (2024–2026).
3. **Out-of-Sample (OOS) Partitioning:**
   - 70% In-Sample (IS) data partition for parameter calibration.
   - 30% Out-of-Sample (OOS) blind data partition for strategy validation.

---

## 5. Quantitative Robustness Battery

- **Annualized Sharpe Ratio:** $S = \frac{\mathbb{E}[R_p - R_f]}{\sigma_p} \cdot \sqrt{252}$ ($R_f = 4.5\%$).
- **Sortino Ratio:** Measures downside semi-deviation: $\text{Sortino} = \frac{\mathbb{E}[R_p - R_f]}{\sigma_{\text{down}}}$.
- **Calmar Ratio:** $\text{Calmar} = \frac{\text{CAGR}}{|\text{Max Drawdown}|}$.
- **Profit Factor:** $\text{PF} = \frac{\sum \text{Gross Profits}}{\sum |\text{Gross Losses}|}$.
- **Deflated Sharpe Ratio (DSR):** Bailey & López de Prado adjustment penalizing trial counts to prevent data snooping.
- **Monte Carlo Resampling (1,000 runs):** Trade order shuffling to estimate 95th/99th percentile Max Drawdown and ruin probability.

---

## 6. Open-Source Reproducibility

All code and indicators supporting these methodologies are available in this repository:
- MetaTrader 4 / MetaTrader 5: `mql/`
- TradingView: `pinescript/`
- cTrader Automate: `ctrader/`
- Vectorized Python Engine: `python/`

*© 2026 Gueta Quant — Open Quantitative Standards*
