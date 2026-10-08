# Backup and Log Retention Strategy

🌍 **Read this in:** [Español](../es/Estrategia_Respaldos.md) | [English](Backup_Strategy.md)

> **Status:** Pending drafting.
> **Instructions:** Use Prompt 6 (`docs/en/prompts/06-Backup-Strategy.md`) with DeepSeek web.
> **Depends on:** `docs/en/SSD-TDD.md`

---

## 1. Assets to back up

| Asset | Description | Criticality |
|-------|-------------|-------------|
| Source code | Git repository | High |
| Database | Production data | High |
| Configurations | Config files (no secrets) | Medium |
| Logs | Application and security logs | Medium |
| Documentation | Documents in `docs/` | Medium |

## 2. Backup frequency

| Asset | Frequency | Destination | Retention |
|-------|-----------|-------------|-----------|
| Source code | Every push | GitHub | Permanent |
| Database | [Daily/Weekly] | [Destination] | [30 days] |
| Configurations | [Weekly] | [Destination] | [90 days] |
| Logs | [Continuous] | [Destination] | [90 days] |

## 3. Backup destination

### 3.1. Local
- **Path:** [e.g. `/var/backups/my-app/`]
- **Format:** [e.g. `.tar.gz`, `.sql.gz`]
- **Encryption:** [Yes/No, with what]

### 3.2. Cloud
- **Provider:** [e.g. Backblaze B2, S3, etc.]
- **Bucket:** [name]
- **Encryption:** [Yes/No, with what]

### 3.3. Remote Git
- **Repository:** [URL]
- **What is versioned:** Code, documentation, configuration (no secrets)
- **What is NOT versioned:** `.env`, credentials, production data

## 4. 3-2-1 rule

- **3 copies:** [Code locally + GitHub + mirror]
- **2 media:** [SSD + cloud, or external disk + cloud]
- **1 off-site:** [Cloud, or external disk in another location]

## 5. Retention

| Backup type | Retention | Compression | Deletion |
|-------------|-----------|-------------|----------|
| Daily | 30 days | After 7 days | Automatic |
| Weekly | 90 days | After 30 days | Automatic |
| Monthly | 1 year | Immediate | Automatic |
| Yearly | 5 years | Immediate | Manual |

## 6. Log retention

| Log type | Retention | Format | Rotation |
|----------|-----------|--------|----------|
| Application | [30 days] | [JSON/Text] | [Daily] |
| Access | [90 days] | [Common Log Format] | [Daily] |
| Security | [≥ 90 days] | [JSON] | [Daily] |
| Errors | [90 days] | [JSON] | [Daily] |

**Note:** Security logs **must never contain** sensitive data (PII, passwords, tokens).

## 7. Restoration procedure

### Restore code
```bash
git clone [url]
cd [project]
git checkout [tag or commit]
```

### Restore database
```bash
# [Engine-specific command]
pg_restore -d [db] [backup.dump]
```

### Restore configuration
```bash
tar -xzf [backup.tar.gz] -C [destination]
```

### Post-restoration verification
- [ ] The code clones without errors.
- [ ] The DB restores without errors.
- [ ] The application starts correctly.
- [ ] The tests pass.

## 8. Backup verification

| Test | Frequency | Responsible |
|------|-----------|-------------|
| Code restoration | [Monthly] | [You] |
| DB restoration | [Monthly] | [You] |
| Integrity verification | [Weekly] | [Automatic] |

## 9. Automation

### Database backup script (example)
```bash
#!/usr/bin/env bash
# backup-db.sh
set -euo pipefail

DATE=$(date +%Y%m%d_%H%M%S)
DESTINATION="/var/backups/my-app/db"
mkdir -p "$DESTINATION"

pg_dump -Fc my_db > "$DESTINATION/my_db_$DATE.dump"
gzip "$DESTINATION/my_db_$DATE.dump"

# Delete backups older than 30 days
find "$DESTINATION" -name "*.dump.gz" -mtime +30 -delete

echo "Backup completed: my_db_$DATE.dump.gz"
```

### Cron job
```cron
# Daily backup at 3 AM
0 3 * * * /usr/local/bin/backup-db.sh >> /var/log/backup.log 2>&1
```
