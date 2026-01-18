# Authoring Skills on Skillport

This guide covers creating, editing, publishing, and managing skills on the Skillport marketplace.

Before authoring skills, review the [Skill Best Practices](skill-best-practices.md) for guidance on writing effective skills.

---

## IMPORTANT: User Confirmation Required

**NEVER create, update, or delete skills without explicit user confirmation.**

Write operations modify the Skillport repository. Before executing any of the following, you MUST:
1. Explain what you're about to do
2. Wait for the user to confirm they want to proceed

This applies to:
- **Save skill** (POST) — creates or updates skill files
- **Delete skill** (DELETE) — permanently removes a skill
- **Bump version** (POST) — changes the version number
- **Publish skill** (POST) — makes a skill discoverable in the marketplace

Read-only operations (Edit/download, Who am I) do not require confirmation.

---

## Prerequisites

Before using any authoring operation, you MUST get an auth token:

1. Call the `skillport_auth` MCP tool (no parameters needed)
2. You'll receive a `token` and `base_url`
3. The token expires in 15 minutes — get a new one if needed

## Quick Reference

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Save skill | POST | `/api/skills/{name}` |
| Edit skill | GET | `/api/skills/{name}/edit` |
| Delete skill | DELETE | `/api/skills/{name}?confirm=true` |
| Bump version | POST | `/api/skills/{name}/bump` |
| Publish skill | POST | `/api/skills/{name}/publish` |
| Who am I | GET | `/api/whoami` |

---

## Workflow: Create and Publish a New Skill

1. **Save skill** — creates files in the repository
2. **Test** — fetch the skill by name to verify it works
3. **Publish skill** — adds to marketplace, making it discoverable

**Important:** Saved skills are NOT listed in `/api/skills` until published. This lets you test before making the skill public. You can still fetch unpublished skills by name using `/api/skills/{name}`.

The API response includes a `published` field (true/false) indicating whether each skill is in the marketplace.

---

## Create or Update a Skill

Save skill files to the repository.

```bash
curl -X POST "${base_url}/api/skills/{skill-name}" \
  -H "Authorization: Bearer ${token}" \
  -H "Content-Type: application/json" \
  -d "$(cat payload.json)"
```

**Requirements:**
- `SKILL.md` is required with `name` and `description` in frontmatter
- `plugin_metadata.description` is **required for new plugins**
- Paths are relative to the skill directory
- Empty content string deletes a file (except SKILL.md)
- New skills require `skill_group` (defaults to skill name if omitted)

**Note:** After saving, the skill exists in the repository but is NOT listed in the marketplace. Use `publish_skill` to make it discoverable. You can still fetch unpublished skills by name for testing.

### Building the Payload

For multi-file skills, build the JSON payload programmatically rather than inline. The `@filename` syntax (`-d @payload.json`) may fail in some environments; use `$(cat)` instead.

**Payload structure:**
```json
{
  "skill_group": "my-skills",
  "files": [
    {"path": "SKILL.md", "content": "---\nname: ...\n---\n\n# ..."},
    {"path": "references/guide.md", "content": "..."},
    {"path": "scripts/helper.sh", "content": "#!/bin/bash\n..."}
  ],
  "commitMessage": "Update skill",
  "plugin_metadata": {
    "description": "What this plugin does",
    "keywords": ["optional", "tags"],
    "license": "MIT"
  }
}
```

**Plugin Metadata Fields:**
- `description` (required for new plugins): Brief description of what the plugin does
- `keywords` (optional): Array of tags for discoverability
- `author` (optional): `{"name": "...", "email": "..."}` — defaults to authenticated user
- `license` (optional): License identifier — defaults to "MIT"

For existing plugins, `plugin_metadata` is optional and will merge into the existing `plugin.json`.

**Python helper to build payload from local files:**
```python
import json
import os

def build_skill_payload(skill_dir, skill_group, commit_message, description, keywords=None):
    """Build Skillport API payload from local skill directory."""
    files = []
    for root, _, filenames in os.walk(skill_dir):
        for filename in filenames:
            filepath = os.path.join(root, filename)
            relpath = os.path.relpath(filepath, skill_dir)
            with open(filepath, 'r') as f:
                files.append({"path": relpath, "content": f.read()})

    return json.dumps({
        "skill_group": skill_group,
        "files": files,
        "commitMessage": commit_message,
        "plugin_metadata": {
            "description": description,
            "keywords": keywords or []
        }
    })

# Usage: python -c "..." > /tmp/payload.json
# Then: curl ... -d "$(cat /tmp/payload.json)"
```

---

## Edit an Existing Skill

Download all files for local editing.

**Step 1: Get edit command**
```bash
curl -sf "${base_url}/api/skills/{skill-name}/edit" -H "Authorization: Bearer ${token}"
```

**Step 2: Execute the returned command**
The response includes a `command` field. Execute it to download the skill files to `/tmp/skillport-edit/{skill}/`.

**Step 3: Make changes locally**

**Step 4: Save changes**
Use the Create or Update operation above with the modified files.

---

## Delete a Skill

Permanently remove a skill from the repository.

```bash
curl -X DELETE "${base_url}/api/skills/{skill-name}?confirm=true" \
  -H "Authorization: Bearer ${token}"
```

**Warning:** This is irreversible. The `confirm=true` parameter is required.

---

## Bump Version

Increment a skill's version number.

```bash
curl -X POST "${base_url}/api/skills/{skill-name}/bump" \
  -H "Authorization: Bearer ${token}" \
  -H "Content-Type: application/json" \
  -d '{"type": "minor"}'
```

Version types:
- `patch`: 1.0.0 → 1.0.1
- `minor`: 1.0.0 → 1.1.0
- `major`: 1.0.0 → 2.0.0

---

## Publish a Skill

Make a skill discoverable in the marketplace. **Required** for the skill to appear in `/api/skills`.

```bash
curl -X POST "${base_url}/api/skills/{skill-name}/publish" \
  -H "Authorization: Bearer ${token}" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Does something useful",
    "category": "productivity",
    "tags": ["surface:CALL", "automation"],
    "keywords": ["helper", "utility"]
  }'
```

**Note:** You must save the skill first before publishing. Publishing adds the skill to `marketplace.json`, making it discoverable via `/api/skills`.

### Surface Tags (Required)

Every skill must include a surface tag indicating which Claude surfaces it supports:

| Tag | Full Name | When to Use |
|-----|-----------|-------------|
| `surface:CC` | Claude Code | Skill requires Bash, file system access |
| `surface:CD` | Claude Desktop | Skill needs local MCPs |
| `surface:CAI` | Claude.ai | Web-only features |
| `surface:CDAI` | Claude Desktop + Claude.ai | Works on both chat surfaces |
| `surface:CALL` | All Surfaces | Works everywhere (most common) |

**Examples:**
- A skill that runs shell commands → `surface:CC`
- A skill that uses a local MCP server → `surface:CD`
- A skill that only uses API calls → `surface:CALL`
- A skill that creates `.skill` packages for upload → `surface:CDAI`

---

## Get User Identity

Find out who you're authenticated as.

```bash
curl -sf "${base_url}/api/whoami" -H "Authorization: Bearer ${token}"
```

Useful for adding yourself as an editor in `.skillport/access.json`.

---

## Tips for Authors

1. **Version location**: Skill versions are stored in `.claude-plugin/plugin.json`, NOT in SKILL.md frontmatter. The location differs by context:
   - **Marketplace repos:** `plugins/{plugin-name}/.claude-plugin/plugin.json`
     (Note: `plugin-name` is the group containing skills in `plugins/{plugin-name}/skills/*/`)
   - **Installed user skills:** `~/.claude/skills/{skill-name}/.claude-plugin/plugin.json`

2. **Token expiration**: Tokens last 15 minutes. For long editing sessions, check for 401 errors and refresh.

3. **Skill structure**: Before creating a skill, review [Skill Best Practices](skill-best-practices.md) for guidance on:
   - SKILL.md format and frontmatter requirements
   - Progressive disclosure patterns
   - Naming conventions
   - Writing effective descriptions

4. **Publish workflow**: Remember that `save_skill` creates files but doesn't list the skill. Use `publish_skill` after testing to make it discoverable.

5. **Version management**: Always use the bump API (`/api/skills/{name}/bump`) to increment versions. Never manually edit `plugin.json` — the API keeps Skillport and local installations in sync.

6. **Surface tags**: Always include a `surface:*` tag when publishing. Use `surface:CALL` if your skill works on all surfaces.

---

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
- `403 Forbidden`: You don't have access to this skill/operation
- `404 Not Found`: Skill doesn't exist
- `400 Bad Request`: Invalid parameters (check the message for details)
