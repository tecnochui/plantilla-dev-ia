# Prompt 6 — Backup and Log Retention Strategy

🌍 **Read this in:** [Español](../es/06-Estrategia-Respaldos.md) | [English](06-Backup-Strategy.md)

## Purpose
Define how the project's assets are backed up and how long logs are retained.

## Recommended model
DeepSeek web.

## Files to attach
`docs/SSD-TDD.md`

## When to use it
After the SSD-TDD has been validated.

---

## Complete prompt

```
Based on the attached SSD-TDD, generate the Backup and Log Retention Strategy for this project.

Before starting, ask me these questions:

1. Where do you want to store the backups? (local, cloud, remote git, mixed)
2. How long do you want to retain application logs? (days, weeks, months)
3. How long do you want to retain security logs? (recommendation: minimum 90 days)
4. Do you have a budget for cloud storage? (if not, local only)

With my answers, generate:

1. Assets to back up
   - Source code
   - Database
   - Configurations
   - Logs
   - Documentation
   - Secrets (are they backed up? how?)

2. Backup frequency per asset
   - Table: asset → frequency → destination → retention

3. Backup destination
   - Local: concrete paths
   - Cloud: provider, bucket, encryption
   - Remote git: what is versioned and what is not

4. Applied 3-2-1 backup rule
   - 3 copies of the data
   - 2 different media
   - 1 off-site copy

5. Retention
   - How long to keep each type of backup
   - When to compress (e.g., after 30 days)
   - When to delete (e.g., after 1 year)

6. Log retention
   - Application logs: how long, what format
   - Access logs: how long
   - Security logs: how long (minimum 90 days)
   - Rotation: when and how

7. Restoration procedure
   - Step by step to restore from backup
   - Post-restoration verification

8. Backup verification
   - How to test that backups are restorable
   - Frequency of restoration tests

9. Automation
   - Required scripts or cron jobs
   - Tools (rsync, restic, borgbackup, etc.)

Rules:
- Be specific about paths, commands, and frequencies.
- Include example scripts (bash) for the backups.
- If information is missing, ask me questions.
- Expected length: 200-300 lines.
```

---

## Post-generation validation

- [ ] The 3-2-1 backup rule is applied with concrete destinations.
- [ ] Each asset has a defined frequency and retention.
- [ ] The restoration procedure is step by step.
- [ ] The backup scripts are executable (valid bash).
- [ ] Security log retention is ≥ 90 days.

## What to do if the output does not meet expectations

| Problem | Action |
|---------|--------|
| Backups are not restorable | Ask "the restoration procedure must be step by step and verifiable" |
| Missing 3-2-1 backup rule | Ask "apply the 3-2-1 backup rule with concrete destinations for each asset" |
| Insufficient log retention | Ask "security logs must be retained for at least 90 days" |
| Scripts are not executable | Ask "validate the bash syntax of each script and use absolute paths" |
| No restoration verification | Ask "include a restoration test plan with a defined frequency" |

## Save as
`docs/Backup_Strategy.md`
