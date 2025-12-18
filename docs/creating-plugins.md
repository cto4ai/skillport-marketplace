# Creating Plugins

A comprehensive guide to creating plugins for your Skillport marketplace.

## Plugin Anatomy

A plugin is a directory containing:

```
my-plugin/
├── plugin.json          # Plugin manifest
├── skills/              # Skills (for all surfaces)
│   └── SKILL.md
├── commands/            # Slash commands (Claude Code only)
│   └── my-command.md
├── agents/              # Sub-agents (Claude Code only)
│   └── my-agent.md
├── scripts/             # Executable scripts (optional)
│   └── helper.py
├── references/          # Reference docs (optional)
│   └── guide.md
└── assets/              # Asset files (optional)
    └── template.docx
```

## Quick Start

### 1. Create Plugin Directory

```bash
mkdir -p plugins/my-plugin/skills
```

### 2. Create Plugin Manifest

`plugins/my-plugin/plugin.json`:

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "What this plugin does",
  "author": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "license": "MIT"
}
```

### 3. Create Skill

`plugins/my-plugin/skills/SKILL.md`:

```markdown
---
name: my-skill
description: Brief description for Claude to know when to use this skill.
---

# My Skill

## When to Use This Skill

- When user asks for X
- When user needs Y

## Instructions

1. First, do this
2. Then, do that
3. Finally, complete with this

## Examples

**User:** "Help me with X"
**Action:** Claude does Y and produces Z
```

### 4. Add to Marketplace

In `.claude-plugin/marketplace.json`:

```json
{
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/my-plugin",
      "description": "What this plugin does",
      "version": "1.0.0",
      "surfaces": ["claude-code", "claude-desktop", "claude-ai"]
    }
  ]
}
```

### 5. Test

**Claude Code:**
```bash
/plugin marketplace add ./
/plugin install my-plugin@your-marketplace
```

## Plugin Manifest (plugin.json)

The manifest describes your plugin:

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Detailed description of what this plugin does",
  "author": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "homepage": "https://github.com/you/my-plugin",
  "repository": "https://github.com/you/my-plugin",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2"]
}
```

### Required Fields

| Field | Description |
|-------|-------------|
| `name` | Plugin identifier (kebab-case) |
| `version` | Semver version |

### Optional Fields

| Field | Description |
|-------|-------------|
| `description` | What the plugin does |
| `author` | Author info (`name`, `email`) |
| `homepage` | Documentation URL |
| `repository` | Source code URL |
| `license` | SPDX license identifier |
| `keywords` | Discovery tags |

## Skills (SKILL.md)

Skills are the primary component that works across all Claude surfaces.

### Frontmatter

```yaml
---
name: skill-name
description: >
  A clear description that helps Claude know when to activate this skill.
  Include trigger words and use cases.
---
```

The `description` is critical — it determines when Claude activates the skill.

### Recommended Sections

#### When to Use This Skill

Help Claude understand activation triggers:

```markdown
## When to Use This Skill

- User asks to create a sales pitch
- User mentions "pitch", "proposal", or "sales deck"
- User has product information and needs persuasive content
```

#### Instructions

Step-by-step guidance for Claude:

```markdown
## Instructions

1. **Gather Information**
   - Ask for product/service details if not provided
   - Identify target audience
   - Understand key value propositions

2. **Structure the Pitch**
   - Opening hook
   - Problem statement
   - Solution presentation
   - Benefits and proof points
   - Call to action

3. **Output**
   - Create document using docx skill if requested
   - Otherwise provide in markdown format
```

#### Examples

Show expected interactions:

```markdown
## Examples

**User:** "Create a pitch for our new project management tool"

**Action:** 
1. Ask clarifying questions about target audience and key features
2. Draft pitch following the structure
3. Offer to create as Word document

**User:** "Make it more compelling"

**Action:**
1. Add stronger emotional hooks
2. Include specific statistics or social proof
3. Strengthen the call to action
```

#### Resources

Document what the skill can access:

```markdown
## Resources

This skill can use:
- `web_search` tool for market research
- `docx` skill for document creation
- Files in `references/` directory for templates
```

#### Notes

Additional context:

```markdown
## Notes

- Works best with specific product information
- Can integrate with brand guidelines skill
- Output length typically 500-1000 words
```

### Complete SKILL.md Example

```markdown
---
name: sales-pitch
description: >
  Generate compelling sales pitches and proposals. Use when user needs 
  persuasive content for products, services, or ideas. Triggers: pitch, 
  proposal, sales deck, persuade, convince.
---

# Sales Pitch Generator

## When to Use This Skill

- User asks to create a sales pitch or proposal
- User needs persuasive content for a product or service
- User mentions "pitch", "proposal", "sales deck"
- User wants to convince or persuade an audience

## Instructions

### 1. Gather Information

Before creating the pitch, ensure you have:
- Product/service name and description
- Target audience
- Key benefits and differentiators
- Any specific requirements or constraints

If information is missing, ask focused questions.

### 2. Structure the Pitch

Follow this proven structure:

1. **Hook** — Attention-grabbing opening
2. **Problem** — Pain point the audience experiences  
3. **Solution** — How your product/service solves it
4. **Benefits** — Specific advantages (use numbers when possible)
5. **Proof** — Testimonials, case studies, statistics
6. **Call to Action** — Clear next step

### 3. Tone and Style

- Confident but not arrogant
- Specific rather than vague
- Benefit-focused, not feature-focused
- Appropriate for the target audience

### 4. Output Format

- Default: Structured markdown
- If user requests document: Use docx skill
- If user requests presentation: Use pptx skill

## Examples

**User:** "Create a pitch for our AI scheduling assistant"

**Claude:** 
- Asks about target audience and key features
- Creates structured pitch with hook, problem, solution, benefits
- Offers to format as document if needed

**User:** "Make it shorter and punchier"

**Claude:**
- Tightens language
- Focuses on top 3 benefits
- Strengthens hook and CTA

## Resources

- Can use `web_search` for competitor/market research
- Can use `docx` skill for Word document output
- Can use `pptx` skill for presentation output

## Notes

- Best results with specific product information
- Can adapt tone for B2B vs B2C audiences
- Typical output: 300-800 words for standard pitch
```

## Commands (Claude Code Only)

Slash commands for Claude Code:

`commands/generate-pitch.md`:

```markdown
---
name: generate-pitch
description: Generate a sales pitch from product info
arguments:
  - name: product
    description: Product or service name
    required: true
  - name: audience
    description: Target audience
    required: false
---

# Generate Pitch Command

Generate a compelling sales pitch for the specified product.

## Steps

1. Load product information from context or arguments
2. Apply sales-pitch skill methodology
3. Output formatted pitch

## Usage

```
/generate-pitch product="AI Scheduler" audience="small business owners"
```
```

## Agents (Claude Code Only)

Specialized sub-agents:

`agents/pitch-reviewer.md`:

```markdown
---
name: pitch-reviewer
description: Reviews and improves sales pitches
---

# Pitch Reviewer Agent

You are a sales pitch expert who reviews and improves persuasive content.

## Your Role

- Analyze pitch structure and flow
- Identify weak points
- Suggest specific improvements
- Rate pitch effectiveness (1-10)

## Review Criteria

1. **Hook strength** — Does it grab attention?
2. **Problem clarity** — Is the pain point clear?
3. **Solution fit** — Does the solution address the problem?
4. **Benefit specificity** — Are benefits concrete?
5. **Proof credibility** — Is evidence convincing?
6. **CTA clarity** — Is the next step obvious?

## Output Format

Provide:
- Overall score (1-10)
- Strengths (bullet points)
- Areas for improvement (bullet points)
- Specific rewrite suggestions
```

## Scripts

Executable code that skills can reference:

`scripts/analyze_competitors.py`:

```python
#!/usr/bin/env python3
"""Analyze competitor pricing from web search results."""

import sys
import json

def analyze(search_results):
    # Parse and analyze competitor data
    # Return structured insights
    pass

if __name__ == "__main__":
    data = json.load(sys.stdin)
    result = analyze(data)
    print(json.dumps(result))
```

Reference in SKILL.md:

```markdown
## Advanced Analysis

For competitive analysis, run:
```bash
python scripts/analyze_competitors.py
```
```

## References

Documentation loaded into context as needed:

`references/pitch-templates.md`:

```markdown
# Pitch Templates

## The Problem-Solution Template

[Opening that identifies a pain point]
[Transition to your solution]
[Three key benefits]
[Social proof]
[Call to action]

## The Story Template

[Relatable character with a problem]
[Their journey to find a solution]
[Discovery of your product]
[Transformation/results]
[Invitation to experience the same]
```

Reference in SKILL.md:

```markdown
## Templates

See `references/pitch-templates.md` for proven pitch structures.
```

## Assets

Files used in output:

`assets/pitch-template.docx` — Word template with branding
`assets/logo.png` — Company logo for documents

Reference in SKILL.md:

```markdown
## Document Creation

When creating Word documents, use the template at `assets/pitch-template.docx`.
```

## Surface-Specific Components

### What Works Where

| Component | Claude Code | Claude Desktop | Claude.ai |
|-----------|:-----------:|:--------------:|:---------:|
| Skills | ✅ | ✅ | ✅ |
| Commands | ✅ | ❌ | ❌ |
| Agents | ✅ | ❌ | ❌ |
| Hooks | ✅ | ❌ | ❌ |
| Scripts | ✅ | ✅ | ✅ |
| References | ✅ | ✅ | ✅ |
| Assets | ✅ | ✅ | ✅ |

### Indicating Surfaces

In marketplace.json:

```json
{
  "name": "my-plugin",
  "surfaces": ["claude-code", "claude-desktop", "claude-ai"]
}
```

For Claude Code-only plugins:

```json
{
  "name": "code-review-tools",
  "surfaces": ["claude-code"]
}
```

## Best Practices

### Naming

- Use kebab-case: `sales-pitch`, not `SalesPitch`
- Be descriptive: `invoice-generator`, not `inv-gen`
- Avoid conflicts with built-in skills

### Descriptions

- Include trigger words
- Be specific about use cases
- Help Claude understand when to activate

### Instructions

- Step-by-step is better than prose
- Be explicit about edge cases
- Include error handling guidance

### Versioning

- Use semver: `1.0.0`, `1.1.0`, `2.0.0`
- Document breaking changes
- Update marketplace.json when version changes

### Testing

1. Test with Claude Code first (fastest feedback)
2. Test edge cases
3. Test with real user scenarios
4. Verify all surfaces work (if multi-surface)

## Troubleshooting

### Skill Not Activating

- Check description includes trigger words
- Verify skill is in marketplace.json
- Ensure plugin is installed

### Wrong Skill Activating

- Make description more specific
- Add "When NOT to use" section
- Differentiate from similar skills

### Scripts Not Running

- Check file permissions (`chmod +x`)
- Verify shebang line
- Test script standalone first

### Missing Assets

- Verify path is relative to plugin root
- Check file exists and is committed
- Ensure not in .gitignore
