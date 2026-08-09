# 📐 Estándar de Calidad: No-Repaint & QA / No-Repaint & QA Standard

> **ES-first.** Cada sección incluye espejo EN. Este documento es el contrato de
> calidad de todo indicador publicado en este repositorio. Es vinculante para
> MQL4/MQL5, Pine Script v6 y cTrader (cuando aplique, e.g. alerts en Pine).
>
> *EN mirror: this is the binding quality contract for every indicator published
> in this repo.*

---

## 1. Taxonomía de repintado / Repaint taxonomy

*(EN mirror: repaint classification per TradingView community standards.)*

| Categoría | Definición | Estado |
|---|---|---|
| ✅ **Aceptable** | Valores históricos **no cambian**; solo se dibujan/descartan elementos en la vela en formación usando datos confirmados. | Permitido, sin aviso |
| ⚠️ **Potencialmente engañoso** | Cambia valores de velas **cerradas** (e.g. pivotes recalculados, zonas SMC/FVG que se desplazan con velas nuevas, VWAP acumulativo, volumen por barra). | Permitido **solo con declaración visible** en el README del indicador |
| ❌ **Inaceptable** | Repintado **oculto o no documentado**, señales que aparecen/desaparecen en velas cerradas, o `security()` con lookahead. | Prohibido en este repositorio |

Reglas de decisión:
- Un indicador **no repinta** si su salida para la vela `i` se puede calcular
  con datos de velas `≤ i` (barra actual incluida usando `close` confirmado) y
  el resultado no cambia retroactivamente.
- Repintado **aceptable** ≠ silencioso: toda sección del README de un indicador
  que repinta debe contener la línea exacta:
  `**⚠️ Repinta:** <qué cambia> · <por qué> · <cuándo se estabiliza>`.

---

## 2. Reglas anti-lookahead / No-lookahead rules

*(EN mirror: no lookahead-bias rules.)*

### Pine Script v6 (obligatorio)

1. `barstate.isconfirmed` — cualquier cálculo que alimente alerts/etiquetas
   sobre la vela actual debe ejecutarse solo con `barstate.isconfirmed`
   (o documentar explícitamente el caso de uso en vela en formación).
2. `request.security()` — siempre con `lookahead=barmerge.lookahead_off`
   (o `gaps=barmerge.gaps_on` cuando la semántica lo exija). **Prohibido**
   `lookahead_on` fuera de educación explícitamente documentada.
3. `ta.pivothigh()/pivotlow()` — son repintado declarado (retrospectivo por
   `leftbars`/`rightbars`); deben marcarse en la taxonomía ⚠️.
4. `calc_on_every_tick=false` (default) para indicadores en vela; si un
   estudio usa `calc_on_every_tick=true`, debe justificarlo en el README.

### MQL4/MQL5 (obligatorio)

1. EAs con `OnTick()`: lógica de entrada solo sobre ticks del precio confirmado
   por la plataforma; sin buffers calculados en el futuro (sin `Shift < 0`).
2. Indicadores: buffers dibujados con `SetIndexShift` solo si la semántica lo
   requiere y se declara; el cálculo debe ser causal (índice `i` depende de
   `≤ i`).
3. Backtest vs. live: el mismo código compilado corre en ambos; si el backtest
   usa `MODEL_*` distinto, documentarlo.

### cTrader (obligatorio)

1. En `OnTick()`/`OnBar()`: operar solo con barras cerradas salvo declaración
   explícita; verificar `Bar.IsClosed` cuando sea relevante.
2. Sin llamadas a datos futuros (`BarData` con índice negativo, series no
   causalmente completas).

---

## 3. Procedimiento de prueba de repintado (3 minutos) / 3-minute repaint test

*(EN mirror: quick manual repaint test.)*

Material: un símbolo líquido (EURUSD), un timeframe (15m), dos gráficos del
mismo símbolo con el indicador.

1. **Captura inicial (0:00):** screenshot de 20–30 velas visibles con el
   indicador aplicado. Anota precio y hora.
2. **Espera (3:00+):** deja cerrar 5–10 velas nuevas **sin tocar nada**.
3. **Comparación (al final):** sobre la misma zona de las 20–30 velas
   iniciales, verifica elemento por elemento (líneas, zonas, etiquetas,
   valores de POC/VAH/VAL): ¿algo cambió en velas **ya cerradas**?
   - Nada cambió → ✅ Aceptable (sin repintado).
   - Cambió y está declarado en el README → ⚠️ aceptable con aviso.
   - Cambió y NO está declarado → ❌ bloquear el merge y abrir fix.

> 🧪 **Prueba numérica opcional (golden):** exporta los valores del buffer en
> un conjunto fijo de barras (misma fecha, mismo símbolo, mismos parámetros) y
> compara contra valores de referencia del repo (`tests/golden/*.json`). Si el
> indicador produce valores numéricos (POC, VWAP, ATR, RSI), el golden test es
> **requerido** antes de marcar el indicador "verificado".

---

## 4. Tarjeta de verificación por indicador / Per-indicator verification card

*(EN mirror: every indicator's README section must include a card.)*

```markdown
### 🎴 Tarjeta de verificación / Verification card

| Campo / Field | Valor / Value |
|---|---|
| **Versión** / Version | vX.Y.Z (fecha) |
| **Plataformas** / Platforms | MT4 · MT5 · TradingView (Pine v6) · cTrader |
| **Estado de repintado** / Repaint status | ✅ Sin repintado / ⚠️ Repinta (declarado) — verificado: YYYY-MM-DD |
| **Test de repintado** / Repaint test | 🕒 Procedimiento de 3 min aplicado en EURUSD 15m (YYYY-MM-DD) |
| **Semántica de alerts** / Alert semantics | Qué dispara la alerta, en qué vela (confirmada/en formación), y qué significa para el usuario |
| **Golden values** / Golden values | ✅ `tests/golden/<tool>.json` (fecha, símbolo, parámetros, valores) o ⬜ pendiente |
```

Requisitos:
- **Repaint status:** obligatorio siempre (aunque sea ✅).
- **Alert semantics:** obligatorio para Pine con `alert()`/`alertcondition()`:
  ¿la alerta dispara en la vela confirmada? ¿puede re-disparar? ¿qué acción
  debería tomar el usuario (ninguna —educativo—)?
- **Golden values:** requerido para lógica numérica (POC/VAH/VAL, VWAP, ATR,
  medias); recomendado para todo lo demás.

---

## 5. Definición de "verificado" / Definition of "verified"

Un indicador del README puede tener tres estados (tabla "Estado" del README raíz):

| Estado | Criterio |
|---|---|
| 🔴 **beta** | Compila, sin golden test, repintado sin declarar (o sin tarjeta) |
| 🟡 **verificado** | Compila en CI + tarjeta completa + repintado declarado |
| 🟢 **golden-tested** | Verificado + golden values reproducidos en `tests/golden/` |

**Ningún indicador puede pasar de 🟡 sin tarjeta de verificación.** La frase
"verificado" en un README sin tarjeta es un claim sin respaldo → lo bloquea
`scripts/check_readme_claims.py` si se lista en `claim_exceptions.json` sin
prueba.

---

*Última revisión: 2026-08-09 · Vinculante para todo código nuevo y cambios de
comportamiento. / Last reviewed: 2026-08-09 · Binding for all new code and
behavior changes.*
