# Documentation Prompts

🌍 **Read this in:** [Español](../es/README.md) | [English](README.md)

> Usage guide for the prompts that generate the project's foundational documentation.
> Each prompt generates **a single document**. They are validated sequentially before moving on.

---

## Sequential flow

```
1. PRD-SRD            → What are we building and for whom?
2. SRS                → What functional and non-functional requirements does it have?
3. Technical Proposal → How are we going to build it? (stack, architecture, license)
4. SSD-TDD            → How is it designed in detail? (architecture, DB, API)
5. NIST+OWASP Mapping → How do we comply with security?
6. Backup Strategy    → How do we back up and retain?
7. Test Plan          → How do we verify that it works and is secure?
```

Each document depends on the previous one. **No step is skipped.**

---

## Quick reference table

| # | Prompt | Depends on | Recommended model | Files to attach |
|---|--------|-----------|-------------------|-----------------|
| 1 | PRD-SRD | Nothing | DeepSeek web / Gemini web | None |
| 2 | SRS | PRD-SRD | DeepSeek web | docs/PRD-SRD.md |
| 3 | Technical Proposal | SRS | DeepSeek web / Gemini web | docs/SRS.md |
| 4 | SSD-TDD | SRS + Proposal | DeepSeek web | docs/SRS.md, docs/Technical_Proposal.md |
| 5 | NIST+OWASP Mapping | SSD-TDD | DeepSeek web | docs/SSD-TDD.md, docs/SRS.md |
| 6 | Backup Strategy | SSD-TDD | DeepSeek web | docs/SSD-TDD.md |
| 7 | Test Plan | SSD-TDD + SRS | DeepSeek web / Gemini web | docs/SRS.md, docs/SSD-TDD.md, docs/Technical_Proposal.md |
| 8 | Forensic Record | Existing code | DeepSeek via Zoo Code | The complete repo |

**Note on Prompt 8:** It is the only one not used at the start. It is used **after** the code exists, when you need to understand a system without documentation.

---

## Usage rules

1. **One prompt = one document.** Never ask for two documents in the same prompt.
2. **Validate before moving on.** If the document doesn't convince you, iterate on that prompt before moving to the next one.
3. **Attach the files when the prompt says so.** Without them, the AI makes things up.
4. **Use free web models.** Reserve Claude Sonnet via API only for critical cases.
5. **Save the result** with the exact name indicated in each prompt.
6. **Don't regenerate from scratch** if you only need to fix one section. Ask the AI to modify only that section.

---

## When to iterate and when to move on

| Situation | Action |
|-----------|--------|
| The document is complete and coherent | Save and move on to the next |
| Detail is missing in 1-2 sections | Ask the AI to expand those sections |
| The document is generic (not project-specific) | Regenerate with more context in the prompt |
| The document contradicts an SRS requirement | Regenerate the conflicting section |
| The document makes things up that you didn't tell it | Correct with "don't make things up, ask if context is missing" |

---

## Recommended models by task type

| Task | Model | Reason |
|------|-------|--------|
| Short, structured documents (PRD, SRS) | DeepSeek web | Fast, precise, no daily limit |
| Long documents with analysis (Proposal, SSD) | Gemini web | Better handling of long context |
| Documents with critical security decisions | Claude web | Better reasoning on security |
| Prompts and output validation | DeepSeek web | Consistent and without limits |

---

## Conventions

- **Language:** English (technical terms such as JWT, API, etc. are kept as-is).
- **Format:** Markdown with tables, checkboxes, and code blocks.
- **Expected length:** 300-500 lines for documents with analysis; 100-200 for operational documents.
- **Diagrams:** Mermaid when it adds clarity (architecture, flows, DB).
- **Code:** never generate code in these documents; only design decisions.

---

## Resulting file structure

```
docs/
├── PRD-SRD.md
├── SRS.md
├── Technical_Proposal.md
├── SSD-TDD.md
├── NIST_OWASP_Mapping.md
├── Backup_Strategy.md
├── Test_Plan.md
├── FORENSIC_RECORD.md
└── prompts/
    ├── README.md              ← This file
    ├── 01-PRD-SRD.md
    ├── 02-SRS.md
    ├── 03-Technical-Proposal.md
    ├── 04-SSD-TDD.md
    ├── 05-NIST-OWASP-Mapping.md
    ├── 06-Backup-Strategy.md
    ├── 07-Test-Plan.md
    └── 08-Forensic-Record.md
```

---

## How to use a prompt (step by step)

1. Open `docs/prompts/0X-Name.md`.
2. Copy **all the content** of the "Complete prompt" block.
3. Open the website of the recommended model.
4. Attach the files indicated in the "Files to attach" section.
5. Paste the prompt.
6. Wait for the response.
7. Validate with the "Post-generation validation" section of the file itself.
8. Save the result in `docs/Name.md`.
9. Move on to the next prompt.
