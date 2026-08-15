> ⚠️ **Repaint notice:** `GQ_Volume_Profile` (mql4/mql5) includes the currently-forming bar in its profile, so POC/VAH/VAL and the histogram update intraday as the bar forms (standard intraday volume-profile behavior). For evaluation or decision-making, prefer analyzing closed sessions (e.g., previous day/session), or set the script to a closed-session timeframe. `GQ_Market_Structure` confirms pivots only after the right-side confirmation bars close — no repaint.

<div align="center">

<!-- LOGO PLACEHOLDER -->
<img src="https://guetaquant.com/images/gueta-quant-philosophy.avif" alt="Gueta Quant Logo" width="120" />

# 🏛️ Gueta Quant — Herramientas Open-Source

**Educación cuantitativa 100% independiente para traders de Colombia y Latinoamérica**

[![Licencia AGPLv3](https://img.shields.io/badge/Licencia-AGPL%20v3-gold?style=flat-square&logo=gnu)](./LICENSE)
[![Plataforma](https://img.shields.io/badge/Plataforma-MT4%20%7C%20MT5%20%7C%20cTrader%20%7C%20TradingView-blue?style=flat-square)](https://guetaquant.com/herramientas/)
[![Estado](https://img.shields.io/badge/Estado-Activo-brightgreen?style=flat-square)](https://guetaquant.com)
[![SFC Colombia](https://img.shields.io/badge/SFC_Colombia-Decreto_2555_de_2010-orange?style=flat-square)](https://guetaquant.com/nuestra-mision/)
[![Zero Señales](https://img.shields.io/badge/Zero%20Se%C3%B1ales-Política%20Estricta-red?style=flat-square)](https://guetaquant.com/nuestra-mision/)
[![Compile MQL](https://github.com/guetaquant-byte/guetaquant-tools/actions/workflows/compile-mql.yml/badge.svg)](https://github.com/guetaquant-byte/guetaquant-tools/actions/workflows/compile-mql.yml)
[![Static Checks](https://github.com/guetaquant-byte/guetaquant-tools/actions/workflows/static-checks.yml/badge.svg)](https://github.com/guetaquant-byte/guetaquant-tools/actions/workflows/static-checks.yml)

[🌐 Sitio Web](https://guetaquant.com) · [📖 Blog Educativo](https://guetaquant.com/blog/) · [📓 Trading Journal](https://guetaquant.com/journal/) · [🛠️ Herramientas](https://guetaquant.com/herramientas/)

---

</div>

> [!CAUTION]
> **⚠️ AVISO REGULATORIO SFC COLOMBIA:** Este repositorio es de uso **exclusivamente educativo**. Ningún código, indicador, ni herramienta publicada aquí constituye asesoría de inversión, señal de compra/venta, ni promesa de rentabilidad. Actividades de asesoría en valores sin registro ante la SFC son ilegales bajo el **Decreto 2555 de 2010 y la Ley 964 de 2005**. El trading conlleva riesgo sustancial de pérdida de capital.

---

## 📊 Estado del Repositorio / Repository Status

**44 herramientas · todas compilan en CI · estado de calidad por herramienta en [mql/README.md](mql/README.md), [pinescript/README.md](pinescript/README.md), [ctrader/README.md](ctrader/README.md)**

| Componente | Estado |
|---|---|
| ✅ **Compila** | CI en GitHub Actions: MQL4/MQL5 compilados con MetaEditor (Windows) → `.ex4`/`.ex5` como artifacts. Pine v6 y C# son revisados estáticamente (sin compilador oficial en runners Linux). |
| 🧪 **Tests** | Golden values (valores de referencia por herramienta) — **planificado** (`tests/golden/`, ver [docs/QA_STANDARD.md](docs/QA_STANDARD.md)) |
| 📜 **Licencia** | AGPLv3 ([LICENSE](./LICENSE)) |
| 🔍 **Verificación** | Cada indicador debe pasar la tarjeta de verificación (repintado, alerts, golden values) antes de ser marcado "verificado" |

*EN mirror: 44 tools · all compile in CI · per-tool quality status in the platform
READMEs. Golden-value tests planned. License AGPLv3. Honest status: a tool is only
"verified" after passing the [QA Standard](docs/QA_STANDARD.md) card.*

---

## 📋 Tabla de Contenidos / Table of Contents

| 🇨🇴 Español | 🇬🇧 English |
|---|---|
| [¿Qué es Gueta Quant?](#-qué-es-gueta-quant) | [What is Gueta Quant?](#-what-is-gueta-quant) |
| [Filosofía Anti-Estafa](#-filosofía-anti-estafa--transparencia) | [Anti-Scam Philosophy](#-anti-scam-philosophy--transparency) |
| [Herramientas del Repositorio](#-herramientas-del-repositorio) | [Repository Tools](#-repository-tools) |
| [Estructura del Repositorio](#-estructura-del-repositorio) | [Repository Structure](#-repository-structure) |
| [Instalación Rápida](#-instalación-rápida) | [Quick Installation](#-quick-installation) |
| [Seguridad & Privacidad Local-First](#-seguridad--privacidad-local-first) | [Security & Local-First Privacy](#-security--local-first-privacy) |
| [Contribuir](#-contribuir) | [Contributing](#-contributing) |
| [Licencia](#-licencia) | [License](#-license) |

---

# 🇨🇴 ESPAÑOL

## 🏛️ ¿Qué es Gueta Quant?

**Gueta Quant** es una plataforma educativa de trading cuantitativo 100% independiente, diseñada para proteger a los traders de Colombia y Latinoamérica de:

- 🚨 **Brokers offshore no regulados** que operan sin supervisión de la SFC
- 🚨 **Empresas de fondeo con cláusulas engañosas** y trailing drawdowns ocultos
- 🚨 **Academias de criptoesquemas** y vendedores de señales con conflicto de interés

Nuestro enfoque se basa en el **Cálculo Vigesimal Muisca (Gueta)** — rigor matemático puro sobre emoción.

> *"No señales. No afiliados opacos. No gestión de cuentas. Solo educación cuantitativa verificable."*

---

## 🛡️ Filosofía Anti-Estafa & Transparencia

| Principio | Implementación |
|---|---|
| 🔐 **Zero Conflictos de Interés** | Sin esquemas de afiliados con brokers no regulados ni captación ilegal de clientes |
| 📐 **Rigor Cuantitativo** | Algoritmos basados en Pine Script v6, ATR, Volume Profile (POC/VAH/VAL) |
| 🖥️ **Autonomía Local-First** | El Trading Journal corre 100% en tu dispositivo. Cero datos enviados a servidores |
| ⚖️ **Cumplimiento SFC** | Operamos bajo el marco del Decreto 2555 de 2010 — solo educación |
| 🔍 **Código Verificable** | Todo el código es auditable públicamente en este repositorio |

---

## 🛠️ Herramientas del Repositorio

### 📊 MetaTrader 4 & 5 (MQL4/MQL5)

| # | Herramienta | Tipo | Archivo | Descripción |
|---|------------|------|---------|-------------|
| 1 | **GQ Position Sizer** | EA | `mql/GQ_Position_Sizer.mq4` / `.mq5` | Calcula lotaje por ATR y riesgo 2% |
| 2 | **GQ SuperTrend** | EA | `mql/GQ_SuperTrend.mq4` / `.mq5` | Trend following con SuperTrend ATR (TP fijo 1xATR, reversión en cruce) |
| 3 | **GQ MACD Trader** | EA | `mql/GQ_MACD_Trader.mq4` / `.mq5` | Cruces MACD + gestión de riesgo ATR |
| 4 | **GQ Bollinger Reversion** | EA | `mql/GQ_Bollinger_Reversion.mq4` / `.mq5` | Reversión al medio con BB + RSI |
| 5 | **GQ Trend Follow** | EA | `mql/GQ_Trend_Follow.mq4` / `.mq5` | Seguidor de tendencia con MA crossover |
| 6 | **GQ RSI Pro** | Indicador | `mql/GQ_RSI_Pro.mq4` / `.mq5` | RSI con detección de divergencias |
| 7 | **GQ ATR Stop Loss** | Indicador | `mql/GQ_ATR_Stop_Loss.mq4` / `.mq5` | Trailing stop visual basado en ATR |
| 8 | **GQ Market Structure** | Indicador | `mql/GQ_Market_Structure.mq4` / `.mq5` | Estructura de mercado BOS/CHoCH (heurística price-action sobre swings) |
| 9 | **GQ Ichimoku Cloud** | Indicador | `mql/GQ_Ichimoku_Cloud.mq4` / `.mq5` | Sistema Ichimoku completo |
| 10 | **GQ Support & Resistance** | Indicador | `mql/GQ_Support_Resistance.mq4` / `.mq5` | S/R dinámicos con clustering de pivotes |
| 11 | **GQ Volume Profile** | Indicador | `mql/GQ_Volume_Profile.mq4` / `.mq5` | Perfil de volumen con POC/VA |

---

### 📈 TradingView (Pine Script v6)

| # | Herramienta | Archivo | Descripción |
|---|------------|---------|-------------|
| 1 | **GQ Volume Profile Mini** | `pinescript/GQ_Volume_Profile.mini.pb` | POC, Value Area, histograma de volumen |
| 2 | **GQ SuperTrend** | `pinescript/GQ_SuperTrend.pb` | Trailing stop ATR con cambios de trend |
| 3 | **GQ VWAP Standard** | `pinescript/GQ_VWAP_Standard.pb` | VWAP con bandas de desviación σ |
| 4 | **GQ RSI Pro** | `pinescript/GQ_RSI_Pro.pb` | RSI + divergencias regulares/ocultas |
| 5 | **GQ MACD Pro** | `pinescript/GQ_MACD_Pro.pb` | MACD con histograma de momentum |
| 6 | **GQ Bollinger Bands** | `pinescript/GQ_Bollinger_Bands.pb` | Bandas con detección de squeeze |
| 7 | **GQ Market Structure** | `pinescript/GQ_Market_Structure.pb` | SMC/ICT: FVG, BOS, CHoCH, OB (heurística price-action, no order-flow institucional) |
| 8 | **GQ Order Flow CVD** | `pinescript/GQ_Order_Flow_CVD.pb` | Delta de volumen acumulativo |
| 9 | **GQ Anchored VWAP** | `pinescript/GQ_Anchored_VWAP.pb` | VWAP multi-ancla con 3 líneas simultáneas |
| 10 | **GQ Support & Resistance** | `pinescript/GQ_Support_Resistance.pb` | S/R con clustering de pivotes |
| 11 | **GQ MTF Trend Matrix** | `pinescript/GQ_MTF_Trend_Matrix.pb` | Matriz de tendencia multi-timeframe |

---

### 🤖 cTrader (C# cBots)

| # | Herramienta | Archivo | Descripción |
|---|------------|---------|-------------|
| 1 | **GQ Position Sizer** | `ctrader/GQ_Position_Sizer_cBot.cs` | Sizing automático por ATR |
| 2 | **GQ Trend Follower** | `ctrader/GQ_Trend_Follower.cs` | Trend multi-indicador con EMA + SuperTrend |
| 3 | **GQ Breakout ORB** | `ctrader/GQ_Breakout_Orb.cs` | Breakout de rango de apertura |
| 4 | **GQ Grid Scalper** | `ctrader/GQ_Grid_Scalper.cs` | Grid adaptativo por ATR |
| 5 | **GQ Mean Reversion** | `ctrader/GQ_Mean_Reversion.cs` | Reversión BB + RSI con volumen |
| 6 | **GQ Divergence Scanner** | `ctrader/GQ_Divergence_Scanner.cs` | Escáner de divergencias multi-símbolo |
| 7 | **GQ Trailing Stop Manager** | `ctrader/GQ_Trailing_Stop_Manager.cs` | 4 métodos de trailing + gestión parcial |
| 8 | **GQ DCA Recovery** | `ctrader/GQ_DCA_Recovery.cs` | Recuperación DCA adaptativa |
| 9 | **GQ Session Scalper** | `ctrader/GQ_Session_Scalper.cs` | Scalper por sesiones horarias |
| 10 | **GQ Multi-Symbol Scanner** | `ctrader/GQ_Multi_Symbol_Scanner.cs` | Escáner multi-símbolo con ranking |
| 11 | **GQ Risk Manager** | `ctrader/GQ_Risk_Manager.cs` | Gestión de riesgo a nivel portafolio |

---

### 🔐 Auditoría de Privacidad Zero-Knowledge

> Documentación técnica completa para verificar que el **Trading Journal no transmite datos** a ningún servidor.

📄 Ver: [`docs/ZERO_KNOWLEDGE_PRIVACY_AUDIT.md`](./docs/ZERO_KNOWLEDGE_PRIVACY_AUDIT.md)

**Tres pruebas de verificación:**
1. **Auditoría DevTools (Red)** — Abre F12 → Red y verifica que 0 bytes se transmiten al registrar operaciones
2. **Modo Avión** — La app funciona completamente offline
3. **IndexedDB Inspector** — Datos encriptados localmente en tu navegador

---

## 📁 Estructura del Repositorio

```
guetaquant-tools/
├── 📂 mql/
│   ├── GQ_Position_Sizer.mq4       # EA Position Sizer (MT4)
│   ├── GQ_Position_Sizer.mq5       # EA Position Sizer (MT5)
│   ├── GQ_SuperTrend.mq4           # EA SuperTrend (MT4)
│   ├── GQ_SuperTrend.mq5           # EA SuperTrend (MT5)
│   ├── GQ_MACD_Trader.mq4          # EA MACD Trader (MT4)
│   ├── GQ_MACD_Trader.mq5          # EA MACD Trader (MT5)
│   ├── GQ_Bollinger_Reversion.mq4  # EA Bollinger Reversion (MT4)
│   ├── GQ_Bollinger_Reversion.mq5  # EA Bollinger Reversion (MT5)
│   ├── GQ_Trend_Follow.mq4         # EA Trend Follow (MT4)
│   ├── GQ_Trend_Follow.mq5         # EA Trend Follow (MT5)
│   ├── GQ_RSI_Pro.mq4              # Indicator RSI Pro (MT4)
│   ├── GQ_RSI_Pro.mq5              # Indicator RSI Pro (MT5)
│   ├── GQ_ATR_Stop_Loss.mq4        # Indicator ATR Stop Loss (MT4)
│   ├── GQ_ATR_Stop_Loss.mq5        # Indicator ATR Stop Loss (MT5)
│   ├── GQ_Market_Structure.mq4     # Indicator Market Structure (MT4)
│   ├── GQ_Market_Structure.mq5     # Indicator Market Structure (MT5)
│   ├── GQ_Ichimoku_Cloud.mq4       # Indicator Ichimoku Cloud (MT4)
│   ├── GQ_Ichimoku_Cloud.mq5       # Indicator Ichimoku Cloud (MT5)
│   ├── GQ_Support_Resistance.mq4   # Indicator S/R (MT4)
│   ├── GQ_Support_Resistance.mq5   # Indicator S/R (MT5)
│   ├── GQ_Volume_Profile.mq4       # Indicator Volume Profile (MT4)
│   └── GQ_Volume_Profile.mq5       # Indicator Volume Profile (MT5)
├── 📂 pinescript/
│   ├── GQ_Volume_Profile.mini.pb   # Volume Profile con POC/VA
│   ├── GQ_SuperTrend.pb            # SuperTrend ATR
│   ├── GQ_VWAP_Standard.pb         # VWAP con bandas σ
│   ├── GQ_RSI_Pro.pb               # RSI + divergencias
│   ├── GQ_MACD_Pro.pb              # MACD con histograma
│   ├── GQ_Bollinger_Bands.pb       # BB con squeeze
│   ├── GQ_Market_Structure.pb      # SMC/ICT: FVG, BOS
│   ├── GQ_Order_Flow_CVD.pb        # Cumulative Volume Delta
│   ├── GQ_Anchored_VWAP.pb         # VWAP multi-ancla
│   ├── GQ_Support_Resistance.pb    # S/R dinámicos
│   └── GQ_MTF_Trend_Matrix.pb      # Matriz multi-timeframe
├── 📂 ctrader/
│   ├── GQ_Position_Sizer_cBot.cs   # Risk manager básico
│   ├── GQ_Trend_Follower.cs        # Trend multi-indicador
│   ├── GQ_Breakout_Orb.cs          # ORB breakout
│   ├── GQ_Grid_Scalper.cs          # Grid ATR
│   ├── GQ_Mean_Reversion.cs        # BB + RSI
│   ├── GQ_Divergence_Scanner.cs    # Escáner divergencias
│   ├── GQ_Trailing_Stop_Manager.cs # Trailing stop
│   ├── GQ_DCA_Recovery.cs          # DCA recovery
│   ├── GQ_Session_Scalper.cs       # Scalper por sesión
│   ├── GQ_Multi_Symbol_Scanner.cs  # Scanner multi-símbolo
│   └── GQ_Risk_Manager.cs          # Riesgo portafolio
├── 📂 docs/
│   └── ZERO_KNOWLEDGE_PRIVACY_AUDIT.md  # Auditoría de privacidad
├── LICENSE                          # Licencia AGPLv3
└── README.md                        # Este archivo
```

---

## ⚡ Instalación Rápida

### MetaTrader 4 / MetaTrader 5

```bash
# 1. Descarga el/los archivos .mq4 / .mq5 desde mql/
# 2. Abre MetaEditor (F4 en MT5/MT4)
# 3. Archivo → Abrir → Selecciona el/los archivos descargados
# 4. Compila (F7) cada archivo
# 5. Arrastra el EA/indicador desde el Navegador a un gráfico
```

### TradingView (Pine Script v6)

```bash
# 1. Abre el archivo .pb desde pinescript/
# 2. En TradingView: Editor Pine → Nuevo Script
# 3. Pega el código y haz clic en "Agregar al gráfico"
```

### cTrader

```bash
# 1. Descarga el .cs desde ctrader/
# 2. cTrader → Automate → New cBot → Source Files
# 3. Reemplaza el código generado con el archivo descargado
# 4. Compila y adjunta al símbolo
```

---

## 🔐 Seguridad & Privacidad Local-First

Nuestro **Trading Journal** (`guetaquant.com/journal/`) está diseñado con arquitectura **Local-First**:

```
Tu Dispositivo
    ├── IndexedDB (encriptado)
    │     ├── operaciones/
    │     ├── métricas/
    │     └── configuración/
    └── Service Worker (funciona offline)
          └── CERO comunicación con servidores externos al registrar operaciones (núcleo local-first; análisis con IA es opt-in)
```

> [!NOTE]
> Para verificar esto tú mismo: abre `guetaquant.com/journal/`, presiona **F12 → Red**, registra una operación y confirma que **ninguna solicitud de red** aparece en el panel.

---

## 🤝 Contribuir

¡Las contribuciones de la comunidad quant latinoamericana son bienvenidas!

1. **Fork** este repositorio
2. Crea una rama: `git checkout -b feature/mi-indicador`
3. Agrega tu código con documentación en **español**
4. Abre un **Pull Request** describiendo la lógica cuantitativa

> 📖 Guía completa por plataforma, checks obligatorios y PR checklist en [`CONTRIBUTING.md`](./CONTRIBUTING.md).

> **Política de Contribución:** No se aceptan señales de trading, bots de copy-trading comerciales, ni código que requiera acceso a datos de usuarios. Solo herramientas educativas y de gestión de riesgo local.

---

## 📜 Licencia

Este repositorio está bajo la **Licencia AGPLv3**.

Uso libre para:
- ✅ Investigación educativa personal
- ✅ Backtesting y análisis cuantitativo
- ✅ Modificación y redistribución con la misma licencia

Uso **NO** permitido para:
- ❌ Servicios comerciales sin divulgar código fuente
- ❌ Integración en plataformas de gestión de cuentas
- ❌ Redistribución como señales de pago

Ver [`LICENSE`](./LICENSE) para términos completos.

---

<br>

---

# 🇬🇧 ENGLISH

## 🏛️ What is Gueta Quant?

**Gueta Quant** is a 100% independent quantitative trading education platform designed to protect traders in Colombia and Latin America from:

- 🚨 **Unregulated offshore brokers** operating without SFC supervision
- 🚨 **Prop firms with deceptive clauses** and hidden trailing drawdowns
- 🚨 **Crypto scheme academies** and signal sellers with conflicts of interest

Our approach is rooted in **Muisca Vigesimal Calculus (Gueta)** — pure mathematical rigor over emotion.

> *"No signals. No opaque affiliates. No account management. Only verifiable quantitative education."*

---

## 🛡️ Anti-Scam Philosophy & Transparency

| Principle | Implementation |
|---|---|
| 🔐 **Zero Conflicts of Interest** | No affiliate schemes with unregulated brokers, no illegal client solicitation |
| 📐 **Quantitative Rigor** | Algorithms based on Pine Script v6, ATR, Volume Profile (POC/VAH/VAL) |
| 🖥️ **Local-First Autonomy** | Trading Journal runs 100% on your device. Zero data sent to any server |
| ⚖️ **SFC Compliance** | Operating under Decreto 2555 de 2010 framework — education only |
| 🔍 **Verifiable Code** | All code is publicly auditable in this repository |

---

## 🛠️ Repository Tools

### 📊 MetaTrader 4 & 5 (MQL4/MQL5)

| # | Tool | Type | File | Description |
|---|------|------|------|-------------|
| 1 | **GQ Position Sizer** | EA | `mql/GQ_Position_Sizer.mq4` / `.mq5` | ATR-based position sizing |
| 2 | **GQ SuperTrend** | EA | `mql/GQ_SuperTrend.mq4` / `.mq5` | Trend following with SuperTrend ATR (fixed 1xATR TP, flip-on-cross) |
| 3 | **GQ MACD Trader** | EA | `mql/GQ_MACD_Trader.mq4` / `.mq5` | MACD crossovers + ATR risk |
| 4 | **GQ Bollinger Reversion** | EA | `mql/GQ_Bollinger_Reversion.mq4` / `.mq5` | BB + RSI mean reversion |
| 5 | **GQ Trend Follow** | EA | `mql/GQ_Trend_Follow.mq4` / `.mq5` | MA crossover trend follower |
| 6 | **GQ RSI Pro** | Indicator | `mql/GQ_RSI_Pro.mq4` / `.mq5` | RSI with divergence detection |
| 7 | **GQ ATR Stop Loss** | Indicator | `mql/GQ_ATR_Stop_Loss.mq4` / `.mq5` | ATR trailing stop on chart |
| 8 | **GQ Market Structure** | Indicator | `mql/GQ_Market_Structure.mq4` / `.mq5` | Market structure BOS/CHoCH |
| 9 | **GQ Ichimoku Cloud** | Indicator | `mql/GQ_Ichimoku_Cloud.mq4` / `.mq5` | Complete Ichimoku system |
| 10 | **GQ Support & Resistance** | Indicator | `mql/GQ_Support_Resistance.mq4` / `.mq5` | Dynamic S/R with pivot clustering |
| 11 | **GQ Volume Profile** | Indicator | `mql/GQ_Volume_Profile.mq4` / `.mq5` | Volume Profile with POC/VA |

---

### 📈 TradingView (Pine Script v6)

| # | Tool | File | Description |
|---|------|------|-------------|
| 1 | **GQ Volume Profile Mini** | `pinescript/GQ_Volume_Profile.mini.pb` | POC, Value Area, volume histogram |
| 2 | **GQ SuperTrend** | `pinescript/GQ_SuperTrend.pb` | ATR trailing stop with trend flips |
| 3 | **GQ VWAP Standard** | `pinescript/GQ_VWAP_Standard.pb` | VWAP with σ deviation bands |
| 4 | **GQ RSI Pro** | `pinescript/GQ_RSI_Pro.pb` | RSI + regular/hidden divergences |
| 5 | **GQ MACD Pro** | `pinescript/GQ_MACD_Pro.pb` | MACD momentum histogram |
| 6 | **GQ Bollinger Bands** | `pinescript/GQ_Bollinger_Bands.pb` | Bands with squeeze detection |
| 7 | **GQ Market Structure** | `pinescript/GQ_Market_Structure.pb` | SMC/ICT: FVG, BOS, CHoCH (price-action heuristic, not institutional order flow) |
| 8 | **GQ Order Flow CVD** | `pinescript/GQ_Order_Flow_CVD.pb` | Cumulative Volume Delta |
| 9 | **GQ Anchored VWAP** | `pinescript/GQ_Anchored_VWAP.pb` | Multi-anchor VWAP (3 lines) |
| 10 | **GQ Support & Resistance** | `pinescript/GQ_Support_Resistance.pb` | S/R with pivot clustering |
| 11 | **GQ MTF Trend Matrix** | `pinescript/GQ_MTF_Trend_Matrix.pb` | Multi-timeframe trend matrix |

---

### 🤖 cTrader (C# cBots)

| # | Tool | File | Description |
|---|------|------|-------------|
| 1 | **GQ Position Sizer** | `ctrader/GQ_Position_Sizer_cBot.cs` | ATR-based position sizing |
| 2 | **GQ Trend Follower** | `ctrader/GQ_Trend_Follower.cs` | Multi-indicator trend bot |
| 3 | **GQ Breakout ORB** | `ctrader/GQ_Breakout_Orb.cs` | Opening range breakout |
| 4 | **GQ Grid Scalper** | `ctrader/GQ_Grid_Scalper.cs` | ATR-adaptive grid |
| 5 | **GQ Mean Reversion** | `ctrader/GQ_Mean_Reversion.cs` | BB + RSI reversion |
| 6 | **GQ Divergence Scanner** | `ctrader/GQ_Divergence_Scanner.cs` | Multi-symbol divergence scanner |
| 7 | **GQ Trailing Stop Manager** | `ctrader/GQ_Trailing_Stop_Manager.cs` | 4 trailing methods + partial close |
| 8 | **GQ DCA Recovery** | `ctrader/GQ_DCA_Recovery.cs` | Adaptive DCA recovery |
| 9 | **GQ Session Scalper** | `ctrader/GQ_Session_Scalper.cs` | Time-window scalper |
| 10 | **GQ Multi-Symbol Scanner** | `ctrader/GQ_Multi_Symbol_Scanner.cs` | Ranked multi-symbol scanner |
| 11 | **GQ Risk Manager** | `ctrader/GQ_Risk_Manager.cs` | Portfolio-level risk management |

---

### 🔐 Zero-Knowledge Privacy Audit

> Complete technical documentation to verify the **Trading Journal transmits zero data** to any server.

📄 See: [`docs/ZERO_KNOWLEDGE_PRIVACY_AUDIT.md`](./docs/ZERO_KNOWLEDGE_PRIVACY_AUDIT.md)

**Three verification proofs:**
1. **DevTools Network Audit** — Open F12 → Network and verify 0 bytes transmitted when logging trades
2. **Airplane Mode Test** — The app works fully offline
3. **IndexedDB Inspector** — Data encrypted locally in your browser

---

## 📁 Repository Structure

```
guetaquant-tools/
├── 📂 mql/
│   ├── GQ_Position_Sizer.mq4       # EA Position Sizer (MT4)
│   ├── GQ_Position_Sizer.mq5       # EA Position Sizer (MT5)
│   ├── GQ_SuperTrend.mq4           # EA SuperTrend (MT4)
│   ├── GQ_SuperTrend.mq5           # EA SuperTrend (MT5)
│   ├── GQ_MACD_Trader.mq4          # EA MACD Trader (MT4)
│   ├── GQ_MACD_Trader.mq5          # EA MACD Trader (MT5)
│   ├── GQ_Bollinger_Reversion.mq4  # EA Bollinger Reversion (MT4)
│   ├── GQ_Bollinger_Reversion.mq5  # EA Bollinger Reversion (MT5)
│   ├── GQ_Trend_Follow.mq4         # EA Trend Follow (MT4)
│   ├── GQ_Trend_Follow.mq5         # EA Trend Follow (MT5)
│   ├── GQ_RSI_Pro.mq4              # Indicator RSI Pro (MT4)
│   ├── GQ_RSI_Pro.mq5              # Indicator RSI Pro (MT5)
│   ├── GQ_ATR_Stop_Loss.mq4        # Indicator ATR Stop Loss (MT4)
│   ├── GQ_ATR_Stop_Loss.mq5        # Indicator ATR Stop Loss (MT5)
│   ├── GQ_Market_Structure.mq4     # Indicator Market Structure (MT4)
│   ├── GQ_Market_Structure.mq5     # Indicator Market Structure (MT5)
│   ├── GQ_Ichimoku_Cloud.mq4       # Indicator Ichimoku Cloud (MT4)
│   ├── GQ_Ichimoku_Cloud.mq5       # Indicator Ichimoku Cloud (MT5)
│   ├── GQ_Support_Resistance.mq4   # Indicator S/R (MT4)
│   ├── GQ_Support_Resistance.mq5   # Indicator S/R (MT5)
│   ├── GQ_Volume_Profile.mq4       # Indicator Volume Profile (MT4)
│   └── GQ_Volume_Profile.mq5       # Indicator Volume Profile (MT5)
├── 📂 pinescript/
│   ├── GQ_Volume_Profile.mini.pb   # Volume Profile POC/VA
│   ├── GQ_SuperTrend.pb            # SuperTrend ATR
│   ├── GQ_VWAP_Standard.pb         # VWAP σ bands
│   ├── GQ_RSI_Pro.pb               # RSI + divergences
│   ├── GQ_MACD_Pro.pb              # MACD histogram
│   ├── GQ_Bollinger_Bands.pb       # BB squeeze
│   ├── GQ_Market_Structure.pb      # SMC/ICT: FVG, BOS
│   ├── GQ_Order_Flow_CVD.pb        # Cumulative Volume Delta
│   ├── GQ_Anchored_VWAP.pb         # Multi-anchor VWAP
│   ├── GQ_Support_Resistance.pb    # Dynamic S/R
│   └── GQ_MTF_Trend_Matrix.pb      # MTF trend matrix
├── 📂 ctrader/
│   ├── GQ_Position_Sizer_cBot.cs   # Basic risk manager
│   ├── GQ_Trend_Follower.cs        # Multi-indicator trend
│   ├── GQ_Breakout_Orb.cs          # ORB breakout
│   ├── GQ_Grid_Scalper.cs          # ATR grid
│   ├── GQ_Mean_Reversion.cs        # BB + RSI
│   ├── GQ_Divergence_Scanner.cs    # Divergence scanner
│   ├── GQ_Trailing_Stop_Manager.cs # Trailing stop
│   ├── GQ_DCA_Recovery.cs          # DCA recovery
│   ├── GQ_Session_Scalper.cs       # Session scalper
│   ├── GQ_Multi_Symbol_Scanner.cs  # Multi-symbol scanner
│   └── GQ_Risk_Manager.cs          # Portfolio risk
├── 📂 docs/
│   └── ZERO_KNOWLEDGE_PRIVACY_AUDIT.md  # Privacy audit
├── LICENSE                          # AGPLv3 License
└── README.md                        # This file
```

---

## ⚡ Quick Installation

### MetaTrader 4 / MetaTrader 5

```bash
# 1. Download the .mq4 / .mq5 file(s) from mql/
# 2. Open MetaEditor (F4 inside MT5/MT4)
# 3. File → Open → Select the downloaded file(s)
# 4. Compile (F7) each file
# 5. Drag the EA/indicator from the Navigator onto a chart
```

### TradingView (Pine Script v6)

```bash
# 1. Open the .pb file from pinescript/
# 2. In TradingView: Pine Editor → New Script
# 3. Paste the code and click "Add to chart"
```

### cTrader

```bash
# 1. Download the .cs file from ctrader/
# 2. cTrader → Automate → New cBot → Source Files
# 3. Replace the generated code with the downloaded file
# 4. Compile and attach to a symbol
```

---

## 🔐 Security & Local-First Privacy

Our **Trading Journal** (`guetaquant.com/journal/`) is built with a **Local-First architecture**:

```
Your Device
    ├── IndexedDB (encrypted)
    │     ├── trades/
    │     ├── metrics/
    │     └── settings/
    └── Service Worker (offline capable)
          └── ZERO communication with external servers
```

> [!NOTE]
> To verify this yourself: open `guetaquant.com/journal/`, press **F12 → Network**, log a trade and confirm **no network request** appears in the panel.

---

## 🤝 Contributing

Contributions from the Latin American quant community are welcome!

1. **Fork** this repository
2. Create a branch: `git checkout -b feature/my-indicator`
3. Add your code with documentation in **Spanish or English**
4. Open a **Pull Request** describing the quantitative logic

> **Contribution Policy:** We do not accept trading signals, commercial copy-trading bots, or any code requiring user data access. Educational tools and local risk management only.

---

## 📜 License

This repository is under the **AGPLv3 License**.

Free for:
- ✅ Personal educational research
- ✅ Backtesting and quantitative analysis
- ✅ Modification and redistribution under the same license

**NOT** permitted for:
- ❌ Commercial services without disclosing source code
- ❌ Integration in account management platforms
- ❌ Redistribution as paid signals

See [`LICENSE`](./LICENSE) for full terms.

---

<div align="center">

**Construido en Colombia 🇨🇴 para Latinoamérica 🌎 | Built in Colombia 🇨🇴 for Latin America 🌎**

[![Sitio Web](https://img.shields.io/badge/guetaquant.com-Visit%20Portal-gold?style=for-the-badge&logo=globe)](https://guetaquant.com)
[![GitHub Org](https://img.shields.io/badge/GitHub-guetaquant--byte-181717?style=for-the-badge&logo=github)](https://github.com/guetaquant-byte)

*© 2025 Gueta Quant — Todos los derechos reservados bajo AGPLv3 | All rights reserved under AGPLv3*

</div>
