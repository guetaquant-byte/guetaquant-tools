# 🤖 cTrader C# cBots — Gueta Quant

**11 cBots para cTrader escritos en C# .NET.**  
Automatización cuantitativa educativa. Siempre prueba en demo antes de operar en vivo.

> Repositorio principal: [github.com/guetaquant-byte/guetaquant-tools](https://github.com/guetaquant-byte/guetaquant-tools)

---

## 📋 Lista de Herramientas

| # | cBot | Archivo | Descripción |
|---|------|---------|-------------|
| 1 | **GQ Position Sizer** | `GQ_Position_Sizer_cBot.cs` | Calcula el tamaño de posición basado en ATR, riesgo porcentual y distancia al stop. |
| 2 | **GQ Trend Follower** | `GQ_Trend_Follower.cs` | Trend follower multi-indicador usando EMA + SuperTrend + ATR para filtros de entrada. |
| 3 | **GQ Breakout ORB** | `GQ_Breakout_Orb.cs` | Breakout del rango de apertura (Opening Range Breakout) con órdenes pendientes. |
| 4 | **GQ Grid Scalper** | `GQ_Grid_Scalper.cs` | Grid scalper adaptativo con espaciado basado en ATR y gestión de niveles. |
| 5 | **GQ Mean Reversion** | `GQ_Mean_Reversion.cs` | Reversión a la media usando Bandas de Bollinger + RSI + filtro de volumen. |
| 6 | **GQ Divergence Scanner** | `GQ_Divergence_Scanner.cs` | Escáner multi-símbolo que detecta divergencias RSI/MACD en múltiples activos. |
| 7 | **GQ Trailing Stop Manager** | `GQ_Trailing_Stop_Manager.cs` | 4 métodos de trailing stop (ATR, porcentaje, fixed, parabolico) con toma parcial. |
| 8 | **GQ DCA Recovery** | `GQ_DCA_Recovery.cs` | Recuperación adaptativa DCA (Dollar Cost Average) con take profit de canasta. |
| 9 | **GQ Session Scalper** | `GQ_Session_Scalper.cs` | Scalper por ventanas de tiempo para sesiones de alta probabilidad (Londres/NY). |
| 10 | **GQ Multi-Symbol Scanner** | `GQ_Multi_Symbol_Scanner.cs` | Escáner multi-símbolo con ranking por fuerza de tendencia y momentum. |
| 11 | **GQ Risk Manager** | `GQ_Risk_Manager.cs` | Gestor de riesgo a nivel portafolio: drawdown máximo, exposición, y stops globales. |

---

## 🔧 Detalle por cBot

### 1. GQ Position Sizer

Calcula automáticamente el tamaño de posición ideal basado en la distancia al stop medida en ATR.

- **Parámetros clave:**
  - `RiskPercent` (double, default 1.0) — % del capital a arriesgar por operación
  - `ATRPeriod` (int, default 14) — períodos para cálculo de ATR
  - `ATRMultiplier` (double, default 2.0) — multiplicador para distancia del stop
  - `MaxPositionSize` (double, default 100000) — tamaño máximo en unidades
- **Comportamiento:** No abre operaciones por sí mismo. Se integra con otros cBots para calcular lotaje óptimo.

### 2. GQ Trend Follower

Sistema de seguimiento de tendencia que combina EMA (2 períodos), SuperTrend, y filtro de ATR mínimo.

- **Parámetros clave:**
  - `FastEMA` (int, default 20) — EMA rápida
  - `SlowEMA` (int, default 50) — EMA lenta
  - `SuperTrendPeriod` (int, default 10) — período del SuperTrend
  - `SuperTrendMultiplier` (double, default 3.0) — multiplicador ATR del SuperTrend
  - `MinATR` (double, default 0.0005) — ATR mínimo para filtrar mercados laterales
- **Comportamiento:** Abre largo cuando EMA rápida cruza arriba de lenta y SuperTrend es alcista. Corto en condición opuesta. Trailing stop por ATR.

### 3. GQ Breakout ORB

Opera la ruptura del rango de apertura después de un período de acumulación inicial.

- **Parámetros clave:**
  - `OrbMinutes` (int, default 30) — minutos para definir el rango de apertura
  - `BreakoutBuffer` (double, default 0.0002) — buffer en pips para evitar falsos rompimientos
  - `StopLossATR` (double, default 1.5) — stop loss en ATR
  - `TakeProfitATR` (double, default 3.0) — take profit en ATR
- **Comportamiento:** Coloca órdenes pendientes Buy Stop y Sell Stop por encima/debajo del rango. Cancela órdenes no ejecutadas al cierre de la sesión.

### 4. GQ Grid Scalper

Grid automático con espaciado adaptativo basado en ATR y toma de ganancias por niveles.

- **Parámetros clave:**
  - `GridLevels` (int, default 5) — número de niveles del grid
  - `GridSpacingATR` (double, default 0.5) — espaciado entre niveles en ATR
  - `TakeProfitATR` (double, default 0.8) — take profit por nivel en ATR
  - `MaxSpread` (double, default 0.0003) — spread máximo permitido para abrir órdenes
- **Comportamiento:** Abre posiciones largas y cortas en niveles escalonados. Cada nivel tiene su propio TP. El grid se rebalancea automáticamente.

### 5. GQ Mean Reversion

Busca reversiones a la media cuando el precio se extiende fuera de las Bandas de Bollinger y el RSI confirma sobre-compra/venta.

- **Parámetros clave:**
  - `BBPeriod` (int, default 20) — período de las Bandas de Bollinger
  - `BBStdDev` (double, default 2.0) — desviaciones estándar
  - `RSIPeriod` (int, default 14) — período del RSI
  - `RSIThreshold` (double, default 30.0) — umbral de sobre-compra (100 - threshold) / sobre-venta (threshold)
  - `VolumeFilter` (bool, default true) — filtrar por aumento de volumen
- **Comportamiento:** Abre corto cuando precio toca banda superior + RSI > 70. Abre largo cuando toca banda inferior + RSI < 30. Stop loss en la banda opuesta.

### 6. GQ Divergence Scanner

Escanea múltiples símbolos en busca de divergencias entre precio y RSI o MACD.

- **Parámetros clave:**
  - `ScanSymbols` (string, default "EURUSD,GBPUSD,USDJPY") — lista separada por comas
  - `DivergenceType` (enum, default RSI) — RSI o MACD
  - `LookbackBars` (int, default 50) — barras hacia atrás para buscar divergencias
  - `MinDivStrength` (double, default 0.5) — fuerza mínima de divergencia
- **Comportamiento:** No abre operaciones. Genera alertas y muestra en el log los símbolos con divergencias detectadas. Ideal para encontrar oportunidades en múltiples pares.

### 7. GQ Trailing Stop Manager

Gestiona el trailing stop de posiciones existentes usando 4 métodos diferentes.

- **Parámetros clave:**
  - `TrailingMethod` (enum, default ATR) — ATR, Percentage, Fixed, Parabolic
  - `ATRPeriod` (int, default 14) — período ATR para método ATR
  - `ATRMultiplier` (double, default 2.0) — multiplicador para trailing ATR
  - `TrailPercent` (double, default 1.0) — porcentaje para trailing percentage
  - `PartialProfitPercent` (double, default 50.0) — % de la posición a cerrar parcialmente
  - `PartialProfitTarget` (double, default 1.5) — target en ATR para toma parcial
- **Comportamiento:** Se adjunta al mismo símbolo que otras posiciones. Monitorea y ajusta stops dinámicamente. Ejecuta toma parcial al alcanzar el primer target.

### 8. GQ DCA Recovery

Sistema de recuperación por Dollar Cost Average que agrega posiciones en contra de la dirección inicial.

- **Parámetros clave:**
  - `MaxLevels` (int, default 5) — niveles máximos de DCA
  - `LevelSpacingATR` (double, default 1.0) — espaciado entre niveles en ATR
  - `LotMultiplier` (double, default 1.5) — multiplicador de lote por nivel (piramiding)
  - `BasketTPATR` (double, default 0.5) — take profit de la canasta en ATR
  - `MaxDrawdownPercent` (double, default 10.0) — drawdown máximo antes de detener DCA
- **Comportamiento:** Abre posición inicial. Si el precio se mueve en contra, abre posiciones adicionales en niveles predefinidos. Todas las posiciones se cierran como canasta cuando el TP se alcanza.

### 9. GQ Session Scalper

Scalper que opera solo durante ventanas de tiempo específicas con alta probabilidad estadística.

- **Parámetros clave:**
  - `SessionStart` (TimeSpan, default "08:00") — inicio de sesión (hora del broker)
  - `SessionEnd` (TimeSpan, default "17:00") — fin de sesión
  - `TradeDirection` (enum, default Both) — Long, Short, o Both
  - `MinRangeATR` (double, default 0.3) — rango mínimo en ATR para abrir operación
  - `StopLossATR` (double, default 0.8) — stop loss en ATR
  - `TakeProfitATR` (double, default 1.2) — take profit en ATR
  - `MaxTradesPerSession` (int, default 3) — máximo de operaciones por sesión
- **Comportamiento:** Solo opera dentro de la ventana horaria definida. Usa un filtro de rango mínimo para evitar mercados planos. No abre posiciones fuera del horario.

### 10. GQ Multi-Symbol Scanner

Escáner que rankea múltiples símbolos por fuerza de tendencia usando EMAs y tasa de cambio.

- **Parámetros clave:**
  - `SymbolList` (string, default "EURUSD,GBPUSD,USDJPY,AUDUSD,USDCAD,NZDUSD,USDCHF") — símbolos a escanear
  - `FastEMA` (int, default 10) — EMA rápida para ranking
  - `SlowEMA` (int, default 30) — EMA lenta para ranking
  - `TopRankToTrade` (int, default 2) — cantidad de símbolos top a operar
  - `MinScore` (double, default 0.3) — puntaje mínimo para considerar operación
- **Comportamiento:** Calcula un score de tendencia para cada símbolo. Opera solo los N mejores rankeados. Rotación automática cuando cambia el ranking.

### 11. GQ Risk Manager

Gestor de riesgo global que monitorea todo el portafolio y aplica stops de emergencia.

- **Parámetros clave:**
  - `MaxDailyDrawdown` (double, default 5.0) — drawdown diario máximo % antes de cerrar todo
  - `MaxTotalExposure` (double, default 10.0) — exposición total máxima como % del capital
  - `MaxConsecutiveLosses` (int, default 5) — pérdidas consecutivas máximas antes de pausar
  - `CooldownMinutes` (int, default 60) — minutos de enfriamiento después de pausa
  - `NotifyOnStop` (bool, default true) — notificar cuando se active un stop de emergencia
- **Comportamiento:** Se ejecuta en segundo plano. Monitorea drawdown, exposición, y pérdidas consecutivas. Puede cerrar todas las posiciones y pausar el trading automáticamente.

---

## 🚀 Instalación en cTrader

### Paso a paso

1. **Abrir Automate:** En cTrader, haz clic en **Automate** (icono de engranaje en la barra lateral izquierda).
2. **Crear nuevo cBot:** Haz clic en **New cBot** → **Source Files**.
3. **Pegar el código:** El editor mostrará un cBot genérico. Selecciona todo el texto (`Ctrl+A` / `Cmd+A`) y reemplázalo con el contenido del archivo `.cs` correspondiente.
4. **Compilar:** Haz clic en **Compile** (o presiona `F7`). Debes ver "Compiled successfully" en la consola.
5. **Adjuntar al gráfico:** Arrastra el cBot desde la lista de **My cBots** al gráfico del símbolo deseado.
6. **Configurar parámetros:** Aparecerá una ventana con los inputs del cBot. Ajusta los valores según tu estrategia.
7. **Iniciar:** Haz clic en **Start** para activar el cBot.

### Para backtesting

1. Abre **Automate** → **cBots** → selecciona tu cBot.
2. Haz clic en **Backtest** en lugar de arrastrar al gráfico.
3. Configura el período, símbolo y parámetros.
4. Ejecuta y analiza el reporte.

### Para live trading

1. Asegúrate de tener una cuenta real (o demo) conectada.
2. Sigue los pasos 1-6 arriba.
3. Verifica que el botón **Auto trading** esté activado (verde) en la esquina inferior izquierda.
4. Monitorea las primeras operaciones para confirmar comportamiento esperado.

---

## ⚙️ Configuración de Parámetros en la UI

Cuando adjuntas un cBot al gráfico, cTrader muestra una ventana de configuración con:

- **Inputs:** Todos los parámetros públicos con controles nativos (sliders, text boxes, dropdowns, checkboxes).
- **Display:** Opciones para mostrar información en el gráfico (etiquetas, líneas).
- **Common:** Configuración de permisos (trading, notificaciones).

Para modificar parámetros después de iniciar:
1. Detén el cBot (Stop).
2. Haz clic derecho en el indicador/cBot → **Settings**.
3. Ajusta los valores.
4. Reinicia el cBot (Start).

---

## ⚠️ Advertencias de Riesgo

> [!CAUTION]
> - **Siempre prueba primero en una cuenta demo** durante al menos 20-30 operaciones.
> - Los cBots automatizados pueden generar pérdidas rápidamente si no se configuran correctamente.
> - El backtesting no garantiza resultados futuros. Las condiciones del mercado cambian.
> - Entiende completamente la lógica de cada cBot antes de usarlo en vivo.
> - Usa siempre un stop loss global y monitorea el riesgo de portafolio (especialmente con Grid/DCA bots).

### Recomendaciones de seguridad

1. Comienza con riesgo bajo (0.5-1% por operación).
2. No ejecutes múltiples cBots en el mismo símbolo sin coordinar la lógica.
3. Revisa los logs periódicamente en Automate → Log.
4. Activa notificaciones de email/push para eventos críticos.

---

## 🔗 Enlaces

- [Repositorio principal](https://github.com/guetaquant-byte/guetaquant-tools)
- [Documentación cTrader Automate](https://ctrader.com/automate)
- [Gueta Quant — Portal educativo](https://guetaquant.com)

---

<br>

---

## ENGLISH

# 🤖 cTrader C# cBots — Gueta Quant

**11 cBots for cTrader written in C# .NET.**  
Educational quantitative automation. Always test on demo before live trading.

> Main repository: [github.com/guetaquant-byte/guetaquant-tools](https://github.com/guetaquant-byte/guetaquant-tools)

---

## 📋 Tool List

| # | cBot | File | Description |
|---|------|------|-------------|
| 1 | **GQ Position Sizer** | `GQ_Position_Sizer_cBot.cs` | Calculates position size based on ATR, percentage risk, and stop distance. |
| 2 | **GQ Trend Follower** | `GQ_Trend_Follower.cs` | Multi-indicator trend follower using EMA + SuperTrend + ATR filters. |
| 3 | **GQ Breakout ORB** | `GQ_Breakout_Orb.cs` | Opening Range Breakout with pending orders. |
| 4 | **GQ Grid Scalper** | `GQ_Grid_Scalper.cs` | ATR-adaptive grid scalper with level management. |
| 5 | **GQ Mean Reversion** | `GQ_Mean_Reversion.cs` | Mean reversion using Bollinger Bands + RSI + volume filter. |
| 6 | **GQ Divergence Scanner** | `GQ_Divergence_Scanner.cs` | Multi-symbol RSI/MACD divergence scanner. |
| 7 | **GQ Trailing Stop Manager** | `GQ_Trailing_Stop_Manager.cs` | 4 trailing methods (ATR, percentage, fixed, parabolic) with partial take-profit. |
| 8 | **GQ DCA Recovery** | `GQ_DCA_Recovery.cs` | Adaptive Dollar Cost Average recovery with basket take-profit. |
| 9 | **GQ Session Scalper** | `GQ_Session_Scalper.cs` | Time-window scalper for high-probability sessions (London/NY). |
| 10 | **GQ Multi-Symbol Scanner** | `GQ_Multi_Symbol_Scanner.cs` | Ranked multi-symbol trend strength scanner. |
| 11 | **GQ Risk Manager** | `GQ_Risk_Manager.cs` | Portfolio-level risk manager: max drawdown, exposure, and emergency stops. |

---

## 🔧 Per-cBot Detail

### 1. GQ Position Sizer

Automatically calculates optimal position size based on ATR-measured stop distance.

- **Key parameters:**
  - `RiskPercent` (double, default 1.0) — % of capital to risk per trade
  - `ATRPeriod` (int, default 14) — ATR calculation period
  - `ATRMultiplier` (double, default 2.0) — multiplier for stop distance
  - `MaxPositionSize` (double, default 100000) — maximum units
- **Behavior:** Does not open trades on its own. Integrates with other cBots for optimal lot sizing.

### 2. GQ Trend Follower

Trend-following system combining EMA crossovers, SuperTrend direction, and minimum ATR filter.

- **Key parameters:**
  - `FastEMA` (int, default 20), `SlowEMA` (int, default 50)
  - `SuperTrendPeriod` (int, default 10), `SuperTrendMultiplier` (double, default 3.0)
  - `MinATR` (double, default 0.0005) — minimum ATR to filter sideways markets
- **Behavior:** Long when fast EMA crosses above slow EMA and SuperTrend is bullish. Short opposite. ATR trailing stop.

### 3. GQ Breakout ORB

Trades the breakout of the opening range after an initial accumulation period.

- **Key parameters:**
  - `OrbMinutes` (int, default 30), `BreakoutBuffer` (double, default 0.0002)
  - `StopLossATR` (double, default 1.5), `TakeProfitATR` (double, default 3.0)
- **Behavior:** Places Buy Stop and Sell Stop orders above/below the range. Cancels unexecuted orders at session close.

### 4. GQ Grid Scalper

Automatic grid with ATR-adaptive spacing and per-level take profit.

- **Key parameters:**
  - `GridLevels` (int, default 5), `GridSpacingATR` (double, default 0.5)
  - `TakeProfitATR` (double, default 0.8), `MaxSpread` (double, default 0.0003)
- **Behavior:** Opens long and short positions at staggered levels. Each level has its own TP. Grid auto-rebalances.

### 5. GQ Mean Reversion

Seeks mean reversion when price extends beyond Bollinger Bands and RSI confirms overbought/oversold.

- **Key parameters:**
  - `BBPeriod` (int, default 20), `BBStdDev` (double, default 2.0)
  - `RSIPeriod` (int, default 14), `RSIThreshold` (double, default 30.0)
  - `VolumeFilter` (bool, default true)
- **Behavior:** Short when price touches upper band + RSI > 70. Long when touching lower band + RSI < 30. Stop at opposite band.

### 6. GQ Divergence Scanner

Scans multiple symbols for RSI or MACD divergences.

- **Key parameters:**
  - `ScanSymbols` (string, default "EURUSD,GBPUSD,USDJPY")
  - `DivergenceType` (enum, default RSI)
  - `LookbackBars` (int, default 50), `MinDivStrength` (double, default 0.5)
- **Behavior:** Does not open trades. Generates alerts and logs symbols with detected divergences.

### 7. GQ Trailing Stop Manager

Manages trailing stops on existing positions using 4 different methods.

- **Key parameters:**
  - `TrailingMethod` (enum, default ATR) — ATR, Percentage, Fixed, Parabolic
  - `ATRPeriod` (int, default 14), `ATRMultiplier` (double, default 2.0)
  - `TrailPercent` (double, default 1.0)
  - `PartialProfitPercent` (double, default 50.0), `PartialProfitTarget` (double, default 1.5)
- **Behavior:** Attaches to the same symbol as existing positions. Dynamically adjusts stops. Executes partial take-profit at first target.

### 8. GQ DCA Recovery

Dollar Cost Average recovery system that adds positions against the initial direction.

- **Key parameters:**
  - `MaxLevels` (int, default 5), `LevelSpacingATR` (double, default 1.0)
  - `LotMultiplier` (double, default 1.5), `BasketTPATR` (double, default 0.5)
  - `MaxDrawdownPercent` (double, default 10.0)
- **Behavior:** Opens initial position. If price moves against, adds positions at predefined levels. All positions close as a basket at TP.

### 9. GQ Session Scalper

Scalper operating only during specific time windows with high statistical probability.

- **Key parameters:**
  - `SessionStart` (TimeSpan, default "08:00"), `SessionEnd` (TimeSpan, default "17:00")
  - `TradeDirection` (enum, default Both), `MinRangeATR` (double, default 0.3)
  - `StopLossATR` (double, default 0.8), `TakeProfitATR` (double, default 1.2)
  - `MaxTradesPerSession` (int, default 3)
- **Behavior:** Operates only within the defined time window. Filters flat markets via minimum range check.

### 10. GQ Multi-Symbol Scanner

Ranks multiple symbols by trend strength using EMAs and rate of change.

- **Key parameters:**
  - `SymbolList` (string, default majors list)
  - `FastEMA` (int, default 10), `SlowEMA` (int, default 30)
  - `TopRankToTrade` (int, default 2), `MinScore` (double, default 0.3)
- **Behavior:** Calculates trend score per symbol. Trades only top N ranked. Auto-rotates when ranking changes.

### 11. GQ Risk Manager

Global risk monitor that watches the entire portfolio and applies emergency stops.

- **Key parameters:**
  - `MaxDailyDrawdown` (double, default 5.0), `MaxTotalExposure` (double, default 10.0)
  - `MaxConsecutiveLosses` (int, default 5), `CooldownMinutes` (int, default 60)
  - `NotifyOnStop` (bool, default true)
- **Behavior:** Runs in background. Monitors drawdown, exposure, and consecutive losses. Can close all positions and pause trading.

---

## 🚀 Installation on cTrader

### Step by step

1. **Open Automate:** Click **Automate** (gear icon in left sidebar).
2. **Create new cBot:** Click **New cBot** → **Source Files**.
3. **Paste code:** Select all generic code (`Ctrl+A` / `Cmd+A`) and replace with the `.cs` file content.
4. **Compile:** Click **Compile** (or press `F7`). Confirm "Compiled successfully".
5. **Attach to chart:** Drag the cBot from **My cBots** list onto your desired symbol chart.
6. **Configure parameters:** Adjust inputs in the popup dialog.
7. **Start:** Click **Start** to activate.

### Backtesting

1. Open **Automate** → **cBots** → select your cBot.
2. Click **Backtest** instead of dragging to chart.
3. Set period, symbol, and parameters.
4. Run and analyze the report.

### Live trading

1. Ensure a live (or demo) account is connected.
2. Follow steps 1–6 above.
3. Verify **Auto trading** is enabled (green) in the bottom-left corner.
4. Monitor initial trades to confirm expected behavior.

---

## ⚙️ Parameter Configuration in UI

When attaching a cBot, cTrader shows a configuration window with:

- **Inputs:** All public parameters with native controls.
- **Display:** Chart display options (labels, lines).
- **Common:** Permission settings (trading, notifications).

To modify parameters after starting:
1. Stop the cBot.
2. Right-click → **Settings**.
3. Adjust values.
4. Restart (Start).

---

## ⚠️ Risk Warnings

> [!CAUTION]
> - **Always test on a demo account first** for at least 20-30 trades.
> - Automated cBots can generate losses quickly if misconfigured.
> - Backtesting does not guarantee future results. Market conditions change.
> - Fully understand each cBot's logic before going live.
> - Use a global stop loss and monitor portfolio risk (especially with Grid/DCA bots).

### Safety recommendations

1. Start with low risk (0.5-1% per trade).
2. Do not run multiple cBots on the same symbol without coordinated logic.
3. Check logs periodically in Automate → Log.
4. Enable email/push notifications for critical events.

---

## 🔗 Links

- [Main repository](https://github.com/guetaquant-byte/guetaquant-tools)
- [cTrader Automate Documentation](https://ctrader.com/automate)
- [Gueta Quant — Educational portal](https://guetaquant.com)

---

*© 2026 Gueta Quant — Educational use under AGPLv3*
