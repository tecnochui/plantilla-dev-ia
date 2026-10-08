# Prompt 1 — PRD-SRD (Product and Software Requirements Document)

🌍 **Read this in:** [Español](../es/01-PRD-SRD.md) | [English](01-PRD-SRD.md)

## Purpose
Define **what** is going to be built and **for whom**, before deciding **how**.

## Recommended model
DeepSeek web or Gemini web (free).

## Files to attach
None.

## When to use it
At the start of a new project, when the client/user describes what they want but there is no prior documentation.

---

## Complete prompt

```
Act as a product and requirements analyst. I am going to build a system called [NAME].

Business context:
- Problem it solves: [describe the problem]
- Users who will use it: [who they are]
- Value it provides: [why it is useful]

Initial scope:
- DOES include: [list of included features]
- DOES NOT include: [list of explicitly excluded features]

Generate the PRD-SRD with these sections:

1. Executive summary (3-5 lines)
2. Objectives and success metrics
3. Target users (personas)
4. User stories with acceptance criteria
5. Scope: included / excluded
6. Constraints and assumptions
7. Initial risks

Rules:
- Do not generate code or technical decisions (stack, languages, frameworks).
- Be specific and concrete. Avoid generalities like "the system must be fast".
- If information is missing for any section, ask me questions BEFORE making things up.
- Use Markdown format with tables and checkboxes.
- Expected length: 200-400 lines.

At the end, include a "Pending questions" section with everything you need clarified before continuing.
```

---

## Post-generation validation

- [ ] The executive summary explains the project in 3-5 lines without technical jargon.
- [ ] The objectives are measurable (not "be fast", but "respond in < 200ms").
- [ ] The user stories follow the format "As a [role], I want [action] so that [benefit]".
- [ ] The acceptance criteria are verifiable (not "works well").
- [ ] The excluded scope is explicit (avoids scope creep).
- [ ] The risks have estimated probability and impact.

## What to do if the output does not meet expectations

| Problem | Action |
|---------|--------|
| It is generic | Add more context to the prompt and regenerate |
| It makes up features | Correct with "do not include features I did not mention" |
| A section is missing | Ask "expand section X with more detail" |
| Too long | Ask "reduce to the essentials, remove redundancy" |

## Save as
`docs/PRD-SRD.md`
