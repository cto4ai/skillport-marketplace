---
name: skillport-browser
description: >
  Browses and installs Skills from Skillport marketplaces. Activates when the 
  user asks to list available skills, browse a marketplace, install a skill, 
  check for updates, or mentions "Skillport" in context of skills or plugins.
---

# Skillport Browser

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

```
Install Progress:
- [ ] Fetch skill files
- [ ] Write files to /home/claude/{name}/
- [ ] Package as .skill
- [ ] Present to user
```

1. **Fetch**: `Skillport Connector:fetch_skill` with skill name → returns `files` array

2. **Write files**: Create skill directory and write each file:
```bash
mkdir -p /home/claude/SKILLNAME
```
Then write SKILL.md and any bundled files (scripts/, references/, assets/).

3. **Package**:
```bash
cd /home/claude && zip -r SKILLNAME.skill SKILLNAME/
mv SKILLNAME.skill /mnt/user-data/outputs/
```

4. **Verify**: Check the zip contains SKILLNAME/SKILL.md:
```bash
unzip -l /mnt/user-data/outputs/SKILLNAME.skill
```

5. **Present**: Call `present_files` with the .skill path. Tell user: "Click 'Copy to your skills' to install."

## Check for Updates

1. List installed skills:
```bash
ls /mnt/skills/user/
```

2. For each, extract version from SKILL.md frontmatter

3. Call `Skillport Connector:check_updates` with `installed` array of `{name, version}` objects

4. Report findings and offer to install updates
