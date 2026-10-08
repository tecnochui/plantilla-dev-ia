# Prompt 8 — Forensic Record (Reverse Engineering)

🌍 **Read this in:** [Español](../es/08-Registro-Forense.md) | [English](08-Forensic-Record.md)

## Purpose
Generate `docs/FORENSIC_RECORD.md` from the analysis of a system without documentation (your own or third-party).

## Recommended model
DeepSeek V4 Flash via Zoo Code (Architect mode).

## Files to attach
- The system's source code (via Zoo Code, which can read the whole repo)
- If it exists, any prior documentation (README.md, comments)

## When to use it
**After** the code exists. It is the only prompt that is not used at the start of the project.
It is used when:
- You inherit a project without documentation.
- You pick up an old project of yours that you never documented.
- You need to modify a third-party system you do not understand.

## Difference from the other prompts

| Aspect | Prompts 1-7 | Prompt 8 |
|--------|-------------|----------|
| **When** | At the start, before coding | When code already exists |
| **What it produces** | Design documents (forward-looking) | Record of findings (backward-looking) |
| **Model** | DeepSeek web / Gemini web | DeepSeek via Zoo Code (needs to read files) |
| **Iteration** | Validate and move on | Updated continuously |

---

## Complete prompt

```
Act as a forensic software engineer. I need you to analyze this system without documentation and generate a Forensic Record that documents what you discover.

Context:
- System type: [web / API / script / desktop / mixed]
- Origin: [own without docs / third-party / unknown]
- My goal: [what I need to do with this system]
- Available time: [urgency of the analysis]

Analysis process (follow this order):

1. INVENTORY
   - List all relevant directories and files
   - For each one, indicate: type, inferred purpose, confidence (High/Medium/Low)
   - Ignore node_modules/, venv/, dist/, build/, .git/

2. DATA FLOW
   - Draw a Mermaid diagram with the main flow
   - Identify inputs, transformations, and outputs
   - Mark the points where there is interaction with the outside

3. ENTRY POINTS
   - List all points through which the system receives input
   - For each one: protocol, port, authentication, notes
   - Include HTTP endpoints, CLI commands, cron jobs, webhooks

4. EXTERNAL DEPENDENCIES
   - List the critical dependencies
   - For each one: version, type, detected risk
   - Verify known vulnerabilities if possible

5. DATABASE SCHEMA
   - If there is a DB, draw the ER diagram in Mermaid
   - List tables, columns, relationships
   - Indicate whether indexes or foreign keys are missing

6. DARK ZONES
   - List what you could NOT understand
   - For each zone: file/module, why it is not understood, what is needed to understand it

7. PENDING VERIFICATIONS
   - List concrete actions to complete the analysis
   - Prioritize by impact

8. SECURITY FINDINGS
   - First pass: hardcoded secrets, endpoints without auth, logs with PII
   - Classify by severity (High/Medium/Low)
   - Suggest an action for each finding

Rules:
- Do NOT make things up. If you do not understand something, mark it as a "dark zone".
- Be specific about paths and file names.
- Use Mermaid for diagrams (flowchart and erDiagram).
- Mark each finding with a date for the history.
- At the end, include a section "Instructions for future AI sessions" with rules so that another session can continue the analysis.
- Expected length: 200-500 lines (depends on the size of the system).

Output format: Markdown following the template at docs/FORENSIC_RECORD.md.
```

---

## Post-generation validation

- [ ] The inventory covers all relevant directories (excluding the ignored ones).
- [ ] The flow diagram is coherent with the entry points.
- [ ] The dark zones are marked as unresolved checkboxes.
- [ ] The security findings have severity and a suggested action.
- [ ] The "Instructions for future sessions" section explains how to update the record.

## How to use the generated record

1. **Save** the result in `docs/FORENSIC_RECORD.md`.
2. **Commit** with `docs(forensic): initial analysis of [name]`.
3. **In each future AI session**, verify that `AGENTS.md` instructs the AI to read the record before modifying code.
4. **Update** the record when:
   - A dark zone is resolved → mark it as resolved.
   - A pending item is completed → mark it as completed.
   - A new finding is discovered → add it with a date.
   - A module is modified → update its entry in the inventory.

## Iteration

The Forensic Record **is not a one-time document.** It is alive. It is updated with each analysis session. Section 10 (History) records each update.

## What to do if the output does not meet expectations

| Problem | Action |
|---------|--------|
| Makes things up that it cannot verify | Correct with "if you do not understand something, mark it as a dark zone, do not make things up" |
| Does not use Mermaid diagrams | Ask "generate the flowchart of the data flow and the erDiagram of the DB" |
| Dark zones are missing | Ask "explicitly list everything you could not understand and what is needed to understand it" |
| Security findings without severity | Ask "classify each finding by severity (High/Medium/Low) and suggest an action" |
| Does not include instructions for future sessions | Ask "add the instructions section so that another AI session can continue the analysis" |

## Save as
`docs/FORENSIC_RECORD.md`