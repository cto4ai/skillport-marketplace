---
name: skillport-manager
description: >
  Manages Skills from Skillport marketplaces — browse available skills, install them
  efficiently, and check for updates. For Claude.ai and Claude Desktop.
---

# Skillport Manager

## Prerequisites

The Skillport Connector must be enabled. Verify by checking if these tools exist:
- `Skillport Connector:list_skills`
- `Skillport Connector:install_skill`

If unavailable, tell the user: "Please add the Skillport Connector in Settings > Connectors, then enable it via the 'Search and tools' menu."

**Network Access Required:** Users must add `skillport-connector.jack-ivers.workers.dev` to their allowed domains in Settings > Code execution and file creation > Additional allowed domains.

## List Skills

Call `Skillport Connector:list_skills`. Present results as a brief list showing name, description, and version.

## Get Skill Details

Call `Skillport Connector:fetch_skill_details` with `name` parameter. This returns the SKILL.md content which describes capabilities, usage, and examples.

## Install a Skill

### Step 1: Get Install Token

Call `Skillport Connector:install_skill` with the skill name.

Response includes:
- `install_token`: Short-lived token (5 min TTL)
- `skill`: Skill name
- `version`: Skill version

### Step 2: Run Install Script

Run the `command` from the response. It will look something like:

```bash
curl -sf https://skillport-connector.jack-ivers.workers.dev/install.sh | bash -s -- <token> --package
```

### Step 3: Present Result

The script outputs `SKILL_FILE=<path>` on the last line. Extract that path and call `present_files` with the .skill file.

Tell user: "Click 'Copy to your skills' to install. **Start a new conversation to use the skill.**"

## Check for Updates

1. **Get installed versions**:
   ```bash
   python scripts/get_versions.py
   ```
   Returns JSON array of `{name, version}` objects.

2. **Check marketplace**: Call `Skillport Connector:check_updates` with the JSON output.

3. **Report**: Show which skills have updates. Offer to install updates.
