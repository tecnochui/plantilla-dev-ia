#!/usr/bin/env bash
# init-project.sh — Crea un proyecto nuevo desde la plantilla plantilla-dev-ia.
#
# Uso:
#   ./scripts/init-project.sh <nombre> [opciones]
#
# Opciones:
#   --path <ruta>            Directorio donde crear el proyecto (default: .)
#   --language <es|en>       Idioma del proyecto (default: es)
#   --with-other-language    Incluye también la documentación del otro idioma
#   --git                    Inicializar repositorio Git (default: true)
#   --no-git                 No inicializar Git
#   --private                Crear repo privado en GitHub (requiere gh CLI)
#   --public                 Crear repo público en GitHub (requiere gh CLI)
#   --template <ruta>        Usar una plantilla alternativa (default: template/)
#   --yes, -y                Auto-confirmar sin prompt (útil en CI)
#   --help                   Mostrar esta ayuda
#
# Ejemplos:
#   ./scripts/init-project.sh mi-app
#   ./scripts/init-project.sh mi-app --language en
#   ./scripts/init-project.sh mi-app --language en --with-other-language
#   ./scripts/init-project.sh mi-app --language es --path ~/proyectos --private
#   ./scripts/init-project.sh mi-app --language en --yes   # CI

set -euo pipefail

# ──────────────────────────────────────────────
# Valores por defecto
# ──────────────────────────────────────────────
PROJECT_NAME=""
PROJECT_PATH="."
PROJECT_LANGUAGE="es"
WITH_OTHER_LANGUAGE=false
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
# Función de mensajes bilingües
# UI_LANG controla el idioma de la interfaz. Se fija tras parsear argumentos
# y se puede actualizar tras la pregunta interactiva.
# ──────────────────────────────────────────────
UI_LANG="es"

msg() {
  local key="$1"
  local a1="${2:-}"
  local a2="${3:-}"
  local a3="${4:-}"
  case "$UI_LANG:$key" in
    # Banner / summary
    es:title)                echo "Crear nuevo proyecto" ;;
    en:title)                echo "Create new project" ;;
    es:label_name)           echo "Nombre:" ;;
    en:label_name)           echo "Name:" ;;
    es:label_dest)           echo "Destino:" ;;
    en:label_dest)           echo "Destination:" ;;
    es:label_template)       echo "Plantilla:" ;;
    en:label_template)       echo "Template:" ;;
    es:label_lang)           echo "Idioma:" ;;
    en:label_lang)           echo "Language:" ;;
    es:label_other_lang)     echo "Idioma secundario:" ;;
    en:label_other_lang)     echo "Secondary language:" ;;
    es:label_git)            echo "Git:" ;;
    en:label_git)            echo "Git:" ;;
    es:label_create_repo)    echo "Crear repo:" ;;
    en:label_create_repo)    echo "Create repo:" ;;
    es:yes)                  echo "sí" ;;
    en:yes)                  echo "yes" ;;
    es:no)                   echo "no" ;;
    en:no)                   echo "no" ;;
    es:confirm)              echo "¿Continuar? [y/N]" ;;
    en:confirm)              echo "Continue? [y/N]" ;;

    # Interactive config
    es:config_header)        echo "Configuración del proyecto" ;;
    en:config_header)        echo "Project configuration" ;;
    es:ask_language)         echo "Idioma del proyecto / Project language [es/en] (default: es): " ;;
    en:ask_language)         echo "Idioma del proyecto / Project language [es/en] (default: es): " ;;
    es:ask_other_lang)       echo "¿Incluir también la documentación en '$a1'? / Include '$a1' docs too? [y/N]: " ;;
    en:ask_other_lang)       echo "¿Incluir también la documentación en '$a1'? / Include '$a1' docs too? [y/N]: " ;;
    es:invalid_lang)         echo "Idioma inválido '$a1'. Usando 'es'." ;;
    en:invalid_lang)         echo "Invalid language '$a1'. Using 'es'." ;;
    es:cancelled)            echo "Cancelado." ;;
    en:cancelled)            echo "Cancelled." ;;
    es:auto_confirmed)       echo "Auto-confirmado (--yes)." ;;
    en:auto_confirmed)       echo "Auto-confirmed (--yes)." ;;
    en:auto_confirmed)       echo "Auto-confirmed (--yes)." ;;
    es:no_tty)               echo "No hay TTY disponible. Auto-confirmando." ;;
    en:no_tty)               echo "No TTY available. Auto-confirming." ;;

    # Process
    es:copying_template)     echo "Copiando template..." ;;
    en:copying_template)     echo "Copying template..." ;;
    es:copying_placeholders) echo "Copiando placeholders en '$a1'..." ;;
    en:copying_placeholders) echo "Copying placeholders in '$a1'..." ;;
    es:placeholders_copied)  echo "Placeholders copiados." ;;
    en:placeholders_copied)  echo "Placeholders copied." ;;
    es:placeholders_notfound) echo "No se encontraron placeholders en: $a1" ;;
    en:placeholders_notfound) echo "Placeholders not found at: $a1" ;;
    es:copying_reference)    echo "Copiando documentación de referencia..." ;;
    en:copying_reference)    echo "Copying reference documentation..." ;;
    es:copied_file)          echo "Copiado: docs/$a1" ;;
    en:copied_file)          echo "Copied: docs/$a1" ;;
    es:not_found_file)       echo "No encontrado: $a1" ;;
    en:not_found_file)       echo "Not found: $a1" ;;
    es:copying_prompts)      echo "Copiando prompts de documentación..." ;;
    en:copying_prompts)      echo "Copying documentation prompts..." ;;
    es:prompts_copied)       echo "Prompts copiados: $a1 archivos." ;;
    en:prompts_copied)       echo "Prompts copied: $a1 files." ;;
    es:prompts_notfound)     echo "No se encontraron prompts en: $a1" ;;
    en:prompts_notfound)     echo "Prompts not found at: $a1" ;;
    es:copying_other)        echo "Copiando documentación en '$a1'..." ;;
    en:copying_other)        echo "Copying documentation in '$a1'..." ;;
    es:other_copied)         echo "Copiados $a1 archivos en 'docs/$a2/'." ;;
    en:other_copied)         echo "Copied $a1 files in 'docs/$a2/'." ;;
    es:creating_dirs)        echo "Creando directorios del proyecto..." ;;
    en:creating_dirs)        echo "Creating project directories..." ;;
    es:dirs_created)         echo "Directorios creados: src, tests, scripts, config" ;;
    en:dirs_created)         echo "Directories created: src, tests, scripts, config" ;;
    es:cleaning_links)       echo "Limpiando enlaces cruzados de los docs..." ;;
    en:cleaning_links)       echo "Cleaning cross-links from docs..." ;;
    es:links_cleaned)        echo "Enlaces cruzados eliminados." ;;
    en:links_cleaned)        echo "Cross-links removed." ;;
    es:saving_lang)          echo "Idioma del proyecto guardado en .project-language: $a1" ;;
    en:saving_lang)          echo "Project language saved in .project-language: $a1" ;;
    es:replacing_placeholders) echo "Reemplazando placeholders..." ;;
    en:replacing_placeholders) echo "Replacing placeholders..." ;;
    es:placeholders_replaced) echo "Placeholders reemplazados." ;;
    en:placeholders_replaced) echo "Placeholders replaced." ;;
    es:initing_git)          echo "Inicializando repositorio Git..." ;;
    en:initing_git)          echo "Initializing Git repository..." ;;
    es:git_inited)           echo "Repositorio Git inicializado con commit inicial." ;;
    en:git_inited)           echo "Git repository initialized with initial commit." ;;
    es:creating_github)      echo "Creando repositorio en GitHub..." ;;
    en:creating_github)      echo "Creating GitHub repository..." ;;
    es:github_created)       echo "Repositorio creado en GitHub." ;;
    en:github_created)       echo "GitHub repository created." ;;
    es:gh_missing)           echo "gh CLI no está instalado. No se puede crear el repo en GitHub." ;;
    en:gh_missing)           echo "gh CLI is not installed. Cannot create the GitHub repo." ;;
    es:gh_install_hint)      echo "Instálalo: https://cli.github.com/" ;;
    en:gh_install_hint)      echo "Install it: https://cli.github.com/" ;;

    # Final
    es:project_created)      echo "PROYECTO CREADO" ;;
    en:project_created)      echo "PROJECT CREATED" ;;
    es:next_steps)           echo "Próximos pasos:" ;;
    en:next_steps)           echo "Next steps:" ;;
    es:step_cd)              echo "cd $a1" ;;
    en:step_cd)              echo "cd $a1" ;;
    es:step_edit_agents)     echo "Editar AGENTS.md y verificar el nombre del proyecto." ;;
    en:step_edit_agents)     echo "Edit AGENTS.md and verify the project name." ;;
    es:step_init_git)        echo "Inicializar Git: git init && git add . && git commit -m 'chore: initial setup'" ;;
    en:step_init_git)        echo "Initialize Git: git init && git add . && git commit -m 'chore: initial setup'" ;;
    es:step_install_tools)   echo "Instalar herramientas de seguridad:" ;;
    en:step_install_tools)   echo "Install security tools:" ;;
    es:step_add_lang)        echo "Añadir documentación en '$a1' (opcional):" ;;
    en:step_add_lang)        echo "Add documentation in '$a1' (optional):" ;;
    es:step_gen_docs)        echo "Generar la documentación fundacional:" ;;
    en:step_gen_docs)        echo "Generate the foundational documentation:" ;;
    es:step_gen_docs_detail) echo "Revisar docs/prompts/README.md y seguir los 8 prompts secuenciales." ;;
    en:step_gen_docs_detail) echo "Review docs/prompts/README.md and follow the 8 sequential prompts." ;;
    es:step_secrets)         echo "Configurar secrets en GitHub:" ;;
    en:step_secrets)         echo "Configure GitHub secrets:" ;;
    es:step_secrets_detail)  echo "- CODECOV_TOKEN (para cobertura)" ;;
    en:step_secrets_detail)  echo "- CODECOV_TOKEN (for coverage)" ;;
    es:step_secrets_detail2) echo "- SSH_HOST, SSH_USER, SSH_KEY (si usas deploy.yml)" ;;
    en:step_secrets_detail2) echo "- SSH_HOST, SSH_USER, SSH_KEY (if you use deploy.yml)" ;;
    es:ready)                echo "Listo para empezar." ;;
    en:ready)                echo "Ready to start." ;;

    # Errors
    es:missing_name)         echo "Falta el nombre del proyecto." ;;
    en:missing_name)         echo "Missing project name." ;;
    es:usage)                echo "Uso: $0 <nombre> [opciones]" ;;
    en:usage)                echo "Usage: $0 <name> [options]" ;;
    es:invalid_lang_flag)    echo "El idioma debe ser 'es' o 'en'. Recibido: '$a1'" ;;
    en:invalid_lang_flag)    echo "Language must be 'es' or 'en'. Received: '$a1'" ;;
    es:template_notfound)    echo "No se encontró la plantilla en: $a1" ;;
    en:template_notfound)    echo "Template not found at: $a1" ;;
    es:dir_exists)           echo "El directorio '$a1' ya existe." ;;
    en:dir_exists)           echo "Directory '$a1' already exists." ;;
    es:unknown_arg)          echo "Argumento desconocido: $a1" ;;
    en:unknown_arg)          echo "Unknown argument: $a1" ;;

    *) echo "$key" ;;
  esac
}

# ──────────────────────────────────────────────
# Help bilingüe (independiente de UI_LANG porque aún no se conoce)
# ──────────────────────────────────────────────
show_help() {
  cat <<'EOF'
Uso / Usage: ./scripts/init-project.sh <nombre> [opciones]

Opciones:
  --path <ruta>            Directorio donde crear el proyecto (default: .)
  --language <es|en>       Idioma del proyecto (default: es)
  --with-other-language    Incluye también la documentación del otro idioma
  --git                    Inicializar repositorio Git (default: true)
  --no-git                 No inicializar Git
  --private                Crear repo privado en GitHub (requiere gh CLI)
  --public                 Crear repo público en GitHub (requiere gh CLI)
  --template <ruta>        Usar plantilla alternativa (default: template/)
  --yes, -y                Auto-confirmar sin prompt (útil en CI)
  --help                   Mostrar esta ayuda

Options:
  --path <path>            Directory where the project will be created (default: .)
  --language <es|en>       Project language (default: es)
  --with-other-language    Include the other language's documentation too
  --git                    Initialize Git repository (default: true)
  --no-git                 Do not initialize Git
  --private                Create private GitHub repo (requires gh CLI)
  --public                 Create public GitHub repo (requires gh CLI)
  --template <path>        Use an alternative template (default: template/)
  --yes, -y                Auto-confirm without prompt (useful in CI)
  --help                   Show this help

Ejemplos / Examples:
  ./scripts/init-project.sh mi-app
  ./scripts/init-project.sh mi-app --language en
  ./scripts/init-project.sh mi-app --language en --with-other-language
  ./scripts/init-project.sh mi-app --language es --path ~/proyectos --private
  ./scripts/init-project.sh mi-app --language en --yes
EOF
}

# ──────────────────────────────────────────────
# Parsear argumentos
# ──────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --path)
      PROJECT_PATH="$2"
      shift 2
      ;;
    --language)
      PROJECT_LANGUAGE="$2"
      shift 2
      ;;
    --with-other-language)
      WITH_OTHER_LANGUAGE=true
      shift
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
      show_help
      exit 0
      ;;
    *)
      if [ -z "$PROJECT_NAME" ]; then
        PROJECT_NAME="$1"
      else
        UI_LANG="$PROJECT_LANGUAGE"
        log_error "$(msg unknown_arg "$1")"
        exit 1
      fi
      shift
      ;;
  esac
done

# Después de parsear, sabemos el idioma de la interfaz (por defecto el del proyecto)
UI_LANG="$PROJECT_LANGUAGE"

# ──────────────────────────────────────────────
# Validaciones
# ──────────────────────────────────────────────
if [ -z "$PROJECT_NAME" ]; then
  log_error "$(msg missing_name)"
  echo "$(msg usage)"
  exit 1
fi

if [ "$PROJECT_LANGUAGE" != "es" ] && [ "$PROJECT_LANGUAGE" != "en" ]; then
  log_error "$(msg invalid_lang_flag "$PROJECT_LANGUAGE")"
  exit 1
fi

if [ -z "$TEMPLATE_DIR" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  TEMPLATE_DIR="$SCRIPT_DIR/template"
  REPO_DOCS="$SCRIPT_DIR/docs"
else
  REPO_DOCS="$(cd "$TEMPLATE_DIR/.." && pwd)/docs"
fi

if [ ! -d "$TEMPLATE_DIR" ]; then
  log_error "$(msg template_notfound "$TEMPLATE_DIR")"
  exit 1
fi

TARGET_DIR="$PROJECT_PATH/$PROJECT_NAME"

if [ -d "$TARGET_DIR" ]; then
  log_error "$(msg dir_exists "$TARGET_DIR")"
  exit 1
fi

# ──────────────────────────────────────────────
# Preguntas interactivas (si no es --yes)
# ──────────────────────────────────────────────
if [ "$AUTO_CONFIRM" = false ] && [ -t 0 ]; then
  echo ""
  echo "───────────────────────────────────────────────"
  echo " $(msg config_header)"
  echo "───────────────────────────────────────────────"
  echo ""

  # 1. Idioma (bilingüe porque aún no sabemos la preferencia)
  read -r -p "$(msg ask_language)" lang_input
  lang_input="${lang_input:-es}"
  lang_input=$(echo "$lang_input" | tr '[:upper:]' '[:lower:]')
  if [ "$lang_input" = "es" ] || [ "$lang_input" = "en" ]; then
    PROJECT_LANGUAGE="$lang_input"
  else
    PROJECT_LANGUAGE="es"
    log_warn "$(msg invalid_lang "$lang_input")"
  fi

  # Actualizar UI_LANG con la elección
  UI_LANG="$PROJECT_LANGUAGE"

  # 2. ¿Incluir el otro idioma?
  other_lang=$([ "$PROJECT_LANGUAGE" = "es" ] && echo "en" || echo "es")
  read -r -p "$(msg ask_other_lang "$other_lang")" include_input
  case "$include_input" in
    [yY][eE][sS]|[yY]) WITH_OTHER_LANGUAGE=true ;;
    *) WITH_OTHER_LANGUAGE=false ;;
  esac

  echo ""
fi

# ──────────────────────────────────────────────
# Confirmación
# ──────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════╗"
TITLE=$(msg title)
printf "║  %-42s  ║\n" "$TITLE"
echo "╚══════════════════════════════════════════════╝"
echo ""
printf "  %-20s %s\n" "$(msg label_name)"          "$PROJECT_NAME"
printf "  %-20s %s\n" "$(msg label_dest)"          "$TARGET_DIR"
printf "  %-20s %s\n" "$(msg label_template)"      "$TEMPLATE_DIR"
printf "  %-20s %s\n" "$(msg label_lang)"          "$PROJECT_LANGUAGE"
OTHER_LABEL=$([ "$WITH_OTHER_LANGUAGE" = true ] && echo "$(msg yes)" || echo "$(msg no)")
printf "  %-20s %s\n" "$(msg label_other_lang)"    "$OTHER_LABEL"
printf "  %-20s %s\n" "$(msg label_git)"           "$INIT_GIT"
printf "  %-20s %s\n" "$(msg label_create_repo)"   "$CREATE_REPO"
echo ""

if [ "$AUTO_CONFIRM" = true ]; then
  log_info "$(msg auto_confirmed)"
elif [ ! -t 0 ]; then
  log_warn "$(msg no_tty)"
else
  read -r -p "$(msg confirm) " response
  case "$response" in
    [yY][eE][sS]|[yY]) ;;
    *) log_info "$(msg cancelled)"; exit 0 ;;
  esac
fi

# ──────────────────────────────────────────────
# 1. Copiar template completo
# ──────────────────────────────────────────────
log_info "$(msg copying_template)"
mkdir -p "$TARGET_DIR"
cp -r "$TEMPLATE_DIR"/. "$TARGET_DIR"/

# ──────────────────────────────────────────────
# 2. Limpiar placeholders bilingües del template
# ──────────────────────────────────────────────
if [ -d "$TARGET_DIR/docs/es" ]; then
  rm -rf "$TARGET_DIR/docs/es"
fi
if [ -d "$TARGET_DIR/docs/en" ]; then
  rm -rf "$TARGET_DIR/docs/en"
fi

# ──────────────────────────────────────────────
# 3. Copiar placeholders del idioma elegido
# ──────────────────────────────────────────────
PLACEHOLDER_SOURCE="$TEMPLATE_DIR/docs/$PROJECT_LANGUAGE"
if [ -d "$PLACEHOLDER_SOURCE" ]; then
  log_info "$(msg copying_placeholders "$PROJECT_LANGUAGE")"
  for file in "$PLACEHOLDER_SOURCE"/*.md; do
    [ -f "$file" ] || continue
    cp "$file" "$TARGET_DIR/docs/"
  done
  log_ok "$(msg placeholders_copied)"
else
  log_warn "$(msg placeholders_notfound "$PLACEHOLDER_SOURCE")"
fi

# ──────────────────────────────────────────────
# 4. Copiar docs de referencia del repo
# ──────────────────────────────────────────────
log_info "$(msg copying_reference)"

if [ "$PROJECT_LANGUAGE" = "en" ]; then
  REFERENCE_DOCS=("WORKFLOWS.md" "SECURITY_TOOLS.md" "GITHUB_SECRETS.md")
else
  REFERENCE_DOCS=("WORKFLOWS.md" "HERRAMIENTAS_SEGURIDAD.md" "GITHUB_SECRETS.md")
fi

for doc in "${REFERENCE_DOCS[@]}"; do
  src="$REPO_DOCS/$PROJECT_LANGUAGE/$doc"
  if [ -f "$src" ]; then
    cp "$src" "$TARGET_DIR/docs/$doc"
    log_ok "$(msg copied_file "$doc")"
  else
    log_warn "$(msg not_found_file "$src")"
  fi
done

# ──────────────────────────────────────────────
# 5. Copiar prompts del idioma elegido
# ──────────────────────────────────────────────
PROMPTS_SOURCE="$REPO_DOCS/$PROJECT_LANGUAGE/prompts"
PROMPTS_TARGET="$TARGET_DIR/docs/prompts"

if [ -d "$PROMPTS_SOURCE" ]; then
  log_info "$(msg copying_prompts)"
  mkdir -p "$PROMPTS_TARGET"
  cp "$PROMPTS_SOURCE"/*.md "$PROMPTS_TARGET/"
  PROMPTS_COUNT=$(find "$PROMPTS_TARGET" -maxdepth 1 -type f -name "*.md" | wc -l)
  log_ok "$(msg prompts_copied "$PROMPTS_COUNT")"
else
  log_warn "$(msg prompts_notfound "$PROMPTS_SOURCE")"
fi

# ──────────────────────────────────────────────
# 6. Copiar el otro idioma si se pidió
# ──────────────────────────────────────────────
if [ "$WITH_OTHER_LANGUAGE" = true ]; then
  OTHER_LANG=$([ "$PROJECT_LANGUAGE" = "es" ] && echo "en" || echo "es")
  log_info "$(msg copying_other "$OTHER_LANG")"

  OTHER_TARGET="$TARGET_DIR/docs/$OTHER_LANG"
  mkdir -p "$OTHER_TARGET"

  OTHER_PLACEHOLDER_SOURCE="$TEMPLATE_DIR/docs/$OTHER_LANG"
  if [ -d "$OTHER_PLACEHOLDER_SOURCE" ]; then
    for file in "$OTHER_PLACEHOLDER_SOURCE"/*.md; do
      [ -f "$file" ] || continue
      cp "$file" "$OTHER_TARGET/"
    done
  fi

  OTHER_REFERENCE_SOURCE="$REPO_DOCS/$OTHER_LANG"
  if [ -d "$OTHER_REFERENCE_SOURCE" ]; then
    for file in "$OTHER_REFERENCE_SOURCE"/*.md; do
      [ -f "$file" ] || continue
      cp "$file" "$OTHER_TARGET/"
    done
  fi

  OTHER_PROMPTS_SOURCE="$REPO_DOCS/$OTHER_LANG/prompts"
  if [ -d "$OTHER_PROMPTS_SOURCE" ]; then
    mkdir -p "$OTHER_TARGET/prompts"
    for file in "$OTHER_PROMPTS_SOURCE"/*.md; do
      [ -f "$file" ] || continue
      cp "$file" "$OTHER_TARGET/prompts/"
    done
  fi

  OTHER_COUNT=$(find "$OTHER_TARGET" -type f -name "*.md" | wc -l)
  log_ok "$(msg other_copied "$OTHER_COUNT" "$OTHER_LANG")"
fi

# ──────────────────────────────────────────────
# 7. Crear directorios vacíos del proyecto
# ──────────────────────────────────────────────
log_info "$(msg creating_dirs)"

EMPTY_DIRS=("src" "tests" "scripts" "config")
for dir in "${EMPTY_DIRS[@]}"; do
  mkdir -p "$TARGET_DIR/$dir"
  touch "$TARGET_DIR/$dir/.gitkeep"
done
log_ok "$(msg dirs_created)"

# ──────────────────────────────────────────────
# 8. Eliminar enlaces cruzados de los docs copiados
# ──────────────────────────────────────────────
log_info "$(msg cleaning_links)"
find "$TARGET_DIR/docs" -type f -name "*.md" -exec \
  sed -i '/Lee esto en:/d;/Read this in:/d' {} \;
find "$TARGET_DIR/docs" -type f -name "*.md" -exec \
  sed -i '/^$/N;/^\n$/D' {} \;
log_ok "$(msg links_cleaned)"

# ──────────────────────────────────────────────
# 9. Escribir .project-language
# ──────────────────────────────────────────────
echo "$PROJECT_LANGUAGE" > "$TARGET_DIR/.project-language"
log_ok "$(msg saving_lang "$PROJECT_LANGUAGE")"

# ──────────────────────────────────────────────
# 10. Reemplazar placeholders
# ──────────────────────────────────────────────
log_info "$(msg replacing_placeholders)"

find "$TARGET_DIR" -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.toml" -o -name "*.sh" \) \
  -exec sed -i "s/\[NOMBRE DEL PROYECTO\]/$PROJECT_NAME/g" {} \;

find "$TARGET_DIR" -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.toml" -o -name "*.sh" \) \
  -exec sed -i "s/\[PROJECT NAME\]/$PROJECT_NAME/g" {} \;

log_ok "$(msg placeholders_replaced)"

# ──────────────────────────────────────────────
# 11. Inicializar Git
# ──────────────────────────────────────────────
if [ "$INIT_GIT" = true ]; then
  log_info "$(msg initing_git)"
  cd "$TARGET_DIR"
  git init -q
  git add .
  git commit -q -m "chore: initial setup from plantilla-dev-ia"
  log_ok "$(msg git_inited)"
else
  cd "$TARGET_DIR"
fi

# ──────────────────────────────────────────────
# 12. Crear repositorio en GitHub (opcional)
# ──────────────────────────────────────────────
if [ "$CREATE_REPO" = true ]; then
  if ! command -v gh >/dev/null 2>&1; then
    log_warn "$(msg gh_missing)"
    log_warn "$(msg gh_install_hint)"
  else
    log_info "$(msg creating_github)"
    gh repo create "$PROJECT_NAME" $REPO_VISIBILITY --source=. --push
    log_ok "$(msg github_created)"
  fi
fi

# ──────────────────────────────────────────────
# 13. Instrucciones finales
# ──────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
DONE=$(msg project_created)
printf "║  ✅ %-56s  ║\n" "$DONE"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 $(msg next_steps)"
echo ""
echo "  1. $(msg step_cd "$TARGET_DIR")"
echo ""
if [ "$INIT_GIT" = true ]; then
  echo "  2. $(msg step_edit_agents)"
else
  echo "  2. $(msg step_init_git)"
  echo "  3. $(msg step_edit_agents)"
fi
echo ""
echo "  4. $(msg step_install_tools)"
echo "     ./setup.sh --install-tools"
echo ""
if [ "$WITH_OTHER_LANGUAGE" = false ]; then
  OTHER_LANG=$([ "$PROJECT_LANGUAGE" = "es" ] && echo "en" || echo "es")
  echo "  5. $(msg step_add_lang "$OTHER_LANG")"
  echo "     ./setup.sh --add-language $OTHER_LANG"
  echo ""
fi
echo "  6. $(msg step_gen_docs)"
echo "     $(msg step_gen_docs_detail)"
echo ""
echo "  7. $(msg step_secrets)"
echo "     $(msg step_secrets_detail)"
echo "     $(msg step_secrets_detail2)"
echo ""

log_ok "$(msg ready)"