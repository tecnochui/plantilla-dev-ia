# Prompt 7 — Test Plan

🌍 **Read this in:** [Español](../es/07-Plan-Pruebas.md) | [English](07-Test-Plan.md)

## Purpose
Define the complete testing strategy: unit, integration, E2E, security.

## Recommended model
DeepSeek web or Gemini web.

## Files to attach
`docs/SRS.md` + `docs/SSD-TDD.md` + `docs/Technical_Proposal.md`

## When to use it
After the SSD-TDD and the Technical Proposal have been validated.

---

## Complete prompt

```
Act as a QA and security engineer. Based on the following already approved documents:

- `docs/SRS.md` (functional and non-functional requirements)
- `docs/SSD-TDD.md` (architecture, DB design, API, and summarized testing strategy)
- `docs/Technical_Proposal.md` (technology stack)

Generate the complete Test Plan for this project. Use Markdown format and respect the section structure indicated below. Be specific and concrete; avoid generalities.

---

## 1. Testing strategy

### 1.1. Testing pyramid
Define the target percentages and tools for each level. Based on the project's stack, recommend:
- **Unit:** target % and tool (e.g., Vitest for JS/TS, pytest for Python). Recommended minimum global coverage: 80% for unit, 70% for integration, and E2E only for critical happy paths.
- **Integration:** target % and tool.
- **End-to-end (E2E):** tool (e.g., Playwright) and which flows to cover.
- **Manual:** what is tested by hand and why (e.g., UX, exploratory).

### 1.2. Minimum coverage
Define concrete thresholds:
- Global project coverage (e.g., 80%).
- New code coverage per PR (patch coverage, e.g., 50%).
- Files excluded from coverage (e.g., migrations, configuration, `main`).

### 1.3. Test data
- Strategy to generate test data (fixtures, factories, anonymized data).
- Handling of sensitive data in tests (never use production data).

---

## 2. Tools by test type

Generate a table with this format, adapted to the project's stack:

| Type | Tool | Command | Run on | Blocking threshold |
|------|------|---------|--------|--------------------|
| Unit (JS/TS) | Vitest | `npm test` | Local + CI | Test failure |
| Unit (Python) | pytest | `pytest` | Local + CI | Test failure |
| Integration | [tool] | [command] | CI | Test failure |
| E2E | Playwright | `npx playwright test` | CI (staging) | Test failure |
| Coverage | Codecov | automatic | CI | < 80% global |
| SAST | Semgrep | `semgrep ci` | CI (every PR) | CRITICAL, HIGH |
| SCA | Trivy | `trivy fs .` | CI (every PR) | CRITICAL, HIGH |
| Secrets | Gitleaks + detect-secrets | `gitleaks detect` | CI + pre-commit | Any new secret |
| DAST | OWASP ZAP | `zap-baseline.py` | CI (post-deploy staging) | HIGH (informational only) |

---

## 3. Automated security tests

### 3.1. Test categories

| Category | Tool | What it detects | Workflow |
|----------|------|-----------------|----------|
| SAST | Semgrep + CodeQL | Insecure patterns in code (injection, XSS, eval, etc.) | `sast.yml` |
| SCA | Trivy + OWASP Dependency-Check | Vulnerabilities in third-party dependencies | `sca.yml` |
| Secrets | Gitleaks + detect-secrets | Hardcoded secrets (API keys, tokens, passwords) | `secrets.yml` |
| DAST | OWASP ZAP | Vulnerabilities in the running app (XSS, SQLi, headers) | `dast.yml` |
| IaC | Checkov | Misconfigurations in infrastructure as code | `iac.yml` (if applicable) |

### 3.2. OWASP Top 10:2025 coverage

For each category of the OWASP Top 10:2025, indicate whether it applies to the project, how it is mitigated, and what test verifies it:

| # | OWASP Category | Applies? | Mitigation | Test that verifies it |
|---|----------------|----------|------------|-----------------------|
| A01 | Broken Access Control | [Yes/No] | [strategy] | [test/scanner] |
| A02 | Security Misconfiguration | [Yes/No] | [strategy] | [test/scanner] |
| A03 | Software Supply Chain Failures | [Yes/No] | [strategy] | [test/scanner] |
| A04 | Cryptographic Failures | [Yes/No] | [strategy] | [test/scanner] |
| A05 | Injection | [Yes/No] | [strategy] | [test/scanner] |
| A06 | Insecure Design | [Yes/No] | [strategy] | [test/scanner] |
| A07 | Authentication Failures | [Yes/No] | [strategy] | [test/scanner] |
| A08 | Software or Data Integrity Failures | [Yes/No] | [strategy] | [test/scanner] |
| A09 | Security Logging & Alerting Failures | [Yes/No] | [strategy] | [test/scanner] |
| A10 | Mishandling of Exceptional Conditions | [Yes/No] | [strategy] | [test/scanner] |

### 3.3. NIST SSDF mapping

Indicate which NIST SSDF (SP 800-218) practices apply to this project:

| Practice | Group | How it is applied | Tool |
|----------|-------|-------------------|------|
| PO.1 | Prepare | Define security requirements | Requirements document |
| PO.3 | Prepare | Control the toolchain | `package.json`, `requirements.txt` |
| PS.1 | Protect | Protect the code | `.gitignore`, `.env` |
| PS.2 | Protect | Verify component integrity | Trivy, `npm audit` |
| PW.1 | Produce | Threat modeling | Design document |
| PW.4 | Produce | Verify third-party components | Trivy, `pip-audit` |
| PW.7 | Produce | Code review | PR reviews |
| RV.1 | Respond | Identify vulnerabilities | Semgrep, Gitleaks |
| RV.2 | Respond | Assess and remediate | Security issues |

Explicitly document which practices **DO NOT** apply and why (e.g., because it is an individual developer).

---

## 4. Integration with GitHub Actions

Generate a table with the project's workflows:

| Workflow | Runs on | Blocks merge | Purpose |
|----------|---------|--------------|---------|
| `tests.yml` | PR + push to main | Yes | Unit tests, integration, coverage |
| `commitlint.yml` | PR | Yes | Validate Conventional Commits |
| `sast.yml` | PR + push to main | Yes (CRITICAL, HIGH) | Static security analysis |
| `sca.yml` | PR + push to main | Yes (CRITICAL, HIGH) | Vulnerabilities in dependencies |
| `secrets.yml` | PR + push to main | Yes (any secret) | Secret detection |
| `dast.yml` | Post-deploy to staging | No (informational) | Dynamic security scan |
| `changelog.yml` | Tag `v*` creation | No | Generate CHANGELOG.md |

---

## 5. Acceptance criteria for merge

A PR can only be merged if it meets **all** these criteria:

- [ ] All unit tests pass on all supported versions.
- [ ] Global coverage does not drop more than 1% relative to the base branch.
- [ ] New code (patch) has at least 50% coverage.
- [ ] Semgrep reports no CRITICAL or HIGH findings.
- [ ] Trivy reports no CRITICAL or HIGH vulnerabilities in dependencies.
- [ ] Gitleaks and detect-secrets report no new secrets.
- [ ] Commits follow Conventional Commits.
- [ ] At least one person (you) has reviewed the diff.
- [ ] There are no conflicts with the base branch.

---

## 6. Severity thresholds

| Severity | Action | Remediation deadline |
|----------|--------|----------------------|
| CRITICAL | Block merge. Fix before continuing. | Immediate |
| HIGH | Block merge. Fix or document a justified exception. | Before merge |
| MEDIUM | Warn. Review case by case. Can be merged with documented justification. | 7 days |
| LOW | Log. Does not block. | 30 days |
| INFO | Ignore. | N/A |

---

## 7. Periodic manual tests

| Test | Frequency | Responsible | Tool |
|------|-----------|-------------|------|
| Manual pentesting | Every major release | You | OWASP ZAP, Burp Suite (community) |
| Critical dependency review | Monthly | You | `npm audit`, `pip-audit` |
| Secret rotation | Every 6 months | You | Secret manager |
| Security log review | Weekly | You | Manual review |
| Access and permissions review | Quarterly | You | Manual review |

---

## 8. Test log

Generate a table to document the execution of manual security tests:

| Date | Type | Tool | Result | Findings | Action taken | Responsible |
|------|------|------|--------|----------|--------------|-------------|
| [YYYY-MM-DD] | Pentesting | OWASP ZAP | [OK/Failures] | [description] | [action] | [name] |

---

## 9. Documented exceptions

Generate a table to document findings that were decided NOT to fix:

| ID | Finding | Severity | Justification | Date | Reviewed by |
|----|---------|----------|---------------|------|-------------|
| EX-001 | [description] | [MEDIUM] | [why it is not fixed] | [date] | [name] |

---

## 10. Risks and assumptions

- **Risks:** List the risks that could affect the testing strategy (e.g., lack of time, limited tools, legacy project without tests).
- **Assumptions:** List the assumptions under which this plan is designed (e.g., the staging environment exists, developers have access to the tools).

---

## 11. Glossary

Define the technical terms used in this document:

| Term | Definition |
|------|------------|
| SAST | Static Application Security Testing — code analysis without executing it |
| DAST | Dynamic Application Security Testing — analysis of the running app |
| SCA | Software Composition Analysis — analysis of third-party dependencies |
| IAST | Interactive Application Security Testing — runtime analysis |
| CVE | Common Vulnerabilities and Exposures — vulnerability identifier |
| SBOM | Software Bill of Materials — inventory of software components |

---

## Final instructions

1. **Do not make things up.** If context is missing for any section, ask me questions before generating.
2. **Be specific.** Instead of "use security tools", write "use Semgrep with the rulesets `p/owasp-top-ten` and `p/security-audit`".
3. **Align with the real stack.** If the project uses Python, do not mention Vitest. If it uses Node, do not mention pytest.
4. **Format:** Markdown with tables and checkboxes. Use Mermaid only if a diagram adds clarity (e.g., CI/CD flow).
5. **Length:** 300-500 lines. If it is shorter, detail is missing. If it is longer, it is being redundant.
```

---

## Post-generation validation

- [ ] The tools match the stack (does not mix Python with Node).
- [ ] The coverage thresholds are realistic (80% global, 50% patch).
- [ ] The GitHub Actions workflows match those in the repo.
- [ ] The OWASP Top 10:2025 is complete (all 10 categories, with A10 = Mishandling of Exceptional Conditions).
- [ ] The NIST SSDF mapping is honest about what does not apply.

## What to do if the output does not meet expectations

| Problem | Action |
|---------|--------|
| Mixes tools from different stacks | Correct with "align with the real stack of the project, do not mix Python and Node" |
| Unrealistic coverage thresholds | Ask "use 80% global and 50% patch, or justify another threshold" |
| Incomplete OWASP Top 10:2025 | Ask "cover the 10 categories, with A10 = Mishandling of Exceptional Conditions" |
| Dishonest NIST SSDF mapping | Correct with "explicitly document which practices do not apply and why" |
| Workflows that do not exist in the repo | Ask "use only the workflows that actually exist in .github/workflows/" |

## Save as
`docs/Test_Plan.md`