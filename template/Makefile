# ──────────────────────────────────────────────
# Makefile — Common project tasks / Tareas comunes del proyecto
# ──────────────────────────────────────────────
# Uso / Usage:
#   make              → shows help / muestra ayuda
#   make help         → shows help / muestra ayuda
#   make setup        → installs security tools / instala herramientas
#   make test         → runs tests / ejecuta tests
#   make security     → runs full security analysis / análisis completo
# ──────────────────────────────────────────────

# Use bash instead of sh (dash does not support echo -e)
SHELL := /bin/bash

# Detect project language from .project-language
PROJECT_LANG := $(shell cat .project-language 2>/dev/null | tr -d '[:space:]')
ifeq ($(PROJECT_LANG),)
PROJECT_LANG := es
endif

# Colors
GREEN  := \033[0;32m
YELLOW := \033[1;33m
BLUE   := \033[0;34m
RED    := \033[0;31m
NC     := \033[0m

# Detect stack
HAS_NODE   := $(shell [ -f package.json ] && echo yes || echo no)
HAS_PYTHON := $(shell [ -f requirements.txt ] || [ -f pyproject.toml ] && echo yes || echo no)

# ──────────────────────────────────────────────
# Bilingual message strings
# ──────────────────────────────────────────────
ifeq ($(PROJECT_LANG),en)
  MSG_TASKS_TITLE  := Available tasks
  MSG_STACK        := Detected stack:
  MSG_RUNNING      := Running
  MSG_VERIFYING    := Verifying structure
  MSG_TESTING      := Running tests
  MSG_LINTING      := Running linters
  MSG_FORMATTING   := Formatting code
  MSG_SAST         := Running SAST (Semgrep)
  MSG_SCA          := Running SCA (Trivy)
  MSG_SECRETS      := Running secret detection
  MSG_SECURITY_OK  := Security analysis completed
  MSG_CHANGELOG    := Generating changelog
  MSG_CHANGELOG_OK := CHANGELOG.md updated
  MSG_CLEANING     := Cleaning artifacts
  MSG_CLEAN_OK     := Cleanup completed
  MSG_ALL_OK       := All ready for commit
  MSG_NOT_INSTALLED := not installed. Run
  MSG_ONLY_NODE    := test-watch only applies to Node.js projects
else
  MSG_TASKS_TITLE  := Tareas disponibles
  MSG_STACK        := Stack detectado:
  MSG_RUNNING      := Ejecutando
  MSG_VERIFYING    := Verificando estructura
  MSG_TESTING      := Ejecutando tests
  MSG_LINTING      := Ejecutando linters
  MSG_FORMATTING   := Formateando código
  MSG_SAST         := Ejecutando SAST (Semgrep)
  MSG_SCA          := Ejecutando SCA (Trivy)
  MSG_SECRETS      := Ejecutando detección de secretos
  MSG_SECURITY_OK  := Análisis de seguridad completado
  MSG_CHANGELOG    := Generando changelog
  MSG_CHANGELOG_OK := CHANGELOG.md actualizado
  MSG_CLEANING     := Limpiando artefactos
  MSG_CLEAN_OK     := Limpieza completada
  MSG_ALL_OK       := Todo listo para commit
  MSG_NOT_INSTALLED := no está instalado. Ejecuta
  MSG_ONLY_NODE    := test-watch solo aplica a proyectos Node.js
endif

# ──────────────────────────────────────────────
# Default target
# ──────────────────────────────────────────────
.DEFAULT_GOAL := help
.PHONY: help setup check test test-watch lint format security sast sca secrets changelog clean all

# ──────────────────────────────────────────────
# Help
# ──────────────────────────────────────────────
help: ## Shows this help
	@echo ""
	@echo -e "$(BLUE)╔══════════════════════════════════════════════╗$(NC)"
	@printf "$(BLUE)║  %-42s  ║$(NC)\n" "$(MSG_TASKS_TITLE)"
	@echo -e "$(BLUE)╚══════════════════════════════════════════════╝$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "  $(MSG_STACK)"
	@echo "    Node.js: $(HAS_NODE)"
	@echo "    Python:  $(HAS_PYTHON)"
	@echo ""

# ──────────────────────────────────────────────
# Setup
# ──────────────────────────────────────────────
setup: ## Installs security tools and dependencies
	@echo -e "$(BLUE)▶ $(MSG_RUNNING) setup...$(NC)"
	@./setup.sh --install-tools

check: ## Verifies project structure
	@echo -e "$(BLUE)▶ $(MSG_VERIFYING)...$(NC)"
	@./setup.sh --check

# ──────────────────────────────────────────────
# Tests
# ──────────────────────────────────────────────
test: ## Runs unit tests
	@echo -e "$(BLUE)▶ $(MSG_TESTING)...$(NC)"
ifeq ($(HAS_NODE),yes)
	@npm test --if-present
endif
ifeq ($(HAS_PYTHON),yes)
	@pytest --tb=short -v
endif

test-watch: ## Runs tests in watch mode (Node.js only)
ifeq ($(HAS_NODE),yes)
	@npm test -- --watch
else
	@echo -e "$(YELLOW)⚠ $(MSG_ONLY_NODE)$(NC)"
endif

# ──────────────────────────────────────────────
# Code quality
# ──────────────────────────────────────────────
lint: ## Runs linters
	@echo -e "$(BLUE)▶ $(MSG_LINTING)...$(NC)"
ifeq ($(HAS_NODE),yes)
	@npm run lint --if-present || true
endif
ifeq ($(HAS_PYTHON),yes)
	@ruff check . || true
endif

format: ## Formats code
	@echo -e "$(BLUE)▶ $(MSG_FORMATTING)...$(NC)"
ifeq ($(HAS_NODE),yes)
	@npm run format --if-present || npx prettier --write . || true
endif
ifeq ($(HAS_PYTHON),yes)
	@ruff format . || true
endif

# ──────────────────────────────────────────────
# Security
# ──────────────────────────────────────────────
security: sast sca secrets ## Runs full security analysis
	@echo ""
	@echo -e "$(GREEN)✅ $(MSG_SECURITY_OK).$(NC)"

sast: ## Static analysis (Semgrep)
	@echo -e "$(BLUE)▶ $(MSG_SAST)...$(NC)"
	@if command -v semgrep >/dev/null 2>&1; then \
		semgrep --config=p/owasp-top-ten --config=p/security-audit . || true; \
	else \
		echo -e "$(YELLOW)⚠ Semgrep $(MSG_NOT_INSTALLED): make setup$(NC)"; \
	fi

sca: ## Dependency analysis (Trivy)
	@echo -e "$(BLUE)▶ $(MSG_SCA)...$(NC)"
	@if command -v trivy >/dev/null 2>&1; then \
		trivy fs --severity CRITICAL,HIGH . || true; \
	else \
		echo -e "$(YELLOW)⚠ Trivy $(MSG_NOT_INSTALLED): make setup$(NC)"; \
	fi

secrets: ## Secret detection (Gitleaks)
	@echo -e "$(BLUE)▶ $(MSG_SECRETS)...$(NC)"
	@if command -v gitleaks >/dev/null 2>&1; then \
		gitleaks detect --source . --verbose --redact || true; \
	else \
		echo -e "$(YELLOW)⚠ Gitleaks $(MSG_NOT_INSTALLED): make setup$(NC)"; \
	fi
	@if command -v detect-secrets >/dev/null 2>&1; then \
		detect-secrets scan --baseline .secrets.baseline || true; \
	fi

# ──────────────────────────────────────────────
# Changelog
# ──────────────────────────────────────────────
changelog: ## Generates CHANGELOG.md from commits
	@echo -e "$(BLUE)▶ $(MSG_CHANGELOG)...$(NC)"
	@if command -v git-cliff >/dev/null 2>&1; then \
		git-cliff --unreleased -o CHANGELOG.md; \
		echo -e "$(GREEN)✅ $(MSG_CHANGELOG_OK).$(NC)"; \
	else \
		echo -e "$(YELLOW)⚠ git-cliff $(MSG_NOT_INSTALLED): make setup$(NC)"; \
	fi

# ──────────────────────────────────────────────
# Cleanup
# ──────────────────────────────────────────────
clean: ## Cleans temporary artifacts
	@echo -e "$(BLUE)▶ $(MSG_CLEANING)...$(NC)"
	@rm -rf coverage/ htmlcov/ .coverage coverage.xml
	@rm -rf .pytest_cache/ .mypy_cache/ .ruff_cache/
	@rm -rf dist/ build/ out/
	@rm -rf reports/
	@rm -f semgrep.sarif trivy.sarif gitleaks-report.json bandit-report.json zap-report.html
	@echo -e "$(GREEN)✅ $(MSG_CLEAN_OK).$(NC)"

# ──────────────────────────────────────────────
# Shortcut: everything before a PR
# ──────────────────────────────────────────────
all: lint test security ## Runs lint + tests + security
	@echo ""
	@echo -e "$(GREEN)✅ $(MSG_ALL_OK).$(NC)"