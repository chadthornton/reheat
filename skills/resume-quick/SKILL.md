---
name: resume-quick
description: Resume work quickly for immediate continuation (short breaks, same day)
model: sonnet
---

# Resume Work Quickly (Immediate Continuation)

**EXECUTION STRATEGY: Even quick resumes benefit from fresh context for clarity and focus.**

## Step 1: Spawn Focused Subagent for Quick Resume

Use the Task tool to execute the quick resume in a fresh context:

```
Use Task tool with these parameters:

subagent_type: "general-purpose"
description: "Quick resume for immediate continuation"
model: "haiku"
prompt: "You are resuming work from a very recent handoff (same day, short break). The context is still fresh, so you need a faster resume process focused on action rather than deep cognitive rebuilding.

## When to Use This

Use this quick resume when:
- ✅ Resuming within hours of creating the handoff
- ✅ Short break (lunch, meeting, quick task switch)
- ✅ Context is still relatively fresh
- ✅ Just need to get oriented and continue

Use /reheating:resume (full version) when:
- ⏰ Resuming after days/weeks
- ⏰ Different agent/person picking up work
- ⏰ Complex project with lots of context
- ⏰ Need deep cognitive rebuilding

---

## Quick Resume Process (5 minutes total)

### 1. Speed Read (5 minutes)

Read HANDOFF.md focusing on these sections in order:

**Priority 1: Action-Focused**
- CURRENT STATUS - Where are we?
- NEXT STEPS - What should I do?
- CURRENT ISSUES - What's broken?

**Priority 2: Failure Prevention**
- WHAT FAILED - Skim for any approaches to avoid
- ROOT CAUSE ANALYSIS - Any active bugs?

**Priority 3: Reference (as needed)**
- TECHNICAL CONTEXT - Where are files?
- MENTAL MODEL - Only if you need clarification

**Skip (for now):**
- OBJECTIVE & CONTEXT - you know this
- KEY DECISIONS - already internalized
- HIDDEN DEPENDENCIES - check if stuck
- COGNITIVE LOAD HELPERS - you have context
- REFERENCES - check if needed

---

### 2. Quick Confirmation (30 seconds)

Brief check-in:

I've reviewed the handoff. Ready to continue:

Status: [X]% complete
Next: [Specific task from Priority 1]
Avoiding: [Any failed approach if relevant]

Proceeding with [specific action]. Let me know if anything changed.

**No need for:**
- Full mental model explanation
- Detailed understanding of all failures
- Decision rationale review
- Unless something is unclear

---

### 3. Jump Right In

Start working immediately on Priority 1 task.

**Reference handoff as needed:**
- Check WHAT FAILED before trying new approach
- Check TECHNICAL CONTEXT for file locations
- Check ROOT CAUSE ANALYSIS if debugging

**Update as you go:**
- Mark tasks complete
- Document new failures if any
- Update status

---

## If You Hit Confusion

If something doesn't make sense during quick resume:

1. **Stop and read that section carefully**
   - MENTAL MODEL - if you don't understand how it works
   - WHAT FAILED - if you're about to try something
   - KEY DECISIONS - if you're questioning an approach

2. **Or ask to switch to full resume**
   - If it's been longer than you thought
   - If context isn't as fresh as expected
   - If the handoff is more complex than expected

---

## Remember

Quick resume is for **continuity**, not **handoff**.

- You're the same agent (or it hasn't been long)
- Context is fresh
- Just need orientation
- Not rebuilding cognitive state

If any of those aren't true, use /reheating:resume instead.

**Speed is good, but understanding is better than speed when the cost of mistakes is high.**

---

Now execute the quick resume process."
```

Execute the Task tool now with the prompt above.

---

## Step 2: Monitor Quick Resume

After the subagent performs the quick resume, they will:

1. Speed-read HANDOFF.md (5 minutes, action-focused)
2. Provide brief confirmation of status and next action
3. Begin working immediately on Priority 1 task

The subagent operates in fresh context, so even the "quick" resume gets the benefit of focused attention without the clutter of previous conversation history.

**If the subagent indicates confusion or complexity:**

- Consider switching to full resume (`/reheating:resume`)
- The handoff may be more complex than a quick resume can handle
- Fresh context helps, but deep understanding may be needed
