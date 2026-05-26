# Changelog

## v1.1.0 — 2026-05-26

### Added
- Two-layer update architecture: core files vs. user customizations
- `.gitleaks.core.toml` — core Drupal secret-scanning rules, auto-updated via `update.sh`
- `update.sh` — updates pre-commit hook and core gitleaks rules without touching your config
- `HOOK_VERSION` constant in pre-commit hook for traceability

### Changed
- `.gitleaks.toml` is now user-owned — extends `.gitleaks.core.toml`, never overwritten by updates
- `install.sh` now installs core and user gitleaks files separately

### Migration from v1.0.0
Run `bash update.sh` once. Your existing `.gitleaks.toml` allowlists will be preserved.
Add `[extend]\npath = ".gitleaks.core.toml"` to your `.gitleaks.toml` and remove rules now covered by core.

---

## v1.0.0 — 2026-05-20

- Initial release
- Pre-commit hook: Gitleaks + PHPCS + .env blocker + SQL dump blocker
- `.claude/settings.json`: deny rules for destructive git/shell operations
- `.claude/CLAUDE.md`: Drupal/DDEV conventions template
- `install.sh`: one-command setup
