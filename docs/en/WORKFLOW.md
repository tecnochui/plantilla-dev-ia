# Complete Workflow

🌍 **Read this in:** [Español](../es/FLUJO_DE_TRABAJO.md) | [English](WORKFLOW.md)

> Diagram and explanation of the end-to-end process, from "I want to build a system" to "release in production".

---

## Overview

```
┌──────────────────────────────────────────────────────────────────────┐
│                        PHASE 0: PREPARATION                          │
│                                                                       │
│  ./setup.sh --install-tools                                          │
│  • Creates folder structure                                           │
│  • Copies configuration files (AGENTS.md, workflows, etc.)           │
│  • Installs security tools (Semgrep, Trivy, Gitleaks)                │
│                                                                       │
│  Edit AGENTS.md → replace [PROJECT NAME]                             │
│  git add . && git commit -m "chore: initial setup"                   │
└──────────────────────────────────────────────────────────────────────┘
                                    ↓
┌──────────────────────────────────────────────────────────────────────┐
│                   PHASE 1: FOUNDATIONAL DOCUMENTATION                 │
│                                                                       │
│  Step 1: PRD-SRD        → What are we building and for whom?         │
│          Model: DeepSeek web / Gemini web                             │
│          Validate → save to docs/PRD-SRD.md                          │
│                                                                       │
│  Step 2: SRS            → Functional and non-functional requirements │
│          Attach: docs/PRD-SRD.md                                      │
│          Model: DeepSeek web                                          │
│          Validate → save to docs/SRS.md                               │
│                                                                       │
│  Step 3: Technical Proposal → Stack, architecture, licensing         │
│          Attach: docs/SRS.md                                          │
│          Model: DeepSeek web / Gemini web                             │
│          Validate → save to docs/Technical_Proposal.md               │
│                                                                       │
│  Step 4: SSD-TDD        → Detailed design (architecture, DB, API)    │
│          Attach: docs/SRS.md + docs/Technical_Proposal.md            │
│          Model: DeepSeek web                                          │
│          Validate → save to docs/SSD-TDD.md                          │
│                                                                       │
│  Step 5: NIST+OWASP Mapping → Security compliance                    │
│          Attach: docs/SSD-TDD.md + docs/SRS.md                       │
│          Model: DeepSeek web / Claude web                             │
│          Validate → save to docs/NIST_OWASP_Mapping.md               │
│                                                                       │
│  Step 6: Backup Strategy → Backups and log retention                 │
│          Attach: docs/SSD-TDD.md                                      │
│          Model: DeepSeek web                                          │
│          Validate → save to docs/Backup_Strategy.md                  │
│                                                                       │
│  Step 7: Test Plan      → Complete testing strategy                  │
│          Attach: docs/SRS.md + docs/SSD-TDD.md + Proposal            │
│          Model: DeepSeek web / Gemini web                             │
│          Validate → save to docs/Test_Plan.md                        │
│                                                                       │
│  ─────────────────────────────────────────────────────────────────   │
│  ✅ The 7 documents are approved. NOW you can start coding.          │
└──────────────────────────────────────────────────────────────────────┘
                                    ↓
┌──────────────────────────────────────────────────────────────────────┐
│                       PHASE 2: DEVELOPMENT                           │
│                                                                       │
│  For each module of the SSD-TDD:                                     │
│                                                                       │
│  Zoo Code (Architect mode) + DeepSeek V4 Flash                       │
│  → Prompt: "Read AGENTS.md, docs/PRD-SRD.md, docs/SRS.md,            │
│     docs/SSD-TDD.md. Propose a plan to implement [module]."          │
│                                                                       │
│  Zoo Code (Code mode) + DeepSeek V4 Flash                            │
│  → Prompt: "Implement the module according to the approved plan.     │
│     Follow the SSD conventions."                                      │
│                                                                       │
│  Zoo Code (Debug mode) + Qwen3 Coder Next                            │
│  → Prompt: "Run tests, identify the error, fix it, re-run."          │
│                                                                       │
│  Pre-commit hook validates on every commit:                          │
│  • lint-staged (formatting)                                           │
│  • Gitleaks (secrets)                                                 │
│  • ESLint security / Bandit (SAST)                                    │
│  • commitlint (Conventional Commits)                                  │
└──────────────────────────────────────────────────────────────────────┘
                                    ↓
┌──────────────────────────────────────────────────────────────────────┐
│                    PHASE 3: SECURITY REVIEW                          │
│                                                                       │
│  git push → GitHub Actions runs workflows in parallel:               │
│                                                                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                  │
│  │ tests.yml   │  │ sast.yml    │  │ sca.yml     │                  │
│  │ + Codecov   │  │ Semgrep     │  │ Trivy       │                  │
│  └─────────────┘  └─────────────┘  └─────────────┘                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                  │
│  │ secrets.yml │  │ commitlint  │  │ dast.yml    │                  │
│  │ Gitleaks    │  │             │  │ OWASP ZAP   │                  │
│  └─────────────┘  └─────────────┘  └─────────────┘                  │
│                                                                       │
│  If CRITICAL or HIGH → merge blocked                                 │
│  If coverage drops or patch has less than 50% → merge blocked        │
└──────────────────────────────────────────────────────────────────────┘
                                    ↓
┌──────────────────────────────────────────────────────────────────────┐
│                          PHASE 4: RELEASE                            │
│                                                                       │
│  git tag v1.0.0                                                      │
│  git push origin v1.0.0                                              │
│                                                                       │
│  → changelog.yml generates CHANGELOG.md automatically                │
│  → If deploy.yml is configured, deploys to production                │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Workflow for an existing project without documentation

When you find a system without documentation (your own or third-party):

```
1. FORENSIC ANALYSIS
   Zoo Code (Architect mode) + DeepSeek V4 Flash
   → Prompt: "Analyze this system. Generate docs/FORENSIC_RECORD.md
      with module inventory, data flow, entry points,
      dependencies, dark zones and security findings."

2. GENERATE RETROSPECTIVE DOCUMENTATION
   • Reverse README.md (what it does, how to use it)
   • CHANGELOG.md from git log
   • Retrospective PRD-SRD (what the code already does)
   • Retrospective SRS
   • Retrospective SSD-TDD

3. CONTINUE DEVELOPMENT
   From this point, the workflow is the same as for a new project.
   AGENTS.md instructs the AI to always read FORENSIC_RECORD.md.
```

---

## Quick decision table

| Situation | Action |
|-----------|--------|
| New project | Phase 0 → 1 → 2 → 3 → 4 |
| Existing project without docs | Forensic analysis → Retrospective documentation → Phase 2 |
| Existing project with docs | Phase 2 (update docs if necessary) |
| Critical bug in production | Zoo Code Debug → fix → PR → merge |
| New feature | Update SRS → SSD-TDD → Phase 2 |
| Stack change | Technical Proposal → SSD-TDD → Phase 2 |
