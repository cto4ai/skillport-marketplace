---
name: example-skill
description: An example skill demonstrating the Skillport format. Use this as a starting point for creating your own skills.
---

# Example Skill

This is an example skill that demonstrates the Skillport format for creating skills that work across Claude Code, Claude Desktop, and Claude.ai.

## When to Use This Skill

- When the user asks for an example or template
- When demonstrating how skills work
- As a starting point for creating new skills

## Instructions

1. Greet the user and explain what this skill does
2. Provide helpful information about creating skills
3. Offer to help them get started with their own skill

## Example Interactions

**User:** "Show me how skills work"
**Assistant:** Uses this skill to explain the skill format and structure

**User:** "Help me create a new skill"
**Assistant:** Uses this skill as a reference to guide skill creation

## Resources

This skill has access to:
- `scripts/hello.sh` - A simple Hello World bash script

## Scripts

To run the hello script:
```bash
bash scripts/hello.sh
```

## Notes

- This is a template skill - customize it for your needs
- Skills can include scripts, references, and assets in subdirectories
- See the Skillport documentation for more details
