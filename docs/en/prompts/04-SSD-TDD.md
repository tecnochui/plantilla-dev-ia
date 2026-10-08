# Prompt 4 — SSD-TDD (Software Design Document + Technical Design Document)

🌍 **Read this in:** [Español](../es/04-SSD-TDD.md) | [English](04-SSD-TDD.md)

## Purpose
Detailed design: module architecture, DB schema, API contracts, security decisions.

## Recommended model
DeepSeek web.

## Files to attach
`docs/SRS.md` + `docs/Technical_Proposal.md`

## When to use it
After the Technical Proposal has been validated.

---

## Complete prompt

```
Based on the attached SRS and Technical Proposal, generate the SSD-TDD (Software Design Document + Technical Design Document).

Required sections:

1. Detailed architecture
   - Component diagram (Mermaid)
   - Application layers (presentation, logic, data)
   - Design patterns applied (MVC, Repository, CQRS, etc.)
   - Justification for each pattern

2. Database design
   - Entity-Relationship diagram (Mermaid erDiagram)
   - Tables: name, columns, types, constraints
   - Recommended indexes
   - Relationships (1:1, 1:N, N:M)
   - Migration strategy (Alembic, Flyway, etc.)
   - Backup strategy (at the DB level)

3. API design
   - Endpoints: method, path, description
   - Input contracts (request body, query params)
   - Output contracts (response body)
   - Error codes and their meaning
   - Authentication and authorization per endpoint
   - Rate limiting per endpoint

4. Diagrams
   - Components (Mermaid)
   - Sequence for critical flows (login, payment, etc.)
   - States for entities with a state machine
   - Database ER

5. Security decisions in the design
   - Authentication: JWT, OAuth2, sessions
   - Authorization: RBAC, ABAC, ACL
   - Encryption: in transit (TLS), at rest (AES-256)
   - Secret management: .env, vault, KMS
   - Input validation: sanitization, whitelisting
   - Secure logging: what NOT to log (PII, secrets)

6. Testing strategy (summary)
   > Note: full details are in `docs/Test_Plan.md`.
   - Testing pyramid (unit, integration, E2E)
   - Tools per level
   - Coverage threshold

Rules:
- Use Mermaid diagrams so Zoo Code renders them in VS Code.
- Do not generate code. Design only.
- If information is missing, ask me questions before making things up.
- Be specific in the API contracts (use example JSON).
- Expected length: 500-800 lines.
```

---

## Post-generation validation

- [ ] The ER diagram covers all entities in the SRS.
- [ ] Every endpoint has documented input and output contracts.
- [ ] The security section covers the 10 points of the OWASP Top 10:2025.
- [ ] The Mermaid diagrams are valid (render without errors).
- [ ] Section 6 references `Test_Plan.md` (does not duplicate it).

## What to do if the output does not meet expectations

| Problem | Action |
|---------|--------|
| Mermaid diagrams do not render | Ask "validate the Mermaid syntax and fix the errors" |
| Entities from the SRS are missing | Ask "review the SRS and add all missing entities to the ER" |
| Incomplete API contracts | Ask "every endpoint must have an example request body and response body" |
| Shallow security | Ask "cover the 10 points of the OWASP Top 10:2025 with a concrete decision" |
| Duplicates the Test Plan | Correct with "in section 6 only summarize and reference, do not duplicate" |

## Save as
`docs/SSD-TDD.md`
