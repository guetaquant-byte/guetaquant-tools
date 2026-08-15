# Anexo Metodológico de Backtesting Cuantitativo (Backtest Methodology Appendix)
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

*Gueta Quant — Open Quantitative Standards 2026*
