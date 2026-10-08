# Plan de Pruebas

🌍 **Lee esto en:** [Español](Plan_Pruebas.md) | [English](../en/Test_Plan.md)

> **Estado:** Pendiente de redacción.
> **Instrucciones:** Usar el Prompt 7 (`docs/es/prompts/07-Plan-Pruebas.md`) con DeepSeek web o Gemini web.
> **Depende de:** `docs/es/SSD-TDD.md` (sección 6) + `docs/es/SRS.md`
> **Nota:** La sección 6 del `SSD-TDD.md` es un **resumen**. Este documento es el **detalle completo**. Si hay discrepancia, este documento tiene prioridad.

---

## 1. Estrategia de testing

### 1.1. Pirámide de pruebas
- **Unitarias:** [% objetivo] — [Herramienta]
- **Integración:** [% objetivo] — [Herramienta]
- **Extremo a extremo:** [% objetivo] — [Herramienta]
- **Manuales:** [Qué se prueba a mano]

### 1.2. Cobertura mínima
- Cobertura global: [ej. 80%]
- Cobertura del código nuevo (patch): [ej. 50%]
- Archivos excluidos: [ej. migraciones, config]

### 1.3. Datos de prueba
- **Fixtures:** [Cómo se generan]
- **Factories:** [Herramienta]
- **Anonimización:** [Cómo se manejan datos sensibles]

## 2. Herramientas por tipo de prueba

| Tipo | Herramienta | Comando | Ejecutado en | Umbral de bloqueo |
|------|-------------|---------|--------------|-------------------|
| Unitarias (JS/TS) | Vitest | `npm test` | Local + CI | Fallo de tests |
| Unitarias (Python) | pytest | `pytest` | Local + CI | Fallo de tests |
| Integración | [Herramienta] | [Comando] | CI | Fallo de tests |
| E2E | Playwright | `npx playwright test` | CI (staging) | Fallo de tests |
| Cobertura | Codecov | automático | CI | < 80% global |
| SAST | Semgrep | `semgrep ci` | CI | CRITICAL, HIGH |
| SCA | Trivy | `trivy fs .` | CI | CRITICAL, HIGH |
| Secrets | Gitleaks + detect-secrets | `gitleaks detect` | CI + pre-commit | Cualquier secreto |
| DAST | OWASP ZAP | `zap-baseline.py` | CI (staging) | HIGH (informativo) |

## 3. Pruebas de seguridad automatizadas

### 3.1. Categorías

| Categoría | Herramienta | Qué detecta | Workflow |
|-----------|-------------|-------------|----------|
| SAST | Semgrep + CodeQL | Patrones inseguros | `sast.yml` |
| SCA | Trivy | Vulnerabilidades en dependencias | `sca.yml` |
| Secrets | Gitleaks + detect-secrets | Secretos hardcodeados | `secrets.yml` |
| DAST | OWASP ZAP | Vulnerabilidades en ejecución | `dast.yml` |

### 3.2. Cobertura OWASP Top 10:2025

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

### 3.3. Mapeo NIST SSDF

| Práctica | Grupo | Cómo se aplica | Herramienta |
|----------|-------|----------------|-------------|
| PO.1 | Prepare | Definir requisitos de seguridad | Documento de requisitos |
| PO.3 | Prepare | Controlar el toolchain | package.json |
| PS.1 | Protect | Proteger el código | .gitignore, .env |
| PS.2 | Protect | Verificar integridad de componentes | Trivy |
| PW.1 | Produce | Threat modeling | SSD-TDD |
| PW.4 | Produce | Verificar componentes de terceros | Trivy, pip-audit |
| PW.7 | Produce | Revisión de código | PR reviews |
| RV.1 | Respond | Identificar vulnerabilidades | Semgrep, Gitleaks |
| RV.2 | Respond | Evaluar y remediar | Issues de seguridad |

## 4. Integración con GitHub Actions

| Workflow | Se ejecuta en | Bloquea merge | Propósito |
|----------|---------------|---------------|-----------|
| `tests.yml` | PR + push a main | Sí | Tests unitarios, integración, cobertura |
| `commitlint.yml` | PR | Sí | Validar Conventional Commits |
| `sast.yml` | PR + push a main | Sí (CRITICAL, HIGH) | Análisis estático de seguridad |
| `sca.yml` | PR + push a main | Sí (CRITICAL, HIGH) | Vulnerabilidades en dependencias |
| `secrets.yml` | PR + push a main | Sí | Detección de secretos |
| `dast.yml` | Post-deploy a staging | No (informativo) | Escaneo dinámico de seguridad |
| `changelog.yml` | Creación de tag `v*` | No | Generar CHANGELOG.md |

## 5. Criterios de aceptación para merge

- [ ] Todos los tests unitarios pasan.
- [ ] La cobertura global no baja más de 1% respecto a la rama base.
- [ ] El código nuevo (patch) tiene al menos 50% de cobertura.
- [ ] Semgrep no reporta hallazgos CRITICAL ni HIGH.
- [ ] Trivy no reporta vulnerabilidades CRITICAL ni HIGH.
- [ ] Gitleaks y detect-secrets no reportan secretos nuevos.
- [ ] Los commits siguen Conventional Commits.
- [ ] Al menos una persona (tú) ha revisado el diff.

## 6. Umbrales de severidad

| Severidad | Acción | Plazo de corrección |
|-----------|--------|---------------------|
| CRITICAL | Bloquear merge | Inmediato |
| HIGH | Bloquear merge | Antes del merge |
| MEDIUM | Advertir, revisar caso por caso | 7 días |
| LOW | Registrar, no bloquea | 30 días |
| INFO | Ignorar | N/A |

## 7. Pruebas manuales periódicas

| Prueba | Frecuencia | Responsable | Herramienta |
|--------|------------|-------------|-------------|
| Pentesting manual | [Cada release mayor] | Tú | OWASP ZAP |
| Revisión de dependencias | [Mensual] | Tú | npm audit, pip-audit |
| Rotación de secretos | [Cada 6 meses] | Tú | Gestor de secretos |
| Revisión de logs de seguridad | [Semanal] | Tú | Revisión manual |

## 8. Registro de pruebas

| Fecha | Tipo | Herramienta | Resultado | Hallazgos | Acción tomada |
|-------|------|-------------|-----------|-----------|---------------|
| | | | | | |

## 9. Excepciones documentadas

| ID | Hallazgo | Severidad | Justificación | Fecha |
|----|----------|-----------|---------------|-------|
| EX-001 | [Hallazgo] | [Severidad] | [Justificación] | [Fecha] |

## 10. Riesgos y supuestos

### Riesgos
- [Riesgo que afecta la estrategia de pruebas]

### Supuestos
- [Supuesto bajo el cual se diseña este plan]

## 11. Glosario

| Término | Definición |
|---------|------------|
| SAST | Static Application Security Testing |
| DAST | Dynamic Application Security Testing |
| SCA | Software Composition Analysis |
| CVE | Common Vulnerabilities and Exposures |
| SBOM | Software Bill of Materials |