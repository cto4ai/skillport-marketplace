---
name: git-commit-generator
description: Generates well-structured conventional commit messages by analyzing git diffs. Use when users ask to write commit messages, describe staged changes, generate commit text, or want help with git commit formatting. Triggers on phrases like "write a commit message", "commit this", "what should I commit", "describe these changes", or "generate commit".
---

# Git Commit Generator

Generate conventional commit messages from staged changes or diffs.

## Workflow

1. **Get the diff** - Run `scripts/get_diff.sh` or use provided diff
2. **Analyze changes** - Identify type, scope, and impact
3. **Generate message** - Follow conventional commit format

## Quick Reference

See `references/conventional-commits.md` for format specification and type definitions.

## Usage

### From staged changes

```bash
bash /path/to/skill/scripts/get_diff.sh
```

Then analyze output and generate commit message.

### From provided diff

Analyze the diff directly and generate message.

## Message Structure

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Rules:**
- Subject line ≤72 characters
- Use imperative mood ("add" not "added")
- No period at end of subject
- Body wraps at 72 characters
- Separate subject from body with blank line

## Analysis Guidelines

1. **Identify primary change type** - What category of change is this?
2. **Determine scope** - Which component/module/area is affected?
3. **Summarize intent** - What does this change accomplish (not how)?
4. **Note breaking changes** - Add `!` after type/scope if breaking
5. **Extract details for body** - List significant changes if complex
