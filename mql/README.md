# 📊 MQL4 & MQL5 — Gueta Quant

**22 archivos MQL (11 MQL4 + 11 MQL5) para MetaTrader 4 y MetaTrader 5.**  
Indicadores y EAs educativos. Siempre prueba en demo antes de operar en vivo.

> Repositorio principal: [github.com/guetaquant-byte/guetaquant-tools](https://github.com/guetaquant-byte/guetaquant-tools)

---

## 🧠 MQL4 vs MQL5 — ¿Cuál usar?

| Característica | MQL4 (MT4) | MQL5 (MT5) |
|----------------|------------|------------|
| **Plataforma** | MetaTrader 4 | MetaTrader 5 |
| **Paradigma** | Orientado a procedimientos | Orientado a objetos |
| **Ejecución** | Por tick (cada cambio de precio) | Por tick con eventos de trading |
| **Órdenes** | Market / Pending / Stop / Limit | Market / Pending / Stop Limit / Stop Loss / Take Profit |
| **Backtesting** | Simulación básica | Multi-moneda, ticks reales, hedge |
| **Indicadores** | `iCustom()` con buffers simples | `IndicatorCreate()` con handles |
| **Compatible con** | MT4 Builds 1400+ | MT5 Builds 4000+ |

> **Regla simple:** Usa el archivo `.mq4` en MT4 y el archivo `.mq5` en MT5. No son intercambiables.

---

## 📋 Lista de Herramientas

| # | Herramienta | Archivos | Tipo | Descripción |
|---|------------|----------|------|-------------|
| 1 | **GQ Position Sizer** | `.mq4` / `.mq5` | EA | Calcula tamaño de posición basado en ATR y riesgo %. No abre operaciones. |
| 2 | **GQ SuperTrend** | `.mq4` / `.mq5` | EA | Trend follower con SuperTrend ATR, trailing stop y gestión de riesgo. |
| 3 | **GQ MACD Trader** | `.mq4` / `.mq5` | EA | Opera cruces de MACD con stop loss dinámico por ATR. |
| 4 | **GQ Bollinger Reversion** | `.mq4` / `.mq5` | EA | Estrategia de reversión al medio usando Bollinger Bands + RSI. |
| 5 | **GQ Trend Follow** | `.mq4` / `.mq5` | EA | Seguidor de tendencia basado en cruce de medias móviles. |
| 6 | **GQ RSI Pro** | `.mq4` / `.mq5` | Indicador | RSI con detección visual de divergencias regulares y ocultas en el gráfico. |
| 7 | **GQ ATR Stop Loss** | `.mq4` / `.mq5` | Indicador | Línea visual de trailing stop basada en ATR que se dibuja sobre el precio. |
| 8 | **GQ Market Structure** | `.mq4` / `.mq5` | Indicador | Dibuja BOS (Break of Structure), CHoCH, FVG y Order Blocks en el gráfico. |
| 9 | **GQ Ichimoku Cloud** | `.mq4` / `.mq5` | Indicador | Sistema Ichimoku completo con Tenkan, Kijun, Senkou Span A/B, Chikou. |
| 10 | **GQ Support & Resistance** | `.mq4` / `.mq5` | Indicador | Niveles dinámicos de soporte y resistencia con clustering de pivotes. |
| 11 | **GQ Volume Profile** | `.mq4` / `.mq5` | Indicador | Perfil de volumen horizontal con POC, Value Area (VAH/VAL) e histograma. |

---

## 🔧 Detalle por Herramienta

### 1. GQ Position Sizer (EA)

Calculadora de riesgo que determina el lotaje óptimo según la distancia al stop medida en ATR.

- **Parámetros clave:**
  - `RiskPercent` (double, default 1.0) — % del balance a arriesgar
  - `ATRPeriod` (int, default 14) — períodos para ATR
  - `ATRMultiplier` (double, default 2.0) — multiplicador del stop
  - `MaxLot` (double, default 10.0) — lote máximo permitido
- **Tipo:** EA (no ejecuta operaciones, solo calcula)
- **En el gráfico:** Muestra una etiqueta con el tamaño de posición recomendado.

### 2. GQ SuperTrend (EA)

EA de seguimiento de tendencia que usa el indicador SuperTrend para dirección y ATR para trailing stop.

- **Parámetros clave:**
  - `SuperTrendPeriod` (int, default 10)
  - `SuperTrendMultiplier` (double, default 3.0)
  - `ATRStopMultiplier` (double, default 2.0)
  - `UseBreakeven` (bool, default true) — mueve stop a breakeven después de X pips
- **Tipo:** EA
- **En el gráfico:** Dibuja la línea del SuperTrend y las entradas/salidas ejecutadas.

### 3. GQ MACD Trader (EA)

EA que opera los cruces de la línea MACD con la línea de señal, añadiendo filtros ATR.

- **Parámetros clave:**
  - `FastEMA` (int, default 12)
  - `SlowEMA` (int, default 26)
  - `SignalSMA` (int, default 9)
  - `ATRStopMultiplier` (double, default 1.5)
  - `ATRProfitMultiplier` (double, default 3.0)
  - `MagicNumber` (int, default 202401) — identificador único de la EA
- **Tipo:** EA
- **En el gráfico:** Muestra flechas de entrada y líneas de stop/take profit.

### 4. GQ Bollinger Reversion (EA)

EA de reversión a la media que abre posiciones cuando el precio toca las bandas exteriores y el RSI confirma.

- **Parámetros clave:**
  - `BBPeriod` (int, default 20)
  - `BBDeviation` (double, default 2.0)
  - `RSIPeriod` (int, default 14)
  - `RSIOverbought` (int, default 70)
  - `RSIOversold` (int, default 30)
  - `MagicNumber` (int, default 202402)
- **Tipo:** EA
- **En el gráfico:** Dibuja las Bandas de Bollinger y señala las entradas.

### 5. GQ Trend Follow (EA)

EA de cruce de medias móviles con filtro de tendencia y trailing stop.

- **Parámetros clave:**
  - `FastMA` (int, default 10)
  - `SlowMA` (int, default 30)
  - `MAMethod` (enum, default MODE_EMA)
  - `ATRTrailingMultiplier` (double, default 2.0)
  - `MagicNumber` (int, default 202403)
- **Tipo:** EA
- **En el gráfico:** Muestra las medias móviles y marca las entradas.

### 6. GQ RSI Pro (Indicador)

RSI mejorado con detección automática de divergencias regulares (clásicas) y ocultas.

- **Parámetros clave:**
  - `RSIPeriod` (int, default 14)
  - `OverboughtLevel` (int, default 70)
  - `OversoldLevel` (int, default 30)
  - `DivLookback` (int, default 60) — barras hacia atrás para buscar divergencias
- **Tipo:** Indicador
- **En el gráfico:** Ventana separada con el RSI y flechas que marcan divergencias alcistas/bajistas.

### 7. GQ ATR Stop Loss (Indicador)

Indicador visual que dibuja una línea de trailing stop basada en ATR directamente sobre el precio.

- **Parámetros clave:**
  - `ATRPeriod` (int, default 14)
  - `ATRMultiplier` (double, default 2.0)
  - `ShowStopLine` (bool, default true)
  - `LineColor` (color, default clrRed)
- **Tipo:** Indicador
- **En el gráfico:** Línea dinámica que sigue al precio a una distancia determinada por ATR.

### 8. GQ Market Structure (Indicador)

Indicador SMC/ICT que identifica y dibuja estructura de mercado.

- **Parámetros clave:**
  - `PivotLookback` (int, default 5)
  - `ShowFVG` (bool, default true)
  - `ShowBOS` (bool, default true)
  - `ShowOrderBlocks` (bool, default true)
  - `FVGThreshold` (double, default 0.0001)
- **Tipo:** Indicador
- **En el gráfico:** Rectángulos para FVG, líneas para BOS/CHoCH, rectángulos para Order Blocks.

### 9. GQ Ichimoku Cloud (Indicador)

Sistema Ichimoku completo con todos los componentes: Tenkan-sen, Kijun-sen, Senkou Span A/B, Chikou Span.

- **Parámetros clave:**
  - `TenkanPeriod` (int, default 9)
  - `KijunPeriod` (int, default 26)
  - `SenkouPeriod` (int, default 52)
  - `CloudColorBull` (color, default clrGreen)
  - `CloudColorBear` (color, default clrRed)
- **Tipo:** Indicador
- **En el gráfico:** Nube Ichimoku clásica con los 5 componentes y color de nube según tendencia.

### 10. GQ Support & Resistance (Indicador)

Soportes y resistencias dinámicos generados por clustering de pivotes altos y bajos.

- **Parámetros clave:**
  - `PivotLookback` (int, default 10)
  - `ClusterDistancePips` (int, default 20) — distancia para agrupar pivotes
  - `MaxLevels` (int, default 6)
  - `ShowPriceLabels` (bool, default true)
- **Tipo:** Indicador
- **En el gráfico:** Líneas horizontales con etiquetas de precio. Niveles más relevantes se dibujan más gruesos.

### 11. GQ Volume Profile (Indicador)

Perfil de volumen horizontal que muestra el volumen negociado en cada nivel de precio.

- **Parámetros clave:**
  - `NumRows` (int, default 24)
  - `ValueAreaVolume` (int, default 70) — % del volumen total para el Value Area
  - `ShowPOC` (bool, default true)
  - `ShowVAH` (bool, default true)
  - `ShowVAL` (bool, default true)
- **Tipo:** Indicador
- **En el gráfico:** Histograma horizontal a la derecha del precio con POC, VAH y VAL marcados.

---

## 🚀 Instalación en MetaTrader

### Abrir MetaEditor

Presiona **F4** estando en MT4 o MT5. Se abrirá MetaEditor con el navegador de archivos.

### Compilar archivos .mq4 / .mq5

1. En MetaEditor: **Archivo → Abrir** → selecciona el archivo `.mq4` (para MT4) o `.mq5` (para MT5).
2. El archivo se abrirá en el editor. Presiona **F7** (Compilar).
3. Verás en la consola: "0 error(es), 0 advertencia(s)" si la compilación fue exitosa.
4. El archivo compilado (`.ex4` para MT4, `.ex5` para MT5) se guarda automáticamente en la carpeta `Indicators` o `Experts`.

### Instalar un EA

1. Después de compilar, abre el Navegador en MT (`Ctrl+N`).
2. Busca el EA en la carpeta **Expert Advisors**.
3. Arrastra el EA al gráfico del símbolo deseado.
4. En la ventana que aparece:
   - **Common:** Activa "Allow live trading" y "Allow automated trading".
   - **Inputs:** Ajusta los parámetros según tu preferencia.
   - **OK** para adjuntar.
5. Asegúrate de que el botón **Auto Trading** esté activado (verde) en la barra de herramientas superior.

### Instalar un Indicador

1. Después de compilar, abre el Navegador en MT (`Ctrl+N`).
2. Busca el indicador en la carpeta **Indicators** → **Custom**.
3. Arrastra el indicador al gráfico.
4. En la ventana de parámetros, ajusta los inputs y colores.
5. Haz clic en **OK** para agregarlo al gráfico.

---

## ⚙️ Cómo Ajustar Parámetros

### Para EAs

Cuando arrastras un EA al gráfico:
1. Ve a la pestaña **Inputs** (parámetros de entrada).
2. Cada parámetro muestra su nombre, tipo, valor actual y a veces una descripción.
3. Haz doble clic en el valor para editarlo.
4. Presiona **OK** para aplicar.

### Para Indicadores

Al arrastrar un indicador:
1. Pestaña **Parameters** — inputs numéricos y de configuración.
2. Pestaña **Colors** — colores de las líneas y niveles.
3. Pestaña **Visualization** — en qué timeframes se muestra.

---

## 🔢 Números Mágicos (Magic Number)

Los EAs usan un **Magic Number** para identificar las órdenes que les pertenecen. Esto evita conflictos cuando múltiples EAs operan en el mismo símbolo.

| EA | Magic Number Default |
|----|---------------------|
| GQ MACD Trader | 202401 |
| GQ Bollinger Reversion | 202402 |
| GQ Trend Follow | 202403 |
| GQ SuperTrend | 202404 |
| GQ Position Sizer | 202405 |

> [!IMPORTANT]
> - Si ejecutas el mismo EA en múltiples gráficos del mismo símbolo, **cambia el Magic Number** para que no se interfieran.
> - Si usas múltiples EAs diferentes, los Magic Numbers por defecto ya son distintos.
> - Nunca uses Magic Number 0 (es el valor por defecto para operaciones manuales).

---

## ⚠️ Advertencias de Riesgo

> [!CAUTION]
> - **Siempre prueba en una cuenta demo** durante al menos 100 operaciones o 30 días antes de usar en vivo.
> - Los EAs pueden operar 24/7 y acumular pérdidas rápidamente si el mercado se vuelve desfavorable.
> - Verifica que el broker permita el tipo de ejecución (Market, Pending) y el hedging (MT4) vs netting (MT5).
> - El backtesting en MT4 es limitado. MT5 ofrece mejores herramientas de simulación.
> - Revisa periódicamente que el EA sigue activo y funcionando correctamente.
> - No dejes EAs sin supervisión en cuentas reales.

### Recomendaciones

1. Comienza con lote 0.01 en demo.
2. Lee el código fuente para entender exactamente qué hace cada EA/indicador.
3. Activa alertas por email para monitorear el comportamiento.
4. No sobrecargues un gráfico con múltiples EAs.
5. Mantén actualizado el registro de operaciones (trading journal).

---

## 🔗 Enlaces

- [Repositorio principal](https://github.com/guetaquant-byte/guetaquant-tools)
- [Documentación MQL4](https://docs.mql4.com/)
- [Documentación MQL5](https://www.mql5.com/en/docs)
- [Gueta Quant — Portal educativo](https://guetaquant.com)

---

<br>

---

## ENGLISH

# 📊 MQL4 & MQL5 — Gueta Quant

**22 MQL files (11 MQL4 + 11 MQL5) for MetaTrader 4 and MetaTrader 5.**  
Educational indicators and EAs. Always test on demo before live trading.

> Main repository: [github.com/guetaquant-byte/guetaquant-tools](https://github.com/guetaquant-byte/guetaquant-tools)

---

## 🧠 MQL4 vs MQL5 — Which to use?

| Feature | MQL4 (MT4) | MQL5 (MT5) |
|---------|------------|------------|
| **Platform** | MetaTrader 4 | MetaTrader 5 |
| **Paradigm** | Procedural | Object-oriented |
| **Execution** | Per tick (every price change) | Per tick with trading events |
| **Orders** | Market / Pending / Stop / Limit | Market / Pending / Stop Limit / SL / TP |
| **Backtesting** | Basic simulation | Multi-currency, real ticks, hedging |
| **Indicators** | `iCustom()` with simple buffers | `IndicatorCreate()` with handles |
| **Compatible with** | MT4 Builds 1400+ | MT5 Builds 4000+ |

> **Simple rule:** Use `.mq4` files on MT4 and `.mq5` files on MT5. They are not interchangeable.

---

## 📋 Tool List

| # | Tool | Files | Type | Description |
|---|------|-------|------|-------------|
| 1 | **GQ Position Sizer** | `.mq4` / `.mq5` | EA | Calculates position size based on ATR and % risk. Does not open trades. |
| 2 | **GQ SuperTrend** | `.mq4` / `.mq5` | EA | Trend follower with ATR SuperTrend and trailing stop. |
| 3 | **GQ MACD Trader** | `.mq4` / `.mq5` | EA | Trades MACD crossovers with ATR-based dynamic stop loss. |
| 4 | **GQ Bollinger Reversion** | `.mq4` / `.mq5` | EA | Mean reversion strategy using Bollinger Bands + RSI. |
| 5 | **GQ Trend Follow** | `.mq4` / `.mq5` | EA | MA crossover trend follower. |
| 6 | **GQ RSI Pro** | `.mq4` / `.mq5` | Indicator | RSI with visual regular and hidden divergence detection. |
| 7 | **GQ ATR Stop Loss** | `.mq4` / `.mq5` | Indicator | Visual ATR-based trailing stop line drawn over price. |
| 8 | **GQ Market Structure** | `.mq4` / `.mq5` | Indicator | Draws BOS, CHoCH, FVG, and Order Blocks on chart. |
| 9 | **GQ Ichimoku Cloud** | `.mq4` / `.mq5` | Indicator | Complete Ichimoku system with all 5 components. |
| 10 | **GQ Support & Resistance** | `.mq4` / `.mq5` | Indicator | Dynamic S/R levels via pivot clustering. |
| 11 | **GQ Volume Profile** | `.mq4` / `.mq5` | Indicator | Horizontal volume profile with POC and Value Area. |

---

## 🔧 Per-Tool Detail

### 1. GQ Position Sizer (EA)

Risk calculator determining optimal lot size based on ATR-measured stop distance.

- **Key inputs:**
  - `RiskPercent` (double, default 1.0), `ATRPeriod` (int, default 14)
  - `ATRMultiplier` (double, default 2.0), `MaxLot` (double, default 10.0)
- **Type:** EA (no trade execution, calculation only)
- **On chart:** Label showing recommended position size.

### 2. GQ SuperTrend (EA)

Trend-following EA using SuperTrend indicator for direction and ATR for trailing stop.

- **Key inputs:**
  - `SuperTrendPeriod` (int, default 10), `SuperTrendMultiplier` (double, default 3.0)
  - `ATRStopMultiplier` (double, default 2.0), `UseBreakeven` (bool, default true)
- **Type:** EA
- **On chart:** SuperTrend line and executed entry/exit markers.

### 3. GQ MACD Trader (EA)

EA trading MACD line vs signal line crossovers with ATR filters.

- **Key inputs:**
  - `FastEMA` (int, default 12), `SlowEMA` (int, default 26), `SignalSMA` (int, default 9)
  - `ATRStopMultiplier` (double, default 1.5), `ATRProfitMultiplier` (double, default 3.0)
  - `MagicNumber` (int, default 202401)
- **Type:** EA
- **On chart:** Entry arrows and stop/take-profit lines.

### 4. GQ Bollinger Reversion (EA)

Mean reversion EA opening positions when price touches outer bands and RSI confirms.

- **Key inputs:**
  - `BBPeriod` (int, default 20), `BBDeviation` (double, default 2.0)
  - `RSIPeriod` (int, default 14), `RSIOverbought` (int, default 70), `RSIOversold` (int, default 30)
  - `MagicNumber` (int, default 202402)
- **Type:** EA
- **On chart:** Bollinger Bands and entry markers.

### 5. GQ Trend Follow (EA)

MA crossover EA with trend filter and trailing stop.

- **Key inputs:**
  - `FastMA` (int, default 10), `SlowMA` (int, default 30), `MAMethod` (enum, default MODE_EMA)
  - `ATRTrailingMultiplier` (double, default 2.0), `MagicNumber` (int, default 202403)
- **Type:** EA
- **On chart:** Moving averages and entry markers.

### 6. GQ RSI Pro (Indicator)

Enhanced RSI with automatic regular and hidden divergence detection.

- **Key inputs:**
  - `RSIPeriod` (int, default 14), `OverboughtLevel` (int, default 70), `OversoldLevel` (int, default 30)
  - `DivLookback` (int, default 60)
- **Type:** Indicator
- **On chart:** Separate RSI window with bullish/bearish divergence arrows.

### 7. GQ ATR Stop Loss (Indicator)

Visual trailing stop line based on ATR drawn directly over price.

- **Key inputs:**
  - `ATRPeriod` (int, default 14), `ATRMultiplier` (double, default 2.0)
  - `ShowStopLine` (bool, default true), `LineColor` (color, default clrRed)
- **Type:** Indicator
- **On chart:** Dynamic line trailing price at ATR-based distance.

### 8. GQ Market Structure (Indicator)

SMC/ICT indicator identifying and drawing market structure.

- **Key inputs:**
  - `PivotLookback` (int, default 5), `ShowFVG` (bool, default true)
  - `ShowBOS` (bool, default true), `ShowOrderBlocks` (bool, default true)
  - `FVGThreshold` (double, default 0.0001)
- **Type:** Indicator
- **On chart:** FVG rectangles, BOS/CHoCH lines, Order Block zones.

### 9. GQ Ichimoku Cloud (Indicator)

Full Ichimoku system with all components.

- **Key inputs:**
  - `TenkanPeriod` (int, default 9), `KijunPeriod` (int, default 26), `SenkouPeriod` (int, default 52)
  - `CloudColorBull` (color, default clrGreen), `CloudColorBear` (color, default clrRed)
- **Type:** Indicator
- **On chart:** Classic Ichimoku cloud with all 5 components.

### 10. GQ Support & Resistance (Indicator)

Dynamic S/R via high/low pivot clustering.

- **Key inputs:**
  - `PivotLookback` (int, default 10), `ClusterDistancePips` (int, default 20)
  - `MaxLevels` (int, default 6), `ShowPriceLabels` (bool, default true)
- **Type:** Indicator
- **On chart:** Horizontal levels with price labels. Thicker = higher significance.

### 11. GQ Volume Profile (Indicator)

Horizontal volume profile showing traded volume at each price level.

- **Key inputs:**
  - `NumRows` (int, default 24), `ValueAreaVolume` (int, default 70)
  - `ShowPOC` (bool, default true), `ShowVAH` (bool, default true), `ShowVAL` (bool, default true)
- **Type:** Indicator
- **On chart:** Horizontal histogram with POC, VAH, VAL markers.

---

## 🚀 Installation on MetaTrader

### Opening MetaEditor

Press **F4** inside MT4 or MT5. MetaEditor opens with the file browser.

### Compile .mq4 / .mq5 files

1. In MetaEditor: **File → Open** → select `.mq4` (for MT4) or `.mq5` (for MT5).
2. The file opens in the editor. Press **F7** (Compile).
3. Console shows "0 error(s), 0 warning(s)" on success.
4. Compiled file (`.ex4` for MT4, `.ex5` for MT5) saves automatically to `Indicators` or `Experts` folder.

### Installing an EA

1. After compiling, open Navigator in MT (`Ctrl+N`).
2. Find the EA under **Expert Advisors**.
3. Drag the EA onto the desired symbol chart.
4. In the popup:
   - **Common:** Enable "Allow live trading" and "Allow automated trading".
   - **Inputs:** Adjust parameters.
   - **OK** to attach.
5. Ensure **Auto Trading** button is green (enabled) on the top toolbar.

### Installing an Indicator

1. After compiling, open Navigator (`Ctrl+N`).
2. Find the indicator under **Indicators** → **Custom**.
3. Drag onto chart.
4. Adjust inputs and colors in the parameter window.
5. Click **OK** to add to chart.

---

## ⚙️ Adjusting Parameters

### For EAs

When dragging an EA to chart:
1. Go to **Inputs** tab.
2. Each parameter shows name, type, current value, and description.
3. Double-click a value to edit.
4. Press **OK** to apply.

### For Indicators

When dragging an indicator:
1. **Parameters** tab — numeric and config inputs.
2. **Colors** tab — line and level colors.
3. **Visualization** tab — visible timeframes.

---

## 🔢 Magic Numbers

EAs use a **Magic Number** to identify their own orders, preventing conflicts when multiple EAs run on the same symbol.

| EA | Default Magic Number |
|----|---------------------|
| GQ MACD Trader | 202401 |
| GQ Bollinger Reversion | 202402 |
| GQ Trend Follow | 202403 |
| GQ SuperTrend | 202404 |
| GQ Position Sizer | 202405 |

> [!IMPORTANT]
> - Running the same EA on multiple charts for the same symbol? **Change the Magic Number** to avoid interference.
> - Different EAs already have distinct default Magic Numbers.
> - Never use Magic Number 0 (reserved for manual trades).

---

## ⚠️ Risk Warnings

> [!CAUTION]
> - **Always test on a demo account** for at least 100 trades or 30 days before going live.
> - EAs can trade 24/7 and accumulate losses quickly if market conditions turn unfavorable.
> - Verify your broker supports the execution type (Market, Pending) and hedging (MT4) vs netting (MT5).
> - MT4 backtesting is limited. MT5 offers superior simulation tools.
> - Periodically check that the EA is still active and working correctly.
> - Do not leave unsupervised EAs on real accounts.

### Recommendations

1. Start with 0.01 lot on demo.
2. Read the source code to fully understand each tool.
3. Enable email alerts to monitor behavior.
4. Do not overload a single chart with multiple EAs.
5. Keep a detailed trading journal.

---

## 🔗 Links

- [Main repository](https://github.com/guetaquant-byte/guetaquant-tools)
- [MQL4 Documentation](https://docs.mql4.com/)
- [MQL5 Documentation](https://www.mql5.com/en/docs)
- [Gueta Quant — Educational portal](https://guetaquant.com)

---

*© 2025 Gueta Quant — Educational use under AGPLv3*
