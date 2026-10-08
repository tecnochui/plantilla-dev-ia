# NIST SSDF + OWASP Top 10:2025 Mapping

🌍 **Read this in:** [Español](../es/Mapeo_NIST_OWASP.md) | [English](NIST_OWASP_Mapping.md)

> **Status:** Pending drafting.
> **Instructions:** Use Prompt 5 (`docs/en/prompts/05-NIST-OWASP-Mapping.md`) with DeepSeek web or Claude web.
> **Depends on:** `docs/en/SSD-TDD.md` + `docs/en/SRS.md`

---

## 1. NIST SSDF mapping (SP 800-218)

> This project is developed by an individual. It does not aim for certification. Only the applicable practices are documented.

| Practice | Group | How it is applied | Tool | Frequency |
|----------|-------|-------------------|------|-----------|
| PO.1 | Prepare | [Security requirements] | [SRS document] | [At the start] |
| PO.3 | Prepare | [Toolchain control] | [package.json] | [Continuous] |
| PS.1 | Protect | [Code protection] | [.gitignore, .env] | [Continuous] |
| PS.2 | Protect | [Component integrity] | [Trivy] | [Every PR] |
| PW.1 | Produce | [Threat modeling] | [SSD-TDD] | [At design time] |
| PW.4 | Produce | [Verify dependencies] | [Trivy, pip-audit] | [Every PR] |
| PW.7 | Produce | [Code review] | [PRs] | [Every PR] |
| RV.1 | Respond | [Identify vulnerabilities] | [Semgrep, Gitleaks] | [Every PR] |
| RV.2 | Respond | [Remediate vulnerabilities] | [Issues] | [Continuous] |

### Practices consciously omitted

| Practice | Why it is omitted |
|----------|-------------------|
| PO.2 | Does not apply to an individual developer |
| PO.4 | Partially covered by PW.4 |
| PS.3 | Covered by signed tags (optional) |
| PW.2 | Covered by PW.1 |
| PW.5 | Covered by PW.7 |
| PW.6 | Does not apply to all languages |
| PW.8 | Covered in Test_Plan.md |
| PW.9 | Documented in SSD-TDD.md |
| RV.3 | Done manually if necessary |

## 2. OWASP Top 10:2025 mapping

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

## 3. Project security tools

| Tool | Type | Workflow | Blocking threshold |
|------|------|----------|--------------------|
| Semgrep | SAST | `sast.yml` | CRITICAL, HIGH |
| Trivy | SCA | `sca.yml` | CRITICAL, HIGH |
| Gitleaks | Secrets | `secrets.yml` | Any new secret |
| detect-secrets | Secrets | `secrets.yml` | Any new secret |
| Bandit | SAST (Python) | Pre-commit | CRITICAL, HIGH |
| ESLint security | SAST (JS/TS) | Pre-commit | CRITICAL, HIGH |
| OWASP ZAP | DAST | `dast.yml` | HIGH (informational) |

## 4. Security traceability matrix

| Requirement (SRS) | NIST practice | OWASP category | Test that verifies it |
|-------------------|---------------|----------------|-----------------------|
| NFR-SEC-001 | PO.1 | A01 | [Test] |

## 5. Exceptions and omissions

| Practice | Rationale |
|----------|-----------|
| [Omitted practice] | [Why] |