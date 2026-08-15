# 📜 Changelog

Todas las modificaciones notables de este repositorio se documentan aquí.
Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/),
versionado [SemVer](https://semver.org/lang/es/).

## [1.1.0] — 2026-08-15

### Añadido
- **Validación Backtest Fase B (paridad MT5)**: resultados publicados en
  `docs/PHASEB_PARITY_RESULTS.md` y `mql/README.md`. Momentum (13 vs 11 trades,
  +$445.70), RSI2 (97 vs 80, +$711.80) y SMA (9 vs 6, −$952.20) alcanzan
  paridad frente al harness de Gueta.
- EAs de paridad finales: `GQ_Parity_{SMA,RSI2,Momentum}.mq5` con
  diagnóstico de Journal (`OnInit`, `GQDiag`, `ORDER FAIL retcode`).
- Job CI `Smoke test parity EAs` en `compile-mql.yml` (tester headless MT5).

### Eliminado
- `GQ_Parity_Donchian.mq5` — 0 operaciones en el tester MT5 tras 3
  iteraciones (ventana de canal, bucle explícito, diagnóstico); excluido por
  decisión del propietario. Documentado, no ocultado.

## [1.0.0] — 2026-08-15

### Añadido
- Lanzamiento público inicial de la suite (MT4/MT5/cTrader/Pine/Python).
- Infraestructura CI: compilación MQL4/MQL5 en GitHub Actions (Windows) y
  checks estáticos (`static-checks.yml`).
- Puerta de paridad MQL4/MQL5 + Pine v6 (`scripts/check_mql_parity.py`).
- Puerta de claims del README (`scripts/check_readme_claims.py` +
  `scripts/claim_exceptions.json`).
- Plantillas de issues (bug report y feature request) por plataforma.
- `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, `docs/QA_STANDARD.md`.

[Unreleased]: https://github.com/guetaquant-byte/guetaquant-tools/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/guetaquant-byte/guetaquant-tools/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/guetaquant-byte/guetaquant-tools/compare/v0.9.0...v1.0.0

## [0.9.0] — 2026-08-09

### Cambiado
- **Hardening dirigido por auditoría externa** (ver `docs/` del workspace):
  - Fixes de compilación MQL4 (eliminación de API solo-MQL5 en `.mq4`).
  - Fix de binning del Volume Profile (POC/VAH/VAL espejados).
  - Fix de divergencias (código muerto en detección de pivotes).
  - Fixes de runtime en cBots cTrader (flood de órdenes DCA y drenaje de
    trailing stop; flags de una sola ejecución).
- CI añadida: compilación MQL (Windows) + checks estáticos (paridad y claims).

### Añadido
- Registro inicial de calidad por plataforma (`mql/README.md`,
  `pinescript/README.md`, `ctrader/README.md`).

