# Herramientas de Seguridad — Instalación y Uso

🌍 **Lee esto en:** [Español](HERRAMIENTAS_SEGURIDAD.md) | [English](../en/SECURITY_TOOLS.md)

> Guía completa para instalar y usar las herramientas de seguridad del flujo de trabajo.
> Todas son gratuitas y de código abierto. Ninguna requiere cuenta ni API key.

---

## Índice

| Herramienta | Tipo | Instalación | Uso principal |
|-------------|------|-------------|---------------|
| [Semgrep](#semgrep) | SAST | `pipx` / `pip` / `brew` | Análisis estático de código |
| [Trivy](#trivy) | SCA | `apt` / `brew` / binario | Vulnerabilidades en dependencias |
| [Gitleaks](#gitleaks) | Secrets | Binario / `brew` | Detección de secretos |
| [git-cliff](#git-cliff) | Changelog | `npm` / `cargo` / binario | Generación de CHANGELOG.md |
| [detect-secrets](#detect-secrets) | Secrets | `pip` | Detección de alta entropía |
| [Bandit](#bandit) | SAST (Python) | `pip` | Vulnerabilidades en Python |
| [ESLint security](#eslint-security) | SAST (JS/TS) | `npm` | Vulnerabilidades en JS/TS |

---

## Semgrep

**Propósito:** Análisis estático de seguridad (SAST). Detecta patrones inseguros en código: inyección, XSS, `eval`, etc.

**Documentación oficial:** [docs.semgrep.dev](https://docs.semgrep.dev/)

### Instalación

**Método recomendado (pipx, aislado del sistema):**

```bash
# Instalar pipx si no lo tienes
sudo apt install pipx
pipx ensurepath

# Instalar Semgrep
pipx install semgrep
```

**Método alternativo (pip, usuario):**

```bash
pip3 install --user semgrep
```

**Método alternativo (Homebrew, Linux y macOS):**

```bash
brew install semgrep
```

**Verificar instalación:**

```bash
semgrep --version
```

### Uso

```bash
# Escanear todo el proyecto con reglas OWASP Top 10
semgrep --config=p/owasp-top-ten .

# Escanear con reglas de seguridad generales
semgrep --config=p/security-audit .

# Escanear con reglas de secretos
semgrep --config=p/secrets .

# Combinar rulesets
semgrep --config=p/owasp-top-ten --config=p/security-audit .

# Salir con código de error si hay hallazgos (para CI)
semgrep --config=p/owasp-top-ten --error .

# Output en formato SARIF (para GitHub Security)
semgrep --config=p/owasp-top-ten --sarif --output=semgrep.sarif .
```

### Rulesets útiles

| Ruleset | Qué detecta |
|---------|-------------|
| `p/owasp-top-ten` | Las 10 categorías del OWASP Top 10 |
| `p/security-audit` | Patrones inseguros generales |
| `p/secrets` | Secretos hardcodeados |
| `p/python` | Reglas específicas de Python |
| `p/javascript` | Reglas específicas de JavaScript |

### Notas

- **No requiere cuenta ni API key** para usar la versión Community Edition (CE).
- **La versión comercial (Semgrep Code)** añade interfaz web y reglas adicionales, pero no es necesaria para este flujo.
- **En CI**, se ejecuta con `semgrep ci` (detecta automáticamente el ruleset).

---

## Trivy

**Propósito:** Análisis de composición de software (SCA). Detecta vulnerabilidades en dependencias, imágenes de contenedor, IaC y más.

**Documentación oficial:** [trivy.dev](https://trivy.dev/)

### Instalación

**Método recomendado (apt, Debian/Ubuntu — oficial):**

```bash
sudo apt-get install wget apt-transport-https gnupg
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
```

**Método alternativo (script de instalación):**

```bash
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
```

**Método alternativo (Homebrew):**

```bash
brew install trivy
```

**Verificar instalación:**

```bash
trivy --version
```

### Uso

```bash
# Escanear sistema de archivos (dependencias)
trivy fs .

# Escanear solo vulnerabilidades CRITICAL y HIGH
trivy fs --severity CRITICAL,HIGH .

# Salir con código de error si hay hallazgos (para CI)
trivy fs --severity CRITICAL,HIGH --exit-code 1 .

# Output en formato SARIF (para GitHub Security)
trivy fs --format sarif --output trivy.sarif .

# Escanear una imagen de contenedor
trivy image mi-imagen:latest
```

### Notas

- **No requiere cuenta ni API key.**
- **La base de datos de vulnerabilidades se actualiza automáticamente** en cada ejecución.
- **En CI**, se usa la acción `aquasecurity/trivy-action` con `scan-type: 'fs'`.

---

## Gitleaks

**Propósito:** Detección de secretos hardcodeados en el repositorio (API keys, tokens, contraseñas).

**Documentación oficial:** [github.com/gitleaks/gitleaks](https://github.com/gitleaks/gitleaks)

### Instalación

**Método recomendado (binario desde GitHub Releases):**

```bash
# Descargar la última versión
curl -sSfL https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_linux_x64.tar.gz -o gitleaks.tar.gz

# Extraer
tar -xzf gitleaks.tar.gz

# Mover a /usr/local/bin
sudo mv gitleaks /usr/local/bin/
sudo chmod +x /usr/local/bin/gitleaks

# Verificar
gitleaks version
```

**Método alternativo (Homebrew):**

```bash
brew install gitleaks
```

**Método alternativo (Docker):**

```bash
docker pull ghcr.io/gitleaks/gitleaks:latest
```

### Uso

```bash
# Escanear todo el repositorio
gitleaks detect --source . --verbose

# Escanear solo archivos staged (pre-commit)
gitleaks protect --staged --verbose

# Escanear con configuración personalizada
gitleaks detect --source . --config .gitleaks.toml --verbose

# Salir con código de error si hay hallazgos
gitleaks detect --source . --exit-code 1

# Redactar secretos en el output
gitleaks detect --source . --redact
```

### Notas

- **No requiere cuenta ni API key.**
- **Escanea todo el historial de Git**, no solo el commit actual. Esto detecta secretos que se commitearon hace meses.
- **El archivo `.gitleaks.toml`** en la raíz del repo define reglas personalizadas (API keys de IA, tokens de OpenRouter, etc.).
- **En CI**, se usa la acción `gitleaks/gitleaks-action@v2`.

---

## git-cliff

**Propósito:** Generación automática de `CHANGELOG.md` desde Conventional Commits.

**Documentación oficial:** [git-cliff.org](https://git-cliff.org/)

### Instalación

**Método recomendado (npm, multiplataforma):**

```bash
# Ejecutar sin instalar
npx git-cliff@latest

# Instalar en el proyecto
npm install git-cliff --save-dev

# Ejecutar
npx git-cliff
```

**Método alternativo (cargo, si tienes Rust):**

```bash
cargo install git-cliff
```

**Método alternativo (binario desde GitHub Releases):**

```bash
curl -sSL https://github.com/orhun/git-cliff/releases/latest/download/git-cliff-x86_64-unknown-linux-gnu.tar.gz -o git-cliff.tar.gz
tar -xzf git-cliff.tar.gz
sudo mv git-cliff-*/git-cliff /usr/local/bin/
```

**Verificar instalación:**

```bash
git-cliff --version
```

### Uso

```bash
# Inicializar configuración por defecto
git-cliff --init

# Generar changelog completo
git-cliff --tag v1.0.0 -o CHANGELOG.md

# Generar solo cambios no released
git-cliff --unreleased -o CHANGELOG.md

# Previsualizar sin escribir archivo
git-cliff --tag v1.0.0

# Usar configuración personalizada
git-cliff --config cliff.toml --tag v1.0.0 -o CHANGELOG.md
```

### Notas

- **No requiere cuenta ni API key.**
- **El archivo `cliff.toml`** en la raíz del repo define el formato del changelog.
- **En CI**, se usa la acción `orhun/git-cliff-action@v3`.

---

## detect-secrets

**Propósito:** Detección de secretos mediante entropía. Complementa a Gitleaks con un enfoque diferente.

**Documentación oficial:** [github.com/Yelp/detect-secrets](https://github.com/Yelp/detect-secrets)

### Instalación

```bash
pip3 install --user detect-secrets
```

### Uso

```bash
# Generar baseline inicial
detect-secrets scan > .secrets.baseline

# Auditar hallazgos (interactivo)
detect-secrets audit .secrets.baseline

# Verificar contra baseline
detect-secrets scan --baseline .secrets.baseline
```

### Notas

- **Usa un baseline** para marcar falsos positivos conocidos.
- **El archivo `.secrets.baseline`** se versiona en el repo.
- **Complementa a Gitleaks:** Gitleaks detecta patrones conocidos, detect-secrets detecta alta entropía.

---

## Bandit

**Propósito:** Análisis estático de seguridad específico para Python.

**Documentación oficial:** [bandit.readthedocs.io](https://bandit.readthedocs.io/)

### Instalación

```bash
pip3 install --user bandit
```

### Uso

```bash
# Escanear directorio
bandit -r src/

# Escanear con nivel de severidad mínimo
bandit -r src/ -ll

# Output en formato JSON
bandit -r src/ -f json -o bandit-report.json
```

### Notas

- **Solo aplica a proyectos Python.**
- **Se ejecuta en el hook pre-commit** para archivos `.py` staged.

---

## ESLint security

**Propósito:** Análisis estático de seguridad para JavaScript/TypeScript.

**Documentación oficial:** [github.com/eslint-community/eslint-plugin-security](https://github.com/eslint-community/eslint-plugin-security)

### Instalación

```bash
npm install --save-dev eslint eslint-plugin-security eslint-plugin-no-unsanitized
```

### Uso

```bash
# Ejecutar con configuración de seguridad
npx eslint . --config .eslintrc-security.js

# Ejecutar en archivos específicos
npx eslint src/ --config .eslintrc-security.js
```

### Notas

- **Solo aplica a proyectos JS/TS.**
- **Se ejecuta en el hook pre-commit** para archivos `.js`, `.ts`, `.jsx`, `.tsx` staged.
- **La configuración está en `.eslintrc-security.js`** en la raíz del repo.

---

## Tabla resumen: qué instalar por sistema operativo

| Herramienta | Linux Mint (apt) | macOS (brew) | Windows |
|-------------|------------------|--------------|---------|
| Semgrep | `pipx install semgrep` | `brew install semgrep` | `pipx install semgrep` |
| Trivy | `apt` (repo oficial) | `brew install trivy` | Binario desde GitHub |
| Gitleaks | Binario desde GitHub | `brew install gitleaks` | Binario desde GitHub |
| git-cliff | `npm install -g git-cliff` | `brew install git-cliff` | `npm install -g git-cliff` |
| detect-secrets | `pip3 install --user` | `pip3 install --user` | `pip3 install --user` |
| Bandit | `pip3 install --user` | `pip3 install --user` | `pip3 install --user` |
| ESLint security | `npm install --save-dev` | `npm install --save-dev` | `npm install --save-dev` |

---

## Instalación automatizada

El script `setup.sh --install-tools` instala automáticamente:

- **Semgrep, detect-secrets, Bandit, pip-audit, Ruff, Mypy, pytest** → vía `pip3 install --user` (no requiere sudo).
- **Trivy** → vía `apt` desde el repositorio oficial de Aqua Security.
- **Gitleaks** → binario desde GitHub Releases a `/usr/local/bin/`.
- **git-cliff** → binario desde GitHub Releases a `/usr/local/bin/`.

**Uso:**

```bash
./setup.sh --install-tools
```

El script pide confirmación antes de usar `sudo`.

---

## Solución de problemas

| Problema | Causa | Solución |
|----------|-------|----------|
| `semgrep: command not found` | No está en el PATH | `pipx ensurepath` y reiniciar terminal |
| `trivy: command not found` | Repositorio no añadido correctamente | Verificar `/etc/apt/sources.list.d/trivy.list` |
| `gitleaks: command not found` | Binario no movido a `/usr/local/bin` | `sudo mv gitleaks /usr/local/bin/` |
| `git-cliff: command not found` | No está en el PATH | Usar `npx git-cliff` o verificar instalación |
| Gitleaks da muchos falsos positivos | Reglas genéricas muy amplias | Añadir patrones a `[allowlist]` en `.gitleaks.toml` |
| Trivy tarda mucho | Base de datos de vulnerabilidades grande | Es normal la primera vez. Se cachea después. |

---

## Referencias

- [`prompts/05-Mapeo-NIST-OWASP.md`](prompts/05-Mapeo-NIST-OWASP.md) — Mapeo de seguridad
- [`prompts/07-Plan-Pruebas.md`](prompts/07-Plan-Pruebas.md) — Plan de pruebas
- [`../../scripts/README.es.md`](../../scripts/README.es.md) — Scripts del repositorio
- [`../../template/setup.sh`](../../template/setup.sh) — Instalación automatizada