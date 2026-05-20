# drupal-claude-kit

A minimal, production-ready Claude Code setup for Drupal 10/11 projects running on DDEV.

Drop this into any Drupal project to get:

- **Secrets scanning** on every commit (Gitleaks)
- **Coding standards** enforcement (PHPCS / Drupal + DrupalPractice)
- **SQL dump blocker** — client data never reaches git history
- **Claude Code guardrails** — deny rules that prevent destructive operations
- **CLAUDE.md template** — Drupal-specific conventions Claude reads every session

---

## Quick install

```bash
# From your Drupal project root (must be a git repo):
bash <(curl -fsSL https://raw.githubusercontent.com/codeitwisely/drupal-claude-kit/main/install.sh)
```

Or clone and run manually:

```bash
git clone https://github.com/codeitwisely/drupal-claude-kit.git
cd your-drupal-project
bash ../claude-code-drupal-starter/install.sh
```

---

## What gets installed

```
your-drupal-project/
├── .gitleaks.toml              ← Drupal-specific secret scanning rules
├── .git/hooks/pre-commit       ← Gitleaks + PHPCS + SQL dump blocker
└── .claude/
    ├── CLAUDE.md               ← Claude reads this every session
    └── settings.json           ← Deny rules (push to main, rm -rf, etc.)
```

---

## Prerequisites

| Tool | Install |
|---|---|
| [DDEV](https://ddev.com) | `brew install ddev` |
| [Gitleaks](https://github.com/gitleaks/gitleaks) | `brew install gitleaks` |
| Claude Code | `npm install -g @anthropic-ai/claude-code` |

PHPCS is expected via `ddev exec phpcs` — install it in your project:

```bash
ddev composer require --dev drupal/coder
ddev exec vendor/bin/phpcs --config-set installed_paths vendor/drupal/coder/coder_sniffer
```

---

## What the pre-commit hook does

On every `git commit`:

1. **Gitleaks** scans staged files for secrets (API keys, passwords, tokens)
2. **PHPCS** checks staged PHP/module/theme files against `Drupal,DrupalPractice` standards
3. **SQL dump blocker** rejects any `.sql`, `.sql.gz`, or `.dump` file

The hook skips PHPCS gracefully if DDEV is not running. It warns (but doesn't block) if Gitleaks is not installed.

---

## Customizing `.gitleaks.toml`

Add project-specific allowlists for false positives:

```toml
[[allowlists]]
description = "My project's test credentials"
paths = [
  '''tests/fixtures/.*''',
]
```

---

## Customizing `.claude/CLAUDE.md`

Edit `.claude/CLAUDE.md` to add your project-specific context:

- Project name and Jira prefix
- Custom modules and their purpose
- Theme name and structure
- Known gotchas and decisions

Claude reads this file at the start of every session.

---

## Customizing `.claude/settings.json`

The included `settings.json` blocks:
- Pushing to `dev`, `main`, `master`
- Force push
- `composer require` (requires human approval)
- `ddev drush en` (requires human approval)
- Reading `~/.ssh/`, `~/.aws/`, `~/.gnupg/`
- `rm -rf`

Adjust the `allow` and `deny` arrays for your workflow.

---

## Why these guardrails?

Claude Code operates autonomously across files, git, and terminal. Without guardrails:

- Secrets can leak into commit history
- Destructive git operations can happen silently
- Client PII in SQL dumps can be committed accidentally
- `composer require` can introduce unvetted dependencies

These are deterministic controls — they cannot be overridden by prompt content.

---

## License

MIT — use freely, adapt for your projects.

Built by [CodeItWisely](https://codeitwisely.ai)
