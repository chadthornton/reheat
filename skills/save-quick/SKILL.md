---
name: save-quick
description: Save minimal handoff documentation for straightforward tasks
model: sonnet
---

# Save Quick Handoff Documentation

**EXECUTION STRATEGY: This task benefits from fresh context for clarity and focus.**

## Step 1: Spawn Focused Subagent

Use the Task tool to execute this handoff creation in a fresh context:

````
Use Task tool with these parameters:

subagent_type: "general-purpose"
description: "Create quick handoff in fresh context"
model: "sonnet"
prompt: "You are creating a minimal handoff document for straightforward tasks where extensive documentation isn't needed.

## Your Task

Create a concise HANDOFF.md file in the project root with essential information only.

**IMPORTANT - Archive Existing Handoff:**
Before creating the new HANDOFF.md, check if one already exists. If it does:
1. Create a `handoff-archive/` directory if it doesn't exist
2. Move the existing HANDOFF.md to `handoff-archive/HANDOFF-YYYYMMDD-HHMM.md` with the current timestamp
3. Inform the user that the previous handoff was archived

Example:
```bash
if [ -f HANDOFF.md ]; then
  mkdir -p handoff-archive
  timestamp=$(date +%Y%m%d-%H%M)
  mv HANDOFF.md "handoff-archive/HANDOFF-${timestamp}.md"
  echo "📦 Previous handoff archived to handoff-archive/HANDOFF-${timestamp}.md"
fi
````

## Document Structure

Write a streamlined handoff with these sections:

### 1. WHAT WE'RE DOING

One or two sentences describing the goal.

### 2. PROGRESS

- ✅ What's done
- 🔄 What's in progress
- ⏳ What's next

### 3. CURRENT STATE

Brief description of what's working and what's not. Include any active errors with the actual error message.

### 4. NEXT ACTION

The single most important next step, with specific details on how to proceed.

### 5. KEY FILES

List the 3-5 most important files for this work with one-line descriptions.

### 6. NOTES

Any gotchas, decisions, or context that would be painful to rediscover.

## Quality Guidelines

Even in quick mode, be specific:

- Include actual error messages, not summaries
- Reference file paths and line numbers
- Provide concrete next steps, not vague suggestions

If there were failed approaches, mention them briefly with why they failed.

## When to Use Quick vs Create

Use **save-quick** when:

- Task is straightforward with clear next steps
- Limited experimentation or failures
- Progress is linear and well-understood
- Time-sensitive and need to move fast

Use **save** (comprehensive save) when:

- Multiple approaches have been tried
- Complex architectural decisions made
- Many moving parts or files involved
- Want to ensure nothing is lost in handoff

## Remember

Quick doesn't mean sloppy—it means concise. Every detail included should be specific and actionable. The goal is the minimum information needed for another agent to continue effectively."

```

Execute the Task tool now with the prompt above.

---

## Step 2: Report Results to User

After the subagent completes the handoff creation, confirm with the user:

```

✅ Created quick handoff at HANDOFF.md

The handoff was created in a fresh context for clarity and focus.

Essential context captured:

- Current objective and status
- Specific next action
- Key files to focus on
- Any failures to avoid

To resume: Use /reheat:resume (automatically adapts to handoff depth)

```

Ask the user if there's any critical context that should be added to the handoff.
```
