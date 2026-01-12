# Skill Authoring Best Practices

A comprehensive guide for creating effective Claude Skills, compiled from Anthropic's official documentation and the skill-creator skill.

---

## Core Principles

### Conciseness is Key

The context window is a public good. Your Skill shares it with the system prompt, conversation history, other Skills' metadata, and user requests.

**Default assumption**: Claude is already very smart. Only add context Claude doesn't already have.

Challenge each piece of information:
- "Does Claude really need this explanation?"
- "Can I assume Claude knows this?"
- "Does this paragraph justify its token cost?"

**Good example** (~50 tokens):
```markdown
## Extract PDF text

Use pdfplumber for text extraction:

```python
import pdfplumber

with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
```

**Bad example** (~150 tokens):
```markdown
## Extract PDF text

PDF (Portable Document Format) files are a common file format that contains
text, images, and other content. To extract text from a PDF, you'll need to
use a library. There are many libraries available for PDF processing, but we
recommend pdfplumber because it's easy to use...
```

### Set Appropriate Degrees of Freedom

Match specificity to task fragility and variability.

| Freedom Level | When to Use | Example |
|---------------|-------------|---------|
| **High** (text-based) | Multiple approaches valid, depends on context | Code review guidelines |
| **Medium** (pseudocode) | Preferred pattern exists, some variation OK | Report generation templates |
| **Low** (specific scripts) | Fragile operations, consistency critical | Database migrations |

**Analogy**: Think of Claude as a robot exploring a path:
- **Narrow bridge**: One safe way forward → provide exact instructions
- **Open field**: Many paths work → give general direction

---

## Skill Structure

### Required File
Every Skill needs exactly one required file:
```
my-skill/
└── SKILL.md (required)
```

### Optional Supporting Files
```
my-skill/
├── SKILL.md              # Overview and navigation (keep under 500 lines)
├── references/           # Documentation loaded as needed
│   ├── api-docs.md
│   └── examples.md
├── scripts/              # Utility scripts (executed, not loaded)
│   └── helper.py
└── assets/               # Output-ready files (templates, fonts)
    └── template.docx
```

### SKILL.md Format

```yaml
---
name: your-skill-name
description: What this Skill does and when to use it. Include trigger keywords.
allowed-tools: Read, Grep, Glob  # Optional
model: claude-sonnet-4-20250514   # Optional
---

# Your Skill Name

## Instructions
Provide clear, step-by-step guidance for Claude.

## Examples
Show concrete examples of using this Skill.
```

### Frontmatter Requirements

| Field | Required | Max Length | Rules |
|-------|----------|------------|-------|
| `name` | Yes | 64 chars | Lowercase, letters/numbers/hyphens only. No "anthropic" or "claude" |
| `description` | Yes | 1024 chars | Must include what it does AND when to use it. No XML tags |
| `allowed-tools` | No | — | Tools Claude can use without asking permission |
| `model` | No | — | Specific model to use when Skill is active |

---

## Naming Conventions

Use **gerund form** (verb + -ing) for Skill names:

**Good naming examples:**
- `processing-pdfs`
- `analyzing-spreadsheets`
- `managing-databases`
- `testing-code`
- `writing-documentation`

**Acceptable alternatives:**
- Noun phrases: `pdf-processing`, `spreadsheet-analysis`
- Action-oriented: `process-pdfs`, `analyze-spreadsheets`

**Avoid:**
- Vague names: `helper`, `utils`, `tools`
- Overly generic: `documents`, `data`, `files`
- Reserved words: `anthropic-helper`, `claude-tools`

---

## Writing Effective Descriptions

The `description` field is critical for Skill discovery. Claude uses it to choose the right Skill from potentially 100+ available Skills.

### Always Write in Third Person

The description is injected into the system prompt:
- **Good:** "Processes Excel files and generates reports"
- **Avoid:** "I can help you process Excel files"
- **Avoid:** "You can use this to process Excel files"

### Be Specific and Include Key Terms

Each description must provide enough detail for Claude to know when to select this Skill.

**Effective examples:**

```yaml
# PDF Processing
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.

# Excel Analysis
description: Analyze Excel spreadsheets, create pivot tables, generate charts. Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx files.

# Git Commit Helper
description: Generate descriptive commit messages by analyzing git diffs. Use when the user asks for help writing commit messages or reviewing staged changes.
```

**Avoid vague descriptions:**
```yaml
description: Helps with documents    # Too vague
description: Processes data          # Too generic
description: Does stuff with files   # Useless
```

---

## Progressive Disclosure

Keep `SKILL.md` under 500 lines. Use progressive disclosure to load details only when needed.

### How It Works

1. **Metadata pre-loaded**: Name and description loaded at startup
2. **Files read on-demand**: Claude reads SKILL.md only when triggered
3. **Scripts executed efficiently**: Utility scripts run without loading their code into context
4. **No context penalty for large files**: Reference files don't consume tokens until accessed

### Pattern 1: High-level Guide with References

```markdown
---
name: pdf-processing
description: Extract text, fill forms, merge PDFs. Use when working with PDF files.
---

# PDF Processing

## Quick start
[Brief code example]

## Advanced features
**Form filling**: See [FORMS.md](FORMS.md) for complete guide
**API reference**: See [REFERENCE.md](REFERENCE.md) for all methods
```

### Pattern 2: Domain-specific Organization

```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── reference/
    ├── finance.md (revenue metrics)
    ├── sales.md (pipeline data)
    └── product.md (usage analytics)
```

```markdown
# BigQuery Data Analysis

## Available datasets
**Finance**: Revenue, ARR, billing → See [reference/finance.md](reference/finance.md)
**Sales**: Opportunities, pipeline → See [reference/sales.md](reference/sales.md)
```

### Avoid Deeply Nested References

Keep references **one level deep** from SKILL.md. Claude may partially read files when they're referenced from other referenced files.

**Bad** (too deep):
```
SKILL.md → advanced.md → details.md
```

**Good** (one level):
```
SKILL.md → advanced.md
SKILL.md → reference.md
SKILL.md → examples.md
```

### Structure Longer Files with TOC

For reference files over 100 lines, include a table of contents:

```markdown
# API Reference

## Contents
- Authentication and setup
- Core methods (create, read, update, delete)
- Advanced features
- Error handling patterns
- Code examples

## Authentication and setup
...
```

---

## Workflows and Feedback Loops

### Use Workflows for Complex Tasks

Break complex operations into clear, sequential steps with a checklist:

```markdown
## PDF form filling workflow

Copy this checklist and track progress:

```
Task Progress:
- [ ] Step 1: Analyze the form (run analyze_form.py)
- [ ] Step 2: Create field mapping (edit fields.json)
- [ ] Step 3: Validate mapping (run validate_fields.py)
- [ ] Step 4: Fill the form (run fill_form.py)
- [ ] Step 5: Verify output (run verify_output.py)
```

**Step 1: Analyze the form**
Run: `python scripts/analyze_form.py input.pdf`
...
```

### Implement Feedback Loops

**Common pattern**: Run validator → fix errors → repeat

```markdown
## Document editing process

1. Make your edits to `word/document.xml`
2. **Validate immediately**: `python scripts/validate.py unpacked_dir/`
3. If validation fails:
   - Review the error message carefully
   - Fix the issues
   - Run validation again
4. **Only proceed when validation passes**
5. Rebuild the document
```

---

## Content Guidelines

### Avoid Time-sensitive Information

**Bad** (will become wrong):
```markdown
If you're doing this before August 2025, use the old API.
```

**Good** (use "old patterns" section):
```markdown
## Current method
Use the v2 API endpoint.

## Old patterns
<details>
<summary>Legacy v1 API (deprecated 2025-08)</summary>
The v1 API used: `api.example.com/v1/messages`
</details>
```

### Use Consistent Terminology

Choose one term and use it throughout:

**Good - Consistent:**
- Always "API endpoint"
- Always "field"
- Always "extract"

**Bad - Inconsistent:**
- Mix "API endpoint", "URL", "API route", "path"
- Mix "field", "box", "element", "control"

---

## Common Patterns

### Template Pattern

```markdown
## Report structure

ALWAYS use this exact template structure:

```markdown
# [Analysis Title]

## Executive summary
[One-paragraph overview]

## Key findings
- Finding 1 with supporting data
- Finding 2 with supporting data

## Recommendations
1. Specific actionable recommendation
```
```

### Examples Pattern

Provide input/output pairs:

```markdown
## Commit message format

**Example 1:**
Input: Added user authentication with JWT tokens
Output:
```
feat(auth): implement JWT-based authentication

Add login endpoint and token validation middleware
```

**Example 2:**
Input: Fixed bug where dates displayed incorrectly
Output:
```
fix(reports): correct date formatting in timezone conversion
```
```

### Conditional Workflow Pattern

```markdown
## Document modification workflow

1. Determine the modification type:
   **Creating new content?** → Follow "Creation workflow" below
   **Editing existing content?** → Follow "Editing workflow" below

2. Creation workflow:
   - Use docx-js library
   - Build document from scratch

3. Editing workflow:
   - Unpack existing document
   - Modify XML directly
   - Validate after each change
```

---

## Skills with Executable Code

### Solve, Don't Punt

Handle error conditions in scripts rather than failing:

**Good:**
```python
def process_file(path):
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        print(f"File {path} not found, creating default")
        with open(path, 'w') as f:
            f.write('')
        return ''
```

**Bad:**
```python
def process_file(path):
    # Just fail and let Claude figure it out
    return open(path).read()
```

### Document Configuration Values

Avoid "voodoo constants":

**Good:**
```python
# HTTP requests typically complete within 30 seconds
REQUEST_TIMEOUT = 30

# Three retries balances reliability vs speed
MAX_RETRIES = 3
```

**Bad:**
```python
TIMEOUT = 47  # Why 47?
RETRIES = 5   # Why 5?
```

### Provide Utility Scripts

Pre-made scripts offer advantages over generated code:
- More reliable
- Save tokens (no need to include code in context)
- Save time
- Ensure consistency

Make clear whether Claude should **execute** or **read** the script:
- Execute: "Run `analyze_form.py` to extract fields"
- Read as reference: "See `analyze_form.py` for the extraction algorithm"

---

## Anti-patterns to Avoid

### Windows-style Paths
- **Good**: `scripts/helper.py`, `reference/guide.md`
- **Bad**: `scripts\helper.py`

### Too Many Options
```markdown
# Bad - confusing
"You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image..."

# Good - provide a default
"Use pdfplumber for text extraction.
For scanned PDFs requiring OCR, use pdf2image with pytesseract instead."
```

### Assuming Tools are Installed
```markdown
# Bad
"Use the pdf library to process the file."

# Good
"Install required package: `pip install pypdf`

Then use it:
```python
from pypdf import PdfReader
```"
```

---

## Testing and Iteration

### Build Evaluations First

Create evaluations BEFORE writing documentation:

1. **Identify gaps**: Run Claude on tasks without a Skill, document failures
2. **Create evaluations**: Build three scenarios that test these gaps
3. **Establish baseline**: Measure Claude's performance without the Skill
4. **Write minimal instructions**: Just enough to pass evaluations
5. **Iterate**: Execute evaluations, compare, and refine

### Test with Multiple Models

- **Claude Haiku**: Does the Skill provide enough guidance?
- **Claude Sonnet**: Is the Skill clear and efficient?
- **Claude Opus**: Does the Skill avoid over-explaining?

### Develop Iteratively with Claude

1. Complete a task without a Skill, note what context you repeatedly provide
2. Ask Claude A to create a Skill capturing that pattern
3. Review for conciseness
4. Test with Claude B (fresh instance with Skill loaded)
5. Iterate based on observation

---

## Checklist for Effective Skills

### Core Quality
- [ ] Description is specific and includes key trigger terms
- [ ] Description includes both what it does AND when to use it
- [ ] SKILL.md body is under 500 lines
- [ ] Additional details are in separate files (if needed)
- [ ] No time-sensitive information
- [ ] Consistent terminology throughout
- [ ] Examples are concrete, not abstract
- [ ] File references are one level deep
- [ ] Workflows have clear steps

### Code and Scripts
- [ ] Scripts solve problems rather than punt to Claude
- [ ] Error handling is explicit and helpful
- [ ] No "voodoo constants" (all values justified)
- [ ] Required packages listed in instructions
- [ ] No Windows-style paths (use forward slashes)
- [ ] Validation/verification steps for critical operations

### Testing
- [ ] At least three evaluations created
- [ ] Tested with Haiku, Sonnet, and Opus
- [ ] Tested with real usage scenarios

---

## Reference Links

### Official Documentation
- [Skill Authoring Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) - Comprehensive official guide
- [Agent Skills Overview](https://code.claude.com/docs/en/skills) - Claude Code skills documentation
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices) - Agentic coding best practices

### Resources
- [anthropics/skills GitHub](https://github.com/anthropics/skills) - Public repository with example skills
- [What are Skills?](https://support.claude.com/en/articles/12512176-what-are-skills) - Support article
- [Creating Custom Skills](https://support.claude.com/en/articles/12512198-creating-custom-skills) - Step-by-step guide
- [Agent Skills Standard](http://agentskills.io) - Skills specification

### Announcements
- [Introducing Agent Skills](https://www.anthropic.com/news/skills) - Official announcement
- [Equipping Agents for the Real World](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) - Engineering blog post
