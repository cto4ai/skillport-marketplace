# Marketplace Format

Complete reference for the Skillport marketplace format.

## Overview

Skillport marketplaces use the **standard Claude Code Plugin Marketplace format** with optional extensions. This means:

- ✅ Claude Code works natively (no modifications needed)
- ✅ Skillport Connector reads extended fields
- ✅ Claude Code ignores fields it doesn't recognize

## File Location

The marketplace manifest must be at:

```
.claude-plugin/marketplace.json
```

## Schema

### Root Object

```json
{
  "name": "string (required)",
  "owner": { /* required */ },
  "metadata": { /* optional */ },
  "plugins": [ /* required */ ],
  "_skillport": { /* optional, Skillport extension */ }
}
```

### Required Fields

#### name

Marketplace identifier. Use kebab-case, no spaces.

```json
"name": "acme-corp-skillport"
```

#### owner

Marketplace maintainer information.

```json
"owner": {
  "name": "ACME Corporation",
  "email": "plugins@acme.com"
}
```

#### plugins

Array of plugin entries (see below).

### Optional Fields

#### metadata

```json
"metadata": {
  "description": "Internal plugins for ACME Corp",
  "version": "1.0.0",
  "pluginRoot": "./plugins"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | Brief marketplace description |
| `version` | string | Marketplace version (semver) |
| `pluginRoot` | string | Base path for relative plugin sources |

### Skillport Extensions

#### _skillport

Marketplace-level Skillport metadata. Claude Code ignores this.

```json
"_skillport": {
  "version": "1.0.0",
  "features": ["skill-packaging", "surface-filtering"]
}
```

## Plugin Entries

Each plugin in the `plugins` array.

### Required Plugin Fields

#### name

Plugin identifier. Use kebab-case, no spaces.

```json
"name": "sales-pitch-generator"
```

#### source

Where to fetch the plugin. Three formats supported:

**Relative path** (same repo):
```json
"source": "./plugins/sales-pitch"
```

**GitHub repository**:
```json
"source": {
  "source": "github",
  "repo": "acme/sales-plugin"
}
```

**Git URL**:
```json
"source": {
  "source": "url",
  "url": "https://gitlab.com/acme/plugin.git"
}
```

### Standard Optional Fields

These are defined by Claude Code:

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | Brief plugin description |
| `version` | string | Semver version |
| `author` | object | `{ name, email }` |
| `homepage` | string | Documentation URL |
| `repository` | string | Source code URL |
| `license` | string | SPDX license ID (e.g., "MIT") |
| `keywords` | array | Discovery tags |
| `category` | string | Plugin category |
| `tags` | array | Additional tags |
| `strict` | boolean | Require plugin.json (default: true) |

### Component Fields

Specify where plugin components are located:

| Field | Type | Description |
|-------|------|-------------|
| `commands` | string \| array | Path(s) to command files |
| `agents` | string \| array | Path(s) to agent files |
| `hooks` | object \| string | Hook configuration or path |
| `mcpServers` | object \| string | MCP server configuration |

### Skillport Extension Fields

Claude Code ignores these. Skillport Connector uses them.

#### surfaces

Array of target surfaces.

```json
"surfaces": ["claude-code", "claude-desktop", "claude-ai"]
```

| Value | Surface |
|-------|---------|
| `claude-code` | Claude Code CLI |
| `claude-desktop` | Claude Desktop app |
| `claude-ai` | Claude.ai web interface |

If omitted, plugin is assumed to work on all surfaces (for applicable components).

#### skillPath

Path to SKILL.md within the plugin directory.

```json
"skillPath": "skills/SKILL.md"
```

Default: `"skills/SKILL.md"`

#### permissions

Permissions required by the skill.

```json
"permissions": ["web_search", "code_execution"]
```

Common values:
- `web_search` — Needs web search tool
- `code_execution` — Needs to run code
- `file_access` — Needs filesystem access

## Complete Example

```json
{
  "name": "acme-skillport",
  "owner": {
    "name": "ACME Corporation",
    "email": "plugins@acme.com"
  },
  "metadata": {
    "description": "Internal plugins for ACME Corp",
    "version": "2.0.0"
  },
  "plugins": [
    {
      "name": "sales-pitch",
      "source": "./plugins/sales-pitch",
      "description": "Generate compelling sales pitches from product specs",
      "version": "1.2.0",
      "author": {
        "name": "Sales Team",
        "email": "sales@acme.com"
      },
      "category": "sales",
      "tags": ["sales", "writing", "proposals"],
      "keywords": ["pitch", "proposal", "sales"],
      
      "surfaces": ["claude-code", "claude-desktop", "claude-ai"],
      "skillPath": "skills/SKILL.md",
      "permissions": ["web_search"]
    },
    {
      "name": "code-review-agent",
      "source": "./plugins/code-review",
      "description": "Automated code review with security focus",
      "version": "2.0.0",
      "author": {
        "name": "Engineering"
      },
      "category": "development",
      
      "commands": ["./commands/"],
      "agents": ["./agents/security-reviewer.md"],
      
      "surfaces": ["claude-code"],
      "permissions": []
    },
    {
      "name": "brand-guidelines",
      "source": {
        "source": "github",
        "repo": "acme/brand-plugin"
      },
      "description": "Apply ACME brand guidelines to content",
      "version": "1.0.0",
      
      "surfaces": ["claude-code", "claude-desktop", "claude-ai"],
      "skillPath": "SKILL.md"
    }
  ],
  
  "_skillport": {
    "version": "1.0.0",
    "features": ["skill-packaging", "surface-filtering"]
  }
}
```

## Validation

### Claude Code

Claude Code validates marketplace.json when you add the marketplace:

```bash
/plugin marketplace add ./path/to/marketplace
```

### Manual Validation

Use Claude Code's validation:

```bash
claude plugin validate .
```

### Schema Rules

1. `name` must be kebab-case (lowercase, hyphens only)
2. `version` should follow semver
3. `source` paths are relative to marketplace root
4. GitHub repos use `owner/repo` format (no .git suffix)

## Compatibility Notes

### Claude Code Behavior

- Ignores unknown fields (safe to add Skillport extensions)
- Requires `plugin.json` in plugin folder when `strict: true` (default)
- With `strict: false`, marketplace entry serves as manifest

### Skillport Connector Behavior

- Reads standard fields plus Skillport extensions
- Filters by `surfaces` when listing plugins
- Uses `skillPath` to locate SKILL.md
- Falls back to defaults when extensions are missing

## Migration

### From Custom Format

If you have an existing custom skill library:

1. Create `.claude-plugin/marketplace.json`
2. Move skills into `plugins/<n>/skills/SKILL.md`
3. Add plugin entries with `surfaces` extension
4. Test with Claude Code: `/plugin marketplace add ./`

### Adding Skillport to Existing Claude Code Marketplace

If you have an existing Claude Code marketplace:

1. Add `surfaces` to plugin entries
2. Add `skillPath` if SKILL.md isn't at default location
3. Optionally add `_skillport` metadata
4. No changes needed for Claude Code — it ignores new fields
