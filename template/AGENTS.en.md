# AGENTS.md

## Project context
This repository contains [PROJECT NAME].

Before any task, read these files in order:
1. `docs/PRD-SRD.md` — what is being built and for whom
2. `docs/SRS.md` — functional and non-functional requirements
3. `docs/SSD-TDD.md` — architecture, database and technical design
4. `docs/Test_Plan.md` — testing strategy and merge criteria
5. `docs/FORENSIC_RECORD.md` — (if present) reverse engineering findings
6. `CHANGELOG.md` — recent changes

If `docs/FORENSIC_RECORD.md` exists, READ IT IN FULL before modifying any file.
If you discover something new about the system, update that file with date and finding.

## Essential commands
### Via Makefile (recommended)
- `make help` → shows all available tasks
- `make setup` → installs security tools
- `make check` → verifies the project structure
- `make test` → runs unit tests
- `make lint` → runs linters
- `make format` → formats the code
- `make security` → SAST + SCA + secrets
- `make sast` / `make sca` / `make secrets` → individual security tasks
- `make changelog` → generates CHANGELOG.md
- `make clean` → cleans temporary artifacts
- `make all` → lint + test + security (before a PR)

### Via direct commands
- Install dependencies (Node): `npm install`
- Install dependencies (Python): `pip install -r requirements.txt`
- Build: `npm run build`
- Test: `npm test` (Node) or `pytest` (Python)
- Lint: `npm run lint` or `ruff check .`
- Format: `npm run format` or `ruff format .`
- SAST: `semgrep --config=p/owasp-top-ten .`
- SCA: `trivy fs --severity CRITICAL,HIGH .`
- Secrets: `gitleaks detect --source . --verbose`

## Code style
- JavaScript/TypeScript: ESLint + Prettier. Do not use `any` in TypeScript.
- Python: Ruff + Mypy. Docstrings in Google format.
- Document public functions with JSDoc (JS/TS) or docstrings (Python).
- Variable names in English; comments may be in Spanish.

## Security rules
- NEVER hardcode secrets, API keys or passwords. Use `.env` (never commit it).
- Every new dependency must be verified with `trivy` and `pip-audit`/`npm audit` before being added.
- User inputs are always validated before being used.
- Do not use `eval()`, `exec()`, `child_process` with non-literal input.
- Do not use `innerHTML` with unsanitized data (use `textContent` or DOMPurify).
- Do not run commands that modify the system without explicit confirmation.
- Before committing, the pre-commit hook runs Gitleaks and security ESLint.

## Commit rules
- Use Conventional Commits: `feat:`, `fix:`, `security:`, `docs:`, `chore:`, `refactor:`, `test:`, `perf:`.
- The `commit-msg` hook validates the format. If it fails, the commit is cancelled.
- Do not update `CHANGELOG.md` manually; it is generated with `git-cliff` in CI.

## PR rules
- Every PR must pass: tests, SAST (Semgrep), SCA (Trivy), secrets (Gitleaks).
- Do not merge if there are unresolved CRITICAL or HIGH findings.
- MEDIUM findings are reviewed case by case.

## Forbidden zones
- Do not modify `.github/workflows/` without explicit confirmation.
- Do not modify `.gitleaks.toml` or `.secrets.baseline` without confirmation.
- Do not touch database migrations without reviewing `docs/SSD-TDD.md`.
- Do not modify `.eslintrc-security.js` to disable rules without documented justification.

## Environment variables
- ALL environment variables must be documented in `.env.example`.
- NEVER commit `.env` with real values.
- If you add a new variable, update `.env.example` in the same commit.
- Secrets are generated with `openssl rand -hex 32` or similar.
- For tests, use the `TEST_*` variables (never the production ones).

## Project tools
- **IDE:** VS Code + Zoo Code (modes: Architect, Code, Debug)
- **Models via OpenRouter:** DeepSeek V4 Flash (code), Qwen3 Coder Next (debugging)
- **Models via free web:** Gemini/DeepSeek (documentation), Claude (one-off critical design)
- **CI/CD:** GitHub Actions (workflows split by domain)
- **Security:** Semgrep, Trivy, Gitleaks, detect-secrets, Bandit, OWASP ZAP
- **Changelog:** git-cliff + Conventional Commits

## Project conventions
- Code language: English.
- Documentation language: English.
- Commit language: English (Conventional Commits).
- Docs structure: `docs/PRD-SRD.md`, `docs/SRS.md`, `docs/SSD-TDD.md`, `docs/FORENSIC_RECORD.md`.
- Code structure: `src/` (code), `tests/` (tests), `scripts/` (utilities), `config/` (configuration).

## Documentation prompts
The prompts to generate each document are in `docs/prompts/`.
- `README.md` — index and usage guide
- `01-PRD-SRD.md` — Prompt 1
- `02-SRS.md` — Prompt 2
- `03-Technical-Proposal.md` — Prompt 3
- `04-SSD-TDD.md` — Prompt 4
- `05-NIST-OWASP-Mapping.md` — Prompt 5
- `06-Backup-Strategy.md` — Prompt 6
- `07-Test-Plan.md` — Prompt 7
- `08-Forensic-Record.md` — Prompt 8

If you need to regenerate a document, use the corresponding prompt with the model recommended in the README.