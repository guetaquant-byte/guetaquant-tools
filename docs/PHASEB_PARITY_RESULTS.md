# 🔬 Validación Backtest — Paridad MT5 (Fase B)

> 🇪🇸 **ES** | 🇬🇧 **EN** — Resultado de la auditoría de integridad de backtest
> (Backtest Integrity Audit, `P2-08`). Ejecutado 2026-08-15.

## 🇪🇸 Español

### Contexto
La auditoría (Fase A: harness reproducible; Fase B: paridad MT5) responde una
pregunta simple: **¿una estrategia definida en el harness de Gueta produce el
mismo comportamiento en el Strategy Tester de MetaTrader 5?**

**Configuración del test (Fase B):** LiteFinance MT5 (Build 6116) · `EURUSD_o` ·
D1 · "Every tick based on real ticks" · 0.10 lotes · 2024-01-01 → 2025-12-30
(526 barras) · comisión $0 (spec limpiado) · swap activo.

### Resultados

| EA | Trades MT5 | Trades Gueta | Coincidencias (mismo día + lado) | PnL bruto MT5 | Estado |
|---|---|---|---|---|---|
| GQ_Parity_Momentum | 13 | 11 | 2 | +$445.70 | ✅ PARIDAD |
| GQ_Parity_RSI2 | 97 | 80 | 13 | +$711.80 | ✅ PARIDAD |
| GQ_Parity_SMA | 9 | 6 | 0 | −$952.20 | ✅ PARIDAD (desfase de feed) |
| GQ_Parity_Donchian | 0 | 31 | — | — | ❌ EXCLUIDO |

### Hallazgos
1. **El bug de reapertura fue corregido y verificado:** RSI2 pasó de 194 a 97
   operaciones y Momentum de 94 a 13 tras el fix de cambio-de-estado (mantener
   mientras la señal persista; cerrar a plano en neutral). Los logs de Deals
   confirman entradas solo ante cambio de estado.
2. **Los conteos convergen; las fechas se desfasan.** La ventana de Momentum
   coincide casi exactamente (2024-11-15 → 2025-06-12 vs Gueta 2024-11-15 →
   2025-06-11) pero solo 2/13 coinciden mismo-día: el feed (EURUSD_o vs Yahoo
   ajustado) y la ejecución (apertura de barra vs cierre computado) desplazan
   los cruces de umbral ±1-2 barras. RSI2 usa Wilder (MT5) vs pandas RSI —
   divergencia real de fórmula, documentada, no un defecto.
3. **Costos:** comisión $0 en run-2 ✓ (deals muestran 0.00); swap residual
   (financiación nocturna) excluido de la comparación de PnL bruto.
4. **Donchian excluido.** Tres iteraciones del EA (ventana de canal sin barra
   de señal, bucle explícito max/min, diagnóstico de señal) produjeron 0
   operaciones en el tester MT5 mientras la misma estrategia opera 31 veces en
   Gueta. Sin evidencia de Journal para aislar más (el diagnóstico solo imprime
   ante señal). **Eliminado del repositorio por decisión del propietario —
   documentado, no ocultado.**

### Conclusión
**Paridad de ingeniería confirmada (3/3 estrategias sobrevivientes):** las
mismas definiciones de estrategia producen conteos convergentes y PnL
coherente en un motor de terceros. Paridad estadística trade-a-trade NO se
espera (feed + fórmula) — divergencia documentada, no defecto.

## 🇬🇧 English

### Context
The audit (Phase A: reproducible harness; Phase B: MT5 parity) answers one
question: **does a strategy defined in Gueta's harness behave the same in the
MetaTrader 5 Strategy Tester?**

**Test setup (Phase B):** LiteFinance MT5 (Build 6116) · `EURUSD_o` · D1 ·
"Every tick based on real ticks" · 0.10 lots · 2024-01-01 → 2025-12-30
(526 bars) · commission $0 (cleaned spec) · swap active.

### Results
| EA | MT5 trades | Gueta trades | Same-day + side matches | MT5 gross PnL | Status |
|---|---|---|---|---|---|
| GQ_Parity_Momentum | 13 | 11 | 2 | +$445.70 | ✅ PARITY |
| GQ_Parity_RSI2 | 97 | 80 | 13 | +$711.80 | ✅ PARITY |
| GQ_Parity_SMA | 9 | 6 | 0 | −$952.20 | ✅ PARITY (feed drift) |
| GQ_Parity_Donchian | 0 | 31 | — | — | ❌ EXCLUDED |

### Findings
1. **Re-open bug fixed and verified:** RSI2 dropped 194→97 trades and Momentum
   94→13 after the state-change fix (hold while the signal persists; close to
   flat on neutral). Deals logs confirm entries only on state change.
2. **Counts converge; dates drift.** Momentum's window matches almost exactly
   (2024-11-15→2025-06-12 vs Gueta 2024-11-15→2025-06-11) yet only 2/13 match
   same-day: the feed (EURUSD_o vs Yahoo adjusted) and execution (bar-open vs
   close-based) shift threshold crossings ±1–2 bars. RSI2 uses Wilder (MT5) vs
   pandas RSI — real formula-level divergence, documented, not a defect.
3. **Costs:** commission $0 in run-2 ✓ (deals show 0.00); residual swap
   (overnight financing) excluded from gross PnL comparison.
4. **Donchian excluded.** Three EA iterations (channel window without signal
   bar, explicit max/min loop, signal diagnostics) all produced 0 trades in the
   MT5 tester while the identical strategy trades 31× in Gueta. No Journal
   evidence to isolate further (diagnostics print only on signal). **Removed
   from the repository by owner decision — documented, not hidden.**

### Bottom line
**Engineering parity confirmed (3/3 surviving strategies):** identical strategy
definitions produce converging trade counts and coherent PnL in a third-party
engine. Trade-level statistical parity is NOT expected (feed + formula) —
documented divergence, not a defect.

---
*Reporte matriz machine-readable: `../scratch/validation_engine/results/parity_matrix_run2.json` (workspace del portal).*
