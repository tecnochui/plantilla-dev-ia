# Scripts del repositorio

> Utilidades para inicializar y gestionar proyectos basados en `plantilla-dev-ia`.

---

## Índice

| Script | Ubicación | Propósito |
|--------|-----------|-----------|
| [`init-project.sh`](#init-projectsh) | `scripts/` | Crea un proyecto nuevo desde la plantilla |
| [`setup.sh`](#setupsh) | `template/` | Verifica estructura e instala herramientas en un proyecto |

---

## `init-project.sh`

Crea un proyecto nuevo a partir de la carpeta `template/` del repositorio. Copia toda la estructura de archivos, reemplaza los placeholders con el nombre del proyecto, inicializa Git (opcional), y puede crear el repositorio en GitHub (opcional).

### Requisitos

| Requisito | Obligatorio | Notas |
|-----------|-------------|-------|
| **Bash 4+** | Sí | Viene por defecto en Linux Mint 22.3 |
| **Git** | Recomendado | Necesario para inicializar el repositorio |
| **`gh` CLI** | Opcional | Solo si usas `--private` o `--public` |

**Instalar `gh` CLI en Linux Mint:**

```bash
sudo apt install gh
gh auth login
```

### Uso básico

```bash
./scripts/init-project.sh <nombre-del-proyecto> [opciones]
```

### Opciones

| Opción | Valor por defecto | Descripción |
|--------|-------------------|-------------|
| `--path <ruta>` | `.` (directorio actual) | Directorio donde crear el proyecto |
| `--git` | `true` | Inicializar repositorio Git con commit inicial |
| `--no-git` | — | No inicializar Git |
| `--private` | — | Crear repo privado en GitHub (requiere `gh` CLI) |
| `--public` | — | Crear repo público en GitHub (requiere `gh` CLI) |
| `--template <ruta>` | `template/` del repo | Usar una plantilla alternativa |
| `--branch <rama>` | `main` | Rama de la plantilla a usar |
| `--help`, `-h` | — | Mostrar ayuda |

### Ejemplos

#### 1. Proyecto personal, en el directorio actual

```bash
./scripts/init-project.sh mi-app-personal
```

Crea `./mi-app-personal/` con toda la estructura, inicializa Git, hace el primer commit.

#### 2. Proyecto en un directorio específico

```bash
./scripts/init-project.sh mi-app --path ~/proyectos
```

Crea `~/proyectos/mi-app/`.

#### 3. Proyecto para cliente, repo privado en GitHub

```bash
./scripts/init-project.sh sistema-cliente-x --private
```

Crea el proyecto localmente, inicializa Git, y crea un repositorio privado en GitHub con `gh repo create`.

#### 4. Proyecto open source, repo público en GitHub

```bash
./scripts/init-project.sh mi-libreria --public
```

Igual que el anterior, pero el repo es público.

#### 5. Proyecto sin Git (para copiar a otro sistema)

```bash
./scripts/init-project.sh mi-app --no-git
```

Útil si vas a copiar el proyecto a otra máquina y prefieres inicializar Git manualmente allí.

#### 6. Usar una plantilla alternativa

```bash
./scripts/init-project.sh mi-app --template ~/mi-plantilla-custom
```

Útil si tienes una versión modificada de la plantilla con reglas específicas de tu equipo o de un tipo de proyecto.

#### 7. Combinaciones

```bash
./scripts/init-project.sh mi-app --path ~/proyectos --private --template ~/plantillas/web-app
```

Todas las opciones se pueden combinar.

### Flujo de ejecución

El script sigue estos pasos:

```
1. Valida que el nombre del proyecto esté presente.
2. Detecta la carpeta template/ (o usa --template si se especifica).
3. Verifica que el directorio destino no exista.
4. Muestra un resumen y pide confirmación (y/N).
5. Copia la plantilla al directorio destino.
6. Reemplaza [NOMBRE DEL PROYECTO] por el nombre real en:
   - Archivos .md, .json, .yml, .yaml, .toml, .sh
7. Inicializa Git (si --git, que es por defecto).
8. Crea el repo en GitHub (si --private o --public).
9. Muestra los próximos pasos.
```

### Ejemplo de salida

```
╔══════════════════════════════════════════════╗
║         Crear nuevo proyecto                ║
╚══════════════════════════════════════════════╝

  Nombre:       mi-app
  Destino:      /home/tu-usuario/mi-app
  Plantilla:    /home/tu-usuario/plantilla-dev-ia/template
  Git:          true
  Crear repo:   false

¿Continuar? [y/N] y

[INFO] Copiando plantilla...
[INFO] Reemplazando placeholders...
[OK]   Placeholders reemplazados.
[INFO] Inicializando repositorio Git...
[OK]   Repositorio Git inicializado con commit inicial.

╔══════════════════════════════════════════════════════════════╗
║                    ✅ PROYECTO CREADO                        ║
╚══════════════════════════════════════════════════════════════╝

📋 Próximos pasos:

  1. cd /home/tu-usuario/mi-app

  2. Editar AGENTS.md y verificar el nombre del proyecto.

  3. Instalar herramientas de seguridad:
     ./setup.sh --install-tools

  4. Generar la documentación fundacional:
     Revisar docs/prompts/README.md y seguir los 8 prompts secuenciales.

  5. Configurar secrets en GitHub:
     - CODECOV_TOKEN (para cobertura)
     - SSH_HOST, SSH_USER, SSH_KEY (si usas deploy.yml)

[OK]   Listo para empezar.
```

### Qué hace exactamente

#### Copia la plantilla

```bash
cp -r "$TEMPLATE_DIR"/. "$TARGET_DIR"/
```

Copia **todo el contenido** de `template/`, incluidos archivos ocultos (como `.gitignore`, `.husky/`, `.github/`).

#### Reemplaza placeholders

```bash
find "$TARGET_DIR" -type f \( -name "*.md" -o -name "*.json" -o ... \) \
  -exec sed -i "s/\[NOMBRE DEL PROYECTO\]/$PROJECT_NAME/g" {} \;
```

Busca `[NOMBRE DEL PROYECTO]` en todos los archivos de texto relevantes y lo reemplaza por el nombre real. Esto afecta a `AGENTS.md`, `README.md`, `docs/PRD-SRD.md`, etc.

#### Inicializa Git

```bash
git init -q
git add .
git commit -q -m "chore: initial setup from plantilla-dev-ia"
```

Crea un repositorio Git local con un único commit inicial.

#### Crea repo en GitHub (opcional)

```bash
gh repo create "$PROJECT_NAME" $REPO_VISIBILITY --source=. --push
```

Usa el `gh` CLI para crear el repositorio remoto y hacer push del commit inicial.

### Troubleshooting

| Problema | Causa | Solución |
|----------|-------|----------|
| `El directorio 'X' ya existe` | Hay un directorio con el mismo nombre | Elige otro nombre o elimina el directorio existente |
| `No se encontró la plantilla en: X` | La carpeta `template/` no existe | Verifica que estás ejecutando el script desde la raíz del repo |
| `gh CLI no está instalado` | Falta `gh` en el sistema | `sudo apt install gh && gh auth login` |
| `gh: not authenticated` | `gh` no tiene sesión activa | `gh auth login` |
| `Permission denied` al ejecutar | Falta permiso de ejecución | `chmod +x scripts/init-project.sh` |
| Los placeholders no se reemplazan | El archivo tiene otro nombre o extensión | Añade el patrón al `find` del script |
| El nombre tiene espacios | No se recomienda en nombres de proyecto | Usa guiones: `mi-app` en lugar de `mi app` |

### Qué NO hace

- **No instala herramientas de seguridad.** Eso lo hace `setup.sh --install-tools` (dentro del proyecto).
- **No configura secrets de GitHub.** Debes hacerlo manualmente.
- **No genera la documentación.** Solo crea los placeholders.
- **No hace push si no usas `--private` o `--public`.**

### Después de crear el proyecto

```bash
cd mi-app
./setup.sh --check           # Verifica estructura
./setup.sh --install-tools   # Instala herramientas
```

Esto:
- Verifica que la estructura esté completa.
- Instala herramientas de seguridad (Semgrep, Trivy, Gitleaks, etc.).
- Configura Husky.
- Instala dependencias de `package.json` y `requirements.txt` (si existen).

Luego:
- Edita `AGENTS.md` con el nombre real del proyecto.
- Sigue los 8 prompts en `docs/prompts/README.md`.

---

## `setup.sh`

`setup.sh` vive en `template/` del repositorio plantilla, y se copia a **cada proyecto nuevo** al crearlo con `init-project.sh` o al usar "Use this template" de GitHub.

### Diferencias con el `setup.sh` original (raíz del repo plantilla)

> **Nota:** El repositorio plantilla puede tener un `setup.sh` en su raíz (heredado de versiones anteriores). Ese script está **deprecado** y no debe usarse. El `setup.sh` activo es el que está en `template/setup.sh`, que se copia a cada proyecto. Si el `setup.sh` de la raíz sigue existiendo, se recomienda eliminarlo para evitar confusión.

### Uso

```bash
./setup.sh [--force] [--dry-run] [--install-tools] [--check]
```

| Opción | Descripción |
|--------|-------------|
| `--check` | Solo verifica la estructura (no modifica nada) |
| `--force` | Sobrescribe archivos existentes (no usado actualmente) |
| `--dry-run` | Muestra qué haría sin crear ni instalar nada |
| `--install-tools` | Instala herramientas de seguridad vía `apt`/`pip`/binario |

### Ejemplos

```bash
# Solo verificar estructura
./setup.sh --check

# Ver qué haría sin ejecutar nada
./setup.sh --dry-run

# Verificar + instalar herramientas
./setup.sh --install-tools

# Forzar recreación de directorios faltantes
./setup.sh --force
```

### Qué verifica

El script verifica que existan:

**Directorios:**
- `src/`, `tests/`, `scripts/`, `config/`
- `docs/`, `docs/prompts/`
- `.github/workflows/`, `.husky/`

**Archivos (30+):**
- `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`
- `cliff.toml`, `commitlint.config.js`, `codecov.yml`
- `.eslintrc-security.js`, `.gitleaks.toml`, `.secrets.baseline`, `.gitignore`
- `.husky/pre-commit`, `.husky/commit-msg`
- Los 7 workflows de `.github/workflows/`
- Todos los docs en `docs/` y `docs/prompts/`

Si falta un directorio, lo crea (salvo en `--check`). Si falta un archivo, lo reporta (no lo recrea).

### Qué instala con `--install-tools`

| Herramienta | Vía | Requiere sudo |
|-------------|-----|---------------|
| Semgrep | `pip3 install --user` | No |
| detect-secrets | `pip3 install --user` | No |
| Bandit | `pip3 install --user` | No |
| pip-audit | `pip3 install --user` | No |
| Ruff | `pip3 install --user` | No |
| Mypy | `pip3 install --user` | No |
| pytest + pytest-cov | `pip3 install --user` | No |
| pre-commit | `pip3 install --user` | No |
| Trivy | `apt` (repositorio de Aqua Security) | Sí |
| Gitleaks | Binario desde GitHub Releases | Sí (a `/usr/local/bin`) |
| git-cliff | Binario desde GitHub Releases | Sí (a `/usr/local/bin`) |

**Nota:** El script pide confirmación antes de usar `sudo`. Si dices que no, omite la instalación vía `apt`/binario pero continúa con las de `pip`.

### Qué hace además

- **Instala dependencias del proyecto:**
  - Si existe `package.json` → `npm install`
  - Si existe `requirements.txt` → `pip3 install --user -r requirements.txt`
- **Configura Husky:** ejecuta `npx husky install` y da permisos a los hooks.

### Diferencias entre `init-project.sh` y `setup.sh`

| Aspecto | `init-project.sh` | `setup.sh` |
|---------|-------------------|-----------|
| **Dónde vive** | `scripts/` del repo plantilla | `template/` del repo plantilla (se copia a cada proyecto) |
| **Dónde se ejecuta** | En el repo plantilla | Dentro de un proyecto creado |
| **Cuándo se usa** | Una vez, para crear el proyecto | Dentro del proyecto, cuando sea necesario |
| **Qué hace** | Copia la plantilla + Git + repo GitHub | Verifica estructura + instala herramientas + dependencias |
| **Opciones** | 8 (`path`, `git`, `private`, `public`, etc.) | 4 (`check`, `force`, `dry-run`, `install-tools`) |
| **Dependencias** | `gh` CLI (opcional) | `pip3`, `apt`, `sudo`, `npm` |

---

## Solución de problemas comunes

### `init-project.sh`

| Problema | Causa | Solución |
|----------|-------|----------|
| `El directorio 'X' ya existe` | Hay un directorio con el mismo nombre | Elige otro nombre o elimina el directorio existente |
| `No se encontró la plantilla en: X` | La carpeta `template/` no existe | Ejecuta el script desde la raíz del repo |
| `gh CLI no está instalado` | Falta `gh` en el sistema | `sudo apt install gh && gh auth login` |
| `gh: not authenticated` | `gh` no tiene sesión activa | `gh auth login` |
| `Permission denied` | Falta permiso de ejecución | `chmod +x scripts/init-project.sh` |
| Los placeholders no se reemplazan | Extensión no soportada | Añadir patrón al `find` del script |

### `setup.sh`

| Problema | Causa | Solución |
|----------|-------|----------|
| `Faltan N archivos` | El proyecto está incompleto | Copiar manualmente desde `template/` del repo plantilla, o recrear con `init-project.sh` |
| `pip3: command not found` | Python sin pip | `sudo apt install python3-pip` |
| `Trivy no se instala` | Repositorio no añadido | Verificar `/etc/apt/sources.list.d/trivy.list` |
| `Gitleaks no se instala` | Arquitectura no soportada | Comprobar `uname -m` (x86_64, aarch64) |
| `Fallo al instalar dependencias Node.js` | `npm` no está o `package.json` inválido | Verificar `node --version` y `npm --version` |
| `Husky no se configura` | Falta `npx` o `package.json` | Verificar instalación de Node.js |

---

## Referencias

- [`../README.md`](../README.md) — README principal del repositorio
- [`../docs/ARQUITECTURA.md`](../docs/ARQUITECTURA.md) — Filosofía y decisiones de diseño
- [`../docs/FLUJO_DE_TRABAJO.md`](../docs/FLUJO_DE_TRABAJO.md) — Flujo end-to-end
- [`../docs/HERRAMIENTAS.md`](../docs/HERRAMIENTAS.md) — Stack de herramientas
- [`../docs/HERRAMIENTAS_SEGURIDAD.md`](../docs/HERRAMIENTAS_SEGURIDAD.md) — Instalación de herramientas de seguridad
- [`../docs/WORKFLOWS.md`](../docs/WORKFLOWS.md) — Documentación de workflows de GitHub Actions
- [`../docs/GITHUB_SECRETS.md`](../docs/GITHUB_SECRETS.md) — Secrets necesarios en GitHub
- [`../docs/prompts/README.md`](../docs/prompts/README.md) — Prompts secuenciales

---

> **¿Encontraste un bug o quieres añadir una opción?** Abre un issue o un PR siguiendo [`CONTRIBUTING.md`](../CONTRIBUTING.md).
