---
name: save-quick
description: Save minimal handoff documentation with parallel 3-agent architecture
model: sonnet
---

# Save Quick Handoff Documentation

**EXECUTION STRATEGY: Parallel 3-agent architecture for 2x faster handoff creation.**

## Overview

This skill spawns 3 specialized agents in parallel to create RESUME.md sections simultaneously:
- **Agent 1:** Context & Status (sections 1-3)
- **Agent 2:** Action & Files (sections 4-5)
- **Agent 3:** Notes & Warnings (section 6)

**Performance:** ~1 minute (vs 2-3 minutes sequential)

---

## Step 1: Archive Existing Handoff

Before creating new RESUME.md, archive the old one if it exists using Bash tool:

```bash
if [ -f RESUME.md ]; then
  mkdir -p resume-archive
  timestamp=$(date +%Y%m%d-%H%M)
  mv RESUME.md "resume-archive/RESUME-${timestamp}.md"
  echo "📦 Previous handoff archived to resume-archive/RESUME-${timestamp}.md"
fi
```

---

## Step 2: Spawn 3 Parallel Agents

Use the Task tool to spawn all 3 agents **in a single message** with `run_in_background: true`.

### Agent 1: Context & Status Writer

````
Task tool parameters:

subagent_type: "general-purpose"
description: "Agent 1: Write context & status"
model: "haiku"
run_in_background: true
prompt: "You are Agent 1 of 3 creating a quick handoff document. Write ONLY sections 1-3 of RESUME.md.

## Accessing Conversation History

Use the shared helper script to extract conversation context:

```bash
# Extract user's stated goals/objectives (for section 1)
bash .context/extract-conversation.sh user_goals

# Extract error messages from conversation (for section 3)
bash .context/extract-conversation.sh errors
```

These commands return relevant excerpts from the conversation history to help you write accurate sections.

## Your Sections

### 1. WHAT WE'RE DOING

One or two sentences describing the current goal/objective. Use conversation history to capture the user's actual stated objective.

Example:
```
## 1. WHAT WE'RE DOING

Implementing JWT-based authentication for the Express API with token refresh flow.
```

### 2. PROGRESS

Quick status using these exact emojis:
- ✅ What's done (completed items)
- 🔄 What's in progress (current work)
- ⏳ What's next (not started)

Example:
```
## 2. PROGRESS

- ✅ Login endpoint working
- ✅ Token generation implemented
- 🔄 Refresh token flow (80% done, endpoint fails with 500)
- ⏳ Auth middleware not started
- ⏳ Integration tests
```

### 3. CURRENT STATE

Brief description of what's working/broken. Use extracted error messages to include ACTUAL errors from conversation.

Example:
```
## 3. CURRENT STATE

**Working:**
- POST /api/login returns 200 with access + refresh tokens
- Token generation with jwt.sign()

**Broken:**
- POST /api/refresh returns 500: \"Cannot read property 'id' of undefined\"
- Error at routes/auth.ts:67 - decoded payload is undefined
```

## Output Format

Return ONLY the markdown text for sections 1-3. No explanations, just the formatted sections:

```
## 1. WHAT WE'RE DOING

[1-2 sentences from user's actual stated goal]

## 2. PROGRESS

- ✅ [item]
- 🔄 [item]
- ⏳ [item]

## 3. CURRENT STATE

**Working:**
- [item]

**Broken:**
- [item with ACTUAL error message from conversation]
```

## Critical Rules

- Use helper script to extract user goals and error messages from conversation
- Be SPECIFIC: Include file paths, line numbers, ACTUAL error messages (not summaries)
- Be CONCISE: This is quick mode - essential info only
- NO analysis of failures/decisions - just current state
- Return ONLY your sections, no preamble"
````

### Agent 2: Action & Files Writer

````
Task tool parameters:

subagent_type: "general-purpose"
description: "Agent 2: Write action & files"
model: "haiku"
run_in_background: true
prompt: "You are Agent 2 of 3 creating a quick handoff document. Write ONLY sections 4-5 of RESUME.md.

## Accessing Conversation History

Use the shared helper script to extract conversation context:

```bash
# Extract explicit next steps mentioned in conversation (for section 4)
bash .context/extract-conversation.sh next_steps

# Extract file importance discussions (for section 5)
bash .context/extract-conversation.sh key_files
```

These commands return relevant excerpts from the conversation to help identify what was discussed as next steps and which files were mentioned most frequently.

## Your Sections

### 4. NEXT ACTION

The single most important next step with specific details. Use conversation history to capture explicit next steps that were mentioned.

Example:
```
## 4. NEXT ACTION

Fix refresh token endpoint error at routes/auth.ts:67

**Steps:**
1. Add try/catch around jwt.verify() call
2. Check decoded payload exists before accessing .id
3. Test with: curl -X POST http://localhost:3000/api/refresh -d '{\"refreshToken\":\"...\"}'

**Expected fix:** 5-10 minutes
```

### 5. KEY FILES

List 3-5 most important files with one-line descriptions. Use extracted file mentions to prioritize files discussed in conversation.

Example:
```
## 5. KEY FILES

- routes/auth.ts - Login, refresh endpoints (error at line 67)
- services/jwt.ts - Token generation/verification functions
- models/User.ts - User model with refreshToken field
- middleware/auth.ts - Auth middleware (not implemented yet)
```

## Output Format

Return ONLY the markdown text for sections 4-5:

```
## 4. NEXT ACTION

[Single most important step from conversation context]

**Steps:**
1. [specific action]
2. [specific action]

**Expected:** [time estimate]

## 5. KEY FILES

- [file:line] - [one-line description]
- [file] - [description]
```

## Critical Rules

- Use helper script to extract next steps and file importance from conversation
- Next action must be ACTIONABLE: specific file, line number, what to do
- Key files must include LINE NUMBERS where relevant
- Prioritize files that were actually discussed in the conversation
- One-line descriptions only - no paragraphs
- Return ONLY your sections, no preamble"
````

### Agent 3: Notes Writer

````
Task tool parameters:

subagent_type: "general-purpose"
description: "Agent 3: Write notes & gotchas"
model: "haiku"
run_in_background: true
prompt: "You are Agent 3 of 3 creating a quick handoff document. Write ONLY section 6 of RESUME.md.

## Accessing Conversation History

Use the shared helper script to extract conversation context:

```bash
# Extract failed approaches (for Failed approaches section)
bash .context/extract-conversation.sh failures

# Extract architectural decisions (for Decisions section)
bash .context/extract-conversation.sh decisions

# Extract gotchas and warnings (for Gotchas section)
bash .context/extract-conversation.sh gotchas
```

These commands use optimized grep+jq patterns to quickly extract relevant conversation excerpts about what didn't work, what was decided, and what to watch out for.

## Your Section

### 6. NOTES

Any gotchas, decisions, or context that would be painful to rediscover. Use conversation history to capture actual failures, decisions, and gotchas that were discussed.

Include:
- Brief mentions of failed approaches (1 line each with why)
- Key decisions made (with quick rationale)
- Non-obvious behavior or gotchas
- Critical context that's not in code

Example:
```
## 6. NOTES

**Failed approaches:**
- ❌ App-level JWT middleware - caused token expiration errors on auth routes (circular dependency)
- ❌ In-memory refresh tokens - lost on server restart

**Decisions:**
- Using 15min access token expiry (industry standard, balances security/UX)
- Storing refresh tokens in DB (enables logout, security revocation)

**Gotchas:**
- JWT_SECRET and JWT_REFRESH_SECRET must be different values
- Token expiry format is strings like \"15m\", \"7d\" not milliseconds
```

## Output Format

Return ONLY the markdown text for section 6:

```
## 6. NOTES

**Failed approaches:**
- ❌ [approach from conversation] - [why it failed in one line]

**Decisions:**
- [decision from conversation] ([quick rationale])

**Gotchas:**
- [non-obvious thing discovered]
```

## Critical Rules

- Use helper script to extract failures, decisions, and gotchas from conversation
- Keep failures BRIEF: error message + why (one line each)
- Decisions with RATIONALE: not just what, but quick why
- Gotchas are non-obvious things that save time
- Return ONLY your section, no preamble"
````

---

## Step 3: Wait for All Agents & Assemble

After spawning all 3 agents in parallel, wait for their outputs using TaskOutput tool:

```
agent1_output = TaskOutput(agent1_task_id, block=true, timeout=90000)
agent2_output = TaskOutput(agent2_task_id, block=true, timeout=90000)
agent3_output = TaskOutput(agent3_task_id, block=true, timeout=90000)
```

Then assemble sections into single RESUME.md using Write tool:

```markdown
# RESUME.md

{agent1_output content}

{agent2_output content}

{agent3_output content}

---

*Quick handoff created by /reheat:save-quick*
*For comprehensive documentation with failure analysis, use /reheat:save*
```

Write the assembled file to RESUME.md in project root.

---

## Step 4: Report to User

After assembling and writing RESUME.md:

```
✅ Created quick handoff at RESUME.md (parallel 3-agent generation)

Archive: Previous handoff archived to resume-archive/RESUME-[timestamp].md

Essential context captured:
- Current objective and status (sections 1-3)
- Specific next action (section 4)
- Key files to focus on (section 5)
- Gotchas and quick failure notes (section 6)

Performance: ~1 minute (3 agents in parallel)

To resume: /reheat:resume (auto-adapts to handoff depth)
```

Ask the user if there's any critical context that should be added.

---

## Implementation Notes

### Why 3 Agents?

**Section grouping:**
- Agent 1: Context-heavy (what/progress/state) - naturally together
- Agent 2: Action-oriented (next steps/files) - both about "what to do"
- Agent 3: Warnings & gotchas - standalone meta-information

**Load balancing:**
- Agent 1: ~40% of work (3 sections, context analysis)
- Agent 2: ~30% of work (2 sections, concrete info)
- Agent 3: ~30% of work (1 section, but requires synthesis)
- All complete in ~same time (~30-60 seconds)

### Why Haiku Model?

Quick save uses **Haiku** instead of Sonnet:
- 3-5x faster inference
- Sufficient for structured output
- Clear prompts → high quality despite smaller model
- Cost savings for 70% use case

### Performance Comparison

**Old (1 agent sequential):**
- Single agent analyzes + writes all 6 sections
- ~2-3 minutes total

**New (3 agents parallel):**
- All 3 analyze conversation simultaneously (~30s)
- Each writes their sections in parallel (~30s)
- Main assembles (~5s)
- **~1 minute total** (2-3x faster)

---

## When to Use

**Use save-quick when:**
- Task is straightforward with clear next steps
- Limited experimentation, mostly linear progress
- Time-sensitive (need checkpoint fast)
- 70% of handoff use cases

**Use save (comprehensive) when:**
- Multiple failed approaches need detailed documentation
- Complex architectural decisions require rationale
- Want failure analysis (.context/failures.log)
- Want decision records (.context/decisions.log)
- Want deep insights (.context/learnings.log)
- 30% of handoff use cases
