# Mapeo NIST SSDF + OWASP Top 10:2025

🌍 **Lee esto en:** [Español](Mapeo_NIST_OWASP.md) | [English](../en/NIST_OWASP_Mapping.md)

> **Estado:** Pendiente de redacción.
> **Instrucciones:** Usar el Prompt 5 (`docs/es/prompts/05-Mapeo-NIST-OWASP.md`) con DeepSeek web o Claude web.
> **Depende de:** `docs/es/SSD-TDD.md` + `docs/es/SRS.md`

---

## 1. Mapeo NIST SSDF (SP 800-218)

> Este proyecto es desarrollado por un individuo. No apunta a certificación. Solo se documentan las prácticas aplicables.

| Práctica | Grupo | Cómo se aplica | Herramienta | Frecuencia |
|----------|-------|----------------|-------------|------------|
| PO.1 | Prepare | [Requisitos de seguridad] | [Documento SRS] | [Al inicio] |
| PO.3 | Prepare | [Control del toolchain] | [package.json] | [Continuo] |
| PS.1 | Protect | [Protección del código] | [.gitignore, .env] | [Continuo] |
| PS.2 | Protect | [Integridad de componentes] | [Trivy] | [Cada PR] |
| PW.1 | Produce | [Threat modeling] | [SSD-TDD] | [Al diseñar] |
| PW.4 | Produce | [Verificar dependencias] | [Trivy, pip-audit] | [Cada PR] |
| PW.7 | Produce | [Revisión de código] | [PRs] | [Cada PR] |
| RV.1 | Respond | [Identificar vulnerabilidades] | [Semgrep, Gitleaks] | [Cada PR] |
| RV.2 | Respond | [Remediar vulnerabilidades] | [Issues] | [Continuo] |

### Prácticas omitidas conscientemente

| Práctica | Por qué se omite |
|----------|------------------|
| PO.2 | No aplica a desarrollador individual |
| PO.4 | Se cubre parcialmente con PW.4 |
| PS.3 | Se cubre con tags firmados (opcional) |
| PW.2 | Se cubre con PW.1 |
| PW.5 | Se cubre con PW.7 |
| PW.6 | No aplica a todos los lenguajes |
| PW.8 | Se cubre en Plan_Pruebas.md |
| PW.9 | Se documenta en SSD-TDD.md |
| RV.3 | Se hace manualmente si es necesario |

## 2. Mapeo OWASP Top 10:2025

| # | Categoría | ¿Aplica? | Mitigación | Prueba que verifica |
|---|-----------|----------|------------|---------------------|
| A01 | Broken Access Control | [Sí/No] | [Estrategia] | [Test] |
| A02 | Security Misconfiguration | [Sí/No] | [Estrategia] | [Test] |
| A03 | Software Supply Chain Failures | [Sí/No] | [Estrategia] | [Test] |
| A04 | Cryptographic Failures | [Sí/No] | [Estrategia] | [Test] |
| A05 | Injection | [Sí/No] | [Estrategia] | [Test] |
| A06 | Insecure Design | [Sí/No] | [Estrategia] | [Test] |
| A07 | Authentication Failures | [Sí/No] | [Estrategia] | [Test] |
| A08 | Software or Data Integrity Failures | [Sí/No] | [Estrategia] | [Test] |
| A09 | Security Logging & Alerting Failures | [Sí/No] | [Estrategia] | [Test] |
| A10 | Mishandling of Exceptional Conditions | [Sí/No] | [Estrategia] | [Test] |

## 3. Herramientas de seguridad del proyecto

| Herramienta | Tipo | Workflow | Umbral de bloqueo |
|-------------|------|----------|-------------------|
| Semgrep | SAST | `sast.yml` | CRITICAL, HIGH |
| Trivy | SCA | `sca.yml` | CRITICAL, HIGH |
| Gitleaks | Secrets | `secrets.yml` | Cualquier secreto nuevo |
| detect-secrets | Secrets | `secrets.yml` | Cualquier secreto nuevo |
| Bandit | SAST (Python) | Pre-commit | CRITICAL, HIGH |
| ESLint security | SAST (JS/TS) | Pre-commit | CRITICAL, HIGH |
| OWASP ZAP | DAST | `dast.yml` | HIGH (informativo) |

## 4. Matriz de trazabilidad de seguridad

| Requisito (SRS) | Práctica NIST | Categoría OWASP | Prueba que verifica |
|-----------------|---------------|-----------------|---------------------|
| RNF-SEC-001 | PO.1 | A01 | [Test] |

## 5. Excepciones y omisiones

| Práctica | Justificación |
|----------|---------------|
| [Práctica omitida] | [Por qué] |