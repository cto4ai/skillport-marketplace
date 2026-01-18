---
name: surface-detect
description: Detects which Claude surface is currently active (Claude Code, Claude Desktop, or Claude.ai). Use when you need to know what environment Claude is running in, adapt behavior based on available tools, or when the user asks "what surface am I on?" or "what Claude am I using?"
---

# Surface Detect

Identify the current Claude surface and its capabilities.

## Quick Detection

Run this detection logic when triggered:

```
1. Call skillport_auth tool to get client_info

2. Apply detection logic IN THIS ORDER:

   IF client_info is null:
     → Claude Code (CC)
     (primary signal - only CC returns null)
   
   ELSE IF any tool names contain "-local" suffix:
     → Claude Desktop (CD)
     (e.g., "obsidian-local:*", "filesystem-local:*")
   
   ELSE IF "present_files" tool is available:
     → Claude.ai (CAI)
     (no -local tools + present_files = CAI)
   
   ELSE:
     → Claude Desktop without local MCPs
     (or ambiguous - report available signals)
```

**IMPORTANT:** Check `-local` tools BEFORE checking for present_files. Desktop has BOTH `-local` tools AND `present_files`, so order matters.

## MCP Client Info

The `skillport_auth` tool returns `client_info` from the MCP initialization:

| Surface | client_info.name | client_info.version |
|---------|------------------|---------------------|
| Claude Code | `null` | `null` |
| Claude Desktop | `"Anthropic/ClaudeAI"` | `"1.0.0"` |
| Claude.ai | `"Anthropic/ClaudeAI"` | `"1.0.0"` |

**Note:** Desktop and Claude.ai report the same client_info, so other signals are needed.

## Key Detection Signals

| Signal | CC | CD | CAI |
|--------|----|----|-----|
| `client_info` | `null` ✓ | `"Anthropic/ClaudeAI"` | `"Anthropic/ClaudeAI"` |
| `-local` MCP tools | maybe | ✅ **key signal** | ❌ |
| `present_files` tool | ❌ | ✅ (has it) | ✅ (has it) |
| Bash tool | ✅ | ✅ (Computer Use) | ✅ (Computer Use) |
| Skills path | `~/.claude/skills/` | N/A | `/mnt/skills/` |

**Detection priority:** `-local` tools are checked first, so Desktop is caught before the `present_files` check.

**Bash is NOT reliable** - all three surfaces can have bash access now.

## Surface Capabilities

| Capability | CC | CD | CAI |
|------------|----|----|-----|
| Native Bash/terminal | ✅ | ❌ | ❌ |
| Computer Use (container bash) | ❌ | ✅ | ✅ |
| Local file system | ✅ | ❌ | ❌ |
| Local MCP servers | ✅ | ✅ | ❌ |
| Cloud connectors | ✅ | ✅ | ✅ |
| Artifacts (React, HTML) | ❌ | ✅ | ✅ |
| Skills directory | `~/.claude/skills/` | N/A | `/mnt/skills/` |
| `present_files` tool | ❌ | ✅ | ✅ |

## Response Format

When reporting the detected surface, include:

1. **Surface name** — CC, CD, or CAI
2. **Full name** — Claude Code, Claude Desktop, or Claude.ai
3. **MCP client_info** — The raw client_info from skillport_auth
4. **Detection signals** — What led to this detection (in order checked)
5. **Key capabilities** — What's available in this environment

### Example Response (Claude Code)

```
🖥️ **Surface Detected: Claude Code (CC)**

**MCP client_info:** null

**Detection signals:**
- client_info is null ← primary signal (unique to CC)

**Available capabilities:**
- Native Bash/terminal access (not containerized)
- Direct local file system read/write
- Package installation (pip, npm, etc.)
- Local MCP servers (via settings.json)
- Skills installed at ~/.claude/skills/

**Not available:**
- Artifacts (React/HTML rendering)
- Computer Use container
- present_files tool
```

### Example Response (Claude Desktop)

```
🖥️ **Surface Detected: Claude Desktop (CD)**

**MCP client_info:** {"name": "Anthropic/ClaudeAI", "version": "1.0.0"}

**Detection signals:**
- client_info is not null (not CC)
- Local MCP tools detected: obsidian-local:* ← key signal for Desktop

**Available capabilities:**
- Local MCP servers for integrations
- Computer Use (containerized bash if enabled)
- Artifacts render natively
- Cloud connectors
- present_files tool

**Not available:**
- Native local file system access
- Native terminal (bash is containerized if available)
```

### Example Response (Claude.ai)

```
🖥️ **Surface Detected: Claude.ai (CAI)**

**MCP client_info:** {"name": "Anthropic/ClaudeAI", "version": "1.0.0"}

**Detection signals:**
- client_info is not null (not CC)
- No -local MCP tools (not Desktop)
- present_files tool available ← confirms CAI (with no -local)

**Available capabilities:**
- Cloud connectors (Google Drive, Slack, etc.)
- Artifacts render in browser
- Computer Use (containerized bash if enabled)
- Skills at /mnt/skills/
- present_files tool

**Not available:**
- Local MCP servers (no -local tools)
- Native local file system access
```

## Surface-Specific Guidance

### Claude Code (CC)
- Install skills directly to `~/.claude/skills/`
- Full native programming environment
- Can execute Python, Node, shell scripts directly on local machine
- Local MCPs configured in settings.json

### Claude Desktop (CD)
- Local MCPs (with `-local` suffix) provide specialized integrations
- Computer Use provides containerized bash (not native)
- Has `present_files` tool (but detected via -local first)
- Create `.skill` packages for skill installation
- Artifacts render natively

### Claude.ai (CAI)
- Cloud connectors only (no `-local` tools)
- `present_files` tool for file sharing with user
- Computer Use provides containerized bash at `/home/claude`
- Skills at `/mnt/skills/` (ephemeral)
- Create `.skill` packages, user clicks "Copy to your skills"