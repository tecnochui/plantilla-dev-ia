# Repository Scripts

🌍 **Read this in:** [Español](README.es.md) | [English](README.md)

> Utilities to initialize and manage projects based on `plantilla-dev-ia`.

---

## Index

| Script | Location | Purpose |
|--------|----------|---------|
| [`init-project.sh`](#init-projectsh) | `scripts/` | Creates a new project from the template |
| [`setup.sh`](#setupsh) | `template/` | Verifies structure and installs tools in a project |

---

## `init-project.sh`

Creates a new project from the `template/` folder of the repository. Copies the entire file structure, replaces placeholders with the project name, initializes Git (optional), and can create the GitHub repository (optional).

### Requirements

| Requirement | Mandatory | Notes |
|-------------|-----------|-------|
| **Bash 4+** | Yes | Comes by default in Linux Mint 22.3 |
| **Git** | Recommended | Required to initialize the repository |
| **`gh` CLI** | Optional | Only if you use `--private` or `--public` |

**Install `gh` CLI on Linux Mint:**

```bash
sudo apt install gh
gh auth login
```

### Basic usage

```bash
./scripts/init-project.sh <project-name> [options]
```

### Options

| Option | Default | Description |
|--------|---------|-------------|
| `--path <path>` | `.` (current directory) | Directory where the project will be created |
| `--git` | `true` | Initialize Git repository with initial commit |
| `--no-git` | — | Do not initialize Git |
| `--private` | — | Create private GitHub repo (requires `gh` CLI) |
| `--public` | — | Create public GitHub repo (requires `gh` CLI) |
| `--template <path>` | `template/` of the repo | Use an alternative template |
| `--yes`, `-y` | — | Auto-confirm without prompt (useful in CI) |
| `--help`, `-h` | — | Show help |

### Examples

#### 1. Personal project, in the current directory

```bash
./scripts/init-project.sh my-personal-app
```

Creates `./my-personal-app/` with the entire structure, initializes Git, makes the first commit.

#### 2. Project in a specific directory

```bash
./scripts/init-project.sh my-app --path ~/projects
```

Creates `~/projects/my-app/`.

#### 3. Client project, private GitHub repo

```bash
./scripts/init-project.sh client-system-x --private
```

Creates the project locally, initializes Git, and creates a private GitHub repository with `gh repo create`.

#### 4. Open source project, public GitHub repo

```bash
./scripts/init-project.sh my-library --public
```

Same as the previous one, but the repo is public.

#### 5. Project without Git (to copy to another system)

```bash
./scripts/init-project.sh my-app --no-git
```

Useful if you are going to copy the project to another machine and prefer to initialize Git manually there.

#### 6. Use an alternative template

```bash
./scripts/init-project.sh my-app --template ~/my-custom-template
```

Useful if you have a modified version of the template with specific rules for your team or a type of project.

#### 7. Auto-confirm (CI or scripts)

```bash
./scripts/init-project.sh my-app --no-git --yes
```

Skips the confirmation prompt. Useful in CI pipelines or automation.

#### 8. Combinations

```bash
./scripts/init-project.sh my-app --path ~/projects --private --template ~/templates/web-app
```

All options can be combined.

### Execution flow

The script follows these steps:

```
1. Validates that the project name is present.
2. Detects the template/ folder (or uses --template if specified).
3. Verifies that the target directory does not exist.
4. Shows a summary and asks for confirmation (y/N), unless --yes is used.
5. Copies the template to the target directory.
6. Copies the prompts and reference docs from the repo.
7. Creates empty directories (src, tests, scripts, config) with .gitkeep.
8. Replaces [NOMBRE DEL PROYECTO] and [PROJECT NAME] placeholders with the real name in:
   - .md, .json, .yml, .yaml, .toml, .sh files
9. Initializes Git (if --git, which is the default).
10. Creates the GitHub repo (if --private or --public).
11. Shows the next steps.
```

### Example output

```
╔══════════════════════════════════════════════╗
║         Create new project                   ║
╚══════════════════════════════════════════════╝

  Name:         my-app
  Destination:  /home/your-user/my-app
  Template:     /home/your-user/plantilla-dev-ia/template
  Git:          true
  Create repo:  false

Continue? [y/N] y

[INFO] Copying template...
[INFO] Copying documentation prompts...
[OK]   Prompts copied to docs/prompts/ (9 files).
[OK]   Prompts verified: 9 files in docs/prompts/
[OK]   Copied: docs/WORKFLOWS.md
[OK]   Copied: docs/HERRAMIENTAS_SEGURIDAD.md
[INFO] Creating project directories...
[OK]   Directories created: src, tests, scripts, config
[INFO] Replacing placeholders...
[OK]   Placeholders replaced.
[INFO] Initializing Git repository...
[OK]   Git repository initialized with initial commit.

╔══════════════════════════════════════════════════════════════╗
║                    ✅ PROJECT CREATED                        ║
╚══════════════════════════════════════════════════════════════╝

📋 Next steps:

  1. cd /home/your-user/my-app

  2. Edit AGENTS.md and verify the project name.

  3. Install security tools:
     ./setup.sh --install-tools

  4. Generate the foundational documentation:
     Review docs/prompts/README.md and follow the 8 sequential prompts.

  5. Configure GitHub secrets:
     - CODECOV_TOKEN (for coverage)
     - SSH_HOST, SSH_USER, SSH_KEY (if you use deploy.yml)

[OK]   Ready to start.
```

### What it does exactly

#### Copy the template

```bash
cp -r "$TEMPLATE_DIR"/. "$TARGET_DIR"/
```

Copies **all the content** of `template/`, including hidden files (like `.gitignore`, `.husky/`, `.github/`).

#### Copy documentation prompts

The prompts live in `docs/prompts/` of the template repo, not in `template/`. They are copied to the new project so they are available locally.

#### Create empty directories

The template does not include `src/`, `tests/`, `scripts/`, `config/` because they are empty by default. The script creates them with `.gitkeep` files so Git versions them.

#### Replace placeholders

```bash
find "$TARGET_DIR" -type f \( -name "*.md" -o -name "*.json" -o ... \) \
  -exec sed -i "s/\[NOMBRE DEL PROYECTO\]/$PROJECT_NAME/g" {} \;
find "$TARGET_DIR" -type f \( -name "*.md" -o -name "*.json" -o ... \) \
  -exec sed -i "s/\[PROJECT NAME\]/$PROJECT_NAME/g" {} \;
```

Searches for `[NOMBRE DEL PROYECTO]` and `[PROJECT NAME]` in all relevant text files and replaces them with the real name. This affects `AGENTS.md`, `README.md`, `docs/PRD-SRD.md`, etc.

#### Initialize Git

```bash
git init -q
git add .
git commit -q -m "chore: initial setup from plantilla-dev-ia"
```

Creates a local Git repository with a single initial commit.

#### Create GitHub repo (optional)

```bash
gh repo create "$PROJECT_NAME" $REPO_VISIBILITY --source=. --push
```

Uses the `gh` CLI to create the remote repository and push the initial commit.

### Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| `Directory 'X' already exists` | A directory with the same name exists | Choose another name or delete the existing directory |
| `Template not found at: X` | The `template/` folder does not exist | Verify you are running the script from the repo root |
| `gh CLI is not installed` | `gh` is missing from the system | `sudo apt install gh && gh auth login` |
| `gh: not authenticated` | `gh` has no active session | `gh auth login` |
| `Permission denied` when running | Missing execute permission | `chmod +x scripts/init-project.sh` |
| Placeholders are not replaced | The file has another name or extension | Add the pattern to the script's `find` |
| The name has spaces | Not recommended for project names | Use hyphens: `my-app` instead of `my app` |

### What it does NOT do

- **Does not install security tools.** That is done by `setup.sh --install-tools` (inside the project).
- **Does not configure GitHub secrets.** You must do that manually.
- **Does not generate documentation.** It only creates the placeholders.
- **Does not push** unless you use `--private` or `--public`.

### After creating the project

```bash
cd my-app
./setup.sh --check           # Verify structure
./setup.sh --install-tools   # Install tools
```

This:
- Verifies that the structure is complete.
- Installs security tools (Semgrep, Trivy, Gitleaks, etc.).
- Configures Husky.
- Installs dependencies from `package.json` and `requirements.txt` (if they exist).

Then:
- Edit `AGENTS.md` with the real project name.
- Follow the 8 prompts in `docs/prompts/README.md`.

---

## `setup.sh`

`setup.sh` lives in `template/` of the template repository, and is copied to **each new project** when it is created with `init-project.sh`.

### Usage

```bash
./setup.sh [--force] [--dry-run] [--install-tools] [--check]
```

| Option | Description |
|--------|-------------|
| `--check` | Only verifies the structure (does not modify anything) |
| `--force` | Overwrites existing files (not used currently) |
| `--dry-run` | Shows what it would do without creating or installing anything |
| `--install-tools` | Installs security tools via `apt`/`pip`/binary |

### Examples

```bash
# Only verify structure
./setup.sh --check

# See what it would do without executing anything
./setup.sh --dry-run

# Verify + install tools
./setup.sh --install-tools

# Force recreation of missing directories
./setup.sh --force
```

### What it verifies

The script verifies that the following exist:

**Directories:**
- `src/`, `tests/`, `scripts/`, `config/`
- `docs/`, `docs/prompts/`
- `.github/workflows/`, `.husky/`

**Files (30+):**
- `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`
- `Makefile`, `cliff.toml`, `commitlint.config.js`, `codecov.yml`
- `.env.example`, `.eslintrc-security.js`, `.gitleaks.toml`, `.secrets.baseline`, `.gitignore`
- `.husky/pre-commit`, `.husky/commit-msg`
- The 7 workflows in `.github/workflows/`
- All docs in `docs/` and `docs/prompts/`

If a directory is missing, it creates it (except in `--check`). If a file is missing, it reports it (does not recreate it).

### What it installs with `--install-tools`

| Tool | Method | Requires sudo |
|------|--------|---------------|
| Semgrep | `pip3 install --user` | No |
| detect-secrets | `pip3 install --user` | No |
| Bandit | `pip3 install --user` | No |
| pip-audit | `pip3 install --user` | No |
| Ruff | `pip3 install --user` | No |
| Mypy | `pip3 install --user` | No |
| pytest + pytest-cov | `pip3 install --user` | No |
| pre-commit | `pip3 install --user` | No |
| Trivy | `apt` (Aqua Security repository) | Yes |
| Gitleaks | Binary from GitHub Releases | Yes (to `/usr/local/bin`) |
| git-cliff | Binary from GitHub Releases | Yes (to `/usr/local/bin`) |

**Note:** The script asks for confirmation before using `sudo`. If you say no, it skips the `apt`/binary installation but continues with the `pip` ones.

### What it does additionally

- **Installs project dependencies:**
  - If `package.json` exists → `npm install`
  - If `requirements.txt` exists → `pip3 install --user -r requirements.txt`
- **Configures Husky:** runs `npx husky install` and gives permissions to the hooks.

### Differences between `init-project.sh` and `setup.sh`

| Aspect | `init-project.sh` | `setup.sh` |
|--------|-------------------|-----------|
| **Where it lives** | `scripts/` of the template repo | `template/` of the template repo (copied to each project) |
| **Where it runs** | In the template repo | Inside a created project |
| **When it is used** | Once, to create the project | Inside the project, when needed |
| **What it does** | Copies the template + Git + GitHub repo | Verifies structure + installs tools + dependencies |
| **Options** | 7 (`path`, `git`, `private`, `public`, `template`, `yes`, `help`) | 4 (`check`, `force`, `dry-run`, `install-tools`) |
| **Dependencies** | `gh` CLI (optional) | `pip3`, `apt`, `sudo`, `npm` |

---

## Common troubleshooting

### `init-project.sh`

| Problem | Cause | Solution |
|---------|-------|----------|
| `Directory 'X' already exists` | A directory with the same name exists | Choose another name or delete the existing directory |
| `Template not found at: X` | The `template/` folder does not exist | Run the script from the repo root |
| `gh CLI is not installed` | `gh` is missing from the system | `sudo apt install gh && gh auth login` |
| `gh: not authenticated` | `gh` has no active session | `gh auth login` |
| `Permission denied` | Missing execute permission | `chmod +x scripts/init-project.sh` |
| Placeholders are not replaced | Extension not supported | Add pattern to the script's `find` |

### `setup.sh`

| Problem | Cause | Solution |
|---------|-------|----------|
| `Missing N files` | The project is incomplete | Copy manually from `template/` of the template repo, or recreate with `init-project.sh` |
| `pip3: command not found` | Python without pip | `sudo apt install python3-pip` |
| `Trivy not installed` | Repository not added | Check `/etc/apt/sources.list.d/trivy.list` |
| `Gitleaks not installed` | Architecture not supported | Check `uname -m` (x86_64, aarch64) |
| `Failed to install Node.js dependencies` | `npm` missing or invalid `package.json` | Check `node --version` and `npm --version` |
| `Husky not configured` | Missing `npx` or `package.json` | Check Node.js installation |

---

## References

- [`../README.md`](../README.md) — Main repository README
- [`../README.es.md`](../README.es.md) — Main repository README (Spanish)
- [`../docs/ARQUITECTURA.md`](../docs/ARQUITECTURA.md) — Philosophy and design decisions
- [`../docs/FLUJO_DE_TRABAJO.md`](../docs/FLUJO_DE_TRABAJO.md) — End-to-end workflow
- [`../docs/HERRAMIENTAS.md`](../docs/HERRAMIENTAS.md) — Tool stack
- [`../docs/HERRAMIENTAS_SEGURIDAD.md`](../docs/HERRAMIENTAS_SEGURIDAD.md) — Security tools installation
- [`../docs/WORKFLOWS.md`](../docs/WORKFLOWS.md) — GitHub Actions workflows documentation
- [`../docs/GITHUB_SECRETS.md`](../docs/GITHUB_SECRETS.md) — Required GitHub secrets
- [`../docs/prompts/README.md`](../docs/prompts/README.md) — Sequential prompts
