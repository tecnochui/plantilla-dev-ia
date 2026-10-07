# GitHub Actions Workflows

🌍 **Read this in:** [Español](../es/WORKFLOWS.md) | [English](WORKFLOWS.md)

> Documentation of the 7 workflows that run automatically on every project created from `plantilla-dev-ia`.

---

## Index

| Workflow | Runs on | Blocks merge |
|----------|---------|--------------|
| [`tests.yml`](#testsyml) | PR + push to main | Yes |
| [`commitlint.yml`](#commitlintyml) | PR | Yes |
| [`sast.yml`](#sastyml) | PR + push to main | Yes (CRITICAL, HIGH) |
| [`sca.yml`](#scayml) | PR + push to main | Yes (CRITICAL, HIGH) |
| [`secrets.yml`](#secretsyml) | PR + push to main | Yes |
| [`dast.yml`](#dastyml) | Post-deploy to staging | No (informational) |
| [`changelog.yml`](#changelogyml) | Tag creation `v*` | No |

---

## `tests.yml`

**Purpose:** Run unit tests, generate coverage, and upload it to Codecov.

**Triggers on:**
- Pull requests to `main`, `master`, `develop`
- Push to `main`, `master`

**What it does:**

```
1. Detects present stacks (Node.js, Python)
2. For Node.js:
   - Matrix: [20.x, 22.x]
   - npm ci
   - npm run lint
   - npm test with coverage
   - Uploads coverage artifact
3. For Python:
   - Matrix: [3.11, 3.12, 3.13]
   - pip install -r requirements.txt
   - ruff check
   - pytest with coverage
   - Uploads coverage artifact
4. Separate job: downloads all artifacts and uploads to Codecov
```

**Required secrets:**
- `CODECOV_TOKEN` (required to upload coverage)

**Blocking threshold:**
- Unit test failure
- Coverage below 80% global
- Patch coverage (new code) below 50%

**Configuration:**
- `codecov.yml` at the root defines the thresholds
- Patch and project coverage configured as `informational: false` (they block)

**How to skip it temporarily:**
- Add `[skip ci]` to the commit message (skips the entire CI)
- Add `[skip codecov]` to the PR title (only skips the Codecov check)

**Troubleshooting:**

| Problem | Cause | Solution |
|---------|-------|----------|
| `npm ci` fails | Outdated `package-lock.json` | `npm install` locally and commit the lock |
| `pytest` finds no tests | Missing pytest configuration | Create `pytest.ini` or `pyproject.toml` |
| Codecov does not appear | Token not configured | Add `CODECOV_TOKEN` in GitHub Secrets |
| Low coverage | Missing coverage in new files | Add tests or exclude files in `codecov.yml` |

---

## `commitlint.yml`

**Purpose:** Validate that commit messages follow **Conventional Commits**.

**Triggers on:**
- Pull requests to `main`, `master`

**What it does:**
1. Checkout with `fetch-depth: 0` (required to see all commits of the PR)
2. Installs `@commitlint/cli` and `@commitlint/config-conventional`
3. Runs `commitlint` on all commits of the PR

**Required secrets:** None.

**Blocking threshold:**
- Any commit that does not follow Conventional Commits

**Valid formats:**
```
feat(scope): description
fix(scope): description
security(scope): description
docs(scope): description
chore(scope): description
refactor(scope): description
test(scope): description
perf(scope): description
ci(scope): description
build(scope): description
revert(scope): description
```

**Configuration:**
- `commitlint.config.js` at the root defines the rules

**How to skip it:**
- Fix the message with `git commit --amend`
- If already pushed: `git rebase -i` and `git push --force-with-lease`

---

## `sast.yml`

**Purpose:** Static security analysis (SAST) with Semgrep.

**Triggers on:**
- Pull requests (any branch)
- Push to `main`

**What it does:**
1. Runs Semgrep in an official container
2. Applies the rulesets: `p/owasp-top-ten`, `p/security-audit`, `p/secrets`
3. Generates output in SARIF format
4. Uploads the SARIF to GitHub Security (tab "Security" → "Code scanning")

**Required secrets:** None.

**Blocking threshold:**
- CRITICAL findings
- HIGH findings

**How to view the results:**
- Repository "Security" tab → "Code scanning alerts"
- Or in the PR "Checks" section

**How to skip it:**
- It cannot be skipped directly. If a finding is a false positive:
  1. Add a comment in the code: `# nosemgrep: rule-id`
  2. Document the exception in `docs/Test_Plan.md` → section 9

**Troubleshooting:**

| Problem | Cause | Solution |
|---------|-------|----------|
| Semgrep takes too long | Ruleset too broad | Reduce to `p/owasp-top-ten` |
| False positives | Rules too generic | Add `# nosemgrep` with justification |
| SARIF is not uploaded | Missing `security-events: write` permission | Check `permissions` in the workflow |

---

## `sca.yml`

**Purpose:** Software Composition Analysis (SCA) with Trivy.

**Triggers on:**
- Pull requests (any branch)
- Push to `main`

**What it does:**
1. Runs Trivy in filesystem mode (`scan-type: fs`)
2. Scans project dependencies
3. Filters by severity `CRITICAL,HIGH`
4. Generates SARIF and uploads it to GitHub Security
5. Fails if it finds findings (`exit-code: 1`)

**Required secrets:** None.

**Blocking threshold:**
- CRITICAL vulnerabilities in dependencies
- HIGH vulnerabilities in dependencies

**Critical action:**
- The `aquasecurity/trivy-action@0.35.0` action suffered a supply chain compromise in March 2026. **Verify the commit SHA** before using it.

**How to skip it:**
- Update the vulnerable dependency
- If no update is available: document the exception in `docs/Test_Plan.md` and add a comment in `.trivyignore`

---

## `secrets.yml`

**Purpose:** Detection of hardcoded secrets with Gitleaks + detect-secrets.

**Triggers on:**
- Pull requests (any branch)
- Push to `main`

**What it does:**
- **Job 1 (Gitleaks):** scans the entire Git history
- **Job 2 (detect-secrets):** scans against `.secrets.baseline`

**Required secrets:**
- `GITHUB_TOKEN` (automatic, provided by GitHub Actions)

**Blocking threshold:**
- Any new secret detected (not registered in the baseline)

**Configuration:**
- `.gitleaks.toml` defines custom rules (AI API keys, etc.)
- `.secrets.baseline` records known false positives

**How to skip it:**
- If it is a false positive: add it to `[allowlist]` in `.gitleaks.toml` or to `.secrets.baseline`
- If it is real: delete the secret, rotate it, and use `.env` instead

**Troubleshooting:**

| Problem | Cause | Solution |
|---------|-------|----------|
| Gitleaks reports an AI API key | It is a real or placeholder key | Check if it is real → rotate. If placeholder → add to allowlist |
| detect-secrets reports many false positives | Long strings that are not secrets | Add to `.secrets.baseline` |
| Gitleaks scans old commits | It scans the entire history | This is the correct behavior. Fix in the current code |

---

## `dast.yml`

**Purpose:** Dynamic security analysis (DAST) with OWASP ZAP.

**Triggers on:**
- After `Deploy to Staging` completes (`workflow_run`)
- Manually (`workflow_dispatch`)

**What it does:**
1. Runs ZAP Baseline Scan against `https://staging.your-domain.com`
2. Generates an HTML report
3. Uploads the report as an artifact

**Required secrets:** None (uses the target configured in the YAML).

**Blocking threshold:**
- **Does not block** merge. It is informational.

**Required configuration:**
- Change `target: 'https://staging.your-domain.com'` to your actual staging URL
- This workflow **does not run** until you configure a staging target

**How to view the results:**
- Download the `zap-report` artifact from the "Actions" tab

**Troubleshooting:**

| Problem | Cause | Solution |
|---------|-------|----------|
| `workflow_run` does not trigger | The `Deploy to Staging` workflow does not exist | Rename the deploy workflow to `Deploy to Staging` |
| ZAP fails to connect | Target does not respond or does not exist | Verify that staging is accessible |
| Many false positives | Baseline scan detects everything | Review manually. ZAP Baseline is conservative |

---

## `changelog.yml`

**Purpose:** Generate `CHANGELOG.md` automatically from commits.

**Triggers on:**
- Push of a `v*` tag (e.g., `v1.0.0`)
- Manually (`workflow_dispatch`)

**What it does:**
1. Checkout with `fetch-depth: 0` (full history)
2. Runs `git-cliff` with `cliff.toml`
3. Generates or updates `CHANGELOG.md`
4. Commits the change automatically

**Required secrets:** None (uses the automatic `GITHUB_TOKEN`).

**Blocking threshold:**
- Does not block. It only updates the CHANGELOG.

**Configuration:**
- `cliff.toml` at the root defines the format
- The automatic commit uses `chore: update CHANGELOG.md for vX.Y.Z`

**How to use it:**
```bash
# Create a tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```
The workflow triggers automatically and updates `CHANGELOG.md`.

**Important note:** The automatic commit is made with `stefanzweifel/git-auto-commit-action@v5`. If your `main` branch is protected, you need to allow the bot to push.

---

## Required secrets on GitHub

| Secret | Workflow that uses it | Mandatory |
|--------|----------------------|-----------|
| `CODECOV_TOKEN` | `tests.yml` | Yes (for coverage) |
| `GITHUB_TOKEN` | All (automatic) | Automatic |
| `SSH_HOST` | `deploy.yml` (if applicable) | Only if you use deploy |
| `SSH_USER` | `deploy.yml` (if applicable) | Only if you use deploy |
| `SSH_KEY` | `deploy.yml` (if applicable) | Only if you use deploy |

📖 **Detailed documentation:** [`GITHUB_SECRETS.md`](GITHUB_SECRETS.md)

---

## References

- [`SECURITY.md`](SECURITY.md) — NIST SSDF and OWASP alignment
- [`SECURITY_TOOLS.md`](SECURITY_TOOLS.md) — Tool installation
- [`GITHUB_SECRETS.md`](GITHUB_SECRETS.md) — Secrets configuration
- [`prompts/07-Test-Plan.md`](prompts/07-Test-Plan.md) — Test plan
