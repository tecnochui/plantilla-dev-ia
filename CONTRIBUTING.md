# Contributing to plantilla-dev-ia

🌍 **Read this in:** [Español](CONTRIBUTING.es.md) | [English](CONTRIBUTING.md)

Thanks for your interest in improving this project. This guide explains how to contribute effectively.

---

## Commit conventions

This project uses **Conventional Commits**:

```
<type>(<scope>): <description>
```

**Valid types:** `feat`, `fix`, `security`, `docs`, `chore`, `refactor`, `test`, `perf`, `ci`, `build`, `revert`.

**Examples:**

- `feat(prompts): add prompt for dependency audit`
- `fix(scripts): handle paths with spaces in init-project.sh`
- `docs(readme): add English translation`
- `security(gitleaks): update rules for new API keys`

Commits are validated automatically by the `commit-msg` hook. If your commit message does not follow the format, the commit will be rejected.

---

## Workflow

1. **Fork** the repository.
2. **Create a branch**: `git checkout -b feat/my-improvement`.
3. **Make your changes** following the code style of the project.
4. **Verify hooks pass** (`pre-commit` and `commit-msg` run automatically on commit).
5. **Push to your branch**: `git push origin feat/my-improvement`.
6. **Open a Pull Request**.

### Branch naming

| Type | Example |
|------|---------|
| Feature | `feat/add-deploy-workflow` |
| Bug fix | `fix/shellcheck-warning` |
| Documentation | `docs/update-readme` |
| Security | `security/update-gitleaks-rules` |
| Refactor | `refactor/init-project-script` |

---

## Pull Request requirements

All PRs must pass the following automated checks before they can be merged:

| Check | Workflow | Blocks merge |
|-------|----------|--------------|
| Structure validation | `validate-template.yml` | Yes |
| Shell lint | `validate-template.yml` | Yes |
| Config validation | `validate-template.yml` | Yes |
| Template test | `validate-template.yml` | Yes |
| Markdown lint | `validate-template.yml` | Informational |

**The 4 first checks must pass for the PR to be mergeable.** Markdown lint issues are reported but do not block the merge.

### What to include in your PR

- **Clear title** following Conventional Commits (e.g., `feat(template): add bilingual README`).
- **Description** explaining what changes and why.
- **Reference to related issues** if applicable (`Closes #123`).
- **Screenshots** if the change affects rendered output (docs, diagrams).

---

## Code style

### Shell scripts

- Use `#!/usr/bin/env bash` at the top.
- `set -euo pipefail` for safety.
- Use `[[ ]]` instead of `[ ]` for conditionals.
- Quote variables: `"$VAR"` not `$VAR`.
- Pass ShellCheck with no warnings.

### Markdown

- Use ATX headings (`#`, `##`, `###`) — not Setext.
- Fenced code blocks must specify a language (` ```bash `, ` ```yaml `).
- Tables should be aligned for readability.
- Maximum line length: 80 characters (except for tables and long URLs).

### YAML

- 2-space indentation.
- No trailing whitespace.
- Use `kebab-case` for keys where applicable.

---

## Bug reports

When opening an issue for a bug, include:

- **Environment**: OS, version of Bash, Node.js, Python.
- **Steps to reproduce**: exact commands.
- **Expected behavior** vs. **actual behavior**.
- **Logs or screenshots** if applicable.

---

## Feature requests

When opening an issue for a feature:

- **Use case**: why is this feature needed?
- **Proposed solution**: how would you implement it?
- **Alternatives considered**: what other approaches were evaluated?

---

## Security issues

**Do not open public issues for security vulnerabilities.** Instead, open a private security advisory on GitHub:

1. Go to the **Security** tab.
2. Click **Report a vulnerability**.
3. Provide a detailed description.

---

## Code of conduct

Be respectful. Harassment, discrimination, and personal attacks are not tolerated.

Disagreements about technical decisions are fine — focus on the idea, not the person.

---

## License

By contributing, you agree that your contribution will be licensed under the **MIT License**, the same license as this project. See [`LICENSE`](LICENSE) for details.

---

## Questions?

If you have questions before contributing:

- Open an issue with the `question` label.
- Check the documentation in [`docs/`](docs/).
- See [`scripts/README.md`](scripts/README.md) and [`scripts/README.es.md`](scripts/README.es.md) for script-specific help.

---

> **Thank you for contributing!**
