#!/usr/bin/env bash
# setup.sh — Inicializa y verifica un proyecto basado en plantilla-dev-ia.
#
# Uso:
#   ./setup.sh                    # Verifica estructura (no sobrescribe)
#   ./setup.sh --force            # Sobrescribe archivos existentes
#   ./setup.sh --dry-run          # Muestra qué haría sin ejecutar
#   ./setup.sh --install-tools    # Instala herramientas de seguridad
#   ./setup.sh --check            # Solo verifica estructura
#
# Este script se ejecuta DENTRO de un proyecto (no en la plantilla).
# Para crear un proyecto nuevo, usar scripts/init-project.sh en el repo plantilla.

set -euo pipefail

# ──────────────────────────────────────────────
# Configuración
# ──────────────────────────────────────────────
FORCE=false
DRY_RUN=false
INSTALL_TOOLS=false
CHECK_ONLY=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colores
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
# Parsear argumentos
# ──────────────────────────────────────────────
for arg in "$@"; do
  case $arg in
    --force)         FORCE=true ;;
    --dry-run)       DRY_RUN=true ;;
    --install-tools) INSTALL_TOOLS=true ;;
    --check)         CHECK_ONLY=true ;;
    --help|-h)
      cat <<'EOF'
Uso: ./setup.sh [opciones]

Opciones:
  --force          Sobrescribe archivos existentes
  --dry-run        Muestra qué haría sin ejecutar nada
  --install-tools  Instala herramientas de seguridad (Semgrep, Trivy, Gitleaks, etc.)
  --check          Solo verifica la estructura del proyecto
  --help           Muestra esta ayuda

Ejemplos:
  ./setup.sh                    # Verifica estructura
  ./setup.sh --install-tools    # Verifica + instala herramientas
  ./setup.sh --dry-run          # Simula sin ejecutar
  ./setup.sh --force            # Fuerza recreación de archivos
EOF
      exit 0
      ;;
    *)
      log_error "Argumento desconocido: $arg"
      exit 1
      ;;
  esac
done

# ──────────────────────────────────────────────
# Banner
# ──────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║     Setup de proyecto — plantilla-dev-ia     ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

if [ "$DRY_RUN" = true ]; then
  log_warn "Modo DRY-RUN: no se modificará ningún archivo."
  echo ""
fi

# ──────────────────────────────────────────────
# 1. Verificar estructura
# ──────────────────────────────────────────────
log_info "Verificando estructura del proyecto..."

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

REQUIRED_FILES=(
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
  "docs/PRD-SRD.md"
  "docs/SRS.md"
  "docs/Propuesta_Tecnica.md"
  "docs/SSD-TDD.md"
  "docs/Mapeo_NIST_OWASP.md"
  "docs/Estrategia_Respaldos.md"
  "docs/Plan_Pruebas.md"
  "docs/REGISTRO_FORENSE.md"
  "docs/prompts/01-PRD-SRD.md"
  "docs/prompts/02-SRS.md"
  "docs/prompts/03-Propuesta-Tecnica.md"
  "docs/prompts/04-SSD-TDD.md"
  "docs/prompts/05-Mapeo-NIST-OWASP.md"
  "docs/prompts/06-Estrategia-Respaldos.md"
  "docs/prompts/07-Plan-Pruebas.md"
  "docs/prompts/08-Registro-Forense.md"
  "docs/prompts/README.md"
  ".env.example"
  "README.md"
)

MISSING_DIRS=0
MISSING_FILES=0

for dir in "${REQUIRED_DIRS[@]}"; do
  if [ ! -d "$dir" ]; then
    log_warn "Falta directorio: $dir"
    MISSING_DIRS=$((MISSING_DIRS + 1))
    if [ "$DRY_RUN" = false ] && [ "$CHECK_ONLY" = false ]; then
      mkdir -p "$dir"
      log_ok "Directorio creado: $dir"
    fi
  fi
done

for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    # Los prompts son opcionales si el proyecto se creó sin init-project.sh
    if [[ "$file" == docs/prompts/* ]]; then
      log_warn "Falta archivo (opcional): $file"
    else
      log_warn "Falta archivo: $file"
      MISSING_FILES=$((MISSING_FILES + 1))
    fi
  fi
done

if [ "$MISSING_FILES" -eq 0 ] && [ "$MISSING_DIRS" -eq 0 ]; then
  log_ok "Estructura completa: todos los archivos y directorios presentes."
else
  log_warn "Faltan $MISSING_FILES archivo(s) y $MISSING_DIRS directorio(s)."
  if [ "$CHECK_ONLY" = false ] && [ "$DRY_RUN" = false ]; then
    log_info "Los directorios faltantes fueron creados automáticamente."
    log_warn "Los archivos faltantes NO se recrean automáticamente."
    log_warn "Si faltan archivos críticos, considera copiarlos manualmente o recrear el proyecto con init-project.sh."
  fi
fi

# ──────────────────────────────────────────────
# 2. Si es --check, salir aquí
# ──────────────────────────────────────────────
if [ "$CHECK_ONLY" = true ]; then
  echo ""
  log_info "Modo --check: verificación completada."
  exit 0
fi

# ──────────────────────────────────────────────
# 3. Instalar herramientas (opcional)
# ──────────────────────────────────────────────
if [ "$INSTALL_TOOLS" = true ]; then
  install_security_tools
fi

# ──────────────────────────────────────────────
# 4. Instalar dependencias del proyecto (si aplica)
# ──────────────────────────────────────────────
if [ "$DRY_RUN" = false ]; then
  if [ -f "package.json" ]; then
    log_info "Detectado package.json. Instalando dependencias Node.js..."
    if command -v npm >/dev/null 2>&1; then
      npm install --silent 2>/dev/null || log_warn "Fallo al instalar dependencias Node.js."
      log_ok "Dependencias Node.js instaladas."
    else
      log_warn "npm no está instalado. Instálalo: https://nodejs.org/"
    fi
  fi

  if [ -f "requirements.txt" ]; then
    log_info "Detectado requirements.txt. Instalando dependencias Python..."
    if command -v pip3 >/dev/null 2>&1; then
      pip3 install --user --quiet -r requirements.txt 2>/dev/null || log_warn "Fallo al instalar dependencias Python."
      log_ok "Dependencias Python instaladas."
    else
      log_warn "pip3 no está instalado. Instálalo: sudo apt install python3-pip"
    fi
  fi
fi

# ──────────────────────────────────────────────
# 5. Configurar Husky (si aplica)
# ──────────────────────────────────────────────
if [ "$DRY_RUN" = false ] && [ -f "package.json" ]; then
  if [ -d ".husky" ]; then
    log_info "Configurando Husky..."
    if command -v npx >/dev/null 2>&1; then
      npx husky install 2>/dev/null || log_warn "Fallo al configurar Husky."
      chmod +x .husky/pre-commit .husky/commit-msg 2>/dev/null || true
      log_ok "Husky configurado."
    fi
  fi
fi

# ──────────────────────────────────────────────
# 6. Instrucciones finales
# ──────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                  ✅ SETUP COMPLETADO                         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Próximos pasos:"
echo ""
echo "  1. Editar 'AGENTS.md' con el nombre del proyecto."
echo ""
echo "  2. Instalar herramientas de seguridad (si no lo hiciste):"
echo "     ./setup.sh --install-tools"
echo ""
echo "  3. Configurar secrets en GitHub (Settings → Secrets → Actions):"
echo "     - CODECOV_TOKEN (para cobertura)"
echo "     - SSH_HOST, SSH_USER, SSH_KEY (si usas deploy.yml)"
echo ""
echo "  4. Generar la documentación fundacional:"
echo "     Revisar docs/prompts/README.md y seguir los 8 prompts secuenciales."
echo ""
echo "  5. Hacer el primer commit:"
echo "     git add . && git commit -m 'chore: initial project setup'"
echo ""

log_ok "Listo."

# ──────────────────────────────────────────────
# Función: instalar herramientas de seguridad
# ──────────────────────────────────────────────
install_security_tools() {
  log_info "Verificando herramientas de seguridad..."

  # Detectar distro
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO_ID="$ID"
    DISTRO_VERSION="$VERSION_ID"
  else
    log_error "No se pudo detectar la distribución."
    return 1
  fi

  log_info "Distribución detectada: $DISTRO_ID $DISTRO_VERSION"

  if [ "$DRY_RUN" = true ]; then
    log_info "[DRY-RUN] Instalaría herramientas de seguridad. No se ejecuta nada."
    return 0
  fi

  # Confirmar antes de usar sudo
  echo ""
  log_warn "Esta operación puede usar 'sudo' para instalar paquetes del sistema."
  log_warn "Se instalarán: Semgrep, detect-secrets, Bandit, pip-audit, Ruff, Mypy, Trivy, Gitleaks, git-cliff."
  echo ""
  read -r -p "¿Continuar? [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY]) ;;
    *) log_info "Instalación cancelada por el usuario."; return 0 ;;
  esac

  # Dependencias base
  log_info "Instalando dependencias base (wget, gnupg, curl)..."
  sudo apt-get update -qq
  sudo apt-get install -y -qq wget gnupg curl ca-certificates apt-transport-https

  # Herramientas Python vía pip
  log_info "Instalando herramientas Python vía pip (modo usuario)..."
  if ! command -v pip3 >/dev/null 2>&1; then
    log_warn "pip3 no está instalado. Instalando python3-pip vía apt..."
    sudo apt-get install -y -qq python3-pip
  fi

  PIP_TOOLS=(semgrep detect-secrets bandit pip-audit ruff mypy pytest pytest-cov pre-commit)
  for tool in "${PIP_TOOLS[@]}"; do
    if pip3 show "$tool" >/dev/null 2>&1; then
      log_ok "$tool ya está instalado."
    else
      log_info "Instalando $tool..."
      pip3 install --user --quiet "$tool" || log_warn "Falló la instalación de $tool."
    fi
  done

  # Trivy (repositorio oficial de Aqua Security)
  if command -v trivy >/dev/null 2>&1; then
    log_ok "Trivy ya está instalado."
  else
    log_info "Instalando Trivy desde el repositorio oficial de Aqua Security..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO - https://apt.aquasec.com/trivy.gpg.key | \
      gpg --dearmor | sudo tee /etc/apt/keyrings/trivy.gpg > /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/trivy.gpg] https://apt.aquasec.com/trivy/deb/ generic main" | \
      sudo tee /etc/apt/sources.list.d/trivy.list > /dev/null
    sudo apt-get update -qq
    sudo apt-get install -y -qq trivy || log_warn "Falló la instalación de Trivy."
  fi

  # Gitleaks (binario desde GitHub Releases)
  if command -v gitleaks >/dev/null 2>&1; then
    log_ok "Gitleaks ya está instalado."
  else
    log_info "Instalando Gitleaks (última versión)..."
    GITLEAKS_VERSION=$(curl -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest | \
      grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    if [ -n "$GITLEAKS_VERSION" ]; then
      ARCH=$(uname -m)
      case "$ARCH" in
        x86_64) GITLEAKS_ARCH="x64" ;;
        aarch64|arm64) GITLEAKS_ARCH="arm64" ;;
        *) log_warn "Arquitectura $ARCH no soportada para Gitleaks."; GITLEAKS_ARCH="" ;;
      esac
      if [ -n "$GITLEAKS_ARCH" ]; then
        TMP_DIR=$(mktemp -d)
        wget -q "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_${GITLEAKS_ARCH}.tar.gz" \
          -O "$TMP_DIR/gitleaks.tar.gz"
        tar -xzf "$TMP_DIR/gitleaks.tar.gz" -C "$TMP_DIR"
        sudo mv "$TMP_DIR/gitleaks" /usr/local/bin/
        sudo chmod +x /usr/local/bin/gitleaks
        rm -rf "$TMP_DIR"
        log_ok "Gitleaks v${GITLEAKS_VERSION} instalado."
      fi
    else
      log_warn "No se pudo obtener la última versión de Gitleaks."
    fi
  fi

  # git-cliff (binario desde GitHub Releases)
  if command -v git-cliff >/dev/null 2>&1; then
    log_ok "git-cliff ya está instalado."
  else
    log_info "Instalando git-cliff (última versión)..."
    CLIFF_VERSION=$(curl -s https://api.github.com/repos/orhun/git-cliff/releases/latest | \
      grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    if [ -n "$CLIFF_VERSION" ]; then
      ARCH=$(uname -m)
      case "$ARCH" in
        x86_64) CLIFF_ARCH="x86_64-unknown-linux-gnu" ;;
        aarch64|arm64) CLIFF_ARCH="aarch64-unknown-linux-gnu" ;;
        *) log_warn "Arquitectura $ARCH no soportada para git-cliff."; CLIFF_ARCH="" ;;
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
          log_ok "git-cliff v${CLIFF_VERSION} instalado."
        fi
        rm -rf "$TMP_DIR"
      fi
    else
      log_warn "No se pudo obtener la última versión de git-cliff."
    fi
  fi

  # Verificación final
  echo ""
  log_info "Verificando instalación..."
  TOOLS=(semgrep detect-secrets bandit pip-audit ruff mypy pytest trivy gitleaks git-cliff)
  MISSING=0
  for tool in "${TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
      log_ok "$tool: instalado"
    else
      log_error "$tool: NO encontrado"
      MISSING=$((MISSING + 1))
    fi
  done

  if [ "$MISSING" -gt 0 ]; then
    log_warn "$MISSING herramienta(s) no se instalaron. Revisa los errores arriba."
  else
    log_ok "Todas las herramientas instaladas correctamente."
  fi
}