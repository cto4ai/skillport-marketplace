---
name: skillport
description: Browse and install skills from the Skillport marketplace. Search for skills, view details, install packages, and check for updates. Use when the user wants to find, install, or update Claude skills.
---

# Skillport

Skillport is a marketplace for Claude Skills. This skill teaches you how to discover and install skills.

**For creating, editing, or publishing skills**, see [Authoring Skills](references/authoring-skills.md).

## Prerequisites

Before using any Skillport operation, you MUST get an auth token:

1. Call the `skillport_auth` MCP tool (no parameters needed)
2. You'll receive a `token` and `base_url`
3. The token expires in 15 minutes — get a new one if needed

## Quick Reference

| Operation | Method | Endpoint |
|-----------|--------|----------|
| List skills | GET | `/api/skills` |
| List skills (by surface) | GET | `/api/skills?surface=CC` |
| List skills (force refresh) | GET | `/api/skills?refresh=true` |
| Get skill details | GET | `/api/skills/{name}` |
| Install skill | GET | `/api/skills/{name}/install` |
| Check updates | POST | `/api/check-updates` |
| Debug: list plugins | GET | `/api/debug/plugins` |

## Surface Tags

Skills are tagged with compatible Claude surfaces:

| Tag | Full Name | Description |
|-----|-----------|-------------|
| CC | Claude Code | CLI terminal experience with Bash, file system access |
| CD | Claude Desktop | Desktop app, may have local MCPs installed |
| CAI | Claude.ai | Web interface, connectors only |
| CDAI | Claude Desktop + Claude.ai | Both chat surfaces (shared UI patterns) |
| CALL | All Surfaces | Works everywhere |

The `list_skills` response includes a `surface_tags` array for each skill.

### Detecting Your Current Surface

To adapt behavior based on surface:

```
IF Bash tool available:
  → Claude Code (CC)
ELSE IF any *-local MCP tools available:
  → Claude Desktop (CD) with local MCP
ELSE:
  → Claude.ai (CAI) or Desktop without local MCPs
```

## List Available Skills

Find skills in the marketplace.

```bash
curl -sf "${base_url}/api/skills" -H "Authorization: Bearer ${token}"
```

The response includes:
- `published` field (true/false) indicating marketplace visibility
- `surface_tags` array showing compatible surfaces (e.g., `["CC"]`, `["CALL"]`)

### Filter by Surface

Show only skills compatible with a specific surface:

```bash
curl -sf "${base_url}/api/skills?surface=CC" -H "Authorization: Bearer ${token}"
```

Valid surface values: `CC`, `CD`, `CAI`, `CDAI`, `CALL`

Skills tagged `CALL` appear in all surface filters. Skills tagged `CDAI` appear in both `CD` and `CAI` filters.

### Force Cache Refresh

If skills appear stale or missing, force a cache refresh:

```bash
curl -sf "${base_url}/api/skills?refresh=true" -H "Authorization: Bearer ${token}"
```

This clears the server-side cache before fetching the skill list.

## Get Skill Details

View a skill's SKILL.md content and metadata.

```bash
curl -sf "${base_url}/api/skills/{skill-name}" -H "Authorization: Bearer ${token}"
```

Response includes:
- `skill_md` with the full SKILL.md content
- `published` field (true/false)
- `surface_tags` array (e.g., `["CALL"]`)

## Install a Skill

Download and install a skill.

**Step 1: Get install token**
```bash
curl -sf "${base_url}/api/skills/{skill-name}/install" -H "Authorization: Bearer ${token}"
```

This returns JSON with an `install_token` and `command` field.

**Step 2: Execute the install command**

The `command` field contains the full install command. By default it creates a `.skill` package.

*For Claude Code* — add `--skill` flag to install directly to `~/.claude/skills/`:
```bash
curl -sf {base_url}/install.sh | bash -s -- {install_token} --skill
```

*For Claude.ai / Claude Desktop* — use `--package` (default) to create a `.skill` file:
```bash
curl -sf {base_url}/install.sh | bash -s -- {install_token} --package
```
Then find the `SKILL_FILE=` path in the output and call `present_files` with it. Tell the user to click "Copy to your skills" button.

**Step 3: Start a new conversation**
The user needs to start a new conversation for Claude to see the installed skill.

## Check for Updates

See if installed skills have newer versions available.

**Step 1: Gather installed skill versions**

Skill versions are stored in `.claude-plugin/plugin.json`, NOT in SKILL.md frontmatter. The location differs by context:

- **Marketplace repos:** `plugins/{plugin-name}/.claude-plugin/plugin.json`
  (Note: `plugin-name` is the group containing skills in `plugins/{plugin-name}/skills/*/`)
- **Installed user skills:** `~/.claude/skills/{skill-name}/.claude-plugin/plugin.json`

Example plugin.json:
```json
{
  "name": "my-skill",
  "version": "1.0.1",
  "description": "Skill description"
}
```

**Step 2: Call the API**
```bash
curl -X POST "${base_url}/api/check-updates" \
  -H "Authorization: Bearer ${token}" \
  -H "Content-Type: application/json" \
  -d '{
    "installed": [
      {"name": "skill-a", "version": "1.0.0"},
      {"name": "skill-b", "version": "2.1.0"}
    ]
  }'
```

The response indicates which skills have updates and their latest versions.

## Debug Endpoints

For troubleshooting marketplace issues:

```bash
curl -sf "${base_url}/api/debug/plugins" -H "Authorization: Bearer ${token}"
```

Returns raw GitHub API response showing all plugin directories. Useful for diagnosing missing skills.

## Error Handling

All API errors return:
```json
{
  "error": "Error type",
  "message": "Human-readable description"
}
```

Common errors:
- `401 Unauthorized`: Token expired — call `skillport_auth` again
- `403 Forbidden`: You don't have access to this operation
- `404 Not Found`: Skill doesn't exist
- `400 Bad Request`: Invalid parameters (check the message for details)

## Tips

1. **Token expiration**: Tokens last 15 minutes. For long workflows, check for 401 errors and refresh.

2. **Claude Code users**: Use `--skill` flag for direct installation to `~/.claude/skills/`. You have direct file system access.

3. **New conversations**: After a user installs a skill, they need to start a new conversation for Claude to see it.

4. **Surface detection**: Check Bash availability to detect Claude Code vs chat surfaces.
