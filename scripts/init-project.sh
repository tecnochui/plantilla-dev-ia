#!/usr/bin/env bash
# init-project.sh — Crea un proyecto nuevo desde la plantilla plantilla-dev-ia.
#
# Uso:
#   ./scripts/init-project.sh <nombre> [opciones]
#
# Opciones:
#   --path <ruta>        Directorio donde crear el proyecto (default: .)
#   --git                Inicializar repositorio Git (default: true)
#   --no-git             No inicializar Git
#   --private            Crear repo privado en GitHub (requiere gh CLI)
#   --public             Crear repo público en GitHub (requiere gh CLI)
#   --template <ruta>    Usar una plantilla alternativa (default: template/)
#   --yes, -y            Auto-confirmar sin prompt (útil en CI)
#   --help               Mostrar esta ayuda
#
# Ejemplos:
#   ./scripts/init-project.sh mi-app
#   ./scripts/init-project.sh mi-app --path ~/proyectos
#   ./scripts/init-project.sh mi-app --private
#   ./scripts/init-project.sh mi-app --no-git
#   ./scripts/init-project.sh mi-app --yes       # útil en CI

set -euo pipefail

# ──────────────────────────────────────────────
# Valores por defecto
# ──────────────────────────────────────────────
PROJECT_NAME=""
PROJECT_PATH="."
INIT_GIT=true
CREATE_REPO=false
REPO_VISIBILITY=""
TEMPLATE_DIR=""
AUTO_CONFIRM=false

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
# Parsear argumentos
# ──────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --path)
      PROJECT_PATH="$2"
      shift 2
      ;;
    --git)
      INIT_GIT=true
      shift
      ;;
    --no-git)
      INIT_GIT=false
      shift
      ;;
    --private)
      CREATE_REPO=true
      REPO_VISIBILITY="--private"
      shift
      ;;
    --public)
      CREATE_REPO=true
      REPO_VISIBILITY="--public"
      shift
      ;;
    --template)
      TEMPLATE_DIR="$2"
      shift 2
      ;;
    --yes|-y)
      AUTO_CONFIRM=true
      shift
      ;;
    --help|-h)
      echo "Uso: $0 <nombre> [opciones]"
      echo ""
      echo "Opciones:"
      echo "  --path <ruta>        Directorio donde crear el proyecto (default: .)"
      echo "  --git                Inicializar repositorio Git (default: true)"
      echo "  --no-git             No inicializar Git"
      echo "  --private            Crear repo privado en GitHub (requiere gh CLI)"
      echo "  --public             Crear repo público en GitHub (requiere gh CLI)"
      echo "  --template <ruta>    Usar plantilla alternativa (default: template/)"
      echo "  --yes, -y            Auto-confirmar sin prompt (útil en CI)"
      echo "  --help               Mostrar esta ayuda"
      echo ""
      echo "Ejemplos:"
      echo "  $0 mi-app"
      echo "  $0 mi-app --path ~/proyectos"
      echo "  $0 mi-app --private"
      echo "  $0 mi-app --yes"
      exit 0
      ;;
    *)
      if [ -z "$PROJECT_NAME" ]; then
        PROJECT_NAME="$1"
      else
        log_error "Argumento desconocido: $1"
        exit 1
      fi
      shift
      ;;
  esac
done

# ──────────────────────────────────────────────
# Validaciones
# ──────────────────────────────────────────────
if [ -z "$PROJECT_NAME" ]; then
  log_error "Falta el nombre del proyecto."
  echo "Uso: $0 <nombre> [opciones]"
  exit 1
fi

if [ -z "$TEMPLATE_DIR" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  TEMPLATE_DIR="$SCRIPT_DIR/template"
fi

if [ ! -d "$TEMPLATE_DIR" ]; then
  log_error "No se encontró la plantilla en: $TEMPLATE_DIR"
  exit 1
fi

TARGET_DIR="$PROJECT_PATH/$PROJECT_NAME"

if [ -d "$TARGET_DIR" ]; then
  log_error "El directorio '$TARGET_DIR' ya existe."
  exit 1
fi

# ──────────────────────────────────────────────
# Confirmación
# ──────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║         Crear nuevo proyecto                ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "  Nombre:       $PROJECT_NAME"
echo "  Destino:      $TARGET_DIR"
echo "  Plantilla:    $TEMPLATE_DIR"
echo "  Git:          $INIT_GIT"
echo "  Crear repo:   $CREATE_REPO"
echo ""

# Auto-confirmar si --yes, o si no hay TTY (útil en CI)
if [ "$AUTO_CONFIRM" = true ]; then
  log_info "Auto-confirmado (--yes)."
elif [ ! -t 0 ]; then
  log_warn "No hay TTY disponible. Auto-confirmando para evitar bloqueo."
else
  read -r -p "¿Continuar? [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY]) ;;
    *) log_info "Cancelado."; exit 0 ;;
  esac
fi

# ──────────────────────────────────────────────
# Copiar plantilla
# ──────────────────────────────────────────────
log_info "Copiando plantilla..."
mkdir -p "$TARGET_DIR"
cp -r "$TEMPLATE_DIR"/. "$TARGET_DIR"/

# ──────────────────────────────────────────────
# Copiar prompts de documentación
# ──────────────────────────────────────────────
# Los prompts viven en docs/prompts/ del repo plantilla, no en template/.
# Se copian al proyecto nuevo para que estén disponibles localmente.
PROMPTS_SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/docs/prompts"
PROMPTS_TARGET="$TARGET_DIR/docs/prompts"

if [ -d "$PROMPTS_SOURCE" ]; then
  log_info "Copiando prompts de documentación..."
  mkdir -p "$PROMPTS_TARGET"
  cp -r "$PROMPTS_SOURCE"/. "$PROMPTS_TARGET"/
  PROMPTS_COPIED=$(find "$PROMPTS_TARGET" -maxdepth 1 -type f | wc -l)
  log_ok "Prompts copiados a docs/prompts/ ($PROMPTS_COPIED archivos)."
else
  log_warn "No se encontraron prompts en: $PROMPTS_SOURCE"
  log_warn "El proyecto no tendrá prompts locales. Copiarlos manualmente desde el repo plantilla."
fi

# ──────────────────────────────────────────────
# Verificar prompts
# ──────────────────────────────────────────────
if [ -d "$PROMPTS_TARGET" ]; then
  PROMPTS_COUNT=$(find "$PROMPTS_TARGET" -maxdepth 1 -type f 2>/dev/null | wc -l)
  if [ "$PROMPTS_COUNT" -ge 8 ]; then
    log_ok "Prompts verificados: $PROMPTS_COUNT archivos en docs/prompts/"
  else
    log_warn "Solo $PROMPTS_COUNT archivos en docs/prompts/. Se esperaban al menos 8."
  fi
fi

# ──────────────────────────────────────────────
# Copiar documentación de referencia del repo
# ──────────────────────────────────────────────
# Archivos que viven en docs/ del repo plantilla y son útiles dentro
# de cada proyecto nuevo. Se copian al proyecto para consulta local.
REPO_DOCS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/docs"

REFERENCE_DOCS=(
  "WORKFLOWS.md"
  "HERRAMIENTAS_SEGURIDAD.md"
  "GITHUB_SECRETS.md"
)

for doc in "${REFERENCE_DOCS[@]}"; do
  if [ -f "$REPO_DOCS/$doc" ]; then
    if [ -d "$TARGET_DIR/docs" ]; then
      cp "$REPO_DOCS/$doc" "$TARGET_DIR/docs/$doc"
      log_ok "Copiado: docs/$doc"
    else
      log_warn "No existe docs/ en el proyecto. Saltando: $doc"
    fi
  else
    log_warn "No se encontró en el repo: docs/$doc"
  fi
done

# ──────────────────────────────────────────────
# Crear directorios vacíos del proyecto
# ──────────────────────────────────────────────
# El template no incluye estos directorios porque están vacíos por
# defecto. Se crean aquí con .gitkeep para que Git los versione.
log_info "Creando directorios del proyecto..."

EMPTY_DIRS=(
  "src"
  "tests"
  "scripts"
  "config"
)

for dir in "${EMPTY_DIRS[@]}"; do
  mkdir -p "$TARGET_DIR/$dir"
  touch "$TARGET_DIR/$dir/.gitkeep"
done

log_ok "Directorios creados: src, tests, scripts, config"

# ──────────────────────────────────────────────
# Reemplazar placeholders
# ──────────────────────────────────────────────
log_info "Reemplazando placeholders..."

# Placeholder en español
find "$TARGET_DIR" -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.toml" -o -name "*.sh" \) \
  -exec sed -i "s/\[NOMBRE DEL PROYECTO\]/$PROJECT_NAME/g" {} \;

# Placeholder en inglés
find "$TARGET_DIR" -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.toml" -o -name "*.sh" \) \
  -exec sed -i "s/\[PROJECT NAME\]/$PROJECT_NAME/g" {} \;

log_ok "Placeholders reemplazados."

# ──────────────────────────────────────────────
# Inicializar Git
# ──────────────────────────────────────────────
if [ "$INIT_GIT" = true ]; then
  log_info "Inicializando repositorio Git..."
  cd "$TARGET_DIR"
  git init -q
  git add .
  git commit -q -m "chore: initial setup from plantilla-dev-ia"
  log_ok "Repositorio Git inicializado con commit inicial."
else
  cd "$TARGET_DIR"
fi

# ──────────────────────────────────────────────
# Crear repositorio en GitHub (opcional)
# ──────────────────────────────────────────────
if [ "$CREATE_REPO" = true ]; then
  if ! command -v gh >/dev/null 2>&1; then
    log_warn "gh CLI no está instalado. No se puede crear el repo en GitHub."
    log_warn "Instálalo: https://cli.github.com/"
  else
    log_info "Creando repositorio en GitHub..."
    gh repo create "$PROJECT_NAME" $REPO_VISIBILITY --source=. --push
    log_ok "Repositorio creado en GitHub."
  fi
fi

# ──────────────────────────────────────────────
# Instrucciones finales
# ──────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    ✅ PROYECTO CREADO                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Próximos pasos:"
echo ""
echo "  1. cd $TARGET_DIR"
echo ""
if [ "$INIT_GIT" = true ]; then
  echo "  2. Editar AGENTS.md y verificar el nombre del proyecto."
else
  echo "  2. Inicializar Git: git init && git add . && git commit -m 'chore: initial setup'"
  echo "  3. Editar AGENTS.md y verificar el nombre del proyecto."
fi
echo ""
echo "  4. Instalar herramientas de seguridad:"
echo "     ./setup.sh --install-tools"
echo ""
echo "  5. Generar la documentación fundacional:"
echo "     Revisar docs/prompts/README.md y seguir los 8 prompts secuenciales."
echo ""
echo "  6. Configurar secrets en GitHub:"
echo "     - CODECOV_TOKEN (para cobertura)"
echo "     - SSH_HOST, SSH_USER, SSH_KEY (si usas deploy.yml)"
echo ""
log_ok "Listo para empezar."