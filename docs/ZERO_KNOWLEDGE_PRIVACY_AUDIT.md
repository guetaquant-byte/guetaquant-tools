# 🔐 Gueta Quant — Auditoría de Privacidad Zero-Knowledge & Arquitectura Local-First

[![Licencia AGPLv3](https://img.shields.io/badge/Licencia-AGPL%20v3-gold?style=flat-square&logo=gnu)](../LICENSE)
[![Privacidad](https://img.shields.io/badge/Privacidad-Zero--Knowledge-brightgreen?style=flat-square)](https://guetaquant.com/journal/)
[![Estado](https://img.shields.io/badge/Estado-Auditable-blue?style=flat-square)](https://guetaquant.com)

> **🇪🇸 Este documento describe el modelo de seguridad, privacidad y ejecución local-first del Diario de Trading Gueta Quant y su suite de herramientas cuantitativas.**
>
> **🇬🇧 This document outlines the verifiable security, privacy, and local-first execution model of the Gueta Quant Trading Journal and quantitative tools suite.**

---

## 🇪🇸 ESPAÑOL

### Resumen Ejecutivo

Los diarios de trading tradicionales y los bots en la nube obligan a los traders a enviar sus claves de API de solo lectura, métricas de cuenta y estrategias de trading propietarias a servidores centralizados de terceros.

**Gueta Quant elimina este riesgo** mediante una arquitectura **Zero-Knowledge, Local-First del lado del cliente**.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     📱 DISPOSITIVO DEL USUARIO (SU NAVEGADOR)               │
│                                                                             │
│  ┌──────────────────────────────┐       ┌────────────────────────────────┐  │
│  │   Diario de Trading Gueta    │       │   IndexedDB Cifrado (AES-256)  │  │
│  │   (WASM / JS Local)          │ ◄───► │   Llave generada del lado      │  │
│  │   Sin servidor intermedio    │       │   del cliente                  │  │
│  └──────────────────────────────┘       └────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
                                   │
                                   │ Solo solicitudes firmadas directamente
                                   ▼
                       ┌──────────────────────────────┐
                       │   Exchange / Bróker          │
                       │   API Pública de Trading     │
                       └──────────────────────────────┘
```

**Tres verdades fundamentales:**

| # | Principio | Implementación |
|---|-----------|---------------|
| 1 | **Sin intermediarios** | Tu navegador se conecta DIRECTAMENTE a tu bróker. Gueta Quant nunca ve tus datos. |
| 2 | **Sin base de datos central** | Todos tus datos viven en tu dispositivo. No existe un servidor que hackear. |
| 3 | **Funciona sin internet** | La app opera al 100% en modo avión. Sin conexión = sin problema. |

---

### 🧪 3 Auditorías Verificables del Lado del Cliente

Cualquier trader o investigador de seguridad puede auditar y verificar estas 3 garantías de privacidad en tiempo real, sin herramientas externas:

---

#### 1. 🌐 Auditoría de Red DevTools (Cero Telemetría de Terceros)

**Objetivo:** Verificar que ninguna solicitud de red sale del navegador hacia servidores de Gueta Quant.

| Paso | Acción | Resultado esperado |
|------|--------|-------------------|
| 1 | Abre el **Diario de Trading** (`https://guetaquant.com/journal/app`) | App cargada |
| 2 | Presiona `F12` → pestaña **Red** (Network) | Panel de red vacío |
| 3 | Registra operaciones, calcula riesgo, importa datos | **0 solicitudes** a `guetaquant.com` |
| 4 | Verifica | Sin analytics, sin telemetría, sin fuga de datos |

**✅ Verificación:** 0 bytes enviados a servidores externos. Todas las operaciones ocurren en memoria.

---

#### 2. ✈️ Auditoría de Modo Avión (Autonomía Operativa Offline)

**Objetivo:** Demostrar que la aplicación funciona al 100% sin conexión a internet.

| Paso | Acción | Resultado esperado |
|------|--------|-------------------|
| 1 | Carga la app del Diario de Trading | App funcionando |
| 2 | Activa **Modo Avión** o desconecta físicamente el internet | Sin conexión |
| 3 | Continúa registrando trades, aplicando filtros, exportando datos | **100% operativo** |
| 4 | Verifica | Sin errores de red, sin bloqueos |

**✅ Verificación:** La aplicación funciona a capacidad operativa completa sin conexión activa a internet.

---

#### 3. 🔑 Auditoría de Almacenamiento Local y Cifrado (Sin Base de Datos Central)

**Objetivo:** Confirmar que todos los datos residen exclusivamente en el navegador del usuario.

| Paso | Acción | Resultado esperado |
|------|--------|-------------------|
| 1 | Abre DevTools → pestaña **Application** → **IndexedDB** | Base de datos local visible |
| 2 | Inspecciona el esquema de almacenamiento | Tablas: `operaciones`, `métricas`, `configuración` |
| 3 | Verifica que NO hay comunicación con servidores externos | Sin solicitudes de red |
| 4 | Confirma | Datos cifrados localmente con AES-256 |

**✅ Verificación:** Todos los journals, configuraciones y claves de API de solo lectura se almacenan estrictamente dentro del IndexedDB local del navegador. **No existe una base de datos central** que pueda ser hackeada, filtrada o vendida.

---

### 🤖 4. Capa de IA (Alcance Explícito del Núcleo Local-First)

**Las 3 auditorías anteriores aplican exclusivamente al NÚCLEO del Diario** (registro de operaciones, métricas, filtros, exportación, almacenamiento). **NO aplican a las funciones de IA:**

| Función | Qué ocurre con tus datos |
|---------|--------------------------|
| **Núcleo del Diario** (registro, métricas, exportación CSV) | ✅ 100% local. Cero bytes salen del navegador. |
| **AI Analyzer / AI Companion** (`/api/insights`, `/api/chat`) | ⚠️ **OPT-IN:** al hacer clic en Analizar/Chat, un subconjunto de tu historial de operaciones (símbolo, tipo, entrada/salida, P&L, notas) se envía a Google Gemini (modelo en la nube) vía el servidor de guetaquant.com. **Sin tu clic, nada se envía.** |

- El análisis con IA es **opcional y bajo demanda**: el núcleo funciona 100% offline sin activarlo.
- Recomendamos no incluir datos sensibles (nombres, cuentas, contraseñas) en el campo de notas si planeas usar la IA.
- Para permanecer 100% local: simplemente no uses las pestañas de IA, o activa el **Modo Solo-Local** (bloquea todas las llamadas de red) desde Ajustes.

**✅ Resumen verificado:** "Cero datos salen de tu dispositivo" = **verdadero para el núcleo**; "la IA nunca ve tus datos" = **falso por diseño** — la IA es una capa opcional que requiere tu acción explícita y envía datos a un proveedor externo.

---

### 🔒 Matriz de Seguridad

| Componente | Tecnología | Propósito |
|------------|-----------|-----------|
| Cifrado en reposo | AES-256 con clave generada del lado del cliente | Proteger datos almacenados |
| Almacenamiento | IndexedDB (navegador) | Sin servidor central |
| Ejecución | WASM + JavaScript local | Sin procesamiento en la nube |
| API Keys | Solo lectura, almacenadas localmente | Nunca transmitidas a terceros |
| Service Worker | Cache offline | Operación sin conexión |
| Red | Solicitudes directas al bróker | Sin intermediarios |

---

### 🛡️ Aviso de Licencia y Protección de Propiedad Intelectual

Todas las herramientas de código abierto proporcionadas en este repositorio están licenciadas bajo la **GNU Affero General Public License v3 (AGPLv3)**.

| Permiso | Restricción |
|---------|------------|
| ✅ Uso educativo personal | ❌ Redistribución comercial cerrada |
| ✅ Modificación y adaptación | ❌ Hospedaje en la nube sin publicar código fuente |
| ✅ Backtesting y análisis | ❌ Integración en plataformas de gestión de cuentas |
| ✅ Redistribución con misma licencia | ❌ Venta como señales de pago |

> **⚠️ Violación de licencia:** La redistribución comercial o el hospedaje en la nube de versiones modificadas sin publicar el código fuente completo bajo los mismos términos AGPLv3 está estrictamente prohibido y puede resultar en acciones legales.

---

### Preguntas Frecuentes (FAQ)

**P: ¿Gueta Quant puede ver mis operaciones?**
R: No en el núcleo del Diario: la arquitectura Zero-Knowledge significa que el registro de operaciones nunca sale de tu dispositivo. Excepción explícita: si usas el AI Analyzer/Companion (opt-in), el historial se envía a Google Gemini para generar el análisis.

**P: ¿Qué pasa si borro el caché del navegador?**
R: Tus datos se perderán. Recomendamos exportar respaldos periódicos usando la función de exportación integrada en la app.

**P: ¿Cómo sé que realmente no envían datos?**
R: Puedes verificarlo tú mismo con las 3 auditorías descritas arriba. No se requiere confianza — solo una inspección visual de DevTools.

**P: ¿El cifrado AES-256 es seguro?**
R: AES-256 es el estándar de cifrado utilizado por gobiernos y bancos. La clave se genera y almacena exclusivamente en tu navegador. Nadie más puede desencriptar tus datos.

---

<br>

---

## 🇬🇧 ENGLISH

### Executive Summary

Traditional trading journals and cloud bots force traders to send their API read keys, account metrics, and proprietary trading strategies to centralized third-party servers.

Gueta Quant eliminates this risk through a **Zero-Knowledge, Client-Side Local-First Architecture**.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      📱 CLIENT DEVICE (YOUR BROWSER)                        │
│                                                                             │
│  ┌──────────────────────────────┐       ┌────────────────────────────────┐  │
│  │   Trading Journal App        │       │   Encrypted IndexedDB Storage  │  │
│  │   (Local WASM / JS)          │ ◄───► │   (AES-256 Client-Side Key)    │  │
│  │   No intermediary server     │       │                                │  │
│  └──────────────────────────────┘       └────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
                                   │
                                   │ Direct Signed Requests Only
                                   ▼
                       ┌──────────────────────────────┐
                       │   Exchange / Broker          │
                       │   Public Trading API         │
                       └──────────────────────────────┘
```

**Three core truths:**

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | **No middleman** | Your browser connects DIRECTLY to your broker. Gueta Quant never sees your data. |
| 2 | **No central database** | All your data lives on your device. There is no server to hack. |
| 3 | **Works offline** | The app operates at 100% in airplane mode. No connection = no problem. |

---

### 🧪 3 Verifiable Client-Side Audits

Any trader or security researcher can independently audit and verify these 3 privacy guarantees in real time, without external tools:

---

#### 1. 🌐 The DevTools Network Audit (Zero Middleman Telemetry)

**Goal:** Verify that zero network requests leave the browser to Gueta Quant servers.

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | Open the **Gueta Quant Journal App** (`https://guetaquant.com/journal/app`) | App loaded |
| 2 | Press `F12` (or Right-Click → *Inspect*) and switch to the **Network** tab | Empty network panel |
| 3 | Perform trade log entries, risk sizer calculations, or data imports | **0 requests** to `guetaquant.com` |
| 4 | Verify | No analytics, no telemetry, no data leakage |

**✅ Verification:** 0 bytes sent to external servers. All operations happen in-memory.

---

#### 2. ✈️ The Airplane Mode Audit (Offline Operational Autonomy)

**Goal:** Demonstrate the application functions at 100% capacity without an internet connection.

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | Load the Trading Journal app in your browser | App running |
| 2 | Enable **Airplane Mode** or physically disconnect your internet connection | No connection |
| 3 | Continue entering trades, filtering performance metrics, and exporting journals | **100% operational** |
| 4 | Verify | No network errors, no blocking |

**✅ Verification:** The application functions at full operational capacity without an active internet connection.

---

#### 3. 🔑 Local Storage & Encryption Audit (No Central Database)

**Goal:** Confirm that all data resides exclusively in the user's browser.

| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | Open DevTools → **Application** tab → **IndexedDB** | Local database visible |
| 2 | Inspect the local storage schema | Tables: `trades`, `metrics`, `settings` |
| 3 | Verify no external server communication | No network requests |
| 4 | Confirm | Data encrypted locally with AES-256 |

**✅ Verification:** All journals, trade setups, and API read keys are stored strictly inside your local browser's IndexedDB. **No central database exists** to hack, leak, or sell.

---

### 🤖 4. AI Layer (Explicit Scope of the Local-First Core)

**The 3 audits above apply EXCLUSIVELY to the Journal CORE** (trade logging, metrics, filters, export, storage). **They do NOT apply to the AI features:**

| Feature | What happens to your data |
|---------|---------------------------|
| **Journal Core** (logging, metrics, CSV export) | ✅ 100% local. Zero bytes leave the browser. |
| **AI Analyzer / AI Companion** (`/api/insights`, `/api/chat`) | ⚠️ **OPT-IN:** when you click Analyze/Chat, a subset of your trade history (symbol, type, entry/exit, P&L, notes) is sent to Google Gemini (cloud model) via guetaquant.com's server. **Without your click, nothing is sent.** |

- AI analysis is **optional and on-demand**: the core works 100% offline without it.
- We recommend NOT including sensitive data (names, accounts, passwords) in the notes field if you plan to use AI.
- To stay 100% local: simply don't use the AI tabs, or enable **Local-Only Mode** (blocks all network calls) in Settings.

**✅ Verified summary:** "Zero data leaves your device" = **true for the core**; "the AI never sees your data" = **false by design** — AI is an optional layer requiring your explicit action that sends data to an external provider.

---

### 🔒 Security Matrix

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Encryption at rest | AES-256 with client-side generated key | Protect stored data |
| Storage | Browser IndexedDB | No central server |
| Execution | WASM + Local JavaScript | No cloud processing |
| API Keys | Read-only, stored locally | Never transmitted to third parties |
| Service Worker | Offline cache | Offline operation |
| Network | Direct broker requests | No intermediaries |

---

### 🛡️ IP Protection & Copyleft License Notice

All open-source tools provided in this repository are licensed under the **GNU Affero General Public License v3 (AGPLv3)**.

| Permitted | Restricted |
|-----------|-----------|
| ✅ Personal educational use | ❌ Closed-source commercial redistribution |
| ✅ Modification and adaptation | ❌ Cloud hosting without publishing source code |
| ✅ Backtesting and analysis | ❌ Integration in account management platforms |
| ✅ Redistribution under same license | ❌ Sale as paid signals |

> **⚠️ License violation:** Commercial redistribution or cloud hosting of modified versions without publishing full source code under the same AGPLv3 terms is strictly prohibited and may result in legal action.

---

### Frequently Asked Questions

**Q: Can Gueta Quant see my trades?**
A: Not in the Journal core: the Zero-Knowledge architecture means trade logging never leaves your device. Explicit exception: if you use the AI Analyzer/Companion (opt-in), the history is sent to Google Gemini to generate the analysis.

**Q: What happens if I clear my browser cache?**
A: Your data will be lost. We recommend exporting periodic backups using the built-in export function.

**Q: How can I be sure you're not sending data?**
A: You can verify it yourself with the 3 audits described above. No trust required — just a visual DevTools inspection.

**Q: Is AES-256 encryption secure?**
A: AES-256 is the encryption standard used by governments and banks worldwide. The key is generated and stored exclusively in your browser. No one else can decrypt your data.

---

## 📜 Licencia / License

```
Gueta Quant — Zero-Knowledge Privacy Audit
© 2026 Gueta Quant — https://guetaquant.com

Este documento es parte del repositorio guetaquant-tools.
This document is part of the guetaquant-tools repository.

Licenciado bajo / Licensed under GNU Affero General Public License v3 (AGPLv3).

SPDX-License-Identifier: AGPL-3.0-only
```

---

<div align="center">

**🔐 Verificable. Auditável. Zero-Knowledge.**  
**Verifiable. Auditable. Zero-Knowledge.**

[![Sitio Web](https://img.shields.io/badge/guetaquant.com-Visit%20Portal-gold?style=for-the-badge&logo=globe)](https://guetaquant.com)
[![GitHub](https://img.shields.io/badge/GitHub-guetaquant--byte-181717?style=for-the-badge&logo=github)](https://github.com/guetaquant-byte)

</div>
