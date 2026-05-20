#!/usr/bin/env bash
# install.sh — drupal-claude-kit
#
# Installs the pre-commit hook and validates the setup.
# Run once from the root of your Drupal project:
#   curl -fsSL https://raw.githubusercontent.com/codeitwisely/drupal-claude-kit/main/install.sh | bash
#
# Or clone the repo and run:
#   bash install.sh

set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/codeitwisely/drupal-claude-kit/main"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  drupal-claude-kit — install"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ─── 1. Check gitleaks ────────────────────────────────────────────────────────
if command -v gitleaks &>/dev/null; then
  echo "✅ gitleaks: $(gitleaks version 2>/dev/null || echo 'found')"
else
  echo "⚠️  gitleaks not found."
  echo "   Install: brew install gitleaks"
  echo "   The pre-commit hook will warn but not block if gitleaks is missing."
fi

# ─── 2. Check DDEV ───────────────────────────────────────────────────────────
if command -v ddev &>/dev/null; then
  echo "✅ DDEV: $(ddev version 2>/dev/null | head -1 || echo 'found')"
else
  echo "⚠️  DDEV not found. Install: https://ddev.com/get-started/"
fi

# ─── 3. Copy .gitleaks.toml ──────────────────────────────────────────────────
if [ ! -f "$ROOT/.gitleaks.toml" ]; then
  if [ -f "$(dirname "$0")/.gitleaks.toml" ]; then
    cp "$(dirname "$0")/.gitleaks.toml" "$ROOT/.gitleaks.toml"
  else
    curl -fsSL "$REPO_URL/.gitleaks.toml" -o "$ROOT/.gitleaks.toml"
  fi
  echo "✅ .gitleaks.toml installed"
else
  echo "ℹ️  .gitleaks.toml already exists — skipping"
fi

# ─── 4. Install pre-commit hook ──────────────────────────────────────────────
HOOK_DIR="$ROOT/.git/hooks"
HOOK_FILE="$HOOK_DIR/pre-commit"

if [ ! -d "$HOOK_DIR" ]; then
  echo "❌ .git/hooks directory not found. Are you in a git repo?"
  exit 1
fi

if [ -f "$HOOK_FILE" ]; then
  echo "ℹ️  pre-commit hook already exists — backing up to pre-commit.bak"
  cp "$HOOK_FILE" "$HOOK_FILE.bak"
fi

if [ -f "$(dirname "$0")/.git-hooks/pre-commit" ]; then
  cp "$(dirname "$0")/.git-hooks/pre-commit" "$HOOK_FILE"
else
  curl -fsSL "$REPO_URL/.git-hooks/pre-commit" -o "$HOOK_FILE"
fi

chmod +x "$HOOK_FILE"
echo "✅ pre-commit hook installed"

# ─── 5. Copy .claude/ files (optional) ───────────────────────────────────────
if [ ! -d "$ROOT/.claude" ]; then
  read -p "Install .claude/CLAUDE.md and .claude/settings.json template? [y/N] " yn
  if [[ "$yn" =~ ^[Yy]$ ]]; then
    mkdir -p "$ROOT/.claude"
    if [ -f "$(dirname "$0")/.claude/CLAUDE.md" ]; then
      cp "$(dirname "$0")/.claude/CLAUDE.md" "$ROOT/.claude/CLAUDE.md"
      cp "$(dirname "$0")/.claude/settings.json" "$ROOT/.claude/settings.json"
    else
      curl -fsSL "$REPO_URL/.claude/CLAUDE.md" -o "$ROOT/.claude/CLAUDE.md"
      curl -fsSL "$REPO_URL/.claude/settings.json" -o "$ROOT/.claude/settings.json"
    fi
    echo "✅ .claude/ templates installed — customize CLAUDE.md for your project"
  fi
else
  echo "ℹ️  .claude/ already exists — skipping template install"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installation complete."
echo ""
echo "  Next steps:"
echo "  1. Review .gitleaks.toml — add project-specific allowlists if needed"
echo "  2. Customize .claude/CLAUDE.md with your project details"
echo "  3. Adjust .claude/settings.json permissions for your workflow"
echo "  4. Test the hook: git add <file> && git commit -m 'test'"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
