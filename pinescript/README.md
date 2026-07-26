# 📊 Pine Script v6 — Indicadores Gueta Quant

**11 indicadores para TradingView escritos en Pine Script v6.**  
Uso educativo. Verifica siempre la lógica antes de operar en vivo.

> Repositorio principal: [github.com/guetaquant-byte/guetaquant-tools](https://github.com/guetaquant-byte/guetaquant-tools)

---

## 📋 Lista de Herramientas

| # | Indicador | Archivo | Descripción |
|---|-----------|---------|-------------|
| 1 | **GQ Volume Profile Mini** | `GQ_Volume_Profile.mini.pb` | Perfil de volumen horizontal con POC, Value Area (VAH/VAL) e histograma de volumen por precio. |
| 2 | **GQ SuperTrend** | `GQ_SuperTrend.pb` | Trailing stop basado en ATR que cambia de dirección cuando el precio cruza la línea. |
| 3 | **GQ VWAP Standard** | `GQ_VWAP_Standard.pb` | VWAP clásico con bandas de desviación estándar (σ1, σ2, σ3) por sesión. |
| 4 | **GQ RSI Pro** | `GQ_RSI_Pro.pb` | RSI de 14 períodos con detección automática de divergencias regulares y ocultas (bullish/bearish). |
| 5 | **GQ MACD Pro** | `GQ_MACD_Pro.pb` | MACD personalizable con histograma de momentum y detección de cruces de señal. |
| 6 | **GQ Bollinger Bands** | `GQ_Bollinger_Bands.pb` | Bandas de Bollinger con detección de squeezes (contracción de bandas) y etiquetas de volatilidad. |
| 7 | **GQ Market Structure** | `GQ_Market_Structure.pb` | Estructura de mercado SMC/ICT: FVG (Fair Value Gaps), BOS (Break of Structure), CHoCH, Order Blocks. |
| 8 | **GQ Order Flow CVD** | `GQ_Order_Flow_CVD.pb` | Cumulative Volume Delta — histograma que muestra la diferencia acumulada entre volumen comprador y vendedor. |
| 9 | **GQ Anchored VWAP** | `GQ_Anchored_VWAP.pb` | VWAP multi-ancla: permite hasta 3 VWAPs simultáneos desde fechas o barras seleccionadas. |
| 10 | **GQ Support & Resistance** | `GQ_Support_Resistance.pb` | Soportes y resistencias dinámicos calculados mediante clustering de pivotes altos/bajos. |
| 11 | **GQ MTF Trend Matrix** | `GQ_MTF_Trend_Matrix.pb` | Matriz de tendencia multi-timeframe basada en EMAs que muestra la dirección en cada temporalidad. |

---

## 🔧 Detalle por Herramienta

### 1. GQ Volume Profile Mini

Perfil de volumen horizontal que divide el rango de precios en filas y calcula el volumen negociado en cada nivel.

- **Parámetros clave:** `numRows` (número de filas, default 24), `valueAreaVol` (% del volumen total para VA, default 70)
- **Interpretación:** El POC (Punto de Control) es la fila con mayor volumen. VAH/VAL definen el Value Area. Precio fuera del VA sugiere desequilibrio.
- **Timeframe recomendado:** 1h o superior para datos significativos.

### 2. GQ SuperTrend

Indicador de trailing stop que se ajusta usando ATR. Cambia de color cuando la tendencia cambia.

- **Parámetros clave:** `ATR Period` (default 10), `Multiplier` (default 3.0)
- **Interpretación:** Línea verde = tendencia alcista (precio arriba). Línea roja = tendencia bajista (precio abajo).
- **Timeframe recomendado:** Cualquier temporalidad. Mejor en 15m-4h.
- **⚠️ Repinta:** No repinta en tiempo real, pero puede cambiar en la vela de cierre.

### 3. GQ VWAP Standard

VWAP (Volume-Weighted Average Price) calculado desde la apertura de la sesión.

- **Parámetros clave:** `src` (fuente de precio, default hl3), `mult1/2/3` (múltiplos de desviación, default 1.0/2.0/3.0)
- **Interpretación:** Precio sobre VWAP = sesión alcista. Bandas σ muestran niveles de sobre-extensión estadística.
- **Timeframe recomendado:** 1m-1h intradiario. No aplica en temporalidades >1D.

### 4. GQ RSI Pro

RSI mejorado con detección de divergencias.

- **Parámetros clave:** `rsiLength` (default 14), `overbought` (default 70), `oversold` (default 30), `divLookback` (default 90)
- **Interpretación:** Flechas en el gráfico señalan divergencias: bullish (precio hace mínimo más bajo, RSI hace mínimo más alto) y bearish (opuesto).
- **Timeframe recomendado:** 1h-4h para divergencias confiables.
- **⚠️ Repinta:** Las divergencias pueden aparecer/desaparecer al formarse la vela.

### 5. GQ MACD Pro

MACD con histograma de momentum.

- **Parámetros clave:** `fastLength` (default 12), `slowLength` (default 26), `signalLength` (default 9)
- **Interpretación:** Cruce de línea MACD sobre señal = alcista. Histograma creciente = momentum acelerando.
- **Timeframe recomendado:** Cualquiera. 1h-1d para señales de mayor duración.

### 6. GQ Bollinger Bands

Bandas de Bollinger con detección visual de squeezes.

- **Parámetros clave:** `length` (default 20), `mult` (default 2.0), `squeezeThreshold` (default 0.05)
- **Interpretación:** Bandas angostas (squeeze) = baja volatilidad inminente expansión. Precio tocando banda superior/inferior = condición de sobre-extensión.
- **Timeframe recomendado:** Cualquiera.

### 7. GQ Market Structure

Indicador SMC/ICT que identifica estructura de mercado.

- **Parámetros clave:** `pivotLookback` (default 5), `fvgThreshold` (default 0.001), `showOrderBlocks` (default true)
- **Interpretación:** BOS (quiebre de estructura) = línea en el gráfico. FVG = rectángulos entre velas. Order Blocks = zonas de desequilibrio.
- **Timeframe recomendado:** 15m-4h para señales SMC clásicas.
- **⚠️ Repinta:** FVG y Order Blocks pueden cambiar con nuevas velas.

### 8. GQ Order Flow CVD

Cumulative Volume Delta — indicador de flujo de órdenes.

- **Parámetros clave:** `smoothLength` (default 5), `showDivergences` (default true)
- **Interpretación:** Histograma positivo = presión compradora neta. Negativo = presión vendedora neta. Divergencias entre CVD y precio anticipan reversiones.
- **Timeframe recomendado:** 1m-15m para scalping. 1h-4h para swing.
- **⚠️ Repinta:** Depende de la fuente de datos de TradingView; puede variar con tick history.

### 9. GQ Anchored VWAP

VWAP anclado a puntos personalizados.

- **Parámetros clave:** `anchorDate1/2/3` (fechas de anclaje), `anchorBar1/2/3` (número de barra como alternativa)
- **Interpretación:** Cada VWAP anclado actúa como un nivel de valor razonable desde ese punto en adelante. Precio lejos de VWAP = posible rebalanceo.
- **Timeframe recomendado:** Cualquiera. Ideal para eventos específicos (earnings, noticias).

### 10. GQ Support & Resistance

Soportes y resistencias dinámicos.

- **Parámetros clave:** `pivotLookback` (default 10), `clusterDistance` (default 0.002), `maxLevels` (default 6)
- **Interpretación:** Líneas horizontales con etiquetas de precio. Niveles más gruesos = mayor clustering = mayor significancia.
- **Timeframe recomendado:** 1h-1d.

### 11. GQ MTF Trend Matrix

Matriz de tendencia que analiza EMAs en 8 temporalidades simultáneas.

- **Parámetros clave:** `emaFast` (default 9), `emaSlow` (default 21), `showTable` (default true)
- **Interpretación:** Tabla en el gráfico con filas por timeframe y columnas: EMA rápida, EMA lenta, dirección (↑/↓/—).
- **Timeframe recomendado:** Úsalo en el gráfico base que prefieras; la tabla muestra todas las temporalidades.

---

## 🚀 Instalación en TradingView

Sigue estos pasos para agregar cualquier indicador a tu gráfico:

1. **Abrir el Editor Pine:** En TradingView, haz clic en **Pine Editor** (panel inferior) o presiona `Ctrl+Alt+P` / `Cmd+Opt+P`.
2. **Crear nuevo script:** Haz clic en **Nuevo Script** y selecciona **Indicador vacío**.
3. **Pegar el código:** Borra el contenido por defecto y pega el código del archivo `.pb` correspondiente.
4. **Agregar al gráfico:** Haz clic en **Agregar al gráfico** (botón verde en la esquina superior derecha del editor).
5. **Ajustar settings:** Haz clic derecho sobre el indicador en el gráfico → **Configuración** (o **Indicadores** → engranaje).

### Recomendaciones generales

- Abre los archivos `.pb` con cualquier editor de texto (VS Code, Notepad++, Sublime).
- No modifiques el código a menos que entiendas Pine Script v6.
- Cada indicador puede arrastrarse a cualquier símbolo y timeframe.

---

## ⚙️ Cómo Ajustar Parámetros

Cada indicador tiene inputs configurables:

1. Haz clic en el nombre del indicador en la esquina superior izquierda del gráfico.
2. Selecciona **Configuración** (engranaje).
3. En la pestaña **Entradas** (Inputs), ajusta los valores descritos arriba.
4. Los cambios se aplican automáticamente al gráfico.

---

## ⚠️ Advertencia sobre Repainting

Varios indicadores usan cálculos que **pueden repintar** (cambiar retrospectivamente al formarse una nueva vela):

- **GQ RSI Pro** — las divergencias se dibujan en tiempo real pero pueden desaparecer.
- **GQ Market Structure** — FVG y Order Blocks dependen de velas futuras.
- **GQ Order Flow CVD** — el delta acumulativo puede recalcularse con tick history tardío.
- **GQ SuperTrend** — puede cambiar de dirección en el cierre de la vela.

> [!CAUTION]
> **Siempre confirma las señales en la vela cerrada.** No operes basándote únicamente en la vela en formación.

---

## 📈 Timeframes Recomendados por Tipo de Indicador

| Tipo | Timeframes sugeridos |
|------|----------------------|
| Volume Profile | 1h+ |
| SuperTrend | 15m-4h |
| VWAP | 1m-1h |
| RSI + Divergencias | 1h-4h |
| MACD | 1h-1d |
| Bollinger Bands | Cualquiera |
| Market Structure | 15m-4h |
| Order Flow CVD | 1m-15m (scalp), 1h-4h (swing) |
| Anchored VWAP | Cualquiera |
| S/R dinámicos | 1h-1d |
| MTF Trend Matrix | Cualquiera (base chart) |

---

## 🔗 Enlaces

- [Repositorio principal](https://github.com/guetaquant-byte/guetaquant-tools)
- [Documentación Pine Script v6](https://www.tradingview.com/pine-script-docs/en/v6/)
- [Gueta Quant — Portal educativo](https://guetaquant.com)

---

<br>

---

## ENGLISH

# 📊 Pine Script v6 — Gueta Quant Indicators

**11 TradingView indicators written in Pine Script v6.**  
For educational use. Always verify the logic before live trading.

> Main repository: [github.com/guetaquant-byte/guetaquant-tools](https://github.com/guetaquant-byte/guetaquant-tools)

---

## 📋 Tool List

| # | Indicator | File | Description |
|---|-----------|------|-------------|
| 1 | **GQ Volume Profile Mini** | `GQ_Volume_Profile.mini.pb` | Horizontal volume profile with POC, Value Area (VAH/VAL), and per-price volume histogram. |
| 2 | **GQ SuperTrend** | `GQ_SuperTrend.pb` | ATR-based trailing stop that flips direction when price crosses the line. |
| 3 | **GQ VWAP Standard** | `GQ_VWAP_Standard.pb` | Classic VWAP with standard deviation bands (σ1, σ2, σ3) per session. |
| 4 | **GQ RSI Pro** | `GQ_RSI_Pro.pb` | 14-period RSI with automatic regular and hidden divergence detection (bullish/bearish). |
| 5 | **GQ MACD Pro** | `GQ_MACD_Pro.pb` | Customizable MACD with momentum histogram and signal crossover detection. |
| 6 | **GQ Bollinger Bands** | `GQ_Bollinger_Bands.pb` | Bollinger Bands with squeeze detection (band contraction) and volatility labels. |
| 7 | **GQ Market Structure** | `GQ_Market_Structure.pb` | SMC/ICT structure: FVG (Fair Value Gaps), BOS, CHoCH, Order Blocks. |
| 8 | **GQ Order Flow CVD** | `GQ_Order_Flow_CVD.pb` | Cumulative Volume Delta histogram showing net buyer vs seller volume. |
| 9 | **GQ Anchored VWAP** | `GQ_Anchored_VWAP.pb` | Multi-anchor VWAP: up to 3 simultaneous VWAPs from selected dates or bars. |
| 10 | **GQ Support & Resistance** | `GQ_Support_Resistance.pb` | Dynamic support/resistance via high/low pivot clustering. |
| 11 | **GQ MTF Trend Matrix** | `GQ_MTF_Trend_Matrix.pb` | Multi-timeframe trend matrix using EMAs, showing direction across each timeframe. |

---

## 🔧 Per-Tool Detail

### 1. GQ Volume Profile Mini

Horizontal volume profile splitting the price range into rows, calculating traded volume per level.

- **Key inputs:** `numRows` (number of rows, default 24), `valueAreaVol` (% of total volume for VA, default 70)
- **Interpretation:** POC = row with highest volume. VAH/VAL = Value Area boundaries. Price outside VA suggests imbalance.
- **Recommended timeframe:** 1h+ for meaningful data.

### 2. GQ SuperTrend

ATR-adjusted trailing stop indicator that changes color when trend reverses.

- **Key inputs:** `ATR Period` (default 10), `Multiplier` (default 3.0)
- **Interpretation:** Green line = uptrend (price above). Red line = downtrend (price below).
- **Recommended timeframe:** Any. Best on 15m-4h.
- **⚠️ Repaint:** Does not repaint in real-time but may flip on candle close.

### 3. GQ VWAP Standard

Volume-Weighted Average Price calculated from session open.

- **Key inputs:** `src` (price source, default hl3), `mult1/2/3` (deviation multipliers, default 1.0/2.0/3.0)
- **Interpretation:** Price above VWAP = bullish session. σ bands show statistical over-extension levels.
- **Recommended timeframe:** 1m-1h intraday. Not applicable above 1D.

### 4. GQ RSI Pro

Enhanced RSI with divergence detection.

- **Key inputs:** `rsiLength` (default 14), `overbought` (default 70), `oversold` (default 30), `divLookback` (default 90)
- **Interpretation:** Arrows mark divergences: bullish (price lower low, RSI higher low) and bearish (opposite).
- **Recommended timeframe:** 1h-4h for reliable divergences.
- **⚠️ Repaint:** Divergences may appear/disappear as the candle forms.

### 5. GQ MACD Pro

MACD with momentum histogram.

- **Key inputs:** `fastLength` (default 12), `slowLength` (default 26), `signalLength` (default 9)
- **Interpretation:** MACD line crossing above signal = bullish. Growing histogram = accelerating momentum.
- **Recommended timeframe:** Any. 1h-1d for longer-lasting signals.

### 6. GQ Bollinger Bands

Bollinger Bands with visual squeeze detection.

- **Key inputs:** `length` (default 20), `mult` (default 2.0), `squeezeThreshold` (default 0.05)
- **Interpretation:** Narrow bands (squeeze) = low volatility, impending expansion. Price touching upper/lower band = over-extension.
- **Recommended timeframe:** Any.

### 7. GQ Market Structure

SMC/ICT indicator identifying market structure.

- **Key inputs:** `pivotLookback` (default 5), `fvgThreshold` (default 0.001), `showOrderBlocks` (default true)
- **Interpretation:** BOS = structure break line. FVG = rectangles between candles. Order Blocks = imbalance zones.
- **Recommended timeframe:** 15m-4h for classic SMC signals.
- **⚠️ Repaint:** FVG and Order Blocks may shift with new candles.

### 8. GQ Order Flow CVD

Cumulative Volume Delta — order flow indicator.

- **Key inputs:** `smoothLength` (default 5), `showDivergences` (default true)
- **Interpretation:** Positive histogram = net buying pressure. Negative = net selling pressure. CVD-price divergences anticipate reversals.
- **Recommended timeframe:** 1m-15m for scalping. 1h-4h for swing.
- **⚠️ Repaint:** Depends on TradingView data feed; may vary with late tick history.

### 9. GQ Anchored VWAP

VWAP anchored to user-defined points.

- **Key inputs:** `anchorDate1/2/3` (anchor dates), `anchorBar1/2/3` (bar number as alternative)
- **Interpretation:** Each anchored VWAP acts as a fair-value level from that point forward. Price far from VWAP suggests possible rebalance.
- **Recommended timeframe:** Any. Ideal for specific events (earnings, news).

### 10. GQ Support & Resistance

Dynamic support and resistance levels.

- **Key inputs:** `pivotLookback` (default 10), `clusterDistance` (default 0.002), `maxLevels` (default 6)
- **Interpretation:** Horizontal lines with price labels. Thicker levels = more clustering = higher significance.
- **Recommended timeframe:** 1h-1d.

### 11. GQ MTF Trend Matrix

Trend matrix analyzing EMAs across 8 simultaneous timeframes.

- **Key inputs:** `emaFast` (default 9), `emaSlow` (default 21), `showTable` (default true)
- **Interpretation:** On-chart table with rows per timeframe, columns: fast EMA, slow EMA, direction (↑/↓/—).
- **Recommended timeframe:** Use on your preferred base chart; table shows all timeframes.

---

## 🚀 Installation on TradingView

1. **Open Pine Editor:** Click **Pine Editor** (bottom panel) or press `Ctrl+Alt+P` / `Cmd+Opt+P`.
2. **New script:** Click **New Script** → **Empty Indicator**.
3. **Paste code:** Delete default content and paste the `.pb` file code.
4. **Add to chart:** Click **Add to Chart** (green button, top-right of editor).
5. **Adjust settings:** Right-click the indicator on chart → **Settings** (or **Indicators** → gear icon).

### General tips

- Open `.pb` files with any text editor (VS Code, Notepad++, Sublime).
- Do not modify code unless you understand Pine Script v6.
- Every indicator works on any symbol and timeframe.

---

## ⚙️ Adjusting Parameters

1. Click the indicator name (top-left corner of chart).
2. Select **Settings** (gear icon).
3. Go to **Inputs** tab and adjust values as described above.
4. Changes apply to the chart automatically.

---

## ⚠️ Repainting Warning

Several indicators use calculations that **may repaint** (change retroactively as a new candle forms):

- **GQ RSI Pro** — divergences draw in real-time but may disappear.
- **GQ Market Structure** — FVG and Order Blocks depend on future candles.
- **GQ Order Flow CVD** — cumulative delta may recalculate with late tick history.
- **GQ SuperTrend** — may flip direction on candle close.

> [!CAUTION]
> **Always confirm signals on a closed candle.** Do not trade based solely on the forming candle.

---

## 📈 Recommended Timeframes by Indicator Type

| Type | Suggested Timeframes |
|------|---------------------|
| Volume Profile | 1h+ |
| SuperTrend | 15m-4h |
| VWAP | 1m-1h |
| RSI + Divergences | 1h-4h |
| MACD | 1h-1d |
| Bollinger Bands | Any |
| Market Structure | 15m-4h |
| Order Flow CVD | 1m-15m (scalp), 1h-4h (swing) |
| Anchored VWAP | Any |
| Dynamic S/R | 1h-1d |
| MTF Trend Matrix | Any (base chart) |

---

## 🔗 Links

- [Main repository](https://github.com/guetaquant-byte/guetaquant-tools)
- [Pine Script v6 Documentation](https://www.tradingview.com/pine-script-docs/en/v6/)
- [Gueta Quant — Educational portal](https://guetaquant.com)

---

*© 2025 Gueta Quant — Uso educativo bajo AGPLv3 | Educational use under AGPLv3*
