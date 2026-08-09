# 📜 Changelog

Todas las modificaciones notables de este repositorio se documentan aquí.
Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/),
versionado [SemVer](https://semver.org/lang/es/).

## [Unreleased]

### Añadido
- Infraestructura CI: compilación MQL4/MQL5 en GitHub Actions (Windows) y
  checks estáticos (`static-checks.yml`).
- Puerta de paridad MQL4/MQL5 + Pine v6 (`scripts/check_mql_parity.py`).
- Puerta de claims del README (`scripts/check_readme_claims.py` +
  `scripts/claim_exceptions.json`).
- Plantillas de issues (bug report y feature request) por plataforma.
- `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, `docs/QA_STANDARD.md`.

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

[Unreleased]: https://github.com/guetaquant-byte/guetaquant-tools/compare/v0.9.0...HEAD
[0.9.0]: https://github.com/guetaquant-byte/guetaquant-tools/releases/tag/v0.9.0
