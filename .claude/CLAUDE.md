# CLAUDE.md — Drupal Project Template

## Stack

- **Drupal**: 10.x / 11.x
- **PHP**: 8.3+
- **Local environment**: DDEV
- **Package manager**: Composer
- **Drush**: via DDEV (`ddev drush`)

---

## DDEV rules (mandatory)

All PHP/Drupal commands go through DDEV:

```bash
ddev drush <command>        # never: drush <command>
ddev composer <command>     # never: composer <command>
ddev exec phpcs <args>      # never: phpcs directly
ddev exec phpstan <args>
ddev exec phpunit <args>
```

DDEV management needs no prefix: `ddev start`, `ddev stop`, `ddev restart`, `ddev describe`.

---

## Git workflow

Every change — no matter how small — goes through a feature branch + PR:

1. `git checkout -b feature/[TICKET]-[short-slug]` from the base branch
2. Implement, commit: `[TICKET]: Short imperative description`
3. Push branch → open PR targeting base branch
4. **Never** `git push origin dev` or `git push origin main`

---

## Code quality

```bash
# PHPCS — run before every commit
ddev exec phpcs --standard=Drupal,DrupalPractice web/modules/custom/<module>
ddev exec phpcbf --standard=Drupal,DrupalPractice web/modules/custom/<module>

# PHPStan
ddev exec vendor/bin/phpstan analyse --configuration=phpstan.neon web/modules/custom/<module>
```

Both run automatically via pre-commit hook — never use `--no-verify`.

---

## Cache rebuild discipline

Run `ddev drush cr` **once** after all implementation steps are complete — not after each file edit.

**Exceptions** (run immediately, next step depends on it):
- After adding `*.services.yml`
- After adding `*.routing.yml`
- After `hook_install` / `hook_update_N`

---

## Drupal multilingual gotchas

### Views showing both language versions

Set **both**:
1. `rendering_language: '***LANGUAGE_language_interface***'`
2. Add a `langcode` filter with `value: '***LANGUAGE_language_interface***'`

Setting only one leaves the other unconstrained.

### `Url::fromRoute('<current>')` in preprocess

Use `Url::createFromRequest(\Drupal::request())` instead — `fromRoute('<current>')` silently fails in browser preprocess hooks.

---

## Security defaults

- Credentials live in `settings.local.php` or environment variables — never in committed config
- Key module values excluded from git via `.gitignore`: `config/sync/key.key.*.yml`
- SQL dumps never committed: `*.sql`, `*.sql.gz`, `*.dump` in `.gitignore`
- Gitleaks runs on every commit via pre-commit hook

---

## Module structure (custom modules)

```
web/modules/custom/<module>/
├── <module>.info.yml
├── <module>.module           # hooks only, keep thin
├── <module>.services.yml
├── src/
│   ├── Controller/
│   ├── Form/
│   ├── Service/              # business logic here
│   └── Plugin/
├── config/install/
└── tests/
    └── src/
        ├── Unit/
        └── Functional/
```

---

## Output standards

- Root cause with every fix — never just patch symptoms
- Flag deployment / caching / permission risks explicitly
- Run `ddev drush cr` at the end, not between every step
