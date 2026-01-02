# Conventional Commits Reference

## Format

```
<type>[optional scope][!]: <description>

[optional body]

[optional footer(s)]
```

## Types

| Type | When to Use |
|------|-------------|
| `feat` | New feature for users |
| `fix` | Bug fix for users |
| `docs` | Documentation only |
| `style` | Formatting, whitespace (no code change) |
| `refactor` | Code change that neither fixes nor adds |
| `perf` | Performance improvement |
| `test` | Adding/fixing tests |
| `build` | Build system, dependencies |
| `ci` | CI configuration |
| `chore` | Maintenance, tooling |
| `revert` | Reverting previous commit |

## Scope Examples

- `feat(auth):` - Authentication module
- `fix(api):` - API layer
- `docs(readme):` - README file
- `refactor(utils):` - Utility functions

## Breaking Changes

Two ways to indicate:

1. `!` after type/scope: `feat(api)!: change response format`
2. Footer: `BREAKING CHANGE: <description>`

## Footer Keywords

- `BREAKING CHANGE:` - Breaking change description
- `Fixes #123` - Closes issue
- `Refs #456` - References issue
- `Co-authored-by:` - Credit co-authors

## Examples

### Simple feature
```
feat(cart): add quantity selector to product cards
```

### Bug fix with body
```
fix(auth): resolve token refresh race condition

Multiple concurrent requests could trigger simultaneous
refresh attempts. Add mutex lock around refresh logic.

Fixes #892
```

### Breaking change
```
feat(api)!: require authentication for all endpoints

BREAKING CHANGE: Anonymous access removed. All requests
must include valid bearer token.
```

### Multi-scope refactor
```
refactor: consolidate error handling

- Unify error response format across services
- Add error codes enum
- Remove deprecated error helpers
```
