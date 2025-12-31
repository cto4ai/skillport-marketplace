# Skillport Template

A GitHub template for creating Claude Code Plugin Marketplaces that also work with Claude.ai and Claude Desktop via Skillport Connector.

## What is Skillport?

Skillport enables organizations to share Skills and plugins across all Claude surfaces:

| Surface | How It Works |
|---------|--------------|
| **Claude Code** | Native — uses Plugin Marketplace directly |
| **Claude Desktop** | Via Skillport Connector (MCP) |
| **Claude.ai** | Via Skillport Connector (MCP) |

**One marketplace, all surfaces.**

## Quick Start

### 1. Create Your Marketplace

Click **"Use this template"** on GitHub to create your own marketplace repository.

### 2. Configure Your Marketplace

Edit `.claude-plugin/marketplace.json`:

```json
{
  "name": "your-org-skillport",
  "owner": {
    "name": "Your Organization",
    "email": "plugins@yourorg.com"
  },
  "plugins": []
}
```

### 3. Add Your First Plugin

Create a plugin directory:

```
plugins/
└── my-first-skill/
    ├── plugin.json
    └── skills/
        └── SKILL.md
```

Add to marketplace.json:

```json
{
  "plugins": [
    {
      "name": "my-first-skill",
      "source": "./plugins/my-first-skill",
      "description": "What this skill does",
      "version": "1.0.0",
      "category": "productivity",
      "tags": ["example"]
    }
  ]
}
```

### 4. Use Your Marketplace

**Claude Code (native):**
```bash
/plugin marketplace add your-org/your-marketplace
/plugin install my-first-skill@your-marketplace
```

**Claude.ai / Claude Desktop:**
1. Deploy Skillport Connector (see [skillport-connector](../skillport-connector))
2. Add connector to Claude.ai Settings > Connectors
3. Browse and install skills via the connector

## Repository Structure

```
your-marketplace/
├── .claude-plugin/
│   └── marketplace.json    # Plugin manifest (required)
├── plugins/
│   ├── skill-one/
│   │   ├── plugin.json     # Plugin metadata
│   │   ├── skills/
│   │   │   └── SKILL.md    # For Claude.ai/Desktop
│   │   ├── commands/       # For Claude Code (optional)
│   │   └── agents/         # For Claude Code (optional)
│   └── skill-two/
│       └── ...
├── docs/
│   └── marketplace-format.md
└── README.md
```

## Marketplace Format

This template uses the **standard Claude Code Plugin Marketplace format** with Skillport extensions.

### Standard Fields (Claude Code)

These are defined by Anthropic and work natively with Claude Code:

```json
{
  "name": "marketplace-name",
  "owner": { "name": "...", "email": "..." },
  "metadata": { "description": "...", "version": "..." },
  "plugins": [
    {
      "name": "plugin-name",
      "source": "./plugins/plugin-name",
      "description": "...",
      "version": "1.0.0",
      "author": { "name": "..." },
      "commands": "./commands/",
      "agents": "./agents/"
    }
  ]
}
```

### Skillport Extensions

These fields are **ignored by Claude Code** but used by Skillport Connector:

```json
{
  "plugins": [
    {
      "name": "plugin-name",
      "source": "./plugins/plugin-name",
      "skillPath": "skills/SKILL.md",
      "permissions": ["web_search"]
    }
  ],

  "_skillport": {
    "version": "1.0.0"
  }
}
```

| Extension Field | Purpose |
|-----------------|---------|
| `skillPath` | Path to SKILL.md within the plugin |
| `permissions` | Permissions required by the skill |
| `_skillport` | Marketplace-level Skillport metadata |

See [docs/marketplace-format.md](docs/marketplace-format.md) for complete schema.

## Plugin Components

A plugin can contain multiple components:

| Component | File/Directory | Claude Code | Claude.ai/Desktop |
|-----------|----------------|:-----------:|:-----------------:|
| **Skills** | `skills/SKILL.md` | ✅ | ✅ (via Skillport) |
| **Commands** | `commands/*.md` | ✅ | ❌ |
| **Agents** | `agents/*.md` | ✅ | ❌ |
| **Hooks** | `hooks/` | ✅ | ❌ |
| **MCP Servers** | configured in plugin.json | ✅ | ❌ |

**Skills work everywhere.** Commands, agents, and hooks are Claude Code-specific.

## Creating Effective Skills

### SKILL.md Structure

```markdown
---
name: skill-name
description: Brief description that helps Claude know when to activate this skill.
---

# Skill Name

## When to Use This Skill

- Trigger condition 1
- Trigger condition 2

## Instructions

1. Step one
2. Step two
3. Step three

## Examples

**User:** "Example request"
**Action:** What Claude should do

## Resources

- List of files/tools this skill uses

## Notes

- Additional context
```

### Best Practices

1. **Clear triggers** — The description and "When to Use" sections determine when Claude activates the skill
2. **Step-by-step instructions** — Be explicit about what to do
3. **Examples** — Show expected interactions
4. **Focused scope** — One skill, one purpose

See [docs/creating-plugins.md](docs/creating-plugins.md) for detailed guide.

## Team Distribution

### Automatic Installation

Add to `.claude/settings.json` in project repos:

```json
{
  "extraKnownMarketplaces": {
    "your-org-skillport": {
      "source": {
        "source": "github",
        "repo": "your-org/your-marketplace"
      }
    }
  }
}
```

Team members who trust the repo folder automatically get the marketplace.

### Enterprise Controls

Admins can restrict marketplace sources via managed settings. See [Claude Code docs](https://code.claude.com/docs/en/plugin-marketplaces) for details.

## Relationship to Skillport Connector

```
┌─────────────────────────────────────┐
│      This Repository                │
│      (Plugin Marketplace)           │
│                                     │
│  Claude Code reads directly ───────────────► Claude Code
│                                     │
│  Skillport Connector reads ─────────────────► Claude.ai
│  and serves via MCP                 │         Claude Desktop
└─────────────────────────────────────┘
```

The marketplace is the **source of truth**. Claude Code uses it natively. Skillport Connector reads it and serves Skills to Claude.ai/Desktop.

## Example Plugins

This template includes an example plugin at `plugins/example-skill/`. Use it as a starting point for your own plugins.

## Documentation

- [Marketplace Format](docs/marketplace-format.md) — Complete schema reference
- [Creating Plugins](docs/creating-plugins.md) — Step-by-step plugin creation guide

## Related Projects

| Project | Purpose |
|---------|---------|
| [skillport-connector](../skillport-connector) | MCP Connector for Claude.ai/Desktop |
| [skillport-marketplace-template](.) | This template |
| Your marketplace | Your instance created from this template |

## License

MIT
