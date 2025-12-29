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
   The response contains `plugin` (with name, version) and `files` (array of `{path, content}` objects).

2. **Write files directly**: Create the skill directory and write each file:
   - Create directory: `<output-directory>/<skill-name>/`
   - For each file in the `files` array, write `content` to `<output-directory>/<skill-name>/<path>`
   - Create any necessary subdirectories (e.g., `scripts/`, `references/`)
   - Handle binary files: if a file object has `encoding: "base64"`, decode before writing

3. **Package**: Create the .skill zip file:
   ```bash
   python scripts/package_skill.py <skill-directory> [output-directory]
   ```
   Returns the path to the created .skill file. Output directory is optional (defaults to current directory).

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
