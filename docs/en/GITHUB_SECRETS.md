# GitHub Secrets

🌍 **Read this in:** [Español](../es/GITHUB_SECRETS.md) | [English](GITHUB_SECRETS.md)

> Guide to configure the required secrets in GitHub Actions.
> Secrets are encrypted at rest and only exposed to authorized workflows.

---

## How to add a secret

1. Go to the repository on GitHub.
2. **Settings** → **Secrets and variables** → **Actions**.
3. Click on **New repository secret**.
4. Name: (see table below). Value: (the real secret).
5. Click **Add secret**.

**They cannot be read back.** If you lose the value, you must rotate it.

---

## Project secrets

### `CODECOV_TOKEN`

| Field | Value |
|-------|-------|
| **Name** | `CODECOV_TOKEN` |
| **Workflow that uses it** | `tests.yml` |
| **Mandatory** | Yes (for coverage) |
| **Where to get it** | [codecov.io](https://about.codecov.io/) → Register repo → Settings → Repository Upload Token |
| **How to rotate it** | Regenerate on Codecov and update on GitHub |
| **Rotation frequency** | Every 6 months or if leaked |

**How to get it:**
1. Go to [codecov.io](https://about.codecov.io/) and create an account (free for public repos).
2. Connect with GitHub.
3. Select the repository.
4. Copy the **Repository Upload Token**.
5. Add it as a secret on GitHub with the name `CODECOV_TOKEN`.

---

### `SSH_HOST`, `SSH_USER`, `SSH_KEY` (only if you use deploy)

| Field | Value |
|-------|-------|
| **Name** | `SSH_HOST` |
| **Workflow that uses it** | `deploy.yml` (if enabled) |
| **Mandatory** | Only if you use deploy to VPS |
| **Where to get it** | Server IP or domain |
| **Example** | `203.0.113.42` or `my-server.com` |

| Field | Value |
|-------|-------|
| **Name** | `SSH_USER` |
| **Workflow that uses it** | `deploy.yml` |
| **Mandatory** | Only if you use deploy to VPS |
| **Where to get it** | Server user (e.g., `deploy`, `ubuntu`) |
| **Example** | `deploy` |

| Field | Value |
|-------|-------|
| **Name** | `SSH_KEY` |
| **Workflow that uses it** | `deploy.yml` |
| **Mandatory** | Only if you use deploy to VPS |
| **Where to get it** | SSH private key (without passphrase) from the server |
| **How to rotate it** | Generate a new key, update `authorized_keys` on the server, update secret on GitHub |
| **Rotation frequency** | Every 6 months |

**How to generate the SSH key:**

```bash
# On your local machine
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/deploy_key -N ""

# Copy the public key to the server
ssh-copy-id -i ~/.ssh/deploy_key.pub deploy@your-server.com

# Copy the content of the private key to the SSH_KEY secret
cat ~/.ssh/deploy_key
```

**Warning:** The private key must include the lines `-----BEGIN OPENSSH PRIVATE KEY-----` and `-----END OPENSSH PRIVATE KEY-----`.

---

### `GITHUB_TOKEN`

| Field | Value |
|-------|-------|
| **Name** | `GITHUB_TOKEN` |
| **Workflow that uses it** | All |
| **Mandatory** | Automatic |
| **Where to get it** | GitHub provides it automatically |
| **How to rotate it** | GitHub rotates it for you |
| **Rotation frequency** | Automatic |

**Does not require manual configuration.** GitHub Actions injects this token into every workflow that declares it in `permissions`.

---

## Optional secrets (depending on deploy target)

If you use any of the templates in `template/docs/deploy.yml.example`, you need the corresponding secrets:

| Target | Required secrets |
|--------|------------------|
| **Own VPS** | `SSH_HOST`, `SSH_USER`, `SSH_KEY` |
| **Vercel** | `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID` |
| **Docker Hub + VPS** | `DOCKER_USERNAME`, `DOCKER_TOKEN`, `SSH_HOST`, `SSH_USER`, `SSH_KEY` |
| **GitHub Pages** | None (uses `GITHUB_TOKEN`) |
| **Home server (Cloudflare)** | `CLOUDFLARE_TOKEN`, `SSH_HOST`, `SSH_USER`, `SSH_KEY` |

---

## Environments (optional, for production deploy)

GitHub allows creating **environments** to require manual approval before deploying.

### Configure the `production` environment

1. **Settings** → **Environments** → **New environment**.
2. Name: `production`.
3. Check **Required reviewers** → select your user.
4. Save.

In the deploy workflow, use:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://your-domain.com
```

With this, every time the workflow is triggered, GitHub will ask for manual approval before running the steps.

---

## Initial configuration checklist

When creating a new project, configure these secrets:

- [ ] `CODECOV_TOKEN` (required for coverage)
- [ ] `SSH_HOST`, `SSH_USER`, `SSH_KEY` (if you use deploy to VPS)
- [ ] Verify that `GITHUB_TOKEN` is available (it is automatic)
- [ ] Create the `production` environment (if you use deploy with approval)

---

## Verification

To verify that a secret is configured correctly:

1. Go to **Settings** → **Secrets and variables** → **Actions**.
2. Verify that the secret appears in the list.
3. Push to `main` and verify that the workflow using it runs without authentication errors.

---

## Secret rotation

| Secret | Recommended frequency |
|--------|-----------------------|
| `CODECOV_TOKEN` | Every 6 months |
| `SSH_KEY` | Every 6 months |
| `VERCEL_TOKEN` | Every 6 months |
| `DOCKER_TOKEN` | Every 6 months |
| `CLOUDFLARE_TOKEN` | Every 6 months |

**Rotation procedure:**

1. Generate a new value in the corresponding service.
2. Update the secret on GitHub (Settings → Secrets → Edit).
3. Verify that the workflows still work.
4. Revoke the previous value in the service.

---

## If a secret is leaked

1. **Revoke immediately** the secret in the source service.
2. **Rotate it** (create a new one and replace it on GitHub).
3. **Check logs** to detect unauthorized uses.
4. **Document** the incident in `docs/Test_Plan.md` → section 9 (exceptions).
5. **If the secret was in Git**, remove it from the history with `git filter-repo` or BFG.

---

## References

- [`WORKFLOWS.md`](WORKFLOWS.md) — Workflows documentation
- [`SECURITY.md`](SECURITY.md) — NIST SSDF alignment
- [`../../template/docs/deploy.yml.example`](../../template/docs/deploy.yml.example) — Deploy templates
- [GitHub Docs — Encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
