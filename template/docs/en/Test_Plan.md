# Test Plan

🌍 **Read this in:** [Español](../es/Plan_Pruebas.md) | [English](Test_Plan.md)

> **Status:** Pending drafting.
> **Instructions:** Use Prompt 7 (`docs/en/prompts/07-Test-Plan.md`) with DeepSeek web or Gemini web.
> **Depends on:** `docs/en/SSD-TDD.md` (section 6) + `docs/en/SRS.md`
> **Note:** Section 6 of `SSD-TDD.md` is a **summary**. This document is the **full detail**. If there is a discrepancy, this document takes precedence.

---

## 1. Testing strategy

### 1.1. Testing pyramid
- **Unit:** [target %] — [Tool]
- **Integration:** [target %] — [Tool]
- **End-to-end:** [target %] — [Tool]
- **Manual:** [What is tested by hand]

### 1.2. Minimum coverage
- Global coverage: [e.g. 80%]
- New code (patch) coverage: [e.g. 50%]
- Excluded files: [e.g. migrations, config]

### 1.3. Test data
- **Fixtures:** [How they are generated]
- **Factories:** [Tool]
- **Anonymization:** [How sensitive data is handled]

## 2. Tools by test type

| Type | Tool | Command | Run on | Blocking threshold |
|------|------|---------|--------|--------------------|
| Unit (JS/TS) | Vitest | `npm test` | Local + CI | Test failure |
| Unit (Python) | pytest | `pytest` | Local + CI | Test failure |
| Integration | [Tool] | [Command] | CI | Test failure |
| E2E | Playwright | `npx playwright test` | CI (staging) | Test failure |
| Coverage | Codecov | automatic | CI | < 80% global |
| SAST | Semgrep | `semgrep ci` | CI | CRITICAL, HIGH |
| SCA | Trivy | `trivy fs .` | CI | CRITICAL, HIGH |
| Secrets | Gitleaks + detect-secrets | `gitleaks detect` | CI + pre-commit | Any secret |
| DAST | OWASP ZAP | `zap-baseline.py` | CI (staging) | HIGH (informational) |

## 3. Automated security tests

### 3.1. Categories

| Category | Tool | What it detects | Workflow |
|----------|------|-----------------|----------|
| SAST | Semgrep + CodeQL | Insecure patterns | `sast.yml` |
| SCA | Trivy | Vulnerabilities in dependencies | `sca.yml` |
| Secrets | Gitleaks + detect-secrets | Hardcoded secrets | `secrets.yml` |
| DAST | OWASP ZAP | Vulnerabilities at runtime | `dast.yml` |

### 3.2. OWASP Top 10:2025 coverage

| # | Category | Applies? | Mitigation | Test that verifies it |
|---|----------|----------|------------|-----------------------|
| A01 | Broken Access Control | [Yes/No] | [Strategy] | [Test] |
| A02 | Security Misconfiguration | [Yes/No] | [Strategy] | [Test] |
| A03 | Software Supply Chain Failures | [Yes/No] | [Strategy] | [Test] |
| A04 | Cryptographic Failures | [Yes/No] | [Strategy] | [Test] |
| A05 | Injection | [Yes/No] | [Strategy] | [Test] |
| A06 | Insecure Design | [Yes/No] | [Strategy] | [Test] |
| A07 | Authentication Failures | [Yes/No] | [Strategy] | [Test] |
| A08 | Software or Data Integrity Failures | [Yes/No] | [Strategy] | [Test] |
| A09 | Security Logging & Alerting Failures | [Yes/No] | [Strategy] | [Test] |
| A10 | Mishandling of Exceptional Conditions | [Yes/No] | [Strategy] | [Test] |

### 3.3. NIST SSDF mapping

| Practice | Group | How it is applied | Tool |
|----------|-------|-------------------|------|
| PO.1 | Prepare | Define security requirements | Requirements document |
| PO.3 | Prepare | Control the toolchain | package.json |
| PS.1 | Protect | Protect the code | .gitignore, .env |
| PS.2 | Protect | Verify component integrity | Trivy |
| PW.1 | Produce | Threat modeling | SSD-TDD |
| PW.4 | Produce | Verify third-party components | Trivy, pip-audit |
| PW.7 | Produce | Code review | PR reviews |
| RV.1 | Respond | Identify vulnerabilities | Semgrep, Gitleaks |
| RV.2 | Respond | Assess and remediate | Security issues |

## 4. GitHub Actions integration

| Workflow | Runs on | Blocks merge | Purpose |
|----------|---------|--------------|---------|
| `tests.yml` | PR + push to main | Yes | Unit tests, integration, coverage |
| `commitlint.yml` | PR | Yes | Validate Conventional Commits |
| `sast.yml` | PR + push to main | Yes (CRITICAL, HIGH) | Static security analysis |
| `sca.yml` | PR + push to main | Yes (CRITICAL, HIGH) | Dependency vulnerabilities |
| `secrets.yml` | PR + push to main | Yes | Secret detection |
| `dast.yml` | Post-deploy to staging | No (informational) | Dynamic security scan |
| `changelog.yml` | Tag `v*` creation | No | Generate CHANGELOG.md |

## 5. Acceptance criteria for merge

- [ ] All unit tests pass.
- [ ] Global coverage does not drop more than 1% relative to the base branch.
- [ ] New code (patch) has at least 50% coverage.
- [ ] Semgrep reports no CRITICAL or HIGH findings.
- [ ] Trivy reports no CRITICAL or HIGH vulnerabilities.
- [ ] Gitleaks and detect-secrets report no new secrets.
- [ ] Commits follow Conventional Commits.
- [ ] At least one person (you) has reviewed the diff.

## 6. Severity thresholds

| Severity | Action | Remediation deadline |
|----------|--------|----------------------|
| CRITICAL | Block merge | Immediate |
| HIGH | Block merge | Before merge |
| MEDIUM | Warn, review case by case | 7 days |
| LOW | Log, does not block | 30 days |
| INFO | Ignore | N/A |

## 7. Periodic manual tests

| Test | Frequency | Responsible | Tool |
|------|-----------|-------------|------|
| Manual pentesting | [Every major release] | You | OWASP ZAP |
| Dependency review | [Monthly] | You | npm audit, pip-audit |
| Secret rotation | [Every 6 months] | You | Secret manager |
| Security log review | [Weekly] | You | Manual review |

## 8. Test log

| Date | Type | Tool | Result | Findings | Action taken |
|------|------|------|--------|----------|--------------|
| | | | | | |

## 9. Documented exceptions

| ID | Finding | Severity | Rationale | Date |
|----|---------|----------|-----------|------|
| EX-001 | [Finding] | [Severity] | [Rationale] | [Date] |

## 10. Risks and assumptions

### Risks
- [Risk affecting the testing strategy]

### Assumptions
- [Assumption under which this plan is designed]

## 11. Glossary

| Term | Definition |
|------|------------|
| SAST | Static Application Security Testing |
| DAST | Dynamic Application Security Testing |
| SCA | Software Composition Analysis |
| CVE | Common Vulnerabilities and Exposures |
| SBOM | Software Bill of Materials |