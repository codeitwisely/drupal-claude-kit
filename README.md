# drupal-claude-kit

Production-ready Claude Code setup for Drupal 10/11 + DDEV.
One command. No configuration required to get started.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/codeitwisely/drupal-claude-kit/main/install.sh)
```

---

## What you get

```
your-drupal-project/
├── .gitleaks.core.toml     ← core Drupal rules (auto-updated, do not edit)
├── .gitleaks.toml          ← YOUR allowlists — extends core, never overwritten
├── .claudeignore           ← keeps Claude focused on custom code only
├── .git/hooks/pre-commit   ← runs on every commit (see below)
└── .claude/
    ├── CLAUDE.md           ← Drupal/DDEV conventions Claude reads every session
    └── settings.json       ← deny rules: no push to main, no rm -rf, no ~/.ssh reads
```

### Two-layer design

| File | Owner | Updated by |
|---|---|---|
| `.gitleaks.core.toml` | drupal-claude-kit | `update.sh` — auto |
| `.git/hooks/pre-commit` | drupal-claude-kit | `update.sh` — auto |
| `.gitleaks.toml` | **you** | never overwritten |
| `.claude/settings.json` | **you** | never overwritten |
| `.claude/CLAUDE.md` | **you** | never overwritten |

Your customizations survive every update.

**Pre-commit hook blocks:**
- Secrets in staged files (Gitleaks)
- PHPCS errors against `Drupal,DrupalPractice` standards
- `.env` files
- SQL dumps

---

## Prerequisites

| Tool | Install |
|---|---|
| [DDEV](https://ddev.com) | `brew install ddev` |
| [Gitleaks](https://github.com/gitleaks/gitleaks) | `brew install gitleaks` |
| [Claude Code](https://claude.ai/code) | `npm install -g @anthropic-ai/claude-code` |

PHPCS via DDEV:

```bash
ddev composer require --dev drupal/coder
ddev exec vendor/bin/phpcs --config-set installed_paths vendor/drupal/coder/coder_sniffer
```

---

## Staying up to date

```bash
# Update core files (hook + gitleaks rules) — your customizations are safe
bash update.sh

# Or without cloning:
curl -fsSL https://raw.githubusercontent.com/codeitwisely/drupal-claude-kit/main/update.sh | bash
```

`settings.json` and `CLAUDE.md` are never touched by `update.sh`. Check [CHANGELOG.md](CHANGELOG.md) when a new version is released to see if manual updates are recommended.

---

## After install

**CLAUDE.md** — add your project context:
```markdown
## Project
- Name: my-project
- Jira prefix: MP
- Custom modules: web/modules/custom/my_module/
- Theme: web/themes/custom/my_theme/
```

**settings.json** — adjust `allow`/`deny` arrays for your workflow. Defaults block the most common destructive operations.

**`.gitleaks.toml`** — add allowlists for project-specific false positives.

---

## Go further — skills, agents & rules

This kit gives you the safety layer. For a full AI-assisted Drupal development workflow with 30+ skills, 9 agents, and 8 rule files covering entity API, caching, security, migrations, testing and more:

→ **[drupal-ai](https://github.com/edutrul/drupal-ai)** by Eduardo Telaya — a developer toolkit (not a Drupal module) built as knowledge files consumed by AI coding agents.
Full architecture: [eduardotelaya.com/drupal-ai](https://eduardotelaya.com/drupal-ai) · Drupal project page: [ai_code_guardrails](https://www.drupal.org/project/ai_code_guardrails)

---

## Why deterministic guardrails?

Claude Code operates autonomously across files, git, and terminal. Guardrails in `settings.json` are enforced at the tooling level — they cannot be overridden by prompt content, no matter what the model is asked to do.

> `CLAUDE.md` instructions are probabilistic. `settings.json` deny rules are not.

---

## License

[MIT](LICENSE) — free to use, modify, and distribute.
Built by [CodeIt Wisely](https://codeitwisely.ai)
