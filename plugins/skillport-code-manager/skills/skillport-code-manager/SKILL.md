---
name: skillport-code-manager
description: >
  Manages Skills from Skillport marketplaces — browse available skills, install them
  efficiently, and check for updates. For Claude Code.
---

# Skillport Code Manager

## Prerequisites

The Skillport Connector must be added as a remote MCP server:

```bash
claude mcp add --transport sse skillport https://skillport-connector.jack-ivers.workers.dev/sse --scope user
```

Verify by checking if these tools exist:
- `mcp__skillport__list_skills`
- `mcp__skillport__install_skill`

## List Skills

Call `mcp__skillport__list_skills`. Present results as a brief list showing name, description, and version.

## Get Skill Details

Call `mcp__skillport__fetch_skill_details` with `name` parameter. This returns the SKILL.md content which describes capabilities, usage, and examples.

## Install a Skill

### Step 1: Get Install Token

Call `mcp__skillport__install_skill` with the skill name.

Response includes:
- `install_token`: Short-lived token (5 min TTL)
- `skill`: Skill name
- `version`: Skill version

### Step 2: Run Install Script

Run the `command` from the response. It will look something like:

```bash
curl -sf https://skillport-connector.jack-ivers.workers.dev/install.sh | bash -s -- <token>
```

Note: No `--package` flag - writes directly to `~/.claude/skills/`.

### Step 3: Report Success

Tell user: "Installed <skill> v<version> to ~/.claude/skills/. **Start a new Claude Code conversation to use this skill.**"

## Check for Updates

1. **List installed skills**:
   ```bash
   ls ~/.claude/skills/
   ```

2. **Get versions** from each skill's SKILL.md frontmatter (parse the `version` field from the YAML header).

3. **Check marketplace**: Call `mcp__skillport__check_updates` with installed versions as JSON array of `{name, version}` objects.

4. **Report**: Show which skills have updates. Offer to install updates.
