# Skillport Marketplace

A GitHub template for creating skill marketplaces for Claude Code, Claude.ai, and Claude Desktop.

## What is Skillport?

Skillport enables organizations to share Skills across all Claude surfaces:

| Surface | How It Works |
|---------|--------------|
| **Claude Code** | Native skill installation |
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
  "name": "your-org-marketplace",
  "owner": {
    "name": "Your Organization",
    "email": "skills@yourorg.com"
  },
  "plugins": []
}
```

### 3. Set Up Access Control

Edit `.skillport/access.json` to control who can edit skills via Skillport Connector:

```json
{
  "editors": [
    { "id": "google:YOUR_GOOGLE_ID", "label": "your-email@example.com" }
  ]
}
```

**To get your Google ID:** Use the `whoami` tool in Skillport Connector, or check the connector logs after authenticating.

### 4. Add Your First Skill

Create a skill directory:

```
plugins/
└── my-skill/
    ├── .claude-plugin/
    │   └── plugin.json
    └── skills/
        └── my-skill/
            └── SKILL.md
```

Add to marketplace.json:

```json
{
  "plugins": [
    {
      "name": "my-skill",
      "source": "./plugins/my-skill",
      "description": "What this skill does",
      "version": "1.0.0"
    }
  ]
}
```

### 5. Use Your Marketplace

**Claude Code:**
```bash
# Add marketplace
claude mcp add-json skillport-connector '{"type":"url","url":"https://your-connector.workers.dev/sse"}'

# Install skills
# Use list_skills and install_skill tools via the connector
```

**Claude.ai / Claude Desktop:**
1. Deploy Skillport Connector (see [skillport-connector](https://github.com/cto4ai/skillport-connector))
2. Add connector in Settings > Connectors
3. Browse and install skills via the connector

## Repository Structure

```
your-marketplace/
├── .claude-plugin/
│   └── marketplace.json    # Skill manifest
├── .skillport/
│   └── access.json         # Editor access control
├── plugins/
│   ├── my-skill/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   └── skills/
│   │       └── my-skill/
│   │           ├── SKILL.md
│   │           ├── scripts/     # Optional helper scripts
│   │           ├── templates/   # Optional templates
│   │           └── references/  # Optional reference docs
│   └── another-skill/
│       └── ...
└── README.md
```

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
```

### Best Practices

1. **Clear triggers** — The description determines when Claude activates the skill
2. **Step-by-step instructions** — Be explicit about what to do
3. **Examples** — Show expected interactions
4. **Focused scope** — One skill, one purpose

## Example Skills

This template includes example skills in `plugins/`:

- `example-skill` — Basic skill structure demo
- `data-analyzer` — Data processing patterns
- `meeting-digest` — External service integration

## Development Branch

The `development` branch contains additional examples and development artifacts. Check it out for more complex skill patterns.

## Related Projects

| Project | Purpose |
|---------|---------|
| [skillport-connector](https://github.com/cto4ai/skillport-connector) | MCP Connector for Claude.ai/Desktop |
| This template | Create your own marketplace |

## License

MIT
