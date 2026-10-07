# Seguridad — Alineación NIST SSDF y OWASP Top 10:2025

🌍 **Lee esto en:** [Español](SEGURIDAD.md) | [English](../en/SECURITY.md)

> Cómo este flujo implementa prácticas de seguridad reconocidas, adaptadas a un desarrollador individual.

---

## NIST SSDF (SP 800-218)

El NIST SSDF organiza las prácticas de seguridad en 4 grupos: **Prepare (PO)**, **Protect (PS)**, **Produce (PW)** y **Respond (RV)**. Para un desarrollador individual, no todas aplican con la misma profundidad que en una organización.

### Prácticas implementadas

| Práctica | Grupo | Cómo se aplica | Herramienta |
|----------|-------|----------------|-------------|
| **PO.1** | Prepare | Requisitos de seguridad definidos en el SRS | Documento `SRS.md` |
| **PO.3** | Prepare | Toolchain controlado | `package.json`, `requirements.txt` |
| **PS.1** | Protect | Protección del código | `.gitignore`, `.env` |
| **PS.2** | Protect | Verificación de integridad | Trivy, `npm audit`, `pip-audit` |
| **PW.1** | Produce | Threat modeling en el SSD-TDD | Documento `SSD-TDD.md` |
| **PW.4** | Produce | Verificación de dependencias | Trivy, `pip-audit` |
| **PW.7** | Produce | Revisión de código | PRs en GitHub |
| **RV.1** | Respond | Identificación de vulnerabilidades | Semgrep, Gitleaks |
| **RV.2** | Respond | Remediación documentada | Excepciones en `Plan_Pruebas.md` |

### Prácticas omitidas conscientemente

| Práctica | Por qué se omite |
|----------|------------------|
| **PO.2** (Roles y responsabilidades) | No aplica a desarrollador individual |
| **PO.4** (Criterios para componentes de terceros) | Se cubre parcialmente con PW.4 |
| **PS.3** (Archivo de releases con integridad) | Se cubre con tags de Git firmados (opcional) |
| **PW.2** (Diseño de software seguro) | Se cubre con PW.1 (threat modeling) |
| **PW.5** (Código fuente seguro) | Se cubre con PW.7 (revisión de código) |
| **PW.6** (Configuración de compilación) | No aplica a todos los lenguajes |
| **PW.8** (Pruebas de software ejecutable) | Se cubre en `Plan_Pruebas.md` |
| **PW.9** (Configuración segura por defecto) | Se documenta en `SSD-TDD.md` |
| **RV.3** (Análisis de vulnerabilidades) | Se hace manualmente si es necesario |

---

## OWASP Top 10:2025

La edición 2025 consolida la lista anterior con ajustes y cambios de prioridad. **Broken Access Control sigue siendo el riesgo #1**, y ahora incorpora SSRF (anteriormente categoría separada). **Security Misconfiguration y Software Supply Chain Failures** suben al top 3. **Mishandling of Exceptional Conditions** es la única categoría completamente nueva.

### Categorías y cobertura

| # | Categoría | ¿Aplica? | Mitigación | Prueba que verifica |
|---|-----------|----------|------------|---------------------|
| A01 | Broken Access Control | Sí | RBAC, validación de permisos en cada endpoint | Tests de autorización |
| A02 | Security Misconfiguration | Sí | Configuración segura por defecto, `.env` para secretos | Revisión manual + Trivy |
| A03 | Software Supply Chain Failures | Sí | Trivy en cada PR, verificación de dependencias | `sca.yml` |
| A04 | Cryptographic Failures | Sí | TLS, AES-256 en reposo, bcrypt para passwords | Revisión en SSD-TDD |
| A05 | Injection | Sí | Validación de inputs, ORM parametrizado, no `eval` | Semgrep + ESLint security |
| A06 | Insecure Design | Sí | Threat modeling en SSD-TDD | Revisión de diseño |
| A07 | Authentication Failures | Sí | JWT con expiración, rate limiting, MFA si aplica | Tests de auth |
| A08 | Software or Data Integrity Failures | Sí | Verificación de integridad de dependencias | `npm audit`, `pip-audit` |
| A09 | Security Logging & Alerting Failures | Sí | Logs sin PII, retención ≥ 90 días | Revisión en Estrategia Respaldos |
| A10 | Mishandling of Exceptional Conditions | Sí | Manejo de errores sin filtrar información | Tests de errores |

---

## Herramientas de seguridad del flujo

| Herramienta | Tipo | Workflow | Umbral de bloqueo |
|-------------|------|----------|-------------------|
| Semgrep | SAST | `sast.yml` | CRITICAL, HIGH |
| Trivy | SCA | `sca.yml` | CRITICAL, HIGH |
| Gitleaks | Secrets | `secrets.yml` | Cualquier secreto nuevo |
| detect-secrets | Secrets | `secrets.yml` | Cualquier secreto nuevo |
| Bandit | SAST (Python) | Pre-commit | CRITICAL, HIGH |
| ESLint security | SAST (JS/TS) | Pre-commit | CRITICAL, HIGH |
| OWASP ZAP | DAST | `dast.yml` | HIGH (informativo) |
| Codecov | Cobertura | `tests.yml` | < 80% global, < 50% patch |

---

## Cómo contribuir a la seguridad

1. **Nunca commitear secretos.** Usar `.env` (nunca versionado).
2. **Verificar dependencias antes de añadirlas.** Ejecutar `trivy` y `npm audit`/`pip-audit`.
3. **Validar inputs de usuario.** Siempre.
4. **No usar `eval()`, `exec()`, `child_process` con input no literal.**
5. **No usar `innerHTML` con datos no sanitizados.**
6. **Reportar vulnerabilidades** abriendo un issue con la etiqueta `security`.
