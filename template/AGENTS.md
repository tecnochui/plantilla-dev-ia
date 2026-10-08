# AGENTS.md

## Contexto del proyecto
Este repositorio contiene [NOMBRE DEL PROYECTO].

Antes de cualquier tarea, lee estos archivos en orden:
1. `docs/PRD-SRD.md` — qué se construye y para quién
2. `docs/SRS.md` — requisitos funcionales y no funcionales
3. `docs/SSD-TDD.md` — arquitectura, base de datos y diseño técnico
4. `docs/Plan_Pruebas.md` — estrategia de testing y criterios de merge
5. `docs/REGISTRO_FORENSE.md` — (si existe) descubrimientos de ingeniería inversa
6. `CHANGELOG.md` — cambios recientes

Si `docs/REGISTRO_FORENSE.md` existe, LÉELO COMPLETO antes de modificar cualquier archivo.
Si descubres algo nuevo sobre el sistema, actualiza ese archivo con fecha y hallazgo.

## Comandos esenciales
### Vía Makefile (recomendado)
- `make help` → muestra todas las tareas disponibles
- `make setup` → instala herramientas de seguridad
- `make check` → verifica estructura del proyecto
- `make test` → ejecuta tests unitarios
- `make lint` → ejecuta linters
- `make format` → formatea el código
- `make security` → SAST + SCA + secrets
- `make sast` / `make sca` / `make secrets` → tareas de seguridad individuales
- `make changelog` → genera CHANGELOG.md
- `make clean` → limpia artefactos temporales
- `make all` → lint + test + security (antes de un PR)

### Vía comandos directos
- Instalar dependencias (Node): `npm install`
- Instalar dependencias (Python): `pip install -r requirements.txt`
- Build: `npm run build`
- Test: `npm test` (Node) o `pytest` (Python)
- Lint: `npm run lint` o `ruff check .`
- Formato: `npm run format` o `ruff format .`
- SAST: `semgrep --config=p/owasp-top-ten .`
- SCA: `trivy fs --severity CRITICAL,HIGH .`
- Secretos: `gitleaks detect --source . --verbose`

## Estilo de código
- JavaScript/TypeScript: ESLint + Prettier. No usar `any` en TypeScript.
- Python: Ruff + Mypy. Docstrings en formato Google.
- Documentar funciones públicas con JSDoc (JS/TS) o docstrings (Python).
- Nombres de variables en inglés; comentarios pueden ser en español.

## Reglas de seguridad
- NUNCA hardcodear secretos, API keys ni contraseñas. Usar `.env` (nunca commitear).
- Toda dependencia nueva debe verificarse con `trivy` y `pip-audit`/`npm audit` antes de añadirla.
- Los inputs de usuario siempre se validan antes de usarse.
- No usar `eval()`, `exec()`, `child_process` con input no literal.
- No usar `innerHTML` con datos no sanitizados (usar `textContent` o DOMPurify).
- No ejecutar comandos que modifiquen el sistema sin confirmación explícita.
- Antes de commitear, el hook pre-commit ejecuta Gitleaks y ESLint de seguridad.

## Reglas de commits
- Usar Conventional Commits: `feat:`, `fix:`, `security:`, `docs:`, `chore:`, `refactor:`, `test:`, `perf:`.
- El hook `commit-msg` valida el formato. Si falla, el commit se cancela.
- No actualizar `CHANGELOG.md` manualmente; se genera con `git-cliff` en CI.

## Reglas de PR
- Cada PR debe pasar: tests, SAST (Semgrep), SCA (Trivy), secrets (Gitleaks).
- No mergear si hay hallazgos CRITICAL o HIGH sin resolver.
- Los hallazgos MEDIUM se revisan caso por caso.

## Zonas prohibidas
- No modificar `.github/workflows/` sin confirmación explícita.
- No modificar `.gitleaks.toml` ni `.secrets.baseline` sin confirmación.
- No tocar migraciones de base de datos sin revisar `docs/SSD-TDD.md`.
- No modificar `.eslintrc-security.js` para desactivar reglas sin justificación documentada.

## Variables de entorno
- TODAS las variables de entorno deben estar documentadas en `.env.example`.
- NUNCA commitear `.env` con valores reales.
- Si añades una variable nueva, actualiza `.env.example` en el mismo commit.
- Los secretos se generan con `openssl rand -hex 32` o similar.
- Para tests, usa las variables `TEST_*` (nunca las de producción).

## Herramientas del proyecto
- **IDE:** VS Code + Zoo Code (modos: Architect, Code, Debug)
- **Modelos vía OpenRouter:** DeepSeek V4 Flash (código), Qwen3 Coder Next (depuración)
- **Modelos vía web gratuita:** Gemini/DeepSeek (documentación), Claude (diseño crítico puntual)
- **CI/CD:** GitHub Actions (workflows divididos por dominio)
- **Seguridad:** Semgrep, Trivy, Gitleaks, detect-secrets, Bandit, OWASP ZAP
- **Changelog:** git-cliff + Conventional Commits

## Convenciones del proyecto
- Idioma del código: inglés.
- Idioma de documentación: español.
- Idioma de commits: inglés (Conventional Commits).
- Estructura de docs: `docs/PRD-SRD.md`, `docs/SRS.md`, `docs/SSD-TDD.md`, `docs/REGISTRO_FORENSE.md`.
- Estructura de código: `src/` (código), `tests/` (tests), `scripts/` (utilidades), `config/` (configuración).

## Prompts de documentación
Los prompts para generar cada documento están en `docs/prompts/`.
- `README.md` — índice y guía de uso
- `01-PRD-SRD.md` — Prompt 1
- `02-SRS.md` — Prompt 2
- `03-Propuesta-Tecnica.md` — Prompt 3
- `04-SSD-TDD.md` — Prompt 4
- `05-Mapeo-NIST-OWASP.md` — Prompt 5
- `06-Estrategia-Respaldos.md` — Prompt 6
- `07-Plan-Pruebas.md` — Prompt 7
- `08-Registro-Forense.md` — Prompt 8

Si necesitas regenerar un documento, usa el prompt correspondiente con el modelo recomendado en el README.