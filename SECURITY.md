# Política de Divulgación de Seguridad 🇪🇸 · Security Disclosure Policy 🇬🇧

*Última actualización: 2026-08-09 / Last updated: 2026-08-09*

## Reportar una vulnerabilidad / Reporting a vulnerability

Nos tomamos muy en serio la seguridad de los datos de trading de nuestros usuarios. Si crees que has encontrado una vulnerabilidad de seguridad en cualquier producto de Gueta Quant (sitio web, Diario de Trading, herramientas open-source), por favor repórtala en privado:
We take the security of our users' trading data seriously. If you believe you have found a security vulnerability in any Gueta Quant product (website, Trading Journal, open-source tools), please report it privately:

- **Correo / Email:** `security@guetaquant.com`
- **GitHub:** Usa la función de **Private Vulnerability Reporting** del repositorio (Security → Report a vulnerability) en `guetaquant-byte/guetaquant-tools` o `guetaquant-byte/guetaquant-portal`. / Use the repository's **Private Vulnerability Reporting** feature on `guetaquant-byte/guetaquant-tools` or `guetaquant-byte/guetaquant-portal`.
- **Cifrado PGP / PGP encryption:** Solicita nuestra llave por correo antes de enviar detalles sensibles (o usa el canal privado de GitHub, que es cifrado de extremo a extremo). / Request our key via email before sending sensitive details (or use the GitHub private channel, which is end-to-end encrypted).

## Nuestros compromisos (SLA) / Our commitments (SLA)

| Severidad / Severity | Respuesta inicial / Initial response | Objetivo de arreglo / Fix target |
|---|---|---|
| Crítico / Critical | 24h | 72h |
| Alto / High | 48h | 7 días / 7 days |
| Medio / Medium | 72h | 14 días / 14 days |
| Bajo / Low | 7 días / 7 days | 30 días / 30 days |

## Alcance / Scope

- `guetaquant.com` (todas las rutas, incluyendo `/journal/app/`) / (all routes, including `/journal/app/`)
- `guetaquant-byte/guetaquant-tools` (MQL4/5, Pine v6, cTrader C#)
- El SPA del Diario de Trading (almacenamiento local, cifrado IndexedDB, manejo de payload de IA) / The Trading Journal SPA (local storage, IndexedDB encryption, AI payload handling)

## Fuera de alcance (conocido y aceptado) / Out of scope (known and accepted)

- La **capa de IA es opt-in y basada en nube por diseño**: cuando el usuario hace clic en Analizar/Chat, los datos de trading se envían a Google Gemini vía `guetaquant.com/api/*`. Esto se divulga en la UI y en nuestra documentación de privacidad; no es una vulnerabilidad. / The **AI layer is opt-in and cloud-based by design**: when the user clicks Analyze/Chat, trade data is sent to Google Gemini via `guetaquant.com/api/*`. This is disclosed in the UI and in our privacy documentation; it is not a vulnerability.
- Phishing/ingeniería social estándar contra dominios que no sean guetaquant.com. / Standard phishing/social engineering against non-guetaquant.com domains.
- Abuso de rate-limit de endpoints públicos (reportar solo si conduce a exposición de datos). / Rate-limit abuse of public endpoints (report only if it leads to data exposure).

## Nuestra postura (no-scam, no-exfiltración) / Our stance (no-scam, no-exfiltration)

Nunca incluiremos telemetría oculta, venta de datos ni recolección no divulgada en nuestro diario núcleo (es local-first y verificable — ver [ZERO_KNOWLEDGE_PRIVACY_AUDIT.md](https://github.com/guetaquant-byte/guetaquant-tools/blob/main/docs/ZERO_KNOWLEDGE_PRIVACY_AUDIT.md)). Si encuentras código que contradiga esto, es una vulnerabilidad Crítica — repórtala.
We will never include hidden telemetry, data-selling, or undisclosed data collection in our core journal (it is local-first and verifiable — see [ZERO_KNOWLEDGE_PRIVACY_AUDIT.md](https://github.com/guetaquant-byte/guetaquant-tools/blob/main/docs/ZERO_KNOWLEDGE_PRIVACY_AUDIT.md)). If you find code that contradicts this, it is a Critical vulnerability — report it.

## Reconocimientos / Acknowledgments

Agradeceremos públicamente a los reportantes válidos (con permiso) en el CHANGELOG del repositorio y en guetaquant.com/security. / We will publicly thank valid reporters (with permission) in the repository CHANGELOG and on guetaquant.com/security.
