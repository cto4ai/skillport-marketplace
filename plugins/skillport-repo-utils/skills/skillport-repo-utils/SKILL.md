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

## Check Repository Consistency

Validates a marketplace repo for common issues:
- Duplicate plugin entries in marketplace.json
- Version mismatches between plugin.json and marketplace.json
- Missing required files (plugin.json, SKILL.md)
- Invalid SKILL.md frontmatter
- Missing plugin directories (listed in marketplace.json but don't exist)
- Non-compliant `.claude-plugin/` folders at skill level (should only exist at plugin level)

```bash
cd /path/to/your-marketplace
bash ~/.claude/skills/skillport-repo-utils/scripts/check-repo.sh
```

**Exit codes:**
- `0` - All checks passed (or only warnings)
- `1` - Errors found

**Example output:**
```
Checking: /Users/me/my-marketplace
===========================================

## Marketplace Structure

[OK]    Marketplace name: my-marketplace

## Duplicate Check

[OK]    No duplicate plugin entries

## Plugin Validation

--- my-plugin ---
[OK]    Version consistent: 1.0.0
[OK]    Skill 'my-skill': valid

## Unpublished Plugins

[OK]    All plugins are published

===========================================
Summary: 0 error(s), 0 warning(s)

All checks passed!
```

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
