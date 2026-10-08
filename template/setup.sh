#!/usr/bin/env bash
# setup.sh — Inicializa y verifica un proyecto basado en plantilla-dev-ia.
#
# Uso:
#   ./setup.sh                                  # Verifica estructura
#   ./setup.sh --force                          # Sobrescribe archivos existentes
#   ./setup.sh --dry-run                        # Muestra qué haría sin ejecutar
#   ./setup.sh --install-tools                  # Instala herramientas de seguridad
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
    es:detect_req)          echo "Detectado requirements.txt. Instalando dependencias Python..." ;;
    en:detect_req)          echo "Detected requirements.txt. Installing Python dependencies..." ;;
    es:py_installed)        echo "Dependencias Python instaladas." ;;
    en:py_installed)        echo "Python dependencies installed." ;;
    es:py_fail)             echo "Fallo al instalar dependencias Python." ;;
    en:py_fail)             echo "Failed to install Python dependencies." ;;
    es:pip_missing)         echo "pip3 no está instalado. Instálalo: sudo apt install python3-pip" ;;
    en:pip_missing)         echo "pip3 is not installed. Install it: sudo apt install python3-pip" ;;

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
    es:sec_base_deps)       echo "Instalando dependencias base (wget, gnupg, curl)..." ;;
    en:sec_base_deps)       echo "Installing base dependencies (wget, gnupg, curl)..." ;;
    es:sec_pip_install)     echo "Instalando herramientas Python vía pip (modo usuario)..." ;;
    en:sec_pip_install)     echo "Installing Python tools via pip (user mode)..." ;;
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
    es:sec_gitcliff)        echo "Instalando git-cliff (última versión)..." ;;
    en:sec_gitcliff)        echo "Installing git-cliff (latest version)..." ;;
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

    # Próximos pasos
    es:next_steps)          echo "Próximos pasos:" ;;
    en:next_steps)          echo "Next steps:" ;;
    es:step1)               echo "  1. Editar 'AGENTS.md' con el nombre del proyecto." ;;
    en:step1)               echo "  1. Edit 'AGENTS.md' with the project name." ;;
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
# Función: instalar herramientas de seguridad
# ──────────────────────────────────────────────
install_security_tools() {
  log_info "$(msg sec_checking)"

  if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO_ID="$ID"
    DISTRO_VERSION="$VERSION_ID"
  else
    log_error "Could not detect the distribution / No se pudo detectar la distribución."
    return 1
  fi

  log_info "$(msg sec_distro "$DISTRO_ID" "$DISTRO_VERSION")"

  if [ "$DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Would install security tools. Nothing executed."
    return 0
  fi

  echo ""
  log_warn "$(msg sec_confirm)"
  echo ""
  read -r response
  case "$response" in
    [yY][eE][sS]|[yY]) ;;
    *) log_info "$(msg sec_cancelled)"; return 0 ;;
  esac

  log_info "$(msg sec_base_deps)"
  sudo apt-get update -qq
  sudo apt-get install -y -qq wget gnupg curl ca-certificates apt-transport-https

  log_info "$(msg sec_pip_install)"
  if ! command -v pip3 >/dev/null 2>&1; then
    sudo apt-get install -y -qq python3-pip
  fi

  PIP_TOOLS=(semgrep detect-secrets bandit pip-audit ruff mypy pytest pytest-cov pre-commit)
  for tool in "${PIP_TOOLS[@]}"; do
    if pip3 show "$tool" >/dev/null 2>&1; then
      log_ok "$(msg sec_already "$tool")"
    else
      log_info "$(msg sec_installing "$tool")"
      pip3 install --user --quiet "$tool" || log_warn "$(msg sec_install_fail "$tool")"
    fi
  done

  if command -v trivy >/dev/null 2>&1; then
    log_ok "$(msg sec_already "Trivy")"
  else
    log_info "$(msg sec_trivy)"
    sudo mkdir -p /etc/apt/keyrings
    wget -qO - https://apt.aquasec.com/trivy.gpg.key | \
      gpg --dearmor | sudo tee /etc/apt/keyrings/trivy.gpg > /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/trivy.gpg] https://apt.aquasec.com/trivy/deb/ generic main" | \
      sudo tee /etc/apt/sources.list.d/trivy.list > /dev/null
    sudo apt-get update -qq
    sudo apt-get install -y -qq trivy || log_warn "$(msg sec_install_fail "Trivy")"
  fi

  if command -v gitleaks >/dev/null 2>&1; then
    log_ok "$(msg sec_already "Gitleaks")"
  else
    log_info "$(msg sec_gitleaks)"
    GITLEAKS_VERSION=$(curl -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest | \
      grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    if [ -n "$GITLEAKS_VERSION" ]; then
      ARCH=$(uname -m)
      case "$ARCH" in
        x86_64) GITLEAKS_ARCH="x64" ;;
        aarch64|arm64) GITLEAKS_ARCH="arm64" ;;
        *) log_warn "Unsupported architecture: $ARCH"; GITLEAKS_ARCH="" ;;
      esac
      if [ -n "$GITLEAKS_ARCH" ]; then
        TMP_DIR=$(mktemp -d)
        wget -q "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_${GITLEAKS_ARCH}.tar.gz" \
          -O "$TMP_DIR/gitleaks.tar.gz"
        tar -xzf "$TMP_DIR/gitleaks.tar.gz" -C "$TMP_DIR"
        sudo mv "$TMP_DIR/gitleaks" /usr/local/bin/
        sudo chmod +x /usr/local/bin/gitleaks
        rm -rf "$TMP_DIR"
        log_ok "Gitleaks v${GITLEAKS_VERSION} installed."
      fi
    fi
  fi

  if command -v git-cliff >/dev/null 2>&1; then
    log_ok "$(msg sec_already "git-cliff")"
  else
    log_info "$(msg sec_gitcliff)"
    CLIFF_VERSION=$(curl -s https://api.github.com/repos/orhun/git-cliff/releases/latest | \
      grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    if [ -n "$CLIFF_VERSION" ]; then
      ARCH=$(uname -m)
      case "$ARCH" in
        x86_64) CLIFF_ARCH="x86_64-unknown-linux-gnu" ;;
        aarch64|arm64) CLIFF_ARCH="aarch64-unknown-linux-gnu" ;;
        *) log_warn "Unsupported architecture: $ARCH"; CLIFF_ARCH="" ;;
      esac
      if [ -n "$CLIFF_ARCH" ]; then
        TMP_DIR=$(mktemp -d)
        wget -q "https://github.com/orhun/git-cliff/releases/download/v${CLIFF_VERSION}/git-cliff-${CLIFF_VERSION}-${CLIFF_ARCH}.tar.gz" \
          -O "$TMP_DIR/git-cliff.tar.gz"
        tar -xzf "$TMP_DIR/git-cliff.tar.gz" -C "$TMP_DIR"
        CLIFF_BIN=$(find "$TMP_DIR" -name "git-cliff" -type f | head -1)
        if [ -n "$CLIFF_BIN" ]; then
          sudo mv "$CLIFF_BIN" /usr/local/bin/git-cliff
          sudo chmod +x /usr/local/bin/git-cliff
          log_ok "git-cliff v${CLIFF_VERSION} installed."
        fi
        rm -rf "$TMP_DIR"
      fi
    fi
  fi

  echo ""
  log_info "$(msg sec_verify)"
  TOOLS=(semgrep detect-secrets bandit pip-audit ruff mypy pytest trivy gitleaks git-cliff)
  MISSING=0
  for tool in "${TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
      log_ok "$(msg sec_verified "$tool")"
    else
      log_error "$(msg sec_notfound "$tool")"
      MISSING=$((MISSING + 1))
    fi
  done

  if [ "$MISSING" -gt 0 ]; then
    log_warn "$(msg sec_summary "$MISSING")"
  else
    log_ok "$(msg sec_all_ok)"
  fi
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
      npm install --silent 2>/dev/null || log_warn "$(msg node_fail)"
      log_ok "$(msg node_installed)"
    else
      log_warn "$(msg npm_missing)"
    fi
  fi

  if [ -f "requirements.txt" ]; then
    log_info "$(msg detect_req)"
    if command -v pip3 >/dev/null 2>&1; then
      pip3 install --user --quiet -r requirements.txt 2>/dev/null || log_warn "$(msg py_fail)"
      log_ok "$(msg py_installed)"
    else
      log_warn "$(msg pip_missing)"
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
      npx husky install 2>/dev/null || log_warn "$(msg husky_fail)"
      chmod +x .husky/pre-commit .husky/commit-msg 2>/dev/null || true
      log_ok "$(msg husky_done)"
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
echo "$(msg step1)"
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