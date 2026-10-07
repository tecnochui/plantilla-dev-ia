# Security Tools — Installation and Usage

🌍 **Read this in:** [Español](../es/HERRAMIENTAS_SEGURIDAD.md) | [English](SECURITY_TOOLS.md)

> Complete guide to install and use the security tools of the workflow.
> All are free and open source. None require an account or API key.

---

## Index

| Tool | Type | Installation | Main use |
|------|------|--------------|----------|
| [Semgrep](#semgrep) | SAST | `pipx` / `pip` / `brew` | Static code analysis |
| [Trivy](#trivy) | SCA | `apt` / `brew` / binary | Dependency vulnerabilities |
| [Gitleaks](#gitleaks) | Secrets | Binary / `brew` | Secret detection |
| [git-cliff](#git-cliff) | Changelog | `npm` / `cargo` / binary | CHANGELOG.md generation |
| [detect-secrets](#detect-secrets) | Secrets | `pip` | High-entropy detection |
| [Bandit](#bandit) | SAST (Python) | `pip` | Python vulnerabilities |
| [ESLint security](#eslint-security) | SAST (JS/TS) | `npm` | JS/TS vulnerabilities |

---

## Semgrep

**Purpose:** Static security analysis (SAST). Detects insecure patterns in code: injection, XSS, `eval`, etc.

**Official documentation:** [docs.semgrep.dev](https://docs.semgrep.dev/)

### Installation

**Recommended method (pipx, isolated from the system):**

```bash
# Install pipx if you don't have it
sudo apt install pipx
pipx ensurepath

# Install Semgrep
pipx install semgrep
```

**Alternative method (pip, user):**

```bash
pip3 install --user semgrep
```

**Alternative method (Homebrew, Linux and macOS):**

```bash
brew install semgrep
```

**Verify installation:**

```bash
semgrep --version
```

### Usage

```bash
# Scan the whole project with OWASP Top 10 rules
semgrep --config=p/owasp-top-ten .

# Scan with general security rules
semgrep --config=p/security-audit .

# Scan with secrets rules
semgrep --config=p/secrets .

# Combine rulesets
semgrep --config=p/owasp-top-ten --config=p/security-audit .

# Exit with error code if there are findings (for CI)
semgrep --config=p/owasp-top-ten --error .

# Output in SARIF format (for GitHub Security)
semgrep --config=p/owasp-top-ten --sarif --output=semgrep.sarif .
```

### Useful rulesets

| Ruleset | What it detects |
|---------|-----------------|
| `p/owasp-top-ten` | The 10 categories of OWASP Top 10 |
| `p/security-audit` | General insecure patterns |
| `p/secrets` | Hardcoded secrets |
| `p/python` | Python-specific rules |
| `p/javascript` | JavaScript-specific rules |

### Notes

- **Does not require an account or API key** to use the Community Edition (CE).
- **The commercial version (Semgrep Code)** adds a web interface and additional rules, but is not necessary for this workflow.
- **In CI**, it runs with `semgrep ci` (automatically detects the ruleset).

---

## Trivy

**Purpose:** Software Composition Analysis (SCA). Detects vulnerabilities in dependencies, container images, IaC, and more.

**Official documentation:** [trivy.dev](https://trivy.dev/)

### Installation

**Recommended method (apt, Debian/Ubuntu — official):**

```bash
sudo apt-get install wget apt-transport-https gnupg
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
```

**Alternative method (install script):**

```bash
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
```

**Alternative method (Homebrew):**

```bash
brew install trivy
```

**Verify installation:**

```bash
trivy --version
```

### Usage

```bash
# Scan filesystem (dependencies)
trivy fs .

# Scan only CRITICAL and HIGH vulnerabilities
trivy fs --severity CRITICAL,HIGH .

# Exit with error code if there are findings (for CI)
trivy fs --severity CRITICAL,HIGH --exit-code 1 .

# Output in SARIF format (for GitHub Security)
trivy fs --format sarif --output trivy.sarif .

# Scan a container image
trivy image my-image:latest
```

### Notes

- **Does not require an account or API key.**
- **The vulnerability database is updated automatically** on each run.
- **In CI**, the `aquasecurity/trivy-action` action is used with `scan-type: 'fs'`.

---

## Gitleaks

**Purpose:** Detection of hardcoded secrets in the repository (API keys, tokens, passwords).

**Official documentation:** [github.com/gitleaks/gitleaks](https://github.com/gitleaks/gitleaks)

### Installation

**Recommended method (binary from GitHub Releases):**

```bash
# Download the latest version
curl -sSfL https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_linux_x64.tar.gz -o gitleaks.tar.gz

# Extract
tar -xzf gitleaks.tar.gz

# Move to /usr/local/bin
sudo mv gitleaks /usr/local/bin/
sudo chmod +x /usr/local/bin/gitleaks

# Verify
gitleaks version
```

**Alternative method (Homebrew):**

```bash
brew install gitleaks
```

**Alternative method (Docker):**

```bash
docker pull ghcr.io/gitleaks/gitleaks:latest
```

### Usage

```bash
# Scan the whole repository
gitleaks detect --source . --verbose

# Scan only staged files (pre-commit)
gitleaks protect --staged --verbose

# Scan with custom configuration
gitleaks detect --source . --config .gitleaks.toml --verbose

# Exit with error code if there are findings
gitleaks detect --source . --exit-code 1

# Redact secrets in the output
gitleaks detect --source . --redact
```

### Notes

- **Does not require an account or API key.**
- **Scans the entire Git history**, not just the current commit. This detects secrets that were committed months ago.
- **The `.gitleaks.toml` file** at the repo root defines custom rules (AI API keys, OpenRouter tokens, etc.).
- **In CI**, the `gitleaks/gitleaks-action@v2` action is used.

---

## git-cliff

**Purpose:** Automatic generation of `CHANGELOG.md` from Conventional Commits.

**Official documentation:** [git-cliff.org](https://git-cliff.org/)

### Installation

**Recommended method (npm, cross-platform):**

```bash
# Run without installing
npx git-cliff@latest

# Install in the project
npm install git-cliff --save-dev

# Run
npx git-cliff
```

**Alternative method (cargo, if you have Rust):**

```bash
cargo install git-cliff
```

**Alternative method (binary from GitHub Releases):**

```bash
curl -sSL https://github.com/orhun/git-cliff/releases/latest/download/git-cliff-x86_64-unknown-linux-gnu.tar.gz -o git-cliff.tar.gz
tar -xzf git-cliff.tar.gz
sudo mv git-cliff-*/git-cliff /usr/local/bin/
```

**Verify installation:**

```bash
git-cliff --version
```

### Usage

```bash
# Initialize default configuration
git-cliff --init

# Generate full changelog
git-cliff --tag v1.0.0 -o CHANGELOG.md

# Generate only unreleased changes
git-cliff --unreleased -o CHANGELOG.md

# Preview without writing the file
git-cliff --tag v1.0.0

# Use custom configuration
git-cliff --config cliff.toml --tag v1.0.0 -o CHANGELOG.md
```

### Notes

- **Does not require an account or API key.**
- **The `cliff.toml` file** at the repo root defines the changelog format.
- **In CI**, the `orhun/git-cliff-action@v3` action is used.

---

## detect-secrets

**Purpose:** Detection of secrets through entropy. Complements Gitleaks with a different approach.

**Official documentation:** [github.com/Yelp/detect-secrets](https://github.com/Yelp/detect-secrets)

### Installation

```bash
pip3 install --user detect-secrets
```

### Usage

```bash
# Generate initial baseline
detect-secrets scan > .secrets.baseline

# Audit findings (interactive)
detect-secrets audit .secrets.baseline

# Verify against baseline
detect-secrets scan --baseline .secrets.baseline
```

### Notes

- **Uses a baseline** to mark known false positives.
- **The `.secrets.baseline` file** is versioned in the repo.
- **Complements Gitleaks:** Gitleaks detects known patterns, detect-secrets detects high entropy.

---

## Bandit

**Purpose:** Static security analysis specific to Python.

**Official documentation:** [bandit.readthedocs.io](https://bandit.readthedocs.io/)

### Installation

```bash
pip3 install --user bandit
```

### Usage

```bash
# Scan directory
bandit -r src/

# Scan with minimum severity level
bandit -r src/ -ll

# Output in JSON format
bandit -r src/ -f json -o bandit-report.json
```

### Notes

- **Only applies to Python projects.**
- **Runs in the pre-commit hook** for staged `.py` files.

---

## ESLint security

**Purpose:** Static security analysis for JavaScript/TypeScript.

**Official documentation:** [github.com/eslint-community/eslint-plugin-security](https://github.com/eslint-community/eslint-plugin-security)

### Installation

```bash
npm install --save-dev eslint eslint-plugin-security eslint-plugin-no-unsanitized
```

### Usage

```bash
# Run with security configuration
npx eslint . --config .eslintrc-security.js

# Run on specific files
npx eslint src/ --config .eslintrc-security.js
```

### Notes

- **Only applies to JS/TS projects.**
- **Runs in the pre-commit hook** for staged `.js`, `.ts`, `.jsx`, `.tsx` files.
- **The configuration is in `.eslintrc-security.js`** at the repo root.

---

## Summary table: what to install per operating system

| Tool | Linux Mint (apt) | macOS (brew) | Windows |
|------|------------------|--------------|---------|
| Semgrep | `pipx install semgrep` | `brew install semgrep` | `pipx install semgrep` |
| Trivy | `apt` (official repo) | `brew install trivy` | Binary from GitHub |
| Gitleaks | Binary from GitHub | `brew install gitleaks` | Binary from GitHub |
| git-cliff | `npm install -g git-cliff` | `brew install git-cliff` | `npm install -g git-cliff` |
| detect-secrets | `pip3 install --user` | `pip3 install --user` | `pip3 install --user` |
| Bandit | `pip3 install --user` | `pip3 install --user` | `pip3 install --user` |
| ESLint security | `npm install --save-dev` | `npm install --save-dev` | `npm install --save-dev` |

---

## Automated installation

The `setup.sh --install-tools` script automatically installs:

- **Semgrep, detect-secrets, Bandit, pip-audit, Ruff, Mypy, pytest** → via `pip3 install --user` (does not require sudo).
- **Trivy** → via `apt` from the official Aqua Security repository.
- **Gitleaks** → binary from GitHub Releases to `/usr/local/bin/`.
- **git-cliff** → binary from GitHub Releases to `/usr/local/bin/`.

**Usage:**

```bash
./setup.sh --install-tools
```

The script asks for confirmation before using `sudo`.

---

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| `semgrep: command not found` | Not in PATH | `pipx ensurepath` and restart terminal |
| `trivy: command not found` | Repository not added correctly | Check `/etc/apt/sources.list.d/trivy.list` |
| `gitleaks: command not found` | Binary not moved to `/usr/local/bin` | `sudo mv gitleaks /usr/local/bin/` |
| `git-cliff: command not found` | Not in PATH | Use `npx git-cliff` or verify installation |
| Gitleaks gives many false positives | Generic rules too broad | Add patterns to `[allowlist]` in `.gitleaks.toml` |
| Trivy takes too long | Vulnerability database is large | Normal the first time. Cached afterwards. |

---

## References

- [`prompts/05-NIST-OWASP-Mapping.md`](prompts/05-NIST-OWASP-Mapping.md) — Security mapping
- [`prompts/07-Test-Plan.md`](prompts/07-Test-Plan.md) — Test plan
- [`../../scripts/README.md`](../../scripts/README.md) — Repository scripts
- [`../../template/setup.sh`](../../template/setup.sh) — Automated installation
