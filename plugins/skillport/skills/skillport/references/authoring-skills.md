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
- **Publish skill** (POST) — makes a skill public in the marketplace

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

## Create or Update a Skill

Save skill files to the marketplace.

```bash
curl -X POST "${base_url}/api/skills/{skill-name}" \
  -H "Authorization: Bearer ${token}" \
  -H "Content-Type: application/json" \
  -d '{
    "skill_group": "my-skills",
    "files": [
      {"path": "SKILL.md", "content": "---\nname: my-skill\ndescription: Does something\n---\n\n# My Skill\n..."},
      {"path": "scripts/helper.py", "content": "# helper code..."}
    ],
    "commitMessage": "Update skill"
  }'
```

**Requirements:**
- `SKILL.md` is required with `name` and `description` in frontmatter
- Paths are relative to the skill directory
- Empty content string deletes a file (except SKILL.md)
- New skills require `skill_group` (defaults to skill name if omitted)

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

Permanently remove a skill from the marketplace.

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

Make a skill discoverable in the marketplace.

```bash
curl -X POST "${base_url}/api/skills/{skill-name}/publish" \
  -H "Authorization: Bearer ${token}" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Does something useful",
    "category": "productivity",
    "tags": ["automation"],
    "keywords": ["helper", "utility"]
  }'
```

---

## Get User Identity

Find out who you're authenticated as.

```bash
curl -sf "${base_url}/api/whoami" -H "Authorization: Bearer ${token}"
```

Useful for adding yourself as an editor in `.skillport/access.json`.

---

## Tips for Authors

1. **Version location**: Skill versions are stored in `.claude-plugin/plugin.json`, NOT in SKILL.md frontmatter:
   - Project skills: `plugins/{skill-name}/.claude-plugin/plugin.json`
   - User skills: `~/.claude/skills/{skill-name}/.claude-plugin/plugin.json`

2. **Token expiration**: Tokens last 15 minutes. For long editing sessions, check for 401 errors and refresh.

3. **Skill structure**: Before creating a skill, review [Skill Best Practices](skill-best-practices.md) for guidance on:
   - SKILL.md format and frontmatter requirements
   - Progressive disclosure patterns
   - Naming conventions
   - Writing effective descriptions

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
