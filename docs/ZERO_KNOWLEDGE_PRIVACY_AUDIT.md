# 🔐 Gueta Quant Local-First & Zero-Knowledge Architecture Audit Protocol

This document outlines the verifiable security, privacy, and local-first execution model of the **Gueta Quant Trading Journal** and quantitative tools suite.

---

## 🏛️ Executive Summary

Traditional trading journals and cloud bots force traders to send their API read keys, account metrics, and proprietary trading strategies to centralized third-party servers. 

Gueta Quant eliminates this risk through a **Zero-Knowledge, Client-Side Local-First Architecture**.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        📱 CLIENT DEVICE (YOUR BROWSER)                  │
│                                                                         │
│  ┌─────────────────────────┐         ┌──────────────────────────────┐  │
│  │   Trading Journal App   │         │   Encrypted IndexedDB Storage│  │
│  │   (Local WASM / JS)     │ ◄─────► │   (AES-256 Client-Side Key)  │  │
│  └─────────────────────────┘         └──────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
                                   │
                                   │ Direct Signed Requests Only
                                   ▼
                       ┌──────────────────────┐
                       │   Exchange / Broker  │
                       │   Public Trading API │
                       └──────────────────────┘
```

---

## 🧪 3 Verifiable Client-Side Audits

Any trader or security researcher can independently audit and verify these 3 privacy guarantees in real time:

### 1. 🌐 The DevTools Network Audit (Zero Middleman Telemetry)
1. Open the **Gueta Quant Journal App** (`https://guetaquant.com/journal/app`).
2. Press `F12` (or Right-Click → *Inspect*) and switch to the **Network** tab.
3. Perform trade log entries, risk sizer calculations, or data imports.
4. **Verification**: 0 network requests are sent to `guetaquant.com` or any third-party analytics servers. All operations happen in-memory.

### 2. ✈️ The Airplane Mode Audit (Offline Operational Autonomy)
1. Load the Trading Journal app in your browser.
2. Enable **Airplane Mode** or physically disconnect your internet connection.
3. Continue entering trades, filtering performance metrics, and exporting journals.
4. **Verification**: The application functions at 100% operational capacity without an active internet connection.

### 3. 🔑 Local Storage & Encryption Audit (No Central Database)
1. Open DevTools → **Application** tab → **IndexedDB**.
2. Inspect the local storage schema.
3. **Verification**: All journals, trade setups, and API read keys are stored strictly inside your local browser's IndexedDB. No central database exists to hack, leak, or sell.

---

## 🛡️ IP Protection & Copyleft License Notice

All open-source tools provided in this repository are licensed under the **GNU Affero General Public License v3 (AGPLv3)**. Commercial redistribution or cloud hosting of modified versions without publishing full source code is strictly prohibited.
