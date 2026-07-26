<div align="center">

<!-- LOGO PLACEHOLDER -->
<img src="https://guetaquant.com/images/linkedin_logo.png" alt="Gueta Quant Logo" width="120" />

# 🏛️ Gueta Quant — Herramientas Open-Source

**Educación cuantitativa 100% independiente para traders de Colombia y Latinoamérica**

[![Licencia AGPLv3](https://img.shields.io/badge/Licencia-AGPL%20v3-gold?style=flat-square&logo=gnu)](./LICENSE)
[![Plataforma](https://img.shields.io/badge/Plataforma-MT4%20%7C%20MT5%20%7C%20cTrader%20%7C%20TradingView-blue?style=flat-square)](https://guetaquant.com/herramientas/)
[![Estado](https://img.shields.io/badge/Estado-Activo-brightgreen?style=flat-square)](https://guetaquant.com)
[![SFC Colombia](https://img.shields.io/badge/SFC_Colombia-Decreto_2555_de_2010-orange?style=flat-square)](https://guetaquant.com/nuestra-mision/)
[![Zero Señales](https://img.shields.io/badge/Zero%20Se%C3%B1ales-Política%20Estricta-red?style=flat-square)](https://guetaquant.com/nuestra-mision/)

[🌐 Sitio Web](https://guetaquant.com) · [📖 Blog Educativo](https://guetaquant.com/blog/) · [📓 Trading Journal](https://guetaquant.com/journal/) · [🛠️ Herramientas](https://guetaquant.com/herramientas/)

---

</div>

> [!CAUTION]
> **⚠️ AVISO REGULATORIO SFC COLOMBIA:** Este repositorio es de uso **exclusivamente educativo**. Ningún código, indicador, ni herramienta publicada aquí constituye asesoría de inversión, señal de compra/venta, ni promesa de rentabilidad. Actividades de asesoría en valores sin registro ante la SFC son ilegales bajo el **Decreto 2555 de 2010 y la Ley 964 de 2005**. El trading conlleva riesgo sustancial de pérdida de capital.

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

### 1. 📊 GQ Position Sizer — MetaTrader 4 & 5

> **Calcula el tamaño de posición exacto** basado en el riesgo del 2% sobre el capital de la cuenta y la volatilidad ATR(14).

```mql5
// Ejemplo de uso en MQL5
double atrValue = iATR(_Symbol, PERIOD_H1, 14, 1);
double stopLoss = atrValue * 2.5;
double lotSize  = CalcLot(2.0, stopLoss); // Riesgo 2%, SL = 2.5×ATR
```

| Campo | Valor |
|---|---|
| **Plataformas** | MetaTrader 4, MetaTrader 5 |
| **Lenguaje** | MQL4 / MQL5 |
| **Riesgo por Defecto** | 2% del capital |
| **Stop Loss** | 2.5× ATR(14) |
| **Archivos** | `mql/GQ_Position_Sizer.mq4`, `mql/GQ_Position_Sizer.mq5` |

---

### 2. 📈 GQ Volume Profile Mini — Pine Script v6

> **Calcula niveles POC, VAH y VAL** (Point of Control, Value Area High/Low) directamente en TradingView.

```pine
// Pine Script v6 — Auditoria pública completa en pinescript/
//@version=6
indicator("GQ Volume Profile Mini", overlay=true)
// POC, VAH, VAL calculados con bins de precio
// Ver archivo completo: pinescript/GQ_Volume_Profile.mini.pb
```

| Campo | Valor |
|---|---|
| **Plataforma** | TradingView |
| **Lenguaje** | Pine Script v6 |
| **Funcionalidad** | POC, VAH, VAL, Risk/Reward Sizer |
| **Archivo** | `pinescript/GQ_Volume_Profile.mini.pb` |

---

### 3. 🤖 GQ Position Sizer — cTrader cBot

> **Gestor de riesgo paramétrico** para cTrader escrito en C#.

| Campo | Valor |
|---|---|
| **Plataforma** | cTrader |
| **Lenguaje** | C# (.NET) |
| **Funcionalidad** | Sizing automático por volatilidad ATR |
| **Archivo** | `ctrader/GQ_Position_Sizer_cBot.cs` |

---

### 4. 🔐 Auditoría de Privacidad Zero-Knowledge

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
│   ├── GQ_Position_Sizer.mq4       # EA para MetaTrader 4
│   └── GQ_Position_Sizer.mq5       # EA para MetaTrader 5
├── 📂 pinescript/
│   └── GQ_Volume_Profile.mini.pb   # Indicador Volume Profile para TradingView
├── 📂 ctrader/
│   └── GQ_Position_Sizer_cBot.cs   # cBot de gestión de riesgo para cTrader
├── 📂 docs/
│   └── ZERO_KNOWLEDGE_PRIVACY_AUDIT.md  # Auditoría de privacidad técnica
├── LICENSE                          # Licencia AGPLv3
└── README.md                        # Este archivo
```

---

## ⚡ Instalación Rápida

### MetaTrader 4 / MetaTrader 5

```bash
# 1. Descarga el archivo .mq4 o .mq5 desde este repositorio
# 2. Abre MetaEditor (F4 en MT5/MT4)
# 3. Archivo → Abrir → Selecciona el archivo descargado
# 4. Compila (F7)
# 5. Arrastra el EA desde el Navegador a un gráfico
```

### TradingView (Pine Script v6)

```bash
# 1. Abre el archivo .pb desde pinescript/
# 2. En TradingView: Editor Pine → Nuevo Script
# 3. Pega el código y haz clic en "Agregar al gráfico"
```

### cTrader

```bash
# 1. Descarga GQ_Position_Sizer_cBot.cs
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
          └── CERO comunicación con servidores externos
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

### 1. 📊 GQ Position Sizer — MetaTrader 4 & 5

> **Calculates exact position size** based on 2% account equity risk and ATR(14) volatility.

```mql5
// MQL5 usage example
double atrValue = iATR(_Symbol, PERIOD_H1, 14, 1);
double stopLoss = atrValue * 2.5;
double lotSize  = CalcLot(2.0, stopLoss); // 2% risk, SL = 2.5×ATR
```

| Field | Value |
|---|---|
| **Platforms** | MetaTrader 4, MetaTrader 5 |
| **Language** | MQL4 / MQL5 |
| **Default Risk** | 2% of account equity |
| **Stop Loss** | 2.5× ATR(14) |
| **Files** | `mql/GQ_Position_Sizer.mq4`, `mql/GQ_Position_Sizer.mq5` |

---

### 2. 📈 GQ Volume Profile Mini — Pine Script v6

> **Calculates POC, VAH and VAL levels** (Point of Control, Value Area High/Low) directly on TradingView.

| Field | Value |
|---|---|
| **Platform** | TradingView |
| **Language** | Pine Script v6 |
| **Functionality** | POC, VAH, VAL, Risk/Reward Sizer |
| **File** | `pinescript/GQ_Volume_Profile.mini.pb` |

---

### 3. 🤖 GQ Position Sizer — cTrader cBot

> **Parametric risk manager** for cTrader written in C#.

| Field | Value |
|---|---|
| **Platform** | cTrader |
| **Language** | C# (.NET) |
| **Functionality** | Automatic position sizing via ATR volatility |
| **File** | `ctrader/GQ_Position_Sizer_cBot.cs` |

---

### 4. 🔐 Zero-Knowledge Privacy Audit

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
│   ├── GQ_Position_Sizer.mq4       # Expert Advisor for MetaTrader 4
│   └── GQ_Position_Sizer.mq5       # Expert Advisor for MetaTrader 5
├── 📂 pinescript/
│   └── GQ_Volume_Profile.mini.pb   # Volume Profile indicator for TradingView
├── 📂 ctrader/
│   └── GQ_Position_Sizer_cBot.cs   # Risk management cBot for cTrader
├── 📂 docs/
│   └── ZERO_KNOWLEDGE_PRIVACY_AUDIT.md  # Technical privacy audit
├── LICENSE                          # AGPLv3 License
└── README.md                        # This file
```

---

## ⚡ Quick Installation

### MetaTrader 4 / MetaTrader 5

```bash
# 1. Download the .mq4 or .mq5 file from this repository
# 2. Open MetaEditor (F4 inside MT5/MT4)
# 3. File → Open → Select the downloaded file
# 4. Compile (F7)
# 5. Drag the EA from the Navigator onto a chart
```

### TradingView (Pine Script v6)

```bash
# 1. Open the .pb file from pinescript/
# 2. In TradingView: Pine Editor → New Script
# 3. Paste the code and click "Add to chart"
```

### cTrader

```bash
# 1. Download GQ_Position_Sizer_cBot.cs
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
