---
name: skillport-repo-utils
description: >
  Local utilities for managing skills in a Skillport marketplace repo.
  For Claude Code users working directly with the repo filesystem.
---

# Skillport Repo Utils

Utilities for local skill management. These scripts work directly on the filesystem - no MCP connector required.

## Prerequisites

These scripts are installed with this skill at:
```
~/.claude/skills/skillport-repo-utils/scripts/
```

**Important:** Run these scripts from within your Skillport marketplace repo directory (must contain `.claude-plugin/marketplace.json`).

## Delete a Skill

Removes a skill and updates marketplace.json. If the skill is the last one in its plugin group, the entire plugin directory is removed.

```bash
cd /path/to/your-marketplace
bash ~/.claude/skills/skillport-repo-utils/scripts/delete-skill.sh <skill-name>
```

The script will:
1. Find the skill directory in `plugins/*/skills/<skill-name>/`
2. Remove it from the filesystem
3. Update `.claude-plugin/marketplace.json` to remove the plugin entry
4. If it was the last skill in the plugin, remove the entire plugin directory

## Copy a Skill from Another Repo

Copies a skill (and its plugin if needed) from another Skillport marketplace repo.

```bash
cd /path/to/target-marketplace
bash ~/.claude/skills/skillport-repo-utils/scripts/copy-skill.sh <source-repo-path> <skill-name>
```

**Example:**
```bash
cd ~/Projects/my-marketplace
bash ~/.claude/skills/skillport-repo-utils/scripts/copy-skill.sh ../other-marketplace my-skill
```

The script will:
1. Find the skill in the source repo
2. Copy the skill directory (or entire plugin if new)
3. Update `.claude-plugin/marketplace.json` with the plugin entry
