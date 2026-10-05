# ──────────────────────────────────────────────
# Makefile — Tareas comunes del proyecto
# ──────────────────────────────────────────────
# Uso:
#   make              → muestra ayuda
#   make help         → muestra ayuda
#   make setup        → instala herramientas de seguridad
#   make test         → ejecuta tests
#   make security     → ejecuta todo el análisis de seguridad
# ──────────────────────────────────────────────

# Usar bash en lugar de sh (dash no soporta echo -e)
SHELL := /bin/bash

# Colores para output
GREEN  := \033[0;32m
YELLOW := \033[1;33m
BLUE   := \033[0;34m
RED    := \033[0;31m
NC     := \033[0m

# Detectar stack
HAS_NODE   := $(shell [ -f package.json ] && echo yes || echo no)
HAS_PYTHON := $(shell [ -f requirements.txt ] || [ -f pyproject.toml ] && echo yes || echo no)

# ──────────────────────────────────────────────
# Tareas por defecto
# ──────────────────────────────────────────────
.DEFAULT_GOAL := help
.PHONY: help setup check test test-watch lint format security sast sca secrets changelog clean all

# ──────────────────────────────────────────────
# Ayuda
# ──────────────────────────────────────────────
help: ## Muestra esta ayuda
	@echo ""
	@echo -e "$(BLUE)╔══════════════════════════════════════════════╗$(NC)"
	@echo -e "$(BLUE)║         Tareas disponibles                   ║$(NC)"
	@echo -e "$(BLUE)╚══════════════════════════════════════════════╝$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "  Stack detectado:"
	@echo "    Node.js: $(HAS_NODE)"
	@echo "    Python:  $(HAS_PYTHON)"
	@echo ""

# ──────────────────────────────────────────────
# Setup
# ──────────────────────────────────────────────
setup: ## Instala herramientas de seguridad y dependencias
	@echo -e "$(BLUE)▶ Ejecutando setup...$(NC)"
	@./setup.sh --install-tools

check: ## Verifica la estructura del proyecto
	@echo -e "$(BLUE)▶ Verificando estructura...$(NC)"
	@./setup.sh --check

# ──────────────────────────────────────────────
# Tests
# ──────────────────────────────────────────────
test: ## Ejecuta tests unitarios
	@echo -e "$(BLUE)▶ Ejecutando tests...$(NC)"
ifeq ($(HAS_NODE),yes)
	@npm test --if-present
endif
ifeq ($(HAS_PYTHON),yes)
	@pytest --tb=short -v
endif

test-watch: ## Ejecuta tests en modo watch (solo Node.js)
ifeq ($(HAS_NODE),yes)
	@npm test -- --watch
else
	@echo -e "$(YELLOW)⚠ test-watch solo aplica a proyectos Node.js$(NC)"
endif

# ──────────────────────────────────────────────
# Calidad de código
# ──────────────────────────────────────────────
lint: ## Ejecuta linters
	@echo -e "$(BLUE)▶ Ejecutando linters...$(NC)"
ifeq ($(HAS_NODE),yes)
	@npm run lint --if-present || true
endif
ifeq ($(HAS_PYTHON),yes)
	@ruff check . || true
endif

format: ## Formatea el código
	@echo -e "$(BLUE)▶ Formateando código...$(NC)"
ifeq ($(HAS_NODE),yes)
	@npm run format --if-present || npx prettier --write . || true
endif
ifeq ($(HAS_PYTHON),yes)
	@ruff format . || true
endif

# ──────────────────────────────────────────────
# Seguridad
# ──────────────────────────────────────────────
security: sast sca secrets ## Ejecuta todo el análisis de seguridad
	@echo ""
	@echo -e "$(GREEN)✅ Análisis de seguridad completado.$(NC)"

sast: ## Análisis estático (Semgrep)
	@echo -e "$(BLUE)▶ Ejecutando SAST (Semgrep)...$(NC)"
	@if command -v semgrep >/dev/null 2>&1; then \
		semgrep --config=p/owasp-top-ten --config=p/security-audit . || true; \
	else \
		echo -e "$(YELLOW)⚠ Semgrep no está instalado. Ejecuta: make setup$(NC)"; \
	fi

sca: ## Análisis de dependencias (Trivy)
	@echo -e "$(BLUE)▶ Ejecutando SCA (Trivy)...$(NC)"
	@if command -v trivy >/dev/null 2>&1; then \
		trivy fs --severity CRITICAL,HIGH . || true; \
	else \
		echo -e "$(YELLOW)⚠ Trivy no está instalado. Ejecuta: make setup$(NC)"; \
	fi

secrets: ## Detección de secretos (Gitleaks)
	@echo -e "$(BLUE)▶ Ejecutando detección de secretos...$(NC)"
	@if command -v gitleaks >/dev/null 2>&1; then \
		gitleaks detect --source . --verbose --redact || true; \
	else \
		echo -e "$(YELLOW)⚠ Gitleaks no está instalado. Ejecuta: make setup$(NC)"; \
	fi
	@if command -v detect-secrets >/dev/null 2>&1; then \
		detect-secrets scan --baseline .secrets.baseline || true; \
	fi

# ──────────────────────────────────────────────
# Changelog
# ──────────────────────────────────────────────
changelog: ## Genera CHANGELOG.md desde commits
	@echo -e "$(BLUE)▶ Generando changelog...$(NC)"
	@if command -v git-cliff >/dev/null 2>&1; then \
		git-cliff --unreleased -o CHANGELOG.md; \
		echo -e "$(GREEN)✅ CHANGELOG.md actualizado.$(NC)"; \
	else \
		echo -e "$(YELLOW)⚠ git-cliff no está instalado. Ejecuta: make setup$(NC)"; \
	fi

# ──────────────────────────────────────────────
# Limpieza
# ──────────────────────────────────────────────
clean: ## Limpia artefactos temporales
	@echo -e "$(BLUE)▶ Limpiando artefactos...$(NC)"
	@rm -rf coverage/ htmlcov/ .coverage coverage.xml
	@rm -rf .pytest_cache/ .mypy_cache/ .ruff_cache/
	@rm -rf dist/ build/ out/
	@rm -rf reports/
	@rm -f semgrep.sarif trivy.sarif gitleaks-report.json bandit-report.json zap-report.html
	@echo -e "$(GREEN)✅ Limpieza completada.$(NC)"

# ──────────────────────────────────────────────
# Atajo: todo lo que se ejecuta antes de un PR
# ──────────────────────────────────────────────
all: lint test security ## Ejecuta lint + tests + seguridad
	@echo ""
	@echo -e "$(GREEN)✅ Todo listo para commit.$(NC)"