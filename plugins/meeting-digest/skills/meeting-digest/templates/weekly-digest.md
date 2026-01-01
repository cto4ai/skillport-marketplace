# Weekly Meeting Digest

**Week of**: {{week_start}} - {{week_end}}
**Total Meetings**: {{meeting_count}}

---

{{#each meetings}}
## {{this.title}}
📅 {{this.date}} | 👥 {{this.attendee_count}} attendees

**Key Topics**:
{{#each this.topics}}
- {{this}}
{{/each}}

**Decisions**:
{{#each this.decisions}}
- {{this}}
{{/each}}

**Action Items**:
{{#each this.action_items}}
- [ ] {{this.task}} ({{this.owner}})
{{/each}}

---
{{/each}}

## 📋 All Action Items This Week

{{#each all_action_items}}
- [ ] **{{this.owner}}**: {{this.task}} _(from {{this.meeting}})_
{{/each}}
