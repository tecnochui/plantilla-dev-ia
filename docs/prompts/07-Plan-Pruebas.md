# Prompt 7 — Plan de Pruebas

## Propósito
Definir la estrategia de testing completa: unitarias, integración, E2E, seguridad.

## Modelo recomendado
DeepSeek web o Gemini web.

## Archivos a adjuntar
`docs/SRS.md` + `docs/SSD-TDD.md` + `docs/Propuesta_Tecnica.md`

## Cuándo usarlo
Después de que el SSD-TDD y la Propuesta Técnica estén validados.

---

## Prompt completo

```
Actúa como ingeniero de QA y seguridad. Con base en los siguientes documentos ya aprobados:

- `docs/SRS.md` (requisitos funcionales y no funcionales)
- `docs/SSD-TDD.md` (arquitectura, diseño de BD, API y estrategia de testing resumida)
- `docs/Propuesta_Tecnica.md` (stack tecnológico)

Genera el Plan de Pruebas completo para este proyecto. Usa el formato Markdown y respeta la estructura de secciones que se indica a continuación. Sé específico y concreto; evita generalidades.

---

## 1. Estrategia de testing

### 1.1. Pirámide de pruebas
Define los porcentajes objetivo y las herramientas para cada nivel. Basado en el stack del proyecto, recomienda:
- **Unitarias:** % objetivo y herramienta (ej. Vitest para JS/TS, pytest para Python). Cobertura mínima global recomendada: 80% para unitarias, 70% para integración, y E2E solo para caminos felices críticos.
- **Integración:** % objetivo y herramienta.
- **Extremo a extremo (E2E):** herramienta (ej. Playwright) y qué flujos cubrir.
- **Manuales:** qué se prueba a mano y por qué (ej. UX, exploratorio).

### 1.2. Cobertura mínima
Define los umbrales concretos:
- Cobertura global del proyecto (ej. 80%).
- Cobertura del código nuevo por PR (patch coverage, ej. 50%).
- Archivos excluidos de cobertura (ej. migraciones, configuración, `main`).

### 1.3. Datos de prueba
- Estrategia para generar datos de prueba (fixtures, factories, datos anonimizados).
- Manejo de datos sensibles en tests (nunca usar datos de producción).

---

## 2. Herramientas por tipo de prueba

Genera una tabla con este formato, adaptada al stack del proyecto:

| Tipo | Herramienta | Comando | Ejecutado en | Umbral de bloqueo |
|------|-------------|---------|--------------|-------------------|
| Unitarias (JS/TS) | Vitest | `npm test` | Local + CI | Fallo de tests |
| Unitarias (Python) | pytest | `pytest` | Local + CI | Fallo de tests |
| Integración | [herramienta] | [comando] | CI | Fallo de tests |
| E2E | Playwright | `npx playwright test` | CI (staging) | Fallo de tests |
| Cobertura | Codecov | automático | CI | < 80% global |
| SAST | Semgrep | `semgrep ci` | CI (cada PR) | CRITICAL, HIGH |
| SCA | Trivy | `trivy fs .` | CI (cada PR) | CRITICAL, HIGH |
| Secrets | Gitleaks + detect-secrets | `gitleaks detect` | CI + pre-commit | Cualquier secreto nuevo |
| DAST | OWASP ZAP | `zap-baseline.py` | CI (post-deploy staging) | HIGH (solo informativo) |

---

## 3. Pruebas de seguridad automatizadas

### 3.1. Categorías de pruebas

| Categoría | Herramienta | Qué detecta | Workflow |
|-----------|-------------|-------------|----------|
| SAST | Semgrep + CodeQL | Patrones inseguros en código (inyección, XSS, eval, etc.) | `sast.yml` |
| SCA | Trivy + OWASP Dependency-Check | Vulnerabilidades en dependencias de terceros | `sca.yml` |
| Secrets | Gitleaks + detect-secrets | Secretos hardcodeados (API keys, tokens, contraseñas) | `secrets.yml` |
| DAST | OWASP ZAP | Vulnerabilidades en app en ejecución (XSS, SQLi, headers) | `dast.yml` |
| IaC | Checkov | Malas configuraciones en infraestructura como código | `iac.yml` (si aplica) |

### 3.2. Cobertura OWASP Top 10:2025

Para cada categoría del OWASP Top 10:2025, indica si aplica al proyecto, cómo se mitiga, y qué prueba lo verifica:

| # | Categoría OWASP | ¿Aplica? | Mitigación | Prueba que verifica |
|---|-----------------|----------|------------|---------------------|
| A01 | Broken Access Control | [Sí/No] | [estrategia] | [test/escáner] |
| A02 | Security Misconfiguration | [Sí/No] | [estrategia] | [test/escáner] |
| A03 | Software Supply Chain Failures | [Sí/No] | [estrategia] | [test/escáner] |
| A04 | Cryptographic Failures | [Sí/No] | [estrategia] | [test/escáner] |
| A05 | Injection | [Sí/No] | [estrategia] | [test/escáner] |
| A06 | Insecure Design | [Sí/No] | [estrategia] | [test/escáner] |
| A07 | Authentication Failures | [Sí/No] | [estrategia] | [test/escáner] |
| A08 | Software or Data Integrity Failures | [Sí/No] | [estrategia] | [test/escáner] |
| A09 | Security Logging & Alerting Failures | [Sí/No] | [estrategia] | [test/escáner] |
| A10 | Mishandling of Exceptional Conditions | [Sí/No] | [estrategia] | [test/escáner] |

### 3.3. Mapeo NIST SSDF

Indica qué prácticas del NIST SSDF (SP 800-218) se aplican a este proyecto:

| Práctica | Grupo | Cómo se aplica | Herramienta |
|----------|-------|----------------|-------------|
| PO.1 | Prepare | Definir requisitos de seguridad | Documento de requisitos |
| PO.3 | Prepare | Controlar el toolchain | `package.json`, `requirements.txt` |
| PS.1 | Protect | Proteger el código | `.gitignore`, `.env` |
| PS.2 | Protect | Verificar integridad de componentes | Trivy, `npm audit` |
| PW.1 | Produce | Threat modeling | Documento de diseño |
| PW.4 | Produce | Verificar componentes de terceros | Trivy, `pip-audit` |
| PW.7 | Produce | Revisión de código | PR reviews |
| RV.1 | Respond | Identificar vulnerabilidades | Semgrep, Gitleaks |
| RV.2 | Respond | Evaluar y remediar | Issues de seguridad |

Documenta explícitamente qué prácticas **NO** aplican y por qué (ej. por ser desarrollador individual).

---

## 4. Integración con GitHub Actions

Genera una tabla con los workflows del proyecto:

| Workflow | Se ejecuta en | Bloquea merge | Propósito |
|----------|---------------|---------------|-----------|
| `tests.yml` | PR + push a main | Sí | Tests unitarios, integración, cobertura |
| `commitlint.yml` | PR | Sí | Validar Conventional Commits |
| `sast.yml` | PR + push a main | Sí (CRITICAL, HIGH) | Análisis estático de seguridad |
| `sca.yml` | PR + push a main | Sí (CRITICAL, HIGH) | Vulnerabilidades en dependencias |
| `secrets.yml` | PR + push a main | Sí (cualquier secreto) | Detección de secretos |
| `dast.yml` | Post-deploy a staging | No (informativo) | Escaneo dinámico de seguridad |
| `changelog.yml` | Creación de tag `v*` | No | Generar CHANGELOG.md |

---

## 5. Criterios de aceptación para merge

Un PR puede mergearse solo si cumple **todos** estos criterios:

- [ ] Todos los tests unitarios pasan en todas las versiones soportadas.
- [ ] La cobertura global no baja más de 1% respecto a la rama base.
- [ ] El código nuevo (patch) tiene al menos 50% de cobertura.
- [ ] Semgrep no reporta hallazgos CRITICAL ni HIGH.
- [ ] Trivy no reporta vulnerabilidades CRITICAL ni HIGH en dependencias.
- [ ] Gitleaks y detect-secrets no reportan secretos nuevos.
- [ ] Los commits siguen Conventional Commits.
- [ ] Al menos una persona (tú) ha revisado el diff.
- [ ] No hay conflictos con la rama base.

---

## 6. Umbrales de severidad

| Severidad | Acción | Plazo de corrección |
|-----------|--------|---------------------|
| CRITICAL | Bloquear merge. Corregir antes de continuar. | Inmediato |
| HIGH | Bloquear merge. Corregir o documentar excepción justificada. | Antes del merge |
| MEDIUM | Advertir. Revisar caso por caso. Puede mergearse con justificación documentada. | 7 días |
| LOW | Registrar. No bloquea. | 30 días |
| INFO | Ignorar. | N/A |

---

## 7. Pruebas manuales periódicas

| Prueba | Frecuencia | Responsable | Herramienta |
|--------|------------|-------------|-------------|
| Pentesting manual | Cada release mayor | Tú | OWASP ZAP, Burp Suite (community) |
| Revisión de dependencias críticas | Mensual | Tú | `npm audit`, `pip-audit` |
| Rotación de secretos | Cada 6 meses | Tú | Gestor de secretos |
| Revisión de logs de seguridad | Semanal | Tú | Revisión manual |
| Revisión de accesos y permisos | Trimestral | Tú | Revisión manual |

---

## 8. Registro de pruebas

Genera una tabla para documentar la ejecución de pruebas de seguridad manuales:

| Fecha | Tipo | Herramienta | Resultado | Hallazgos | Acción tomada | Responsable |
|-------|------|-------------|-----------|-----------|---------------|-------------|
| [YYYY-MM-DD] | Pentesting | OWASP ZAP | [OK/Fallos] | [descripción] | [acción] | [nombre] |

---

## 9. Excepciones documentadas

Genera una tabla para documentar hallazgos que se decidió NO corregir:

| ID | Hallazgo | Severidad | Justificación | Fecha | Revisado por |
|----|----------|-----------|---------------|-------|--------------|
| EX-001 | [descripción] | [MEDIUM] | [por qué no se corrige] | [fecha] | [nombre] |

---

## 10. Riesgos y supuestos

- **Riesgos:** Lista los riesgos que podrían afectar la estrategia de pruebas (ej. falta de tiempo, herramientas limitadas, proyecto legacy sin tests).
- **Supuestos:** Lista los supuestos bajo los que se diseña este plan (ej. el entorno de staging existe, los desarrolladores tienen acceso a las herramientas).

---

## 11. Glosario

Define los términos técnicos usados en este documento:

| Término | Definición |
|---------|------------|
| SAST | Static Application Security Testing — análisis de código sin ejecutarlo |
| DAST | Dynamic Application Security Testing — análisis de la app en ejecución |
| SCA | Software Composition Analysis — análisis de dependencias de terceros |
| IAST | Interactive Application Security Testing — análisis en tiempo de ejecución |
| CVE | Common Vulnerabilities and Exposures — identificador de vulnerabilidades |
| SBOM | Software Bill of Materials — inventario de componentes de software |

---

## Instrucciones finales

1. **No inventes información.** Si falta contexto para alguna sección, hazme preguntas antes de generar.
2. **Sé específico.** En lugar de "usar herramientas de seguridad", escribe "usar Semgrep con los rulesets `p/owasp-top-ten` y `p/security-audit`".
3. **Alinea con el stack real.** Si el proyecto usa Python, no menciones Vitest. Si usa Node, no menciones pytest.
4. **Formato:** Markdown con tablas y checkboxes. Usa Mermaid solo si un diagrama aporta claridad (ej. flujo de CI/CD).
5. **Longitud:** 300-500 líneas. Si es más corto, falta detalle. Si es más largo, está siendo redundante.
```

---

## Validación post-generación

- [ ] Las herramientas coinciden con el stack (no mezcla Python con Node).
- [ ] Los umbrales de cobertura son realistas (80% global, 50% patch).
- [ ] Los workflows de GitHub Actions coinciden con los del repo.
- [ ] El OWASP Top 10:2025 está completo (las 10 categorías, con A10 = Mishandling of Exceptional Conditions).
- [ ] El mapeo NIST SSDF es honesto sobre lo que no aplica.

## Guardar como
`docs/Plan_Pruebas.md`
