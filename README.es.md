# 🛠️ Plantilla Dev IA — Flujo de trabajo con IA para desarrollo de software

🌍 **Lee esto en:** [Español](README.es.md) | [English](README.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Actions](https://img.shields.io/badge/CI-GitHub_Actions-blue)](https://github.com/features/actions)
[![Security: NIST SSDF](https://img.shields.io/badge/Security-NIST_SSDF-blueviolet)](https://csrc.nist.gov/Projects/ssdf)
[![OWASP Top 10:2025](https://img.shields.io/badge/OWASP-Top_10%3A2025-orange)](https://owasp.org/Top10/)

> **Una plantilla de repositorio para desarrollar software con asistencia de IA, documentación secuencial, seguridad automatizada y flujo de trabajo estandarizado.**

---

## 📋 ¿Qué es esto?

Este repositorio contiene **un flujo de trabajo completo** para desarrollar software con asistencia de IA, desde la documentación inicial hasta el despliegue, pasando por la seguridad automatizada y el control de calidad.

No es un framework ni una librería. Es una **metodología empaquetada en forma de repositorio plantilla** que puedes clonar y usar como base para cualquier proyecto nuevo. La plantilla incluye:

- **8 prompts secuenciales** para generar los documentos fundacionales con IA (gratuita o de bajo costo).
- **Configuración de CI/CD** con 7 workflows de GitHub Actions divididos por dominio (tests, seguridad, changelog, etc.).
- **Herramientas de seguridad automatizadas** (SAST, SCA, detección de secretos, DAST) alineadas con NIST SSDF y OWASP Top 10:2025.
- **Hooks de Git** para validar commits, formato y secretos antes de cada push.
- **Estructura de documentación** lista para usar (PRD-SRD, SRS, SSD-TDD, Plan de Pruebas, etc.).
- **Registro Forense** para continuar proyectos sin documentación (ingeniería inversa).
- **Script de inicialización** (`init-project.sh`) que crea un proyecto completo en un comando.
- **Makefile** con tareas comunes (`make test`, `make security`, `make all`, etc.).

---

## 🚀 Quick Start

### Opción única: Clonar el repositorio y usar `init-project.sh`

```bash
# 1. Clonar este repositorio
git clone https://github.com/tecnochui/plantilla-dev-ia.git
cd plantilla-dev-ia

# 2. Ver las opciones del script
./scripts/init-project.sh --help

# 3. Documentación completa del script
cat scripts/README.md

# 4. Crear un proyecto nuevo (español por defecto)
./scripts/init-project.sh mi-nuevo-proyecto

# 5. Crear un proyecto en inglés
./scripts/init-project.sh mi-nuevo-proyecto --language en

# 6. Crear un proyecto bilingüe (inglés + docs en español)
./scripts/init-project.sh mi-nuevo-proyecto --language en --with-other-language

# 7. Con opciones adicionales
./scripts/init-project.sh mi-nuevo-proyecto --language es --path ~/proyectos --private
```

**Nota:** Este repo es una **herramienta**, no una plantilla de proyecto. No se debe usar "Use this template" de GitHub directamente, porque copiaría la estructura del repo plantilla (con `docs/`, `scripts/`, `template/`), no la estructura de un proyecto nuevo.

---

## 🌍 Soporte bilingüe

Esta plantilla es totalmente bilingüe (español + inglés):

- **Docs de referencia** viven en `docs/es/` y `docs/en/`
- **Prompts** viven en `docs/es/prompts/` y `docs/en/prompts/`
- **Placeholders** viven en `template/docs/es/` y `template/docs/en/`

Cada proyecto generado:
- Guarda su idioma en `.project-language`
- Recibe los docs del idioma elegido en `docs/`
- Puede añadir el otro idioma después con `./setup.sh --add-language <es|en>`

---

## 🏗️ ¿Cómo funciona el flujo?

El flujo de trabajo sigue **7 fases secuenciales**. Cada fase produce un documento que alimenta a la siguiente. No se genera código hasta que los 7 documentos están validados.

```
┌─────────────────────────────────────────────────────────────────┐
│   FASE 0: CONFIGURACIÓN DEL ENTORNO                            │
│   • ./setup.sh --install-tools                                  │
│   • Editar AGENTS.md con el nombre del proyecto                 │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│   FASE 1: DOCUMENTACIÓN FUNDACIONAL (secuencial)                │
│                                                                  │
│   1. PRD-SRD          → ¿Qué construimos y para quién?          │
│   2. SRS              → Requisitos funcionales y no funcionales │
│   3. Propuesta Técnica → Stack, arquitectura, licenciamiento   │
│   4. SSD-TDD          → Diseño detallado (arquitectura, BD, API)│
│   5. Mapeo NIST+OWASP → Cumplimiento de seguridad              │
│   6. Estrategia Respaldos → Respaldos y retención de logs      │
│   7. Plan de Pruebas  → Estrategia de testing completa         │
│                                                                  │
│   Cada documento se valida antes de pasar al siguiente.         │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│   FASE 2: DESARROLLO CON AGENTE                                 │
│   • Zoo Code (Architect) + DeepSeek V4 Flash → plan             │
│   • Zoo Code (Code) + DeepSeek V4 Flash → implementación        │
│   • Zoo Code (Debug) + Qwen3 Coder Next → depuración            │
│   • Pre-commit hook valida en cada commit                       │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│   FASE 3: REVISIÓN DE SEGURIDAD                                 │
│   • Push → GitHub Actions ejecuta workflows en paralelo         │
│   • Codecov reporta cobertura en el PR                          │
│   • Si hay CRITICAL/HIGH → bloqueo de merge                     │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│   FASE 4: RELEASE                                               │
│   • git tag v1.0.0 → changelog.yml genera CHANGELOG.md          │
│   • Deploy (cuando tengas destino configurado)                  │
└─────────────────────────────────────────────────────────────────┘
```

**Nota:** Hay un **8º prompt** (`08-Registro-Forense.md`) que no se usa al inicio. Se usa **después** de que existe código, para hacer ingeniería inversa de un sistema sin documentación.

### 📖 Documentación detallada del flujo

| Documento | Descripción |
|-----------|-------------|
| [`docs/ARQUITECTURA.md`](docs/es/ARQUITECTURA.md) | Filosofía y decisiones de diseño del flujo |
| [`docs/FLUJO_DE_TRABAJO.md`](docs/es/FLUJO_DE_TRABAJO.md) | Diagrama completo del proceso end-to-end |
| [`docs/HERRAMIENTAS.md`](docs/es/HERRAMIENTAS.md) | Stack de herramientas y por qué se eligió cada una |
| [`docs/HERRAMIENTAS_SEGURIDAD.md`](docs/es/HERRAMIENTAS_SEGURIDAD.md) | Instalación y uso de Semgrep, Trivy, Gitleaks, git-cliff |
| [`docs/MODELOS_IA.md`](docs/es/MODELOS_IA.md) | Guía de modelos de IA, costos y cuándo usar cada uno |
| [`docs/SEGURIDAD.md`](docs/es/SEGURIDAD.md) | Alineación con NIST SSDF y OWASP Top 10:2025 |
| [`docs/WORKFLOWS.md`](docs/es/WORKFLOWS.md) | Documentación de los 7 workflows de GitHub Actions |
| [`docs/GITHUB_SECRETS.md`](docs/es/GITHUB_SECRETS.md) | Secrets necesarios en GitHub |
| [`docs/prompts/README.md`](docs/es/prompts/README.md) | Índice maestro de los 8 prompts secuenciales |
| [`scripts/README.md`](scripts/README.md) | Documentación de `init-project.sh` y `setup.sh` |

---

## 🧰 ¿Qué incluye la plantilla?

### Documentación fundacional (8 documentos)

| # | Documento | Propósito | Prompt |
|---|-----------|-----------|--------|
| 1 | **PRD-SRD** | Qué se construye y para quién | [`01-PRD-SRD.md`](docs/es/prompts/01-PRD-SRD.md) |
| 2 | **SRS** | Requisitos funcionales y no funcionales | [`02-SRS.md`](docs/es/prompts/02-SRS.md) |
| 3 | **Propuesta Técnica** | Stack, arquitectura, licenciamiento | [`03-Propuesta-Tecnica.md`](docs/es/prompts/03-Propuesta-Tecnica.md) |
| 4 | **SSD-TDD** | Diseño detallado: arquitectura, BD, API | [`04-SSD-TDD.md`](docs/es/prompts/04-SSD-TDD.md) |
| 5 | **Mapeo NIST+OWASP** | Cumplimiento de seguridad | [`05-Mapeo-NIST-OWASP.md`](docs/es/prompts/05-Mapeo-NIST-OWASP.md) |
| 6 | **Estrategia de Respaldos** | Respaldos y retención de logs | [`06-Estrategia-Respaldos.md`](docs/es/prompts/06-Estrategia-Respaldos.md) |
| 7 | **Plan de Pruebas** | Estrategia de testing completa | [`07-Plan-Pruebas.md`](docs/es/prompts/07-Plan-Pruebas.md) |
| 8 | **Registro Forense** | Ingeniería inversa de sistemas sin docs | [`08-Registro-Forense.md`](docs/es/prompts/08-Registro-Forense.md) |

### Archivos de configuración

| Archivo | Propósito |
|---------|-----------|
| `AGENTS.md` | Contexto persistente para Zoo Code y otros agentes |
| `CLAUDE.md` | Puente `@AGENTS.md` para Claude Code |
| `GEMINI.md` | Puente `@./AGENTS.md` para Gemini CLI |
| `Makefile` | Tareas comunes (`make test`, `make security`, `make all`) |
| `.env.example` | Plantilla de variables de entorno (sin secretos reales) |
| `cliff.toml` | Configuración de `git-cliff` para changelog automático |
| `commitlint.config.js` | Validación de Conventional Commits |
| `.eslintrc-security.js` | SAST con ESLint (seguridad + XSS) |
| `.gitleaks.toml` | Detección de secretos (API keys de IA + genéricos) |
| `.secrets.baseline` | Baseline de `detect-secrets` |
| `codecov.yml` | Umbrales de cobertura (bloqueo de PR) |
| `.gitignore` | Ignora dependencias, entornos, secretos, builds |

### GitHub Actions (workflows del proyecto)

| Workflow | Propósito | Bloquea merge |
|----------|-----------|---------------|
| `tests.yml` | Tests unitarios + cobertura con Codecov | Sí |
| `commitlint.yml` | Valida Conventional Commits en PRs | Sí |
| `sast.yml` | Análisis estático de seguridad con Semgrep | Sí (CRITICAL/HIGH) |
| `sca.yml` | Vulnerabilidades en dependencias con Trivy | Sí (CRITICAL/HIGH) |
| `secrets.yml` | Detección de secretos con Gitleaks + detect-secrets | Sí |
| `dast.yml` | Escaneo dinámico con OWASP ZAP (staging) | No (informativo) |
| `changelog.yml` | Genera `CHANGELOG.md` al crear un tag | No |

### Hooks de Git

| Hook | Propósito |
|------|-----------|
| `pre-commit` | Formato (lint-staged), secretos (Gitleaks), SAST (ESLint security + Bandit) |
| `commit-msg` | Valida que el mensaje siga Conventional Commits |

### Herramientas de seguridad

| Herramienta | Tipo | Qué detecta |
|-------------|------|-------------|
| **Semgrep** | SAST | Patrones inseguros (OWASP Top 10, inyección, XSS) |
| **Trivy** | SCA | Vulnerabilidades en dependencias |
| **Gitleaks** | Secrets | Secretos hardcodeados (API keys, tokens) |
| **detect-secrets** | Secrets | Strings de alta entropía |
| **Bandit** | SAST (Python) | Vulnerabilidades en código Python |
| **ESLint security** | SAST (JS/TS) | `eval`, `child_process`, `innerHTML` |
| **OWASP ZAP** | DAST | Vulnerabilidades en app en ejecución |
| **Codecov** | Cobertura | Umbrales de cobertura en PRs |

### Workflow de autovalidación del repo plantilla

El repo plantilla incluye un workflow (`.github/workflows/validate-template.yml`) que se ejecuta en cada push y PR **del propio repo plantilla** para validar que:

- Todos los archivos y directorios requeridos existen.
- Los scripts Bash pasan ShellCheck.
- Los archivos YAML, TOML y JSON son válidos.
- `init-project.sh` genera un proyecto con la estructura correcta.
- Los prompts y docs de referencia se copian correctamente.

Este workflow **no se copia** a los proyectos generados; solo valida el repo plantilla.

---

## 🧠 ¿Qué modelos de IA usa?

Este flujo está diseñado para funcionar con **modelos gratuitos vía web** y **modelos de bajo costo vía OpenRouter**.

| Tarea | Modelo | Costo | Dónde |
|-------|--------|-------|-------|
| Documentación inicial (PRD, SRS) | DeepSeek web / Gemini web | Gratis | Web |
| Documentos largos (Propuesta, SSD) | Gemini web | Gratis | Web |
| Decisiones críticas de seguridad | Claude web | Gratis | Web |
| Generación de código (caballo de batalla) | DeepSeek V4 Flash | ~$0.04-0.14/M input | OpenRouter |
| Depuración y razonamiento | Qwen3 Coder Next | ~$0.12/M input | OpenRouter |
| Diseño crítico puntual | Claude Sonnet | ~$3/M input | OpenRouter o web |

**Presupuesto estimado:** $10-20 USD/mes con uso disciplinado. El 80-90% de las operaciones se hacen con DeepSeek V4 Flash, que es el modelo más económico de OpenRouter en 2026.

📖 **Guía completa de modelos:** [`docs/MODELOS_IA.md`](docs/es/MODELOS_IA.md)

---

## 🔒 Seguridad

Este flujo implementa las siguientes prácticas de seguridad:

### NIST SSDF (SP 800-218)

| Práctica | Cómo se aplica |
|----------|----------------|
| PO.1 | Requisitos de seguridad definidos en el SRS |
| PO.3 | Toolchain controlado (`package.json`, `requirements.txt`) |
| PS.1 | Protección del código (`.gitignore`, `.env`) |
| PS.2 | Verificación de integridad (Trivy, `npm audit`) |
| PW.1 | Threat modeling en el SSD-TDD |
| PW.4 | Verificación de dependencias (Trivy, `pip-audit`) |
| PW.7 | Revisión de código (PRs) |
| RV.1 | Identificación de vulnerabilidades (Semgrep, Gitleaks) |
| RV.2 | Remediación documentada (excepciones) |

### OWASP Top 10:2025

Las 10 categorías están cubiertas en el Plan de Pruebas y el Mapeo NIST+OWASP:

1. Broken Access Control
2. Security Misconfiguration
3. Software Supply Chain Failures
4. Cryptographic Failures
5. Injection
6. Insecure Design
7. Authentication Failures
8. Software or Data Integrity Failures
9. Security Logging & Alerting Failures
10. **Mishandling of Exceptional Conditions**

📖 **Guía completa de seguridad:** [`docs/SEGURIDAD.md`](docs/es/SEGURIDAD.md)

---

## 📁 Estructura de un proyecto nuevo

Cuando usas `init-project.sh`, cada proyecto nuevo tendrá esta estructura:

```
mi-proyecto/
├── .github/workflows/      (7 workflows)
├── .husky/                 (pre-commit, commit-msg)
├── docs/
│   ├── PRD-SRD.md
│   ├── SRS.md
│   ├── Propuesta_Tecnica.md
│   ├── SSD-TDD.md
│   ├── Mapeo_NIST_OWASP.md
│   ├── Estrategia_Respaldos.md
│   ├── Plan_Pruebas.md
│   ├── REGISTRO_FORENSE.md
│   ├── GITHUB_SECRETS.md
│   ├── WORKFLOWS.md
│   ├── HERRAMIENTAS_SEGURIDAD.md
│   ├── deploy.yml.example
│   └── prompts/            (9 archivos: README + 8 prompts)
├── src/
├── tests/
├── scripts/
├── config/
├── .project-language
├── AGENTS.md
├── CLAUDE.md
├── GEMINI.md
├── README.md
├── CHANGELOG.md
├── Makefile
├── cliff.toml
├── commitlint.config.js
├── .env.example
├── .eslintrc-security.js
├── .gitleaks.toml
├── .secrets.baseline
├── .gitignore
├── codecov.yml
├── package.json
├── requirements.txt
└── setup.sh
```

**Nota:** Si creas el proyecto con `--language en`, los docs usarán nombres en inglés (`Technical_Proposal.md`, `NIST_OWASP_Mapping.md`, etc.).

---

## 🛠️ Herramientas que necesitas

### Software base

| Herramienta | Propósito | Instalación |
|-------------|-----------|-------------|
| **VS Code** | IDE principal | [code.visualstudio.com](https://code.visualstudio.com/) |
| **Zoo Code** | Extensión de VS Code para agentes de IA | Marketplace de VS Code |
| **Git** | Control de versiones | `sudo apt install git` |
| **Make** | Automatización de tareas | `sudo apt install make` |
| **Node.js 20+** | Runtime para herramientas JS | [nodejs.org](https://nodejs.org/) |
| **Python 3.11+** | Runtime para herramientas Python | `sudo apt install python3` |

### Herramientas de seguridad (instaladas por `./setup.sh --install-tools`)

| Herramienta | Instalación |
|-------------|-------------|
| Semgrep | `pip3 install --user semgrep` |
| detect-secrets | `pip3 install --user detect-secrets` |
| Bandit | `pip3 install --user bandit` |
| pip-audit | `pip3 install --user pip-audit` |
| Ruff | `pip3 install --user ruff` |
| Mypy | `pip3 install --user mypy` |
| pytest + pytest-cov | `pip3 install --user pytest pytest-cov` |
| pre-commit | `pip3 install --user pre-commit` |
| Trivy | `apt` desde repositorio de Aqua Security |
| Gitleaks | Binario desde GitHub Releases |
| git-cliff | Binario desde GitHub Releases |

📖 **Guía detallada de instalación:** [`docs/HERRAMIENTAS_SEGURIDAD.md`](docs/es/HERRAMIENTAS_SEGURIDAD.md)

---

## 🎯 Comandos comunes del proyecto

Una vez creado el proyecto, los comandos más útiles son:

```bash
# Ver todas las tareas disponibles
make help

# Instalar herramientas de seguridad
make setup

# Verificar la estructura del proyecto
make check

# Ejecutar tests
make test

# Ejecutar linters
make lint

# Formatear código
make format

# Análisis de seguridad completo (SAST + SCA + secrets)
make security

# Todo antes de un PR
make all

# Generar CHANGELOG.md desde commits
make changelog
```

📖 **Lista completa:** ejecuta `make help` dentro del proyecto.

---

## 🤝 Contribuir

Este repositorio está abierto a contribuciones. Si quieres mejorar el flujo, añadir herramientas, o corregir errores:

1. Forkea el repositorio.
2. Crea una rama para tu contribución (`git checkout -b feat/mi-mejora`).
3. Sigue las convenciones de commits (Conventional Commits).
4. Haz push a tu rama.
5. Abre un Pull Request.

📖 **Guía completa:** [`CONTRIBUTING.md`](CONTRIBUTING.md)

---

## 📜 Licencia

Este proyecto está licenciado bajo la **MIT License**. Puedes usarlo, modificarlo y distribuirlo libremente, incluso para proyectos comerciales. Consulta el archivo [`LICENSE`](LICENSE) para más detalles.

---

## 🙏 Agradecimientos

- A la comunidad de **Zoo Code** (sucesor de Roo Code) por mantener viva la herramienta.
- A **OpenRouter** por hacer accesibles modelos de IA de alta calidad a bajo costo.
- A **DeepSeek**, **Qwen** y **Google** por sus modelos gratuitos vía web.
- A los proyectos open source que hacen posible este flujo: Semgrep, Trivy, Gitleaks, git-cliff, Husky, y todos los demás.

---

## 📞 Soporte

Si tienes preguntas o encuentras problemas:

- Abre un **Issue** en este repositorio.
- Revisa la documentación en [`docs/es/`](docs/es/).
- Consulta el [`docs/prompts/README.md`](docs/es/prompts/README.md) para dudas sobre los prompts.

---

> **Hecho con ❤️ para desarrolladores que quieren usar IA sin sacrificar calidad, seguridad ni documentación.**
