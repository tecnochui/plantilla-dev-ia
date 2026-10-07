# Security — NIST SSDF and OWASP Top 10:2025 Alignment

🌍 **Read this in:** [Español](../es/SEGURIDAD.md) | [English](SECURITY.md)

> How this workflow implements recognized security practices, adapted to an individual developer.

---

## NIST SSDF (SP 800-218)

The NIST SSDF organizes security practices into 4 groups: **Prepare (PO)**, **Protect (PS)**, **Produce (PW)**, and **Respond (RV)**. For an individual developer, not all of them apply with the same depth as in an organization.

### Implemented practices

| Practice | Group | How it is applied | Tool |
|----------|-------|-------------------|------|
| **PO.1** | Prepare | Security requirements defined in the SRS | `SRS.md` document |
| **PO.3** | Prepare | Controlled toolchain | `package.json`, `requirements.txt` |
| **PS.1** | Protect | Code protection | `.gitignore`, `.env` |
| **PS.2** | Protect | Integrity verification | Trivy, `npm audit`, `pip-audit` |
| **PW.1** | Produce | Threat modeling in the SSD-TDD | `SSD-TDD.md` document |
| **PW.4** | Produce | Dependency verification | Trivy, `pip-audit` |
| **PW.7** | Produce | Code review | PRs on GitHub |
| **RV.1** | Respond | Vulnerability identification | Semgrep, Gitleaks |
| **RV.2** | Respond | Documented remediation | Exceptions in `Test_Plan.md` |

### Consciously omitted practices

| Practice | Why it is omitted |
|----------|-------------------|
| **PO.2** (Roles and responsibilities) | Does not apply to an individual developer |
| **PO.4** (Criteria for third-party components) | Partially covered by PW.4 |
| **PS.3** (Release archive with integrity) | Covered by signed Git tags (optional) |
| **PW.2** (Secure software design) | Covered by PW.1 (threat modeling) |
| **PW.5** (Secure source code) | Covered by PW.7 (code review) |
| **PW.6** (Build configuration) | Does not apply to all languages |
| **PW.8** (Executable software testing) | Covered in `Test_Plan.md` |
| **PW.9** (Secure by default configuration) | Documented in `SSD-TDD.md` |
| **RV.3** (Vulnerability analysis) | Done manually if necessary |

---

## OWASP Top 10:2025

The 2025 edition consolidates the previous list with adjustments and priority changes. **Broken Access Control remains the #1 risk**, and now incorporates SSRF (previously a separate category). **Security Misconfiguration and Software Supply Chain Failures** move up to the top 3. **Mishandling of Exceptional Conditions** is the only completely new category.

### Categories and coverage

| # | Category | Applies? | Mitigation | Test that verifies |
|---|----------|----------|------------|-------------------|
| A01 | Broken Access Control | Yes | RBAC, permission validation on every endpoint | Authorization tests |
| A02 | Security Misconfiguration | Yes | Secure by default configuration, `.env` for secrets | Manual review + Trivy |
| A03 | Software Supply Chain Failures | Yes | Trivy on every PR, dependency verification | `sca.yml` |
| A04 | Cryptographic Failures | Yes | TLS, AES-256 at rest, bcrypt for passwords | Review in SSD-TDD |
| A05 | Injection | Yes | Input validation, parameterized ORM, no `eval` | Semgrep + ESLint security |
| A06 | Insecure Design | Yes | Threat modeling in SSD-TDD | Design review |
| A07 | Authentication Failures | Yes | JWT with expiration, rate limiting, MFA if applicable | Auth tests |
| A08 | Software or Data Integrity Failures | Yes | Dependency integrity verification | `npm audit`, `pip-audit` |
| A09 | Security Logging & Alerting Failures | Yes | Logs without PII, retention ≥ 90 days | Review in Backup Strategy |
| A10 | Mishandling of Exceptional Conditions | Yes | Error handling without leaking information | Error tests |

---

## Security tools in the workflow

| Tool | Type | Workflow | Blocking threshold |
|------|------|----------|-------------------|
| Semgrep | SAST | `sast.yml` | CRITICAL, HIGH |
| Trivy | SCA | `sca.yml` | CRITICAL, HIGH |
| Gitleaks | Secrets | `secrets.yml` | Any new secret |
| detect-secrets | Secrets | `secrets.yml` | Any new secret |
| Bandit | SAST (Python) | Pre-commit | CRITICAL, HIGH |
| ESLint security | SAST (JS/TS) | Pre-commit | CRITICAL, HIGH |
| OWASP ZAP | DAST | `dast.yml` | HIGH (informational) |
| Codecov | Coverage | `tests.yml` | < 80% global, < 50% patch |

---

## How to contribute to security

1. **Never commit secrets.** Use `.env` (never versioned).
2. **Verify dependencies before adding them.** Run `trivy` and `npm audit`/`pip-audit`.
3. **Validate user inputs.** Always.
4. **Do not use `eval()`, `exec()`, `child_process` with non-literal input.**
5. **Do not use `innerHTML` with unsanitized data.**
6. **Report vulnerabilities** by opening an issue with the `security` label.
