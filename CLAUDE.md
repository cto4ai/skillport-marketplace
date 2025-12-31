# Skillport Template

GitHub template repository for creating Claude Code Plugin Marketplaces with Skillport extensions.

## Project Overview

This is a **template repository** that organizations use to create their own Plugin Marketplaces. It provides:
- Standard Claude Code Plugin Marketplace format
- Skillport extensions for Claude.ai/Desktop support
- Example plugin with skill structure
- Documentation for creating plugins

## Sibling Repository

This project is part of a two-repo workspace:

| Repo | Purpose |
|------|---------|
| **skillport-template** (this repo) | GitHub template for creating marketplaces |
| **skillport-connector** | MCP connector deployed on Cloudflare Workers |

The connector is at `../skillport-connector/` in this workspace.

## How Organizations Use This

1. Click "Use this template" on GitHub (or clone)
2. Customize marketplace.json with org details
3. Add plugins in `plugins/` directory
4. For Claude Code: `/plugin marketplace add your-org/your-marketplace`
5. For Claude.ai/Desktop: Deploy skillport-connector pointing to this repo

## Directory Structure

```
.claude-plugin/
  marketplace.json       # Marketplace manifest (Claude Code format + extensions)
plugins/
  example-skill/
    plugin.json          # Plugin manifest
    skills/
      SKILL.md           # Skill instructions
    commands/            # Slash commands (Claude Code only)
    agents/              # Sub-agents (Claude Code only)
    scripts/             # Executable scripts
    references/          # Reference documentation
    assets/              # Asset files
docs/
  project-overview.md    # High-level overview
  creating-plugins.md    # Plugin creation guide
  marketplace-format.md  # Format specification
```

## Key Files

| File | Purpose |
|------|---------|
| [.claude-plugin/marketplace.json](.claude-plugin/marketplace.json) | Marketplace manifest |
| [plugins/example-skill/plugin.json](plugins/example-skill/plugin.json) | Example plugin manifest |
| [plugins/example-skill/skills/SKILL.md](plugins/example-skill/skills/SKILL.md) | Example skill |

## Marketplace Format

Uses standard Claude Code format with Skillport extensions:

```json
{
  "name": "your-marketplace",
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/my-plugin",
      "category": "productivity",
      "tags": ["example", "demo"],
      "keywords": ["sample", "starter"]
    }
  ]
}
```

### Official Plugin Metadata Fields

These fields are part of the official Claude Code Plugin Marketplace spec:

| Field | Type | Purpose |
|-------|------|---------|
| `category` | string | Category for organization (e.g., "productivity", "data") |
| `tags` | array | Tags for searchability |
| `keywords` | array | Keywords for discovery |

### Skillport Extensions

These fields are ignored by Claude Code but used by Skillport Connector:

| Field | Purpose |
|-------|---------|
| `skillPath` | Path to SKILL.md within plugin directory |
| `permissions` | Required permissions (web_search, code_execution, etc.) |
| `_skillport` | Marketplace-level Skillport metadata |

## Surface Compatibility

| Component | Claude Code | Claude Desktop | Claude.ai |
|-----------|:-----------:|:--------------:|:---------:|
| Skills | Yes | Yes | Yes |
| Commands | Yes | No | No |
| Agents | Yes | No | No |
| Scripts | Yes | Yes | Yes |
| References | Yes | Yes | Yes |

## Creating Plugins

See [docs/creating-plugins.md](docs/creating-plugins.md) for comprehensive guide.

Quick start:
```bash
mkdir -p plugins/my-plugin/skills
# Create plugin.json and skills/SKILL.md
# Add entry to .claude-plugin/marketplace.json
```

## Documentation

See `/docs/` for detailed documentation:
- [project-overview.md](docs/project-overview.md) - High-level project overview
- [creating-plugins.md](docs/creating-plugins.md) - Comprehensive plugin creation guide
- [marketplace-format.md](docs/marketplace-format.md) - Complete format specification

## Git Workflow

- Use conventional commits
- Push to main after user approval
- "save our work" means add, commit, push
