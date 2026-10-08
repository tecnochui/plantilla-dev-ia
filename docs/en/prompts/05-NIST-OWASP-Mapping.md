# Prompt 5 — NIST SSDF + OWASP Top 10:2025 Mapping

🌍 **Read this in:** [Español](../es/05-Mapeo-NIST-OWASP.md) | [English](05-NIST-OWASP-Mapping.md)

## Purpose
Document how the project complies with recognized security practices.

## Recommended model
DeepSeek web or Claude web (if you need deep security reasoning).

## Files to attach
`docs/SSD-TDD.md` + `docs/SRS.md`

## When to use it
After the SSD-TDD has been validated.

---

## Complete prompt

```
Based on the attached SRS and SSD-TDD, generate the security compliance document for this project.

IMPORTANT: This project is developed by an individual, not by an organization. It does not target certification. Document only the applicable practices.

Required sections:

1. NIST SSDF mapping (SP 800-218)
   For each of the following practices, indicate:
   - How it is applied in this project
   - Which tool is used
   - How often it runs
   - Who is responsible

   Practices:
   - PO.1: Define security requirements
   - PO.3: Control the toolchain
   - PS.1: Protect the code
   - PS.2: Verify component integrity
   - PW.1: Threat modeling
   - PW.4: Verify third-party components
   - PW.7: Code review
   - RV.1: Identify vulnerabilities
   - RV.2: Assess and remediate

   At the end, explicitly list which practices DO NOT apply and why.

2. OWASP Top 10:2025 mapping
   For each category, indicate:
   - Does it apply to the project? (Yes/No)
   - How it is mitigated
   - What test verifies it

   Categories:
   - A01: Broken Access Control
   - A02: Security Misconfiguration
   - A03: Software Supply Chain Failures
   - A04: Cryptographic Failures
   - A05: Injection
   - A06: Insecure Design
   - A07: Authentication Failures
   - A08: Software or Data Integrity Failures
   - A09: Security Logging & Alerting Failures
   - A10: Mishandling of Exceptional Conditions

3. Project security tools
   Table with: tool, type (SAST/SCA/DAST), CI workflow, blocking threshold.

4. Security traceability matrix
   Table: security requirement (SRS) → NIST practice → OWASP category → test that verifies it.

5. Exceptions and omissions
   List of NIST/OWASP practices that are NOT implemented, with justification.

Rules:
- Be honest: if something is not implemented, say so and justify it.
- Do not invent compliance that does not exist.
- If information is missing, ask me questions.
- Use Markdown format with tables.
- Expected length: 300-400 lines.
```

---

## Post-generation validation

- [ ] Every applicable NIST practice has a tool and a frequency.
- [ ] Omitted practices have an explicit justification.
- [ ] All 10 OWASP categories are covered (applicable or not, with reason).
- [ ] The traceability matrix connects SRS → NIST → OWASP → test.
- [ ] The tools match those in the Test Plan.

## What to do if the output does not meet expectations

| Problem | Action |
|---------|--------|
| Invents compliance that does not exist | Correct with "be honest: if something is not implemented, say so and justify it" |
| A NIST practice is missing | Ask "cover the 9 NIST practices listed, even if only to mark them as not applicable" |
| An OWASP category is missing | Ask "cover all 10 categories, with Yes/No and a reason for each one" |
| The traceability matrix is incomplete | Ask "connect each security requirement in the SRS with NIST, OWASP, and a test" |
| Tools do not match the Test Plan | Correct with "use exactly the tools from the Test Plan" |

## Save as
`docs/NIST_OWASP_Mapping.md`
