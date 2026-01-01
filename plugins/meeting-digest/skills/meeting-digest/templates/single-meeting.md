# Meeting Summary: {{title}}

**Date**: {{date}}
**Duration**: {{duration}}
**Attendees**: {{attendees}}

---

## 🎯 Key Topics

{{#each topics}}
- {{this}}
{{/each}}

## ✅ Decisions Made

{{#each decisions}}
- {{this}}
{{/each}}

## 📋 Action Items

{{#each action_items}}
- [ ] **{{this.owner}}**: {{this.task}}
{{/each}}

## 💬 Discussion Highlights

{{#each highlights}}
> "{{this.quote}}" — {{this.speaker}}
{{/each}}

## ❓ Open Questions

{{#each open_questions}}
- {{this}}
{{/each}}
