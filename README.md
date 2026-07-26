# Gueta Quant — Public Open-Source Tools Showcase

Welcome to the official public open-source repository for **Gueta Quant** ([guetaquant.com](https://guetaquant.com)).

Gueta Quant is a 100% independent quantitative finance educational portal and local-first trading tools ecosystem for Latin America.

---

## 🛡️ Transparency & Anti-Scam Philosophy

We believe financial technology should be **open, verified, and client-side**. 

- **Zero Data Collection**: Our local-first tools (like the Gueta Quant Trading Journal) operate 100% on-device using IndexedDB browser storage.
- **Zero Signal Selling**: We do not sell signals, manage accounts, or receive affiliate kickbacks from unregulated brokers.
- **Verifiable Code**: All indicators and EAs published here are open for public inspection.

---

## 🛠️ Repository Tools & Indicators

### 1. `GQ_Position_Sizer.mq4` & `GQ_Position_Sizer.mq5`
- **Platform**: MetaTrader 4 & MetaTrader 5
- **Language**: MQL4 / MQL5
- **Purpose**: Calculates exact lot size based on dynamic account equity risk (e.g. 1% or 2% rule) and ATR volatility stop loss.
- **Location**: `mql/` directory.

### 2. Pine Script v6 Indicators
- **Platform**: TradingView
- **Language**: Pine Script v6
- **Purpose**: Volume Profile POC/VAH/VAL level calculator and risk-reward position sizer.
- **Location**: `pinescript/` directory.

### 3. cTrader cBot Risk Manager
- **Platform**: cTrader
- **Language**: C# (.NET)
- **Purpose**: Automated position sizing EA for cTrader.
- **Location**: `ctrader/` directory.

---

## 📜 License & Usage

All code in this repository is licensed under the **MIT License**. Free for personal educational use, backtesting, and quantitative research.
