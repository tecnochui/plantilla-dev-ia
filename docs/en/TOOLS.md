# Tool Stack

🌍 **Read this in:** [Español](../es/HERRAMIENTAS.md) | [English](TOOLS.md)

> Explanation of each tool in the workflow, why it was chosen, and discarded alternatives.

---

## IDE and AI Agent

| Tool | Purpose | Why it was chosen |
|------|---------|-------------------|
| **VS Code** | Main IDE | De facto standard, extensions for everything |
| **Zoo Code** | Code agent | Differentiated modes (Architect, Code, Debug), per-mode routing, efficient context |
| **OpenRouter** | Model gateway | Access to all models with a single API key |

### Discarded alternatives

| Alternative | Why not |
|-------------|---------|
| **Cline** | Does not have differentiated modes. Prioritizes step-by-step confirmation, which slows things down |
| **Kilo Code** | Roo Code fork with less maintenance. Zoo Code is the official successor |
| **Cursor** | Full proprietary IDE. We prefer VS Code + extension |

---

## AI Models

| Model | Task | Cost | Where |
|-------|------|------|-------|
| **DeepSeek V4 Flash** | Code (workhorse) | ~$0.04-0.14/M input | OpenRouter |
| **Qwen3 Coder Next** | Debugging, reasoning | ~$0.12/M input | OpenRouter |
| **Claude Sonnet** | Occasional critical design | ~$3/M input | OpenRouter or web |
| **DeepSeek web** | Initial documentation | Free | Web |
| **Gemini web** | Long documents | Free | Web |
| **Claude web** | Security decisions | Free | Web |

📖 **Detailed guide:** [`AI_MODELS.md`](AI_MODELS.md)

---

## Version control and CI/CD

| Tool | Purpose |
|------|---------|
| **Git** | Version control |
| **GitHub** | Remote repository, Actions, Codecov |
| **GitHub Actions** | CI/CD (7 workflows split by domain) |
| **Codecov** | Test coverage with PR blocking |

---

## Security

| Tool | Type | What it detects |
|------|------|-----------------|
| **Semgrep** | SAST | Insecure patterns (OWASP Top 10, injection, XSS) |
| **Trivy** | SCA | Vulnerabilities in dependencies |
| **Gitleaks** | Secrets | Hardcoded secrets (API keys, tokens) |
| **detect-secrets** | Secrets | High-entropy strings |
| **Bandit** | SAST (Python) | Vulnerabilities in Python code |
| **ESLint security** | SAST (JS/TS) | `eval`, `child_process`, `innerHTML` |
| **OWASP ZAP** | DAST | Vulnerabilities in running app |

### Discarded alternatives

| Alternative | Why not |
|-------------|---------|
| **Snyk** | Limited free plan, requires account |
| **SonarQube** | Heavy, requires a server |
| **Checkmarx** | Proprietary, expensive |
| **Burp Suite Professional** | Expensive, the community version is limited |

---

## Code quality

| Tool | Purpose |
|------|---------|
| **ESLint** | JS/TS linting |
| **Prettier** | JS/TS formatting |
| **Ruff** | Python linting + formatting (replaces flake8, isort, black) |
| **Mypy** | Python type checking |
| **Vitest** | JS/TS unit tests |
| **pytest** | Python unit tests |
| **Husky** | Git hooks |
| **lint-staged** | Runs linters only on modified files |

---

## Changelog and commits

| Tool | Purpose |
|------|---------|
| **Conventional Commits** | Standard commit message format |
| **commitlint** | Validates Conventional Commits |
| **git-cliff** | Generates CHANGELOG.md from commits |
| **Keep a Changelog** | Changelog format standard |

---

## Installation summary

```bash
# Node.js
npm install --save-dev eslint eslint-plugin-security eslint-plugin-no-unsanitized
npm install --save-dev @commitlint/cli @commitlint/config-conventional
npm install --save-dev husky lint-staged prettier vitest @vitest/coverage-v8

# Python
pip install semgrep detect-secrets bandit pip-audit ruff mypy pytest pytest-cov git-cliff

# Standalone binaries (via setup.sh --install-tools)
# Trivy, Gitleaks, git-cliff
```