# 🤝 Contributing — Gueta Quant Tools

> **Español primero, con espejo en inglés (ES-first, EN mirror).** Este repositorio es
> bilingüe: documentación en español es obligatoria; inglés bienvenido como espejo.

Gueta Quant es 100% educativo y anti-estafa. **No se aceptan**: señales de trading,
bots de copy-trading comerciales, código que requiera acceso a datos de usuarios,
ni claims de rentabilidad.

---

## 🧭 Flujo general / General flow

1. Fork + rama: `git checkout -b feature/mi-herramienta`
2. Código + documentación en español (README por plataforma, tabla de herramientas)
3. **Checks locales (obligatorios)**:
   ```bash
   python3 scripts/check_mql_parity.py      # puerta MQL4/MQL5 + Pine v6
   python3 scripts/check_readme_claims.py   # claims y referencias de archivos
   ```
4. Golden test si aplica (ver [docs/QA_STANDARD.md](./docs/QA_STANDARD.md))
5. PR describiendo la lógica cuantitativa y el estado de verificación

> CI se encarga de los mismos checks (`static-checks.yml`) y de compilar MQL
> (`compile-mql.yml`, solo Windows). Tu PR debe pasar ambos antes del merge.

---

## 📊 MQL4 / MQL5 (MetaTrader)

**Regla de oro: paridad.** Toda herramienta MQL4 debe tener gemelo MQL5 con el mismo
nombre y comportamiento (y viceversa) — `check_mql_parity.py` falla si no.

- Usa **solo API de tu plataforma**:
  - MQL4: `SetIndexBuffer(idx, array)` de 2 argumentos, `#property indicator_buffers`.
  - MQL5: `SetIndexBuffer(idx, array, INDICATOR_DATA)`, `indicator_plots`,
    `PlotIndexSetInteger`, `CopyBuffer`, `IndicatorCreate` — **prohibidos en `.mq4`**.
- EAs: no abrir operaciones sin confirmación; uso educativo, riesgo gestionado.
- Documenta parámetros de entrada en el README de la plataforma (tabla + sección
  "Parámetros clave"), en ES y EN.
- `#property strict` recomendado; 0 warnings de compilación.

**Checks:** `python3 scripts/check_mql_parity.py` · compilación real en CI (Windows).

---

## 📈 Pine Script v6 (TradingView)

- Primera línea **obligatoria**: `//@version=6` (`check_mql_parity.py` lo verifica).
- Ejecuta contra tu plan real de TradingView: respeta límites de barras y variables
  (ej. Free = 5 indicadores públicos, 10.000 barras de cálculo, 40 variables de entrada
  por script). Documenta el plan mínimo en el README.
- **No-lookahead:** usa `barstate.isconfirmed` para confirmar velas, evita calcular
  sobre la vela en formación salvo que sea intencional y esté documentado como
  repintado aceptable.
- Cualquier indicador que repinte debe declararlo en su sección del README
  (ver taxonomía en [docs/QA_STANDARD.md](./docs/QA_STANDARD.md)).

**Checks:** `python3 scripts/check_mql_parity.py` (versión) · revisión manual de
repintado en el PR.

---

## 🤖 C# cTrader (cBots)

- API del framework cTrader (`ctrader` netstandard): no uses APIs de otras
  plataformas (MetaTrader, Pine).
- **No-bucle silencioso:** todo ciclo de reintento (DCA, trailing) necesita flag
  de una sola ejecución (`bool _executed`) para evitar órdenes en cascada.
- Protege contra desalineación de estados: verifica `Position`/`PendingOrder`
  antes de actuar.
- Documenta versión mínima de cTrader y tipo de cuenta (demo/real) en el README.

**Checks:** revisión de código en PR + pruebas manuales en demo; compilación CI de C#
queda fuera de alcance (no hay runner público con SDK de cTrader).

---

## ✅ PR checklist

- [ ] `python3 scripts/check_mql_parity.py` pasa (o el PR es el fix para que pase)
- [ ] `python3 scripts/check_readme_claims.py` pasa (agregado a `claim_exceptions.json`
      solo si el código realmente implementa el claim)
- [ ] README actualizado: tabla de herramientas + sección de parámetros, ES (+ EN espejo)
- [ ] Golden test ejecutado y documentado para lógica numérica (POC/VAH/VAL, VWAP, ATR…)
- [ ] Repintado declarado (taxonomía del QA_STANDARD) si el indicador repinta
- [ ] Sin señales, sin claims de rentabilidad, sin datos de usuarios
- [ ] `CHANGELOG.md` actualizado en `[Unreleased]`
- [ ] CI verde (compilación MQL en Windows + static checks)

---

## 🔐 Política de contribución / Contribution policy

| Aceptado ✅ | Rechazado ❌ |
|---|---|
| Herramientas educativas | Señales de compra/venta |
| Gestión de riesgo local | Copy-trading comercial |
| Código 100% auditable | Código que exige datos de usuarios |
| Docs ES (EN espejo) | Claims sin respaldo en código |
| Golden values verificables | Promesas de rentabilidad |

Cualquier duda: abre un issue antes de invertir horas de código.
