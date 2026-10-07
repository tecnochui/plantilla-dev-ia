# 🛠️ Plantilla Dev IA — AI-assisted development workflow

🌍 **Read this in:** [Español](README.es.md) | [English](README.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Actions](https://img.shields.io/badge/CI-GitHub_Actions-blue)](https://github.com/features/actions)
[![Security: NIST SSDF](https://img.shields.io/badge/Security-NIST_SSDF-blueviolet)](https://csrc.nist.gov/Projects/ssdf)
[![OWASP Top 10:2025](https://img.shields.io/badge/OWASP-Top_10%3A2025-orange)](https://owasp.org/Top10/)

> **A template repository to build software with AI assistance, sequential documentation, automated security, and a standardized workflow.**

---

## 📋 What is this?

This repository contains **a complete workflow** for building software with AI assistance, from initial documentation through deployment, including automated security and quality control.

It is not a framework or a library. It is a **methodology packaged as a template repository** that you can clone and use as the foundation for any new project. The template includes:

- **8 sequential prompts** to generate foundational documents with AI (free or low-cost).
- **CI/CD configuration** with 7 GitHub Actions workflows split by domain (tests, security, changelog, etc.).
- **Automated security tools** (SAST, SCA, secret detection, DAST) aligned with NIST SSDF and OWASP Top 10:2025.
- **Git hooks** to validate commits, formatting, and secrets before every push.
- **Ready-to-use documentation structure** (PRD-SRD, SRS, SSD-TDD, Test Plan, etc.).
- **Forensic Record** to continue projects without documentation (reverse engineering).
- **Initialization script** (`init-project.sh`) that creates a complete project in a single command.
- **Makefile** with common tasks (`make test`, `make security`, `make all`, etc.).

---

## 🚀 Quick Start

### Single option: Clone the repository and use `init-project.sh`

```bash
# 1. Clone this repository
git clone https://github.com/tecnochui/plantilla-dev-ia.git
cd plantilla-dev-ia

# 2. See the script options
./scripts/init-project.sh --help

# 3. Full script documentation
cat scripts/README.md

# 4. Create a new project
./scripts/init-project.sh my-new-project

# 5. With additional options
./scripts/init-project.sh my-new-project --path ~/projects --private
```

**Note:** This repo is a **tool**, not a project template. Do not use GitHub's "Use this template" button directly, because it would copy the structure of the template repo (with `docs/`, `scripts/`, `template/`), not the structure of a new project.

---

## 🏗️ How does the workflow work?

The workflow follows **7 sequential phases**. Each phase produces a document that feeds the next one. No code is generated until all 7 documents are approved.

```
┌─────────────────────────────────────────────────────────────────┐
│   PHASE 0: ENVIRONMENT SETUP                                    │
│   • ./setup.sh --install-tools                                  │
│   • Edit AGENTS.md with the project name                        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│   PHASE 1: FOUNDATIONAL DOCUMENTATION (sequential)              │
│                                                                  │
│   1. PRD-SRD           → What are we building and for whom?     │
│   2. SRS               → Functional and non-functional reqs     │
│   3. Technical Proposal → Stack, architecture, licensing        │
│   4. SSD-TDD           → Detailed design (arch, DB, API)        │
│   5. NIST+OWASP Mapping → Security compliance                   │
│   6. Backup Strategy   → Backups and log retention              │
│   7. Test Plan         → Complete testing strategy              │
│                                                                  │
│   Each document is approved before moving to the next one.      │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│   PHASE 2: DEVELOPMENT WITH AGENT                               │
│   • Zoo Code (Architect) + DeepSeek V4 Flash → plan             │
│   • Zoo Code (Code) + DeepSeek V4 Flash → implementation        │
│   • Zoo Code (Debug) + Qwen3 Coder Next → debugging             │
│   • Pre-commit hook validates on every commit                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│   PHASE 3: SECURITY REVIEW                                      │
│   • Push → GitHub Actions runs workflows in parallel            │
│   • Codecov reports coverage on the PR                          │
│   • If CRITICAL/HIGH findings → merge blocked                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│   PHASE 4: RELEASE                                              │
│   • git tag v1.0.0 → changelog.yml generates CHANGELOG.md       │
│   • Deploy (once you have a configured target)                  │
└─────────────────────────────────────────────────────────────────┘
```

**Note:** There is an **8th prompt** (`08-Registro-Forense.md`) that is not used at the start. It is used **after** code exists, to perform reverse engineering on an undocumented system.

### 📖 Detailed workflow documentation

| Document | Description |
|----------|-------------|
| [`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md) | Philosophy and design decisions behind the workflow |
| [`docs/FLUJO_DE_TRABAJO.md`](docs/FLUJO_DE_TRABAJO.md) | Complete end-to-end process diagram |
| [`docs/HERRAMIENTAS.md`](docs/HERRAMIENTAS.md) | Tool stack and why each was chosen |
| [`docs/HERRAMIENTAS_SEGURIDAD.md`](docs/HERRAMIENTAS_SEGURIDAD.md) | Installation and usage of Semgrep, Trivy, Gitleaks, git-cliff |
| [`docs/MODELOS_IA.md`](docs/MODELOS_IA.md) | AI model guide, costs, and when to use each one |
| [`docs/SEGURIDAD.md`](docs/SEGURIDAD.md) | Alignment with NIST SSDF and OWASP Top 10:2025 |
| [`docs/WORKFLOWS.md`](docs/WORKFLOWS.md) | Documentation for the 7 GitHub Actions workflows |
| [`docs/GITHUB_SECRETS.md`](docs/GITHUB_SECRETS.md) | Required GitHub secrets |
| [`docs/prompts/README.md`](docs/prompts/README.md) | Master index of the 8 sequential prompts |
| [`scripts/README.md`](scripts/README.md) | Documentation for `init-project.sh` and `setup.sh` |

---

## 🧰 What does the template include?

### Foundational documentation (8 documents)

| # | Document | Purpose | Prompt |
|---|----------|---------|--------|
| 1 | **PRD-SRD** | What is built and for whom | [`01-PRD-SRD.md`](docs/prompts/01-PRD-SRD.md) |
| 2 | **SRS** | Functional and non-functional requirements | [`02-SRS.md`](docs/prompts/02-SRS.md) |
| 3 | **Technical Proposal** | Stack, architecture, licensing | [`03-Propuesta-Tecnica.md`](docs/prompts/03-Propuesta-Tecnica.md) |
| 4 | **SSD-TDD** | Detailed design: architecture, DB, API | [`04-SSD-TDD.md`](docs/prompts/04-SSD-TDD.md) |
| 5 | **NIST+OWASP Mapping** | Security compliance | [`05-Mapeo-NIST-OWASP.md`](docs/prompts/05-Mapeo-NIST-OWASP.md) |
| 6 | **Backup Strategy** | Backups and log retention | [`06-Estrategia-Respaldos.md`](docs/prompts/06-Estrategia-Respaldos.md) |
| 7 | **Test Plan** | Complete testing strategy | [`07-Plan-Pruebas.md`](docs/prompts/07-Plan-Pruebas.md) |
| 8 | **Forensic Record** | Reverse engineering of undocumented systems | [`08-Registro-Forense.md`](docs/prompts/08-Registro-Forense.md) |

### Configuration files

| File | Purpose |
|------|---------|
| `AGENTS.md` | Persistent context for Zoo Code and other agents |
| `CLAUDE.md` | `@AGENTS.md` bridge for Claude Code |
| `GEMINI.md` | `@./AGENTS.md` bridge for Gemini CLI |
| `Makefile` | Common tasks (`make test`, `make security`, `make all`) |
| `.env.example` | Environment variables template (no real secrets) |
| `cliff.toml` | `git-cliff` configuration for automatic changelog |
| `commitlint.config.js` | Conventional Commits validation |
| `.eslintrc-security.js` | SAST with ESLint (security + XSS) |
| `.gitleaks.toml` | Secret detection (AI API keys + generic) |
| `.secrets.baseline` | `detect-secrets` baseline |
| `codecov.yml` | Coverage thresholds (PR blocking) |
| `.gitignore` | Ignores dependencies, environments, secrets, builds |

### GitHub Actions (project workflows)

| Workflow | Purpose | Blocks merge |
|----------|---------|--------------|
| `tests.yml` | Unit tests + coverage with Codecov | Yes |
| `commitlint.yml` | Validates Conventional Commits on PRs | Yes |
| `sast.yml` | Static security analysis with Semgrep | Yes (CRITICAL/HIGH) |
| `sca.yml` | Dependency vulnerabilities with Trivy | Yes (CRITICAL/HIGH) |
| `secrets.yml` | Secret detection with Gitleaks + detect-secrets | Yes |
| `dast.yml` | Dynamic scan with OWASP ZAP (staging) | No (informational) |
| `changelog.yml` | Generates `CHANGELOG.md` when a tag is created | No |

### Git hooks

| Hook | Purpose |
|------|---------|
| `pre-commit` | Formatting (lint-staged), secrets (Gitleaks), SAST (ESLint security + Bandit) |
| `commit-msg` | Validates that the message follows Conventional Commits |

### Security tools

| Tool | Type | What it detects |
|------|------|-----------------|
| **Semgrep** | SAST | Insecure patterns (OWASP Top 10, injection, XSS) |
| **Trivy** | SCA | Vulnerabilities in dependencies |
| **Gitleaks** | Secrets | Hardcoded secrets (API keys, tokens) |
| **detect-secrets** | Secrets | High-entropy strings |
| **Bandit** | SAST (Python) | Python code vulnerabilities |
| **ESLint security** | SAST (JS/TS) | `eval`, `child_process`, `innerHTML` |
| **OWASP ZAP** | DAST | Runtime vulnerabilities in running app |
| **Codecov** | Coverage | Coverage thresholds on PRs |

### Self-validation workflow of the template repo

The template repo includes a workflow (`.github/workflows/validate-template.yml`) that runs on every push and PR **of the template repo itself** to validate that:

- All required files and directories exist.
- Bash scripts pass ShellCheck.
- YAML, TOML, and JSON files are valid.
- `init-project.sh` generates a project with the correct structure.
- Prompts and reference docs are copied correctly.

This workflow is **not copied** to generated projects; it only validates the template repo.

---

## 🧠 What AI models does it use?

This workflow is designed to work with **free models via web** and **low-cost models via OpenRouter**.

| Task | Model | Cost | Where |
|------|-------|------|-------|
| Initial documentation (PRD, SRS) | DeepSeek web / Gemini web | Free | Web |
| Long documents (Proposal, SSD) | Gemini web | Free | Web |
| Critical security decisions | Claude web | Free | Web |
| Code generation (workhorse) | DeepSeek V4 Flash | ~$0.04-0.14/M input | OpenRouter |
| Debugging and reasoning | Qwen3 Coder Next | ~$0.12/M input | OpenRouter |
| Occasional critical design | Claude Sonnet | ~$3/M input | OpenRouter or web |

**Estimated budget:** $10-20 USD/month with disciplined usage. 80-90% of operations are done with DeepSeek V4 Flash, the cheapest model on OpenRouter in 2026.

📖 **Full model guide:** [`docs/MODELOS_IA.md`](docs/MODELOS_IA.md)

---

## 🔒 Security

This workflow implements the following security practices:

### NIST SSDF (SP 800-218)

| Practice | How it is applied |
|----------|-------------------|
| PO.1 | Security requirements defined in the SRS |
| PO.3 | Controlled toolchain (`package.json`, `requirements.txt`) |
| PS.1 | Code protection (`.gitignore`, `.env`) |
| PS.2 | Integrity verification (Trivy, `npm audit`) |
| PW.1 | Threat modeling in the SSD-TDD |
| PW.4 | Dependency verification (Trivy, `pip-audit`) |
| PW.7 | Code review (PRs) |
| RV.1 | Vulnerability identification (Semgrep, Gitleaks) |
| RV.2 | Documented remediation (exceptions) |

### OWASP Top 10:2025

The 10 categories are covered in the Test Plan and the NIST+OWASP Mapping:

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

📖 **Full security guide:** [`docs/SEGURIDAD.md`](docs/SEGURIDAD.md)

---

## 📁 Structure of a new project

When you use `init-project.sh`, each new project will have this structure:

```
my-project/
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
│   └── prompts/            (9 files: README + 8 prompts)
├── src/
├── tests/
├── scripts/
├── config/
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

---

## 🛠️ Tools you need

### Base software

| Tool | Purpose | Installation |
|------|---------|--------------|
| **VS Code** | Main IDE | [code.visualstudio.com](https://code.visualstudio.com/) |
| **Zoo Code** | VS Code extension for AI agents | VS Code Marketplace |
| **Git** | Version control | `sudo apt install git` |
| **Make** | Task automation | `sudo apt install make` |
| **Node.js 20+** | Runtime for JS tools | [nodejs.org](https://nodejs.org/) |
| **Python 3.11+** | Runtime for Python tools | `sudo apt install python3` |

### Security tools (installed by `./setup.sh --install-tools`)

| Tool | Installation |
|------|--------------|
| Semgrep | `pip3 install --user semgrep` |
| detect-secrets | `pip3 install --user detect-secrets` |
| Bandit | `pip3 install --user bandit` |
| pip-audit | `pip3 install --user pip-audit` |
| Ruff | `pip3 install --user ruff` |
| Mypy | `pip3 install --user mypy` |
| pytest + pytest-cov | `pip3 install --user pytest pytest-cov` |
| pre-commit | `pip3 install --user pre-commit` |
| Trivy | `apt` from Aqua Security repository |
| Gitleaks | Binary from GitHub Releases |
| git-cliff | Binary from GitHub Releases |

📖 **Detailed installation guide:** [`docs/HERRAMIENTAS_SEGURIDAD.md`](docs/HERRAMIENTAS_SEGURIDAD.md)

---

## 🎯 Common project commands

Once a project is created, the most useful commands are:

```bash
# View all available tasks
make help

# Install security tools
make setup

# Verify project structure
make check

# Run tests
make test

# Run linters
make lint

# Format code
make format

# Complete security analysis (SAST + SCA + secrets)
make security

# Everything before a PR
make all

# Generate CHANGELOG.md from commits
make changelog
```

📖 **Full list:** run `make help` inside the project.

---

## 🤝 Contributing

This repository is open to contributions. If you want to improve the workflow, add tools, or fix bugs:

1. Fork the repository.
2. Create a branch for your contribution (`git checkout -b feat/my-improvement`).
3. Follow the commit conventions (Conventional Commits).
4. Push to your branch.
5. Open a Pull Request.

📖 **Full guide:** [`CONTRIBUTING.md`](CONTRIBUTING.md)

---

## 📜 License

This project is licensed under the **MIT License**. You can use, modify, and distribute it freely, including for commercial projects. See the [`LICENSE`](LICENSE) file for more details.

---

## 🙏 Acknowledgements

- To the **Zoo Code** community (successor to Roo Code) for keeping the tool alive.
- To **OpenRouter** for making high-quality AI models accessible at low cost.
- To **DeepSeek**, **Qwen**, and **Google** for their free models via web.
- To the open source projects that make this workflow possible: Semgrep, Trivy, Gitleaks, git-cliff, Husky, and all the rest.

---

## 📞 Support

If you have questions or find problems:

- Open an **Issue** in this repository.
- Check the documentation in [`docs/`](docs/).
- See [`docs/prompts/README.md`](docs/prompts/README.md) for questions about the prompts.

---

> **Made with ❤️ for developers who want to use AI without sacrificing quality, security, or documentation.**
