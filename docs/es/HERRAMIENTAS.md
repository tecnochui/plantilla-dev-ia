# Stack de Herramientas

🌍 **Lee esto en:** [Español](HERRAMIENTAS.md) | [English](../en/TOOLS.md)

> Explicación de cada herramienta del flujo, por qué se eligió, y alternativas descartadas.

---

## IDE y Agente de IA

| Herramienta | Propósito | Por qué se eligió |
|-------------|-----------|-------------------|
| **VS Code** | IDE principal | Estándar de facto, extensiones para todo |
| **Zoo Code** | Agente de código | Modos diferenciados (Architect, Code, Debug), enrutamiento por modo, contexto eficiente |
| **OpenRouter** | Gateway de modelos | Acceso a todos los modelos con una sola API key |

### Alternativas descartadas

| Alternativa | Por qué no |
|-------------|------------|
| **Cline** | No tiene modos diferenciados. Prioriza confirmación paso a paso, que ralentiza |
| **Kilo Code** | Fork de Roo Code con menos mantenimiento. Zoo Code es el sucesor oficial |
| **Cursor** | IDE completo propietario. Preferimos VS Code + extensión |

---

## Modelos de IA

| Modelo | Tarea | Costo | Dónde |
|--------|-------|-------|-------|
| **DeepSeek V4 Flash** | Código (caballo de batalla) | ~$0.04-0.14/M input | OpenRouter |
| **Qwen3 Coder Next** | Depuración, razonamiento | ~$0.12/M input | OpenRouter |
| **Claude Sonnet** | Diseño crítico puntual | ~$3/M input | OpenRouter o web |
| **DeepSeek web** | Documentación inicial | Gratis | Web |
| **Gemini web** | Documentos largos | Gratis | Web |
| **Claude web** | Decisiones de seguridad | Gratis | Web |

📖 **Guía detallada:** [`MODELOS_IA.md`](MODELOS_IA.md)

---

## Control de versiones y CI/CD

| Herramienta | Propósito |
|-------------|-----------|
| **Git** | Control de versiones |
| **GitHub** | Repositorio remoto, Actions, Codecov |
| **GitHub Actions** | CI/CD (7 workflows divididos por dominio) |
| **Codecov** | Cobertura de tests con bloqueo de PR |

---

## Seguridad

| Herramienta | Tipo | Qué detecta |
|-------------|------|-------------|
| **Semgrep** | SAST | Patrones inseguros (OWASP Top 10, inyección, XSS) |
| **Trivy** | SCA | Vulnerabilidades en dependencias |
| **Gitleaks** | Secrets | Secretos hardcodeados (API keys, tokens) |
| **detect-secrets** | Secrets | Strings de alta entropía |
| **Bandit** | SAST (Python) | Vulnerabilidades en código Python |
| **ESLint security** | SAST (JS/TS) | `eval`, `child_process`, `innerHTML` |
| **OWASP ZAP** | DAST | Vulnerabilidades en app en ejecución |

### Alternativas descartadas

| Alternativa | Por qué no |
|-------------|------------|
| **Snyk** | Plan gratuito limitado, requiere cuenta |
| **SonarQube** | Pesado, requiere servidor |
| **Checkmarx** | Propietario, caro |
| **Burp Suite Professional** | Caro, la versión community es limitada |

---

## Calidad de código

| Herramienta | Propósito |
|-------------|-----------|
| **ESLint** | Linting JS/TS |
| **Prettier** | Formateo JS/TS |
| **Ruff** | Linting + formateo Python (reemplaza flake8, isort, black) |
| **Mypy** | Verificación de tipos Python |
| **Vitest** | Tests unitarios JS/TS |
| **pytest** | Tests unitarios Python |
| **Husky** | Hooks de Git |
| **lint-staged** | Ejecuta linters solo en archivos modificados |

---

## Changelog y commits

| Herramienta | Propósito |
|-------------|-----------|
| **Conventional Commits** | Formato estándar de mensajes de commit |
| **commitlint** | Valida Conventional Commits |
| **git-cliff** | Genera CHANGELOG.md desde commits |
| **Keep a Changelog** | Estándar de formato de changelog |

---

## Resumen de instalación

```bash
# Node.js
npm install --save-dev eslint eslint-plugin-security eslint-plugin-no-unsanitized
npm install --save-dev @commitlint/cli @commitlint/config-conventional
npm install --save-dev husky lint-staged prettier vitest @vitest/coverage-v8

# Python
pip install semgrep detect-secrets bandit pip-audit ruff mypy pytest pytest-cov git-cliff

# Binarios independientes (via setup.sh --install-tools)
# Trivy, Gitleaks, git-cliff
```
