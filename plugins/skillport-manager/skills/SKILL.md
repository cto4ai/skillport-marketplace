---
name: skillport-manager
description: >
  Manages Skills from Skillport marketplaces — browse available skills, install them
  with one click, and check for updates. Activates when the user asks to list, browse,
  install, or update skills, or mentions "Skillport" in context of skills or plugins.
---

# Skillport Manager

## Prerequisites

The Skillport Connector must be enabled. Verify by checking if these tools exist:
- `Skillport Connector:list_plugins`
- `Skillport Connector:fetch_skill`

If unavailable, tell the user: "Please add the Skillport Connector in Settings > Connectors, then enable it via the 'Search and tools' menu."

## List Skills

Call `Skillport Connector:list_plugins` with optional `surface` ("claude-ai" or "claude-desktop") and `category` filters. Present results as a brief list.

## Get Skill Details

Call `Skillport Connector:get_plugin` with `name` parameter. Present the description, version, and author.

## Install a Skill

1. **Fetch**: Call `Skillport Connector:fetch_skill` with the skill name.
   The response contains `plugin` (with name, version) and `files` (array of file objects).

2. **Write files**: Pass the response to the install script. Create JSON with `name` and `files`:
   ```bash
   echo '{"name": "SKILLNAME", "files": [...]}' | python scripts/install_skill.py
   ```
   Run from this skill's directory. The script creates `/home/claude/SKILLNAME/` and writes all files, handling base64-encoded binary files automatically.

3. **Package**: Create the .skill zip file:
   ```bash
   python scripts/package_skill.py /home/claude/SKILLNAME
   ```
   Returns the path to the created .skill file.

4. **Present**: Call `present_files` with the .skill path.
   Tell user: "Click 'Copy to your skills' to install. **Start a new conversation to use the newly installed skill.**"

## Check for Updates

1. **Get installed versions**:
   ```bash
   python scripts/get_versions.py
   ```
   Run from this skill's directory. Returns JSON array of `{name, version}` objects.

2. **Check marketplace**: Call `Skillport Connector:check_updates` with the JSON output.

3. **Report**: Show which skills have updates available. Offer to install updates using the Install workflow above.
