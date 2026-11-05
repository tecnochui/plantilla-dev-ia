#!/usr/bin/env bash
# setup.sh — Inicializa y verifica un proyecto basado en plantilla-dev-ia.
#
# Uso:
#   ./setup.sh                                  # Verifica estructura
#   ./setup.sh --force                          # Sobrescribe archivos existentes
#   ./setup.sh --dry-run                        # Muestra qué haría sin ejecutar
#   ./setup.sh --install-tools                  # Instala herramientas de seguridad (pregunta dónde)
#   ./setup.sh --install-tools --venv           # ...en el entorno virtual del proyecto (.venv/)
#   ./setup.sh --install-tools --system         # ...en todo el sistema (pipx + apt, usa sudo)
#   ./setup.sh --check                          # Solo verifica estructura
#   ./setup.sh --add-language <es|en>           # Añade documentación del otro idioma
#   ./setup.sh --add-language <es|en> --from <ruta>
#
# Este script se ejecuta DENTRO de un proyecto (no en la plantilla).
# Para crear un proyecto nuevo, usar scripts/init-project.sh en el repo plantilla.

set -euo pipefail

# ──────────────────────────────────────────────
# Colores
# ──────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}   $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ──────────────────────────────────────────────
# Configuración inicial
# ──────────────────────────────────────────────
DRY_RUN=false
INSTALL_TOOLS=false
CHECK_ONLY=false
ADD_LANGUAGE=""
ADD_LANGUAGE_FROM=""
INSTALL_MODE=""      # venv | system (vacío = preguntar)
VENV_DIR=".venv"     # entorno virtual del proyecto (ya está en .gitignore)

# ──────────────────────────────────────────────
# Detectar idioma del proyecto
# ──────────────────────────────────────────────
PROJECT_LANG="es"    # default si no existe .project-language
if [ -f ".project-language" ]; then
  _lang=$(cat .project-language | tr -d '[:space:]')
  if [ "$_lang" = "es" ] || [ "$_lang" = "en" ]; then
    PROJECT_LANG="$_lang"
  fi
fi

# El idioma de la interfaz es el del proyecto (no cambia con --add-language)
UI_LANG="$PROJECT_LANG"

# ──────────────────────────────────────────────
# Función de mensajes bilingües
# ──────────────────────────────────────────────
msg() {
  local key="$1"
  local a1="${2:-}"
  local a2="${3:-}"  
  case "$UI_LANG:$key" in
    # Banner
    es:title)               echo "Setup de proyecto — plantilla-dev-ia" ;;
    en:title)               echo "Project setup — plantilla-dev-ia" ;;
    es:dry_run)             echo "Modo DRY-RUN: no se modificará ningún archivo." ;;
    en:dry_run)             echo "DRY-RUN mode: no files will be modified." ;;

    # Verificación
    es:checking)            echo "Verificando estructura del proyecto..." ;;
    en:checking)            echo "Verifying project structure..." ;;
    es:missing_dir)         echo "Falta directorio: $a1" ;;
    en:missing_dir)         echo "Missing directory: $a1" ;;
    es:dir_created)         echo "Directorio creado: $a1" ;;
    en:dir_created)         echo "Directory created: $a1" ;;
    es:missing_file)        echo "Falta archivo: $a1" ;;
    en:missing_file)        echo "Missing file: $a1" ;;
    es:missing_prompt)      echo "Falta archivo (opcional): $a1" ;;
    en:missing_prompt)      echo "Missing file (optional): $a1" ;;
    es:complete)            echo "Estructura completa: todos los archivos y directorios presentes." ;;
    en:complete)            echo "Complete structure: all files and directories present." ;;
    es:missing_summary)     echo "Faltan $a1 archivo(s) y $a2 directorio(s)." ;;
    en:missing_summary)     echo "Missing $a1 file(s) and $a2 directory(ies)." ;;
    es:dirs_created)        echo "Los directorios faltantes fueron creados automáticamente." ;;
    en:dirs_created)        echo "Missing directories were created automatically." ;;
    es:files_not_recreated) echo "Los archivos faltantes NO se recrean automáticamente." ;;
    en:files_not_recreated) echo "Missing files are NOT recreated automatically." ;;
    es:consider)            echo "Si faltan archivos críticos, considera copiarlos manualmente o recrear el proyecto con init-project.sh." ;;
    en:consider)            echo "If critical files are missing, consider copying them manually or recreating the project with init-project.sh." ;;
    es:check_done)          echo "Modo --check: verificación completada." ;;
    en:check_done)          echo "--check mode: verification completed." ;;

    # Dependencias
    es:detect_pkg)          echo "Detectado package.json. Instalando dependencias Node.js..." ;;
    en:detect_pkg)          echo "Detected package.json. Installing Node.js dependencies..." ;;
    es:node_installed)      echo "Dependencias Node.js instaladas." ;;
    en:node_installed)      echo "Node.js dependencies installed." ;;
    es:node_fail)           echo "Fallo al instalar dependencias Node.js." ;;
    en:node_fail)           echo "Failed to install Node.js dependencies." ;;
    es:npm_missing)         echo "npm no está instalado. Instálalo: https://nodejs.org/" ;;
    en:npm_missing)         echo "npm is not installed. Install it: https://nodejs.org/" ;;
    es:detect_req)          echo "Detectado requirements.txt. Instalando dependencias Python en $VENV_DIR/..." ;;
    en:detect_req)          echo "Detected requirements.txt. Installing Python dependencies in $VENV_DIR/..." ;;
    es:py_venv_note)        echo "Las dependencias de requirements.txt siempre van al entorno virtual $VENV_DIR/ (aislamiento y PEP 668)." ;;
    en:py_venv_note)        echo "requirements.txt dependencies always go to the $VENV_DIR/ virtual environment (isolation and PEP 668)." ;;
    es:py_installed)        echo "Dependencias Python instaladas." ;;
    en:py_installed)        echo "Python dependencies installed." ;;
    es:py_fail)             echo "Fallo al instalar dependencias Python." ;;
    en:py_fail)             echo "Failed to install Python dependencies." ;;
    es:pip_missing)         echo "python3 no está instalado. Instálalo: sudo apt install python3 python3-venv" ;;
    en:pip_missing)         echo "python3 is not installed. Install it: sudo apt install python3 python3-venv" ;;

    # Husky
    es:husky_config)        echo "Configurando Husky..." ;;
    en:husky_config)        echo "Configuring Husky..." ;;
    es:husky_fail)          echo "Fallo al configurar Husky." ;;
    en:husky_fail)          echo "Failed to configure Husky." ;;
    es:husky_done)          echo "Husky configurado." ;;
    en:husky_done)          echo "Husky configured." ;;

    # Add language
    es:add_lang_invalid)    echo "--add-language debe ser 'es' o 'en'" ;;
    en:add_lang_invalid)    echo "--add-language must be 'es' or 'en'" ;;
    es:add_lang_same)       echo "El idioma del proyecto ya es '$a1'. Nada que hacer." ;;
    en:add_lang_same)       echo "The project's language is already '$a1'. Nothing to do." ;;
    es:add_lang_start)      echo "Añadiendo documentación en idioma '$a1'..." ;;
    en:add_lang_start)      echo "Adding documentation in language '$a1'..." ;;
    es:add_lang_source)     echo "Origen: $a1" ;;
    en:add_lang_source)     echo "Source: $a1" ;;
    es:add_lang_notfound)   echo "No se encontró el repo plantilla. Pasa --from <ruta> apuntando a docs/ del repo plantilla." ;;
    en:add_lang_notfound)   echo "Template repo not found. Pass --from <path> pointing to docs/ of the template repo." ;;
    es:add_lang_target)     echo "Destino: $a1" ;;
    en:add_lang_target)     echo "Target: $a1" ;;
    es:add_lang_copied)     echo "Copiados $a1 archivo(s) en '$a2'." ;;
    en:add_lang_copied)     echo "Copied $a1 file(s) in '$a2'." ;;
    es:add_lang_done)       echo "Documentación añadida correctamente." ;;
    en:add_lang_done)       echo "Documentation added successfully." ;;

    # Herramientas de seguridad
    es:sec_checking)        echo "Verificando herramientas de seguridad..." ;;
    en:sec_checking)        echo "Verifying security tools..." ;;
    es:sec_distro)          echo "Distribución detectada: $a1 $a2" ;;
    en:sec_distro)          echo "Detected distribution: $a1 $a2" ;;
    es:sec_confirm)         echo "Esta operación puede usar 'sudo'. ¿Continuar? [y/N]" ;;
    en:sec_confirm)         echo "This operation may use 'sudo'. Continue? [y/N]" ;;
    es:sec_cancelled)       echo "Instalación cancelada por el usuario." ;;
    en:sec_cancelled)       echo "Installation cancelled by user." ;;
    es:sec_base_deps)       echo "Instalando dependencias base (gnupg, curl)..." ;;
    en:sec_base_deps)       echo "Installing base dependencies (gnupg, curl)..." ;;
    es:sec_mode_title)      echo "¿Dónde quieres instalar las herramientas de seguridad?" ;;
    en:sec_mode_title)      echo "Where do you want to install the security tools?" ;;
    es:sec_mode_venv)       echo "1) Entorno virtual del proyecto ($VENV_DIR/): aislado por proyecto, sin sudo (recomendado)" ;;
    en:sec_mode_venv)       echo "1) Project virtual environment ($VENV_DIR/): isolated per project, no sudo (recommended)" ;;
    es:sec_mode_system)     echo "2) Todo el sistema (pipx + apt/binarios): compartido entre proyectos, requiere sudo" ;;
    en:sec_mode_system)     echo "2) System-wide (pipx + apt/binaries): shared across projects, requires sudo" ;;
    es:sec_mode_prompt)     echo "Elige [1/2] (Enter = 1):" ;;
    en:sec_mode_prompt)     echo "Choose [1/2] (Enter = 1):" ;;
    es:sec_mode_invalid)    echo "Opción no válida: se usará el entorno virtual." ;;
    en:sec_mode_invalid)    echo "Invalid option: the virtual environment will be used." ;;
    es:sec_mode_noninteractive) echo "Sin terminal interactiva: se usa el entorno virtual. Usa --system para instalar en todo el sistema." ;;
    en:sec_mode_noninteractive) echo "No interactive terminal: using the virtual environment. Use --system to install system-wide." ;;
    es:sec_mode_selected_venv)  echo "Modo: entorno virtual del proyecto ($a1/)" ;;
    en:sec_mode_selected_venv)  echo "Mode: project virtual environment ($a1/)" ;;
    es:sec_mode_selected_system) echo "Modo: instalación en todo el sistema" ;;
    en:sec_mode_selected_system) echo "Mode: system-wide installation" ;;
    es:sec_no_apt)          echo "El modo sistema requiere apt-get (Debian/Ubuntu/Mint). Se usará el entorno virtual." ;;
    en:sec_no_apt)          echo "System-wide mode requires apt-get (Debian/Ubuntu/Mint). The virtual environment will be used." ;;
    es:sec_venv_create)     echo "Creando entorno virtual en $a1/..." ;;
    en:sec_venv_create)     echo "Creating virtual environment in $a1/..." ;;
    es:sec_venv_exists)     echo "Entorno virtual existente: $a1/" ;;
    en:sec_venv_exists)     echo "Existing virtual environment: $a1/" ;;
    es:sec_venv_install_pkg) echo "Falta el módulo venv de Python. Instalando python3-venv con apt..." ;;
    en:sec_venv_install_pkg) echo "Python's venv module is missing. Installing python3-venv with apt..." ;;
    es:sec_venv_fail)       echo "No se pudo crear el entorno virtual. Instala python3-venv: sudo apt install python3-venv" ;;
    en:sec_venv_fail)       echo "Could not create the virtual environment. Install python3-venv: sudo apt install python3-venv" ;;
    es:sec_pip_venv)        echo "Instalando herramientas Python en el entorno virtual ($a1/)..." ;;
    en:sec_pip_venv)        echo "Installing Python tools in the virtual environment ($a1/)..." ;;
    es:sec_pipx_missing)    echo "Instalando pipx..." ;;
    en:sec_pipx_missing)    echo "Installing pipx..." ;;
    es:sec_pipx_fail)       echo "No se pudo instalar pipx. Instálalo: sudo apt install pipx" ;;
    en:sec_pipx_fail)       echo "Could not install pipx. Install it: sudo apt install pipx" ;;
    es:sec_pipx_install)    echo "Instalando herramientas Python con pipx (un entorno aislado por herramienta)..." ;;
    en:sec_pipx_install)    echo "Installing Python tools with pipx (one isolated environment per tool)..." ;;
    es:sec_already)         echo "$a1 ya está instalado." ;;
    en:sec_already)         echo "$a1 is already installed." ;;
    es:sec_installing)      echo "Instalando $a1..." ;;
    en:sec_installing)      echo "Installing $a1..." ;;
    es:sec_install_fail)    echo "Falló la instalación de $a1." ;;
    en:sec_install_fail)    echo "Installation of $a1 failed." ;;
    es:sec_trivy)           echo "Instalando Trivy desde el repositorio oficial de Aqua Security..." ;;
    en:sec_trivy)           echo "Installing Trivy from the official Aqua Security repository..." ;;
    es:sec_gitleaks)        echo "Instalando Gitleaks (última versión)..." ;;
    en:sec_gitleaks)        echo "Installing Gitleaks (latest version)..." ;;
    es:sec_trivy_fallback)  echo "El repositorio apt de Trivy falló. Probando con el binario de GitHub Releases..." ;;
    en:sec_trivy_fallback)  echo "The Trivy apt repository failed. Trying the GitHub Releases binary..." ;;
    es:sec_binary_ok)       echo "$a1 v$a2 instalado." ;;
    en:sec_binary_ok)       echo "$a1 v$a2 installed." ;;
    es:sec_unsupported_arch) echo "Arquitectura no soportada: $a1" ;;
    en:sec_unsupported_arch) echo "Unsupported architecture: $a1" ;;
    es:sec_verify)          echo "Verificando instalación..." ;;
    en:sec_verify)          echo "Verifying installation..." ;;
    es:sec_verified)        echo "$a1: instalado" ;;
    en:sec_verified)        echo "$a1: installed" ;;
    es:sec_notfound)        echo "$a1: NO encontrado" ;;
    en:sec_notfound)        echo "$a1: NOT found" ;;
    es:sec_summary)         echo "$a1 herramienta(s) no se instalaron. Revisa los errores arriba." ;;
    en:sec_summary)         echo "$a1 tool(s) were not installed. Check the errors above." ;;
    es:sec_all_ok)          echo "Todas las herramientas instaladas correctamente." ;;
    en:sec_all_ok)          echo "All tools installed successfully." ;;
    es:sec_venv_hint)       echo "Las herramientas están en $a1/bin: 'make' y los hooks de git las usan solas. En tu terminal: source $a1/bin/activate" ;;
    en:sec_venv_hint)       echo "Tools are in $a1/bin: 'make' and the git hooks pick them up automatically. In your shell: source $a1/bin/activate" ;;
    es:sec_path_hint)       echo "Si en una terminal nueva no encuentras las herramientas Python, ejecuta: pipx ensurepath" ;;
    en:sec_path_hint)       echo "If a new terminal can't find the Python tools, run: pipx ensurepath" ;;

    # Próximos pasos
    es:next_steps)          echo "Próximos pasos:" ;;
    en:next_steps)          echo "Next steps:" ;;
    es:step1)               echo "  1. Poner el nombre del proyecto donde aparece el marcador (archivo:línea):" ;;
    en:step1)               echo "  1. Set the project name where the placeholder appears (file:line):" ;;
    es:step1_done)          echo "  1. Nombre del proyecto: ya configurado (nada que hacer)." ;;
    en:step1_done)          echo "  1. Project name: already set (nothing to do)." ;;
    es:step2)               echo "  2. Instalar herramientas de seguridad (si no lo hiciste):" ;;
    en:step2)               echo "  2. Install security tools (if you haven't):" ;;
    es:step3)               echo "  3. Configurar secrets en GitHub (Settings → Secrets → Actions):" ;;
    en:step3)               echo "  3. Configure GitHub secrets (Settings → Secrets → Actions):" ;;
    es:step4)               echo "  4. Generar la documentación fundacional:" ;;
    en:step4)               echo "  4. Generate the foundational documentation:" ;;
    es:step4_detail)        echo "     Revisar docs/prompts/README.md y seguir los 8 prompts secuenciales." ;;
    en:step4_detail)        echo "     Review docs/prompts/README.md and follow the 8 sequential prompts." ;;
    es:step5)               echo "  5. Hacer el primer commit:" ;;
    en:step5)               echo "  5. Make the first commit:" ;;
    es:done)                echo "Listo." ;;
    en:done)                echo "Done." ;;
    es:setup_done)          echo "SETUP COMPLETADO" ;;
    en:setup_done)          echo "SETUP COMPLETED" ;;

    # Errores
    es:unknown_arg)         echo "Argumento desconocido: $a1" ;;
    en:unknown_arg)         echo "Unknown argument: $a1" ;;
    es:missing_arg)         echo "Falta argumento para $a1" ;;
    en:missing_arg)         echo "Missing argument for $a1" ;;

    # Fallback
    *) echo "$key" ;;
  esac
}

# ──────────────────────────────────────────────
# Función: mostrar ayuda
# ──────────────────────────────────────────────
show_help() {
  if [ "$UI_LANG" = "en" ]; then
    cat <<'EOF'
Usage: ./setup.sh [options]

Options:
  --force                    Overwrite existing files
  --dry-run                  Show what it would do without executing
  --install-tools            Install security tools (Semgrep, Trivy, Gitleaks, etc.)
                             Asks where: project virtual environment or system-wide
  --venv                     With --install-tools: install in the project's .venv/ (no sudo)
  --system                   With --install-tools: install system-wide (pipx + apt, uses sudo)
  --check                    Only verify the project structure
  --add-language <es|en>     Add the documentation of the other language
  --from <path>              Source path for --add-language (points to docs/ of template repo)
  --help, -h                 Show this help

Examples:
  ./setup.sh                                    # Verify structure
  ./setup.sh --install-tools                    # Verify + install tools
  ./setup.sh --dry-run                          # Simulate without executing
  ./setup.sh --add-language en                  # Add English docs (auto-detect source)
  ./setup.sh --add-language en --from ~/plantilla-dev-ia/docs
EOF
  else
    cat <<'EOF'
Uso: ./setup.sh [opciones]

Opciones:
  --force                    Sobrescribe archivos existentes
  --dry-run                  Muestra qué haría sin ejecutar nada
  --install-tools            Instala herramientas de seguridad (Semgrep, Trivy, Gitleaks, etc.)
                             Pregunta dónde: entorno virtual del proyecto o todo el sistema
  --venv                     Con --install-tools: instala en el .venv/ del proyecto (sin sudo)
  --system                   Con --install-tools: instala en todo el sistema (pipx + apt, usa sudo)
  --check                    Solo verifica la estructura del proyecto
  --add-language <es|en>     Añade la documentación del otro idioma
  --from <ruta>              Ruta de origen para --add-language (apunta a docs/ del repo plantilla)
  --help, -h                 Muestra esta ayuda

Ejemplos:
  ./setup.sh                                    # Verifica estructura
  ./setup.sh --install-tools                    # Verifica + instala herramientas
  ./setup.sh --dry-run                          # Simula sin ejecutar
  ./setup.sh --add-language en                  # Añade docs en inglés (autodetecta origen)
  ./setup.sh --add-language en --from ~/plantilla-dev-ia/docs
EOF
  fi
}

# ──────────────────────────────────────────────
# Herramientas de seguridad: paquetes Python
# ──────────────────────────────────────────────
# En modo venv se instalan todos con pip dentro de .venv/.
# En modo sistema se instalan con pipx (pytest-cov se inyecta en pytest).
PY_TOOLS=(semgrep detect-secrets bandit pip-audit ruff mypy pytest pytest-cov pre-commit git-cliff)

# ──────────────────────────────────────────────
# Helper: ejecutar con sudo solo si hace falta (root no lo necesita)
# ──────────────────────────────────────────────
run_sudo() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

# ──────────────────────────────────────────────
# Helper: crear (o reutilizar) el entorno virtual del proyecto
# ──────────────────────────────────────────────
ensure_venv() {
  if [ -x "$VENV_DIR/bin/python" ]; then
    log_ok "$(msg sec_venv_exists "$VENV_DIR")"
    return 0
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    log_error "$(msg pip_missing)"
    return 1
  fi

  # Solo borramos lo que creamos nosotros si la creación falla a medias
  local created=false
  if [ ! -e "$VENV_DIR" ]; then
    created=true
  fi

  log_info "$(msg sec_venv_create "$VENV_DIR")"
  if python3 -m venv "$VENV_DIR" >/dev/null 2>&1; then
    return 0
  fi
  if [ "$created" = true ]; then
    rm -rf "$VENV_DIR"
  fi

  # En Debian/Ubuntu/Mint el módulo venv viene en el paquete python3-venv
  if command -v apt-get >/dev/null 2>&1; then
    log_warn "$(msg sec_venv_install_pkg)"
    if run_sudo apt-get install -y -qq python3-venv && python3 -m venv "$VENV_DIR"; then
      return 0
    fi
    if [ "$created" = true ]; then
      rm -rf "$VENV_DIR"
    fi
  fi

  log_error "$(msg sec_venv_fail)"
  return 1
}

# ──────────────────────────────────────────────
# Helper: elegir dónde instalar (venv del proyecto o todo el sistema)
# ──────────────────────────────────────────────
choose_install_mode() {
  # --venv / --system tienen prioridad sobre la pregunta
  if [ -n "$INSTALL_MODE" ]; then
    return 0
  fi

  # Sin terminal interactiva (CI, pipes) no se puede preguntar: venv es lo más seguro
  if [ ! -t 0 ]; then
    INSTALL_MODE="venv"
    log_info "$(msg sec_mode_noninteractive)"
    return 0
  fi

  echo ""
  log_info "$(msg sec_mode_title)"
  echo "   $(msg sec_mode_venv)"
  echo "   $(msg sec_mode_system)"
  printf "%s " "$(msg sec_mode_prompt)"

  local choice=""
  read -r choice || choice=""
  case "$choice" in
    1|"") INSTALL_MODE="venv" ;;
    2)    INSTALL_MODE="system" ;;
    *)
      INSTALL_MODE="venv"
      log_warn "$(msg sec_mode_invalid)"
      ;;
  esac
}

# ──────────────────────────────────────────────
# Helper: herramientas Python dentro de .venv/
# ──────────────────────────────────────────────
install_python_tools_venv() {
  log_info "$(msg sec_pip_venv "$VENV_DIR")"

  local tool
  for tool in "${PY_TOOLS[@]}"; do
    if "$VENV_DIR/bin/pip" show "$tool" >/dev/null 2>&1; then
      log_ok "$(msg sec_already "$tool")"
    else
      log_info "$(msg sec_installing "$tool")"
      "$VENV_DIR/bin/pip" install --quiet "$tool" || log_warn "$(msg sec_install_fail "$tool")"
    fi
  done
}

# ──────────────────────────────────────────────
# Helper: herramientas Python en todo el sistema (pipx, un entorno por herramienta)
# ──────────────────────────────────────────────
install_python_tools_pipx() {
  if ! command -v pipx >/dev/null 2>&1; then
    log_info "$(msg sec_pipx_missing)"
    if ! run_sudo apt-get install -y -qq pipx; then
      log_error "$(msg sec_pipx_fail)"
      return 1
    fi
  fi

  # pipx instala los ejecutables en ~/.local/bin
  export PATH="$HOME/.local/bin:$PATH"

  log_info "$(msg sec_pipx_install)"
  local installed tool
  installed=$(pipx list --short 2>/dev/null | awk '{print $1}' || true)

  for tool in "${PY_TOOLS[@]}"; do
    # pytest-cov es un plugin: se inyecta en pytest más abajo
    if [ "$tool" = "pytest-cov" ]; then
      continue
    fi
    if printf '%s\n' "$installed" | grep -qx "$tool"; then
      log_ok "$(msg sec_already "$tool")"
    else
      log_info "$(msg sec_installing "$tool")"
      pipx install "$tool" || log_warn "$(msg sec_install_fail "$tool")"
    fi
  done

  if pipx list --short 2>/dev/null | awk '{print $1}' | grep -qx "pytest"; then
    pipx inject pytest pytest-cov || log_warn "$(msg sec_install_fail "pytest-cov")"
  fi
}

# ──────────────────────────────────────────────
# Helper: última versión publicada en GitHub Releases (sin usar la API)
# ──────────────────────────────────────────────
github_latest_version() {
  local repo="$1" final_url tag
  final_url=$(curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/${repo}/releases/latest") || return 1
  tag="${final_url##*/}"
  tag="${tag#v}"
  # Debe parecer una versión (ej. 8.28.0); si no, la redirección no fue a un release
  case "$tag" in
    [0-9]*.[0-9]*) echo "$tag" ;;
    *) return 1 ;;
  esac
}

# ──────────────────────────────────────────────
# Helper: descargar un binario desde GitHub Releases
# Uso: install_release_binary <gitleaks|trivy> <directorio_destino> <usar_sudo: true|false>
# ──────────────────────────────────────────────
install_release_binary() {
  local tool="$1" target_dir="$2" use_sudo="$3"
  local repo version arch asset url tmp bin rc=0

  case "$tool" in
    gitleaks) repo="gitleaks/gitleaks" ;;
    trivy)    repo="aquasecurity/trivy" ;;
    *) return 1 ;;
  esac

  arch=$(uname -m)
  version=$(github_latest_version "$repo") || return 1

  case "$tool:$arch" in
    gitleaks:x86_64)                 asset="gitleaks_${version}_linux_x64.tar.gz" ;;
    gitleaks:aarch64|gitleaks:arm64) asset="gitleaks_${version}_linux_arm64.tar.gz" ;;
    trivy:x86_64)                    asset="trivy_${version}_Linux-64bit.tar.gz" ;;
    trivy:aarch64|trivy:arm64)       asset="trivy_${version}_Linux-ARM64.tar.gz" ;;
    *)
      log_warn "$(msg sec_unsupported_arch "$arch")"
      return 1
      ;;
  esac
  url="https://github.com/${repo}/releases/download/v${version}/${asset}"

  tmp=$(mktemp -d) || return 1
  if curl -fsSL -o "$tmp/pkg.tar.gz" "$url" && tar -xzf "$tmp/pkg.tar.gz" -C "$tmp"; then
    bin=$(find "$tmp" -type f -name "$tool" | head -1)
    if [ -z "$bin" ]; then
      rc=1
    elif [ "$use_sudo" = true ]; then
      run_sudo install -m 0755 "$bin" "$target_dir/$tool" || rc=1
    else
      install -m 0755 "$bin" "$target_dir/$tool" || rc=1
    fi
  else
    rc=1
  fi
  rm -rf "$tmp"

  if [ "$rc" -eq 0 ]; then
    log_ok "$(msg sec_binary_ok "$tool" "$version")"
  fi
  return "$rc"
}

# ──────────────────────────────────────────────
# Helper: Trivy desde el repositorio apt oficial (modo sistema)
# ──────────────────────────────────────────────
install_trivy_apt() {
  local keyring="/usr/share/keyrings/trivy.gpg"
  local list="/etc/apt/sources.list.d/trivy.list"
  local key
  key=$(mktemp) || return 1

  # La clave se descarga a un archivo para poder detectar un fallo real
  # (antes `wget -q | gpg` ocultaba el error y abortaba el script entero).
  if ! curl -fsSL -o "$key" "https://aquasecurity.github.io/trivy-repo/deb/public.key"; then
    rm -f "$key"
    return 1
  fi
  if ! gpg --dearmor < "$key" | run_sudo tee "$keyring" >/dev/null; then
    rm -f "$key"
    run_sudo rm -f "$keyring"
    return 1
  fi
  rm -f "$key"

  echo "deb [signed-by=${keyring}] https://aquasecurity.github.io/trivy-repo/deb generic main" \
    | run_sudo tee "$list" >/dev/null || return 1

  if run_sudo apt-get update -qq && run_sudo apt-get install -y -qq trivy; then
    return 0
  fi

  # No dejamos un repositorio apt roto en el sistema del usuario
  run_sudo rm -f "$list"
  return 1
}

# ──────────────────────────────────────────────
# Instalación en el entorno virtual del proyecto (.venv/)
# ──────────────────────────────────────────────
install_tools_venv() {
  ensure_venv || return 1
  install_python_tools_venv

  local tool
  for tool in gitleaks trivy; do
    if [ -x "$VENV_DIR/bin/$tool" ]; then
      log_ok "$(msg sec_already "$tool")"
    else
      log_info "$(msg sec_installing "$tool")"
      install_release_binary "$tool" "$VENV_DIR/bin" false || log_warn "$(msg sec_install_fail "$tool")"
    fi
  done
}

# ──────────────────────────────────────────────
# Instalación en todo el sistema (pipx + apt/binarios, requiere sudo)
# ──────────────────────────────────────────────
install_tools_system() {
  log_info "$(msg sec_base_deps)"
  run_sudo apt-get update -qq || log_warn "$(msg sec_install_fail "apt-get update")"
  if ! run_sudo apt-get install -y -qq gnupg curl ca-certificates; then
    log_error "$(msg sec_install_fail "gnupg, curl")"
    return 1
  fi

  install_python_tools_pipx || true

  if command -v trivy >/dev/null 2>&1; then
    log_ok "$(msg sec_already "Trivy")"
  else
    log_info "$(msg sec_trivy)"
    if ! install_trivy_apt; then
      log_warn "$(msg sec_trivy_fallback)"
      install_release_binary trivy /usr/local/bin true || log_warn "$(msg sec_install_fail "Trivy")"
    fi
  fi

  if command -v gitleaks >/dev/null 2>&1; then
    log_ok "$(msg sec_already "Gitleaks")"
  else
    log_info "$(msg sec_gitleaks)"
    install_release_binary gitleaks /usr/local/bin true || log_warn "$(msg sec_install_fail "Gitleaks")"
  fi
}

# ──────────────────────────────────────────────
# Verificar que las herramientas quedaron instaladas
# ──────────────────────────────────────────────
verify_tools() {
  echo ""
  log_info "$(msg sec_verify)"

  local tools=(semgrep detect-secrets bandit pip-audit ruff mypy pytest trivy gitleaks git-cliff)
  local missing=0 tool found

  if [ "$INSTALL_MODE" = "system" ]; then
    export PATH="$HOME/.local/bin:$PATH"
  fi

  for tool in "${tools[@]}"; do
    found=false
    if [ "$INSTALL_MODE" = "venv" ]; then
      # En modo venv solo cuenta lo que quedó dentro del proyecto
      if [ -x "$VENV_DIR/bin/$tool" ]; then found=true; fi
    elif command -v "$tool" >/dev/null 2>&1; then
      found=true
    fi

    if [ "$found" = true ]; then
      log_ok "$(msg sec_verified "$tool")"
    else
      log_error "$(msg sec_notfound "$tool")"
      missing=$((missing + 1))
    fi
  done

  if [ "$missing" -gt 0 ]; then
    log_warn "$(msg sec_summary "$missing")"
  else
    log_ok "$(msg sec_all_ok)"
  fi

  if [ "$INSTALL_MODE" = "venv" ]; then
    log_info "$(msg sec_venv_hint "$VENV_DIR")"
  else
    log_info "$(msg sec_path_hint)"
  fi
}

# ──────────────────────────────────────────────
# Función: instalar herramientas de seguridad
# ──────────────────────────────────────────────
install_security_tools() {
  log_info "$(msg sec_checking)"

  DISTRO_ID="unknown"
  DISTRO_VERSION=""
  if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    DISTRO_ID="${ID:-unknown}"
    DISTRO_VERSION="${VERSION_ID:-}"
  else
    log_warn "Could not detect the distribution / No se pudo detectar la distribución."
  fi

  log_info "$(msg sec_distro "$DISTRO_ID" "$DISTRO_VERSION")"

  if [ "$DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Would install security tools (mode: ${INSTALL_MODE:-ask}). Nothing executed."
    return 0
  fi

  choose_install_mode

  # El modo sistema usa apt; en otras distribuciones caemos al venv
  if [ "$INSTALL_MODE" = "system" ] && ! command -v apt-get >/dev/null 2>&1; then
    log_warn "$(msg sec_no_apt)"
    INSTALL_MODE="venv"
  fi

  if [ "$INSTALL_MODE" = "system" ]; then
    log_info "$(msg sec_mode_selected_system)"

    # Pedimos confirmación solo si hay una persona al teclado
    if [ -t 0 ]; then
      echo ""
      log_warn "$(msg sec_confirm)"
      echo ""
      local response=""
      read -r response || response=""
      case "$response" in
        [yY][eE][sS]|[yY]) ;;
        *) log_info "$(msg sec_cancelled)"; return 0 ;;
      esac
    fi

    install_tools_system || true
  else
    log_info "$(msg sec_mode_selected_venv "$VENV_DIR")"
    install_tools_venv || true
  fi

  verify_tools
}

# ──────────────────────────────────────────────
# Parsear argumentos
# ──────────────────────────────────────────────
i=1
while [ $i -le $# ]; do
  arg="${!i}"
  case $arg in
    --force)         FORCE=true ;;
    --dry-run)       DRY_RUN=true ;;
    --install-tools) INSTALL_TOOLS=true ;;
    --venv)          INSTALL_MODE="venv" ;;
    --system)        INSTALL_MODE="system" ;;
    --check)         CHECK_ONLY=true ;;
    --add-language)
      i=$((i+1))
      if [ $i -gt $# ]; then
        log_error "$(msg missing_arg "--add-language")"
        exit 1
      fi
      ADD_LANGUAGE="${!i}"
      ;;
    --from)
      i=$((i+1))
      if [ $i -gt $# ]; then
        log_error "$(msg missing_arg "--from")"
        exit 1
      fi
      ADD_LANGUAGE_FROM="${!i}"
      ;;
    --help|-h)
      show_help
      exit 0
      ;;
    *)
      log_error "$(msg unknown_arg "$arg")"
      exit 1
      ;;
  esac
  i=$((i+1))
done

# ──────────────────────────────────────────────
# Banner
# ──────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════╗"
TITLE=$(msg title)
# padding a 46 caracteres aprox
printf "║  %-42s  ║\n" "$TITLE"
echo "╚══════════════════════════════════════════════╝"
echo ""

if [ "$DRY_RUN" = true ]; then
  log_warn "$(msg dry_run)"
  echo ""
fi

# ──────────────────────────────────────────────
# 1. Verificar estructura
# ──────────────────────────────────────────────
log_info "$(msg checking)"

REQUIRED_DIRS=(
  "src"
  "tests"
  "scripts"
  "config"
  "docs"
  "docs/prompts"
  ".github/workflows"
  ".husky"
)

REQUIRED_FILES_COMMON=(
  "AGENTS.md"
  "CLAUDE.md"
  "GEMINI.md"
  "Makefile"
  "cliff.toml"
  "commitlint.config.js"
  ".eslintrc-security.js"
  ".gitleaks.toml"
  ".secrets.baseline"
  ".gitignore"
  "codecov.yml"
  ".husky/pre-commit"
  ".husky/commit-msg"
  ".github/workflows/tests.yml"
  ".github/workflows/changelog.yml"
  ".github/workflows/commitlint.yml"
  ".github/workflows/sast.yml"
  ".github/workflows/sca.yml"
  ".github/workflows/secrets.yml"
  ".github/workflows/dast.yml"
  ".env.example"
  "README.md"
)

# Bloque de docs según idioma del proyecto
if [ "$PROJECT_LANG" = "en" ]; then
  REQUIRED_DOCS=(
    "docs/PRD-SRD.md"
    "docs/SRS.md"
    "docs/Technical_Proposal.md"
    "docs/SSD-TDD.md"
    "docs/NIST_OWASP_Mapping.md"
    "docs/Backup_Strategy.md"
    "docs/Test_Plan.md"
    "docs/FORENSIC_RECORD.md"
  )
  REQUIRED_PROMPTS=(
    "docs/prompts/README.md"
    "docs/prompts/01-PRD-SRD.md"
    "docs/prompts/02-SRS.md"
    "docs/prompts/03-Technical-Proposal.md"
    "docs/prompts/04-SSD-TDD.md"
    "docs/prompts/05-NIST-OWASP-Mapping.md"
    "docs/prompts/06-Backup-Strategy.md"
    "docs/prompts/07-Test-Plan.md"
    "docs/prompts/08-Forensic-Record.md"
  )
else
  REQUIRED_DOCS=(
    "docs/PRD-SRD.md"
    "docs/SRS.md"
    "docs/Propuesta_Tecnica.md"
    "docs/SSD-TDD.md"
    "docs/Mapeo_NIST_OWASP.md"
    "docs/Estrategia_Respaldos.md"
    "docs/Plan_Pruebas.md"
    "docs/REGISTRO_FORENSE.md"
  )
  REQUIRED_PROMPTS=(
    "docs/prompts/README.md"
    "docs/prompts/01-PRD-SRD.md"
    "docs/prompts/02-SRS.md"
    "docs/prompts/03-Propuesta-Tecnica.md"
    "docs/prompts/04-SSD-TDD.md"
    "docs/prompts/05-Mapeo-NIST-OWASP.md"
    "docs/prompts/06-Estrategia-Respaldos.md"
    "docs/prompts/07-Plan-Pruebas.md"
    "docs/prompts/08-Registro-Forense.md"
  )
fi

REQUIRED_FILES=("${REQUIRED_FILES_COMMON[@]}" "${REQUIRED_DOCS[@]}")

MISSING_DIRS=0
MISSING_FILES=0

for dir in "${REQUIRED_DIRS[@]}"; do
  if [ ! -d "$dir" ]; then
    log_warn "$(msg missing_dir "$dir")"
    MISSING_DIRS=$((MISSING_DIRS + 1))
    if [ "$DRY_RUN" = false ] && [ "$CHECK_ONLY" = false ]; then
      mkdir -p "$dir"
      log_ok "$(msg dir_created "$dir")"
    fi
  fi
done

for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    log_warn "$(msg missing_file "$file")"
    MISSING_FILES=$((MISSING_FILES + 1))
  fi
done

for file in "${REQUIRED_PROMPTS[@]}"; do
  if [ ! -f "$file" ]; then
    log_warn "$(msg missing_prompt "$file")"
  fi
done

if [ "$MISSING_FILES" -eq 0 ] && [ "$MISSING_DIRS" -eq 0 ]; then
  log_ok "$(msg complete)"
else
  log_warn "$(msg missing_summary "$MISSING_FILES" "$MISSING_DIRS")"
  if [ "$CHECK_ONLY" = false ] && [ "$DRY_RUN" = false ]; then
    log_info "$(msg dirs_created)"
    log_warn "$(msg files_not_recreated)"
    log_warn "$(msg consider)"
  fi
fi

# ──────────────────────────────────────────────
# 2. Modo --check: salir
# ──────────────────────────────────────────────
if [ "$CHECK_ONLY" = true ]; then
  echo ""
  log_info "$(msg check_done)"
  exit 0
fi

# ──────────────────────────────────────────────
# 3. Modo --add-language: añadir docs del otro idioma
# ──────────────────────────────────────────────
if [ -n "$ADD_LANGUAGE" ]; then
  if [ "$ADD_LANGUAGE" != "es" ] && [ "$ADD_LANGUAGE" != "en" ]; then
    log_error "$(msg add_lang_invalid)"
    exit 1
  fi

  if [ "$ADD_LANGUAGE" = "$PROJECT_LANG" ]; then
    log_info "$(msg add_lang_same "$ADD_LANGUAGE")"
    exit 0
  fi

  # Localizar origen
  SOURCE_DOCS=""
  if [ -n "$ADD_LANGUAGE_FROM" ]; then
    if [ -d "$ADD_LANGUAGE_FROM/$ADD_LANGUAGE" ]; then
      SOURCE_DOCS="$ADD_LANGUAGE_FROM/$ADD_LANGUAGE"
    elif [ -d "$ADD_LANGUAGE_FROM" ] && [ -f "$ADD_LANGUAGE_FROM/PRD-SRD.md" ]; then
      SOURCE_DOCS="$ADD_LANGUAGE_FROM"
    fi
  fi

  if [ -z "$SOURCE_DOCS" ]; then
    # Auto-detección
    for candidate in \
      "$HOME/proyectos/plantilla-dev-ia/docs/$ADD_LANGUAGE" \
      "../plantilla-dev-ia/docs/$ADD_LANGUAGE" \
      "../../plantilla-dev-ia/docs/$ADD_LANGUAGE"; do
      if [ -d "$candidate" ]; then
        SOURCE_DOCS="$candidate"
        break
      fi
    done
  fi

  if [ -z "$SOURCE_DOCS" ]; then
    log_error "$(msg add_lang_notfound)"
    exit 1
  fi

  log_info "$(msg add_lang_start "$ADD_LANGUAGE")"
  log_info "$(msg add_lang_source "$SOURCE_DOCS")"

  COPIED=0
  TARGET_SUBDIR="docs/${ADD_LANGUAGE}"

  # Copiar docs del idioma secundario a docs/<lang>/
  mkdir -p "$TARGET_SUBDIR"
  for file in "$SOURCE_DOCS"/*.md; do
    [ -f "$file" ] || continue
    cp "$file" "$TARGET_SUBDIR/"
    COPIED=$((COPIED + 1))
  done

  # Copiar prompts a docs/<lang>/prompts/
  if [ -d "$SOURCE_DOCS/prompts" ]; then
    mkdir -p "$TARGET_SUBDIR/prompts"
    for file in "$SOURCE_DOCS/prompts"/*.md; do
      [ -f "$file" ] || continue
      cp "$file" "$TARGET_SUBDIR/prompts/"
      COPIED=$((COPIED + 1))
    done
  fi

  log_ok "$(msg add_lang_target "$TARGET_SUBDIR")"

  log_ok "$(msg add_lang_copied "$COPIED" "$ADD_LANGUAGE")"
  log_ok "$(msg add_lang_done)"
  exit 0
fi

# ──────────────────────────────────────────────
# 4. Instalar herramientas (opcional)
# ──────────────────────────────────────────────
if [ "$INSTALL_TOOLS" = true ]; then
  install_security_tools
fi

# ──────────────────────────────────────────────
# 5. Instalar dependencias del proyecto
# ──────────────────────────────────────────────
if [ "$DRY_RUN" = false ]; then
  if [ -f "package.json" ]; then
    log_info "$(msg detect_pkg)"
    if command -v npm >/dev/null 2>&1; then
      if npm install --loglevel=error; then
        log_ok "$(msg node_installed)"
      else
        log_warn "$(msg node_fail)"
      fi
    else
      log_warn "$(msg npm_missing)"
    fi
  fi

  # Las dependencias Python del proyecto van SIEMPRE al entorno virtual:
  # `pip install` en el Python del sistema está bloqueado por PEP 668
  # (Ubuntu 24.04 / Linux Mint 22 y posteriores).
  if [ -f "requirements.txt" ]; then
    log_info "$(msg detect_req)"
    if [ "$INSTALL_MODE" = "system" ]; then
      log_info "$(msg py_venv_note)"
    fi
    if ensure_venv; then
      if "$VENV_DIR/bin/pip" install --quiet -r requirements.txt; then
        log_ok "$(msg py_installed)"
      else
        log_warn "$(msg py_fail)"
      fi
    else
      log_warn "$(msg py_fail)"
    fi
  fi
fi

# ──────────────────────────────────────────────
# 6. Configurar Husky
# ──────────────────────────────────────────────
if [ "$DRY_RUN" = false ] && [ -f "package.json" ]; then
  if [ -d ".husky" ]; then
    log_info "$(msg husky_config)"
    if command -v npx >/dev/null 2>&1; then
      if npx husky install; then
        log_ok "$(msg husky_done)"
      else
        log_warn "$(msg husky_fail)"
      fi
      chmod +x .husky/pre-commit .husky/commit-msg 2>/dev/null || true
    fi
  fi
fi

# ──────────────────────────────────────────────
# 7. Instrucciones finales
# ──────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
printf "║  ✅ %-56s  ║\n" "$(msg setup_done)"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 $(msg next_steps)"
echo ""
# Solo pide editar el nombre si los marcadores siguen sin reemplazar
# (init-project.sh los reemplaza solo; al copiar la plantilla a mano quedan).
PLACEHOLDER_HITS=$(grep -nE '\[(NOMBRE DEL PROYECTO|PROJECT NAME)\]|"name": "tu-proyecto"' \
  AGENTS.md AGENTS.en.md README.md package.json 2>/dev/null || true)
if [ -n "$PLACEHOLDER_HITS" ]; then
  echo "$(msg step1)"
  while IFS= read -r hit; do
    echo "     $hit"
  done <<< "$PLACEHOLDER_HITS"
else
  echo "$(msg step1_done)"
fi
echo ""
echo "$(msg step2)"
echo "     ./setup.sh --install-tools"
echo ""
echo "$(msg step3)"
echo "     - CODECOV_TOKEN (coverage)"
echo "     - SSH_HOST, SSH_USER, SSH_KEY (if you use deploy.yml)"
echo ""
echo "$(msg step4)"
echo "$(msg step4_detail)"
echo ""
echo "$(msg step5)"
echo "     git add . && git commit -m 'chore: initial project setup'"
echo ""

log_ok "$(msg done)"