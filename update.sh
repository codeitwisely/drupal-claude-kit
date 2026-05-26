#!/usr/bin/env bash
# update.sh — drupal-claude-kit
#
# Updates ONLY core-owned files. Your customizations are never touched.
#
# Core files updated:
#   - .git/hooks/pre-commit      hook logic (secrets + PHPCS + SQL blocker)
#   - .gitleaks.core.toml        Drupal-specific detection rules
#
# Never touched:
#   - .gitleaks.toml             your project allowlists
#   - .claude/settings.json      your permission config
#   - .claude/CLAUDE.md          your project context
#
# Usage:
#   bash update.sh
#   curl -fsSL https://raw.githubusercontent.com/codeitwisely/drupal-claude-kit/main/update.sh | bash

set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/codeitwisely/drupal-claude-kit/main"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  drupal-claude-kit — update"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Core files will be updated."
echo "  Your .gitleaks.toml, settings.json, and CLAUDE.md are safe."
echo ""

# ─── 1. Update pre-commit hook ────────────────────────────────────────────────
HOOK_FILE="$ROOT/.git/hooks/pre-commit"

if [ ! -d "$ROOT/.git/hooks" ]; then
  echo "❌ .git/hooks not found — are you in a git repository?"
  exit 1
fi

OLD_VERSION=""
if [ -f "$HOOK_FILE" ]; then
  OLD_VERSION=$(grep -m1 'HOOK_VERSION=' "$HOOK_FILE" | cut -d'"' -f2 || echo "unknown")
fi

if [ -f "$(dirname "$0")/.git-hooks/pre-commit" ]; then
  cp "$(dirname "$0")/.git-hooks/pre-commit" "$HOOK_FILE"
else
  curl -fsSL "$REPO_URL/.git-hooks/pre-commit" -o "$HOOK_FILE"
fi

chmod +x "$HOOK_FILE"
NEW_VERSION=$(grep -m1 'HOOK_VERSION=' "$HOOK_FILE" | cut -d'"' -f2 || echo "unknown")

if [ "$OLD_VERSION" = "$NEW_VERSION" ]; then
  echo "✅ pre-commit hook: already at v$NEW_VERSION"
else
  echo "✅ pre-commit hook: v$OLD_VERSION → v$NEW_VERSION"
fi

# ─── 2. Update .gitleaks.core.toml ───────────────────────────────────────────
CORE_TOML="$ROOT/.gitleaks.core.toml"

if [ -f "$(dirname "$0")/.gitleaks.core.toml" ]; then
  cp "$(dirname "$0")/.gitleaks.core.toml" "$CORE_TOML"
else
  curl -fsSL "$REPO_URL/.gitleaks.core.toml" -o "$CORE_TOML"
fi

echo "✅ .gitleaks.core.toml: updated"

# ─── 3. Verify .gitleaks.toml extends core ───────────────────────────────────
USER_TOML="$ROOT/.gitleaks.toml"

if [ ! -f "$USER_TOML" ]; then
  echo ""
  echo "⚠️  .gitleaks.toml not found — creating minimal version that extends core..."
  cat > "$USER_TOML" <<'EOF'
# .gitleaks.toml — YOUR project allowlists
# This file is yours. update.sh never touches it.
# Core Drupal rules live in .gitleaks.core.toml (auto-updated).

title = "Gitleaks — project config"

[extend]
path = ".gitleaks.core.toml"

# Add your project-specific [[allowlists]] below
EOF
  echo "✅ .gitleaks.toml: created"
elif ! grep -q 'gitleaks.core.toml' "$USER_TOML"; then
  echo ""
  echo "⚠️  .gitleaks.toml does not extend .gitleaks.core.toml"
  echo "   Add this to your .gitleaks.toml:"
  echo ""
  echo '   [extend]'
  echo '   path = ".gitleaks.core.toml"'
  echo ""
  echo "   Then remove any duplicate rules already covered by core."
fi

# ─── 4. Ensure .gitleaks.core.toml is gitignored ─────────────────────────────
GITIGNORE="$ROOT/.gitignore"

if [ -f "$GITIGNORE" ]; then
  if ! grep -q '\.gitleaks\.core\.toml' "$GITIGNORE"; then
    echo "" >> "$GITIGNORE"
    echo "# drupal-claude-kit — auto-downloaded, do not commit" >> "$GITIGNORE"
    echo ".gitleaks.core.toml" >> "$GITIGNORE"
    echo "✅ .gitignore: .gitleaks.core.toml added"
  else
    echo "✅ .gitignore: already excludes .gitleaks.core.toml"
  fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Update complete."
echo ""
echo "  To check for settings.json / CLAUDE.md changes:"
echo "  https://github.com/codeitwisely/drupal-claude-kit/blob/main/CHANGELOG.md"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
