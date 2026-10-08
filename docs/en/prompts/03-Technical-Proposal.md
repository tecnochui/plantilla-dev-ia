# Prompt 3 — Technical Proposal

🌍 **Read this in:** [Español](../es/03-Propuesta-Tecnica.md) | [English](03-Technical-Proposal.md)

## Purpose
Decide **how** the system will be built: stack, high-level architecture, licensing strategy.

## Recommended model
DeepSeek web or Gemini web.

## Files to attach
`docs/SRS.md`

## When to use it
After the SRS has been validated.

---

## Complete prompt

```
Based on the attached SRS, generate the Technical Proposal for this project.

Before starting, ask me these questions:

1. Will the system be 100% free/open source, 100% proprietary, or an open-core model (free community edition plus a paid enterprise edition)?
2. Do you have a preference for any language or framework? (if not, recommend one)
3. Does the system need to run in a specific environment? (Linux, Windows, web, containers)
4. Are there budget constraints for infrastructure? (e.g., $0, $10/month)

With my answers, generate:

1. Recommended technology stack
   - Programming language(s)
   - Backend framework(s)
   - Frontend framework(s) (if applicable)
   - Database
   - Infrastructure (local, containers, cloud)
   - CI/CD

2. Justification for each choice
   - For each technology, compare it against 2 alternatives
   - Explain why this one was chosen and not the others
   - Mention trade-offs (performance, learning curve, maintenance)

3. High-level architecture
   - Mermaid diagram (flowchart or C4)
   - Main components
   - Data flow between components

4. Deployment strategy
   - How it is deployed in development
   - How it is deployed in production
   - Rollback strategy

5. Licensing strategy
   - Based on my answer, recommend licenses for the project
   - List dependencies compatible with that license
   - Warn about incompatible dependencies (e.g., GPL in a proprietary project)

6. Technical risks and mitigations
   - Table: risk → probability → impact → mitigation

Rules:
- Do not generate code. Technical decisions with justification only.
- If information is missing, ask me questions before making things up.
- Use Mermaid diagrams for architecture.
- Expected length: 300-500 lines.
```

---

## Post-generation validation

- [ ] Each chosen technology has a justification with compared alternatives.
- [ ] The architecture has a Mermaid diagram.
- [ ] The licensing strategy is coherent with the chosen model.
- [ ] The recommended dependencies have no license conflicts.
- [ ] The technical risks have a concrete mitigation.

## What to do if the output does not meet expectations

| Problem | Action |
|---------|--------|
| Stack without justification | Ask "compare each technology against 2 alternatives and explain the trade-off" |
| Missing Mermaid diagram | Ask "generate the high-level architecture Mermaid diagram" |
| Ignores my answers to the questions | Correct with "use the answers I gave you, do not assume" |
| Incompatible licenses | Ask "check the compatibility of each dependency with the chosen license" |
| Risks without mitigation | Ask "each risk must have a concrete, actionable mitigation" |

## Save as
`docs/Technical_Proposal.md`
