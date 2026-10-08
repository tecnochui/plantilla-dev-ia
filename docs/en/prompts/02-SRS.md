# Prompt 2 — SRS (Software Requirements Specification)

🌍 **Read this in:** [Español](../es/02-SRS.md) | [English](02-SRS.md)

## Purpose
Detail the system's functional and non-functional requirements, with traceability to the PRD-SRD.

## Recommended model
DeepSeek web.

## Files to attach
`docs/PRD-SRD.md`

## When to use it
After the PRD-SRD has been validated and approved.

---

## Complete prompt

```
Based on the attached PRD-SRD, generate the SRS (Software Requirements Specification) following the IEEE 830 / ISO 29148 standard.

Required sections:

1. Introduction
   - Purpose
   - Scope
   - Definitions, acronyms, and abbreviations
   - References

2. Overall description
   - Product perspective
   - Main functions
   - Target users
   - General constraints
   - Assumptions and dependencies

3. Functional requirements
   - Numbered (FR-001, FR-002, ...)
   - Each with: description, priority (High/Medium/Low), acceptance criteria
   - Traceability: each FR must map to a user story in the PRD-SRD

4. Non-functional requirements
   - Performance (response times, throughput)
   - Security (authentication, authorization, encryption)
   - Usability (accessibility, languages)
   - Availability (expected uptime, fault tolerance)
   - Maintainability (test coverage, documentation)
   - Portability (operating systems, browsers)

5. External interfaces
   - User interfaces
   - Hardware interfaces
   - Software interfaces (third-party APIs)
   - Communication interfaces (protocols)

6. Design constraints
   - Technical constraints
   - Regulatory constraints
   - Business constraints

7. Traceability matrix
   - Table: user story (PRD-SRD) → functional requirement (SRS)

Rules:
- Be explicit about boundaries. Every requirement must be verifiable.
- If information is missing, ask me questions before making things up.
- Do not generate technical decisions (stack, framework). Requirements only.
- Do not generate code.
- Use Markdown format with tables and checkboxes.
- Expected length: 400-600 lines.
```

---

## Post-generation validation

- [ ] Each functional requirement has a unique ID (FR-001, FR-002...).
- [ ] Each non-functional requirement has a metric (not "fast", but "< 200ms").
- [ ] The traceability matrix covers all user stories in the PRD-SRD.
- [ ] The requirements are prioritized (High/Medium/Low).
- [ ] The external interfaces list concrete protocols (REST, gRPC, WebSocket).

## What to do if the output does not meet expectations

| Problem | Action |
|---------|--------|
| Generic requirements | Add more context to the PRD-SRD and regenerate |
| Non-measurable requirements | Ask "every requirement must have a verifiable metric" |
| Missing traceability matrix | Ask "generate the complete PRD-SRD → SRS matrix" |
| No prioritization | Ask "assign High/Medium/Low priority to each FR" |
| Contradicts the PRD-SRD | Regenerate the conflicting section |

## Save as
`docs/SRS.md`
