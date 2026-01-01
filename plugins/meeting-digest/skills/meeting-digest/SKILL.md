# Meeting Digest Skill

Generate concise, actionable summaries from Fireflies meeting transcripts.

## When to Use

Activate this skill when users ask to:
- Summarize a meeting or set of meetings
- Create meeting notes or digests
- Extract action items from meetings
- Generate a weekly/daily meeting roundup
- Find decisions made in meetings
- Create a briefing document from recent calls

## Trigger Phrases

- "Summarize my meetings"
- "What happened in my calls this week?"
- "Create a meeting digest"
- "Extract action items from [meeting]"
- "What decisions were made in [meeting]?"
- "Brief me on recent meetings"

## Prerequisites

- User must have Fireflies MCP integration connected
- Meetings must be recorded and transcribed in Fireflies

## Output Formats

### Quick Digest (Default)
A scannable summary with:
- **Meeting title & date**
- **Attendees** (brief list)
- **Key Topics** (2-3 bullet points)
- **Decisions Made** (if any)
- **Action Items** (owner + task)

### Detailed Summary
When user asks for "detailed" or "full" summary:
- Everything in Quick Digest plus
- **Discussion Highlights** (key points with speaker attribution)
- **Open Questions** (unresolved items)
- **Follow-up Needed** (items requiring attention)

### Action Items Only
When user asks specifically for action items:
- Bulleted list with owner, task, and due date (if mentioned)
- Grouped by assignee

## Workflow

1. **Identify scope**: Single meeting, date range, or keyword search
2. **Fetch transcripts**: Use Fireflies tools to retrieve meeting data
3. **Extract insights**: Pull out key information based on format requested
4. **Format output**: Present in clean, scannable format
5. **Offer next steps**: Ask if user wants to export, share, or dig deeper

## Example Interactions

### Example 1: Weekly Digest
**User**: "Give me a digest of my meetings this week"

**Claude**:
1. Search Fireflies for meetings in the past 7 days
2. For each meeting, extract: title, date, attendees, key topics, action items
3. Present as a consolidated weekly summary
4. Highlight any overdue or urgent action items

### Example 2: Specific Meeting Deep Dive
**User**: "What did we decide in the product roadmap meeting?"

**Claude**:
1. Search Fireflies for "product roadmap" keyword
2. Fetch full transcript and summary
3. Focus output on decisions and next steps
4. Include relevant context from discussion

## Tips for Best Results

- Be specific about time ranges when asking for multiple meetings
- Use keywords to narrow down to specific topics
- Ask for "action items" specifically if that's your main need
- Request "detailed" summary if you need full context

## Limitations

- Cannot access meetings not recorded in Fireflies
- Summary quality depends on transcript quality
- Cannot determine action item due dates unless explicitly stated in meeting
