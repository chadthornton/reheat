---
name: save
description: Save comprehensive handoff documentation with parallel multi-agent analysis
model: sonnet
---

# Save Comprehensive Handoff Documentation

**EXECUTION STRATEGY: Multi-agent parallel architecture for comprehensive context capture.**

## Overview

This skill spawns 4 specialized agents in parallel to create:
1. **RESUME.md** - Primary handoff document (12 sections)
2. **.context/failures.log** - Chronological failure analysis
3. **.context/decisions.log** - Architectural decision records
4. **.context/learnings.log** - Key insights and patterns

## Step 1: Archive Existing Handoff

Before creating new handoff, archive the old one if it exists:

```bash
if [ -f RESUME.md ]; then
  mkdir -p resume-archive
  timestamp=$(date +%Y%m%d-%H%M)
  mv RESUME.md "resume-archive/RESUME-${timestamp}.md"
  echo "📦 Previous handoff archived to resume-archive/RESUME-${timestamp}.md"
fi

# Also archive .context/ if it exists
if [ -d .context ]; then
  mkdir -p resume-archive
  timestamp=$(date +%Y%m%d-%H%M)
  mv .context "resume-archive/.context-${timestamp}"
  echo "📦 Previous .context/ archived to resume-archive/.context-${timestamp}/"
fi
```

## Step 2: Spawn 4 Parallel Agents

Use the Task tool to spawn all 4 agents in parallel. Each agent works independently in fresh context.

### Agent 1: Resume Builder

```
subagent_type: "general-purpose"
description: "Build primary RESUME.md handoff"
model: "sonnet"
run_in_background: true
prompt: "You are Agent 1 of 4 in a parallel handoff creation system. Your job is to create the primary RESUME.md file that serves as the main entry point for resuming work.

## Your Role

Create a comprehensive RESUME.md that documents:
- What we're building and why
- Current status and progress
- Mental model of how the system works
- Next steps and priorities
- Technical context and setup

**DO NOT document:**
- Failed approaches (Agent 2 handles this → .context/failures.log)
- Decision rationale (Agent 3 handles this → .context/decisions.log)
- Deep insights (Agent 4 handles this → .context/learnings.log)

Instead, REFERENCE these logs where appropriate:
- "See .context/failures.log for attempts that didn't work"
- "See .context/decisions.log for architectural rationale"
- "See .context/learnings.log for key insights"

---

## RESUME.md Structure

Create a file with these sections:

### 1. OBJECTIVE & CONTEXT

**What we're building:**
- Main goal or feature
- Why this work matters
- What problem it solves

**Success criteria:**
- How will we know this is done?
- What does "working" look like?

---

### 2. CURRENT STATUS

**Completed:** ✅
- List what's been finished successfully
- Include file paths and line numbers

**In Progress:** 🔄
- What's partially done
- Current state and what remains

**Not Started:** ⏳
- What hasn't been touched yet
- Dependencies blocking progress

**Overall progress:** X% complete

**Confidence level:** [High/Medium/Low] - How stable is the current work?

---

### 3. MENTAL MODEL

> **Critical:** Document not just what exists, but HOW it's supposed to work

**How it works (expected behavior):**
- Describe the mental model of the system
- What's the intended flow?
- How do components interact?

**Data flow:**
- How does data move through the system?
- What transforms it along the way?
- Where does state live?

**Key assumptions:**
- What must be true for this to work?
- What conditions are assumed?
- What hasn't been verified?

Example:
```
Mental Model: User logs in → JWT generated → Token stored in header →
Middleware validates on each request → User ID attached to req.user

Assumption: Tokens are stateless (no DB lookup on each request)
Assumption: Refresh tokens are stored in DB for invalidation
Unverified: What happens if user changes password mid-session?
```

**Failed approaches:** See .context/failures.log for detailed analysis of what didn't work.

---

### 4. CURRENT ISSUES

List active bugs or blockers. For each:

**Issue [N]: [Brief description]**

**Symptom:**
- What's the visible problem?

**Root cause (if known):**
- What's really causing this?

**Reproduction steps:**
```
1. [Exact command or action]
2. [Expected behavior]
3. [Actual behavior]
```

**Debugging status:**
- What's been checked?
- What's been ruled out?

---

### 5. NEXT STEPS (Prioritized & Concrete)

**Priority 1: [Critical/Blocking]**
- [ ] Task description
  - Why this is urgent
  - What it unblocks
  - Estimated complexity: Low/Medium/High
  - File/line to start: [path:line]

**Priority 2: [Important]**
- [ ] Task description
  - Depends on: [Priority 1 task?]
  - Success criteria: [how to verify it works]

**Priority 3: [Nice to have]**
- [ ] Task description

**Blockers:**
- [ ] [Blocker description] - who can unblock?

---

### 6. TECHNICAL CONTEXT

#### Code Architecture

**Project structure:**
```
src/
├── routes/       - [Brief description]
├── services/     - [Brief description]
└── models/       - [Brief description]
```

**Key files and their roles:**

**[filename.ts](path/to/filename.ts)**
- What it does: [Brief description]
- Key functions: [list with line numbers]
- Status: [working/broken/in-progress]

#### Data Models

Document key data structures with their schemas.

#### Environment & Setup

**Required environment variables:**
```bash
VAR_NAME=description
```

**Setup commands:**
```bash
npm install
npm run dev
```

**Database state:**
- Applied migrations: [list]
- Test data: [brief description]

#### Testing

**How to test manually:**
```bash
# Example commands
curl -X POST http://localhost:3000/api/endpoint
```

**Tests that need writing:**
- [ ] Test description
- [ ] Test description

---

### 7. IMPORTANT NOTES & GOTCHAS

**Non-obvious behavior:**
- [Thing] works differently than expected
  - Location: [file:line]
  - Why: [explanation]

**Performance considerations:**
- [Concern and mitigation]

**Security concerns:**
- ⚠️ [Issue and risk level]

**Technical debt:**
- [Quick fix or hack that needs proper solution]
  - Location: [file:line]

---

### 8. COGNITIVE LOAD HELPERS

> **Help next agent build mental model quickly**

**If I could only tell you 3 things:**
1. [Most critical thing to understand]
2. [Second most critical]
3. [Third most critical]

**Common misconceptions:**
- ❌ You might think: [wrong assumption]
- ✅ Reality: [actual truth]

**What takes longest to understand:**
- [Aspect that requires most mental effort]

---

### 9. CROSS-REFERENCES

**For detailed context, see:**
- **.context/failures.log** - Chronological record of failed approaches with root causes
- **.context/decisions.log** - Architectural decisions with rationale and trade-offs
- **.context/learnings.log** - Key insights, patterns, and mental model refinements

**These logs are loaded lazily during resume - you don't need to read them unless:**
- You're about to try a new approach (check failures.log first)
- You're questioning a design choice (check decisions.log for rationale)
- You need deep insights on system behavior (check learnings.log)

---

## Execution Steps

1. **Analyze the current project state:**
   - Review recent git history: `git log --oneline -20`
   - Check file modifications: `git status`
   - Understand current working state

2. **Build the mental model:**
   - How does this system work?
   - What's the data flow?
   - What assumptions are being made?

3. **Create the RESUME.md file:**
   - Write each section thoroughly
   - Be specific with file paths and line numbers
   - Focus on HOW things work, not just WHAT exists
   - Reference .context/ logs for detailed analysis

4. **Confirm completion:**
   - Show summary of what was captured
   - Report file location
   - List sections included

---

## Quality Guidelines

### Preserve Mental Models
Document HOW things work, not just WHAT exists:
- ❌ "Token validation middleware exists"
- ✅ "When a request comes in, middleware extracts Bearer token, verifies signature, attaches user ID to req.user"

### Be Specific and Actionable
- Include file paths: `src/auth.ts:45`
- Include exact commands: `npm run test:auth`
- Include reproduction steps with expected vs actual

### Make Assumptions Explicit
- ❌ "Users have unique emails"
- ✅ "ASSUMPTION: Users have unique emails (verified by UNIQUE constraint on users.email)"

### Reference, Don't Duplicate
Since other agents handle failures, decisions, and learnings:
- Mention that failed approaches exist
- Link to .context/failures.log for details
- Focus your energy on current state and next steps

---

Now execute: Create RESUME.md following the structure above."
```

### Agent 2: Failure Analyzer

```
subagent_type: "general-purpose"
description: "Analyze failures → .context/failures.log"
model: "sonnet"
run_in_background: true
prompt: "You are Agent 2 of 4 in a parallel handoff creation system. Your job is to create .context/failures.log that documents every failed approach with deep root cause analysis.

## Your Role

Analyze the conversation history and codebase to identify:
- What approaches were tried but failed
- Exact error messages encountered
- Root causes (not just symptoms)
- What was learned from each failure
- Why retrying would fail without changes

**Focus on:** Deep forensic analysis of failures
**Don't document:** Current state, decisions, or general insights (other agents handle this)

---

## failures.log Format

Create `.context/failures.log` with this structure:

```
# Failures Log

This file documents failed approaches in chronological order with root cause analysis.

## Why This Matters

Failed approaches are discoveries, not mistakes. Each failure eliminated a dead end and taught us something about how the system really works. This log prevents future agents from repeating these time-consuming explorations.

---

## Failure #1: [Brief Description]

**Timestamp:** [When this was attempted]

**What I Tried:**
```
[Actual code or approach attempted - be specific]
```

**Error Encountered:**
```
[EXACT error message - copy/paste, don't paraphrase]
[Include stack trace if relevant]
```

**Context:**
- File/Location: [path:line]
- Goal: [What was I trying to accomplish?]
- Assumption: [What did I think would happen?]

**Root Cause:**
[Not just "it didn't work" - WHY didn't it work?]
[Use 5 Whys if needed to get to fundamental issue]

Example:
- Surface: "Middleware threw error"
- One level down: "JWT verification failed"
- Root cause: "jwt.verify() throws exceptions on invalid tokens instead of returning null, and no try/catch existed"

**What I Learned:**
[Key insight from this failure - what does this teach about the system?]

**Mental Model Correction:**
- **Expected:** [What I thought would happen]
- **Reality:** [What actually happens]

**Why Retry Would Fail:**
[What would need to be different for this approach to work?]
[Or: Why this approach is fundamentally flawed?]

**Alternative Approach:**
[If known: What's the better way to solve this?]

---

[Repeat for each failure...]

---

## Pattern Analysis

After documenting individual failures, add analysis section:

### Common Themes
[Are there recurring issues? Similar root causes?]

### System Insights
[What do these failures collectively teach about how the system works?]

### Areas of Confusion
[What aspects of the system caused the most failed attempts?]
```

---

## Execution Steps

1. **Review conversation history thoroughly:**
   - Look for error messages
   - Identify approaches that were abandoned
   - Find mentions of "didn't work", "failed", "error"

2. **For each failure, reconstruct:**
   - What was the actual code/approach?
   - What was the exact error?
   - What was the root cause?
   - What was learned?

3. **Analyze patterns:**
   - Do certain types of failures recur?
   - What system behaviors caused confusion?

4. **Create .context/failures.log:**
   - Document chronologically
   - Be forensically detailed
   - Focus on ROOT CAUSES not symptoms
   - Include exact error messages
   - Explain mental model corrections

5. **Report completion:**
   - Count of failures documented
   - Key patterns identified
   - File location

---

## Quality Guidelines

### Exact Error Messages
❌ "Got an auth error"
✅ "TokenExpiredError: jwt expired at verify (node_modules/jsonwebtoken/verify.js:147)"

### Root Causes Not Symptoms
❌ "Endpoint returned 500"
✅ "jwt.verify() throws on invalid token, no try/catch exists, exception bubbles up to Express default handler"

### Mental Model Corrections
❌ "Approach didn't work"
✅ "Expected: jwt.verify() returns null on invalid token. Reality: It throws exception requiring try/catch"

### Preventive Guidance
Include why retry would fail and what alternative to try instead.

---

Now execute: Create .context/failures.log with comprehensive failure analysis."
```

### Agent 3: Decision Tracker

```
subagent_type: "general-purpose"
description: "Track decisions → .context/decisions.log"
model: "sonnet"
run_in_background: true
prompt: "You are Agent 3 of 4 in a parallel handoff creation system. Your job is to create .context/decisions.log that documents architectural and technical decisions with full rationale.

## Your Role

Analyze the conversation and code to identify:
- Key technical and architectural decisions
- What options were considered
- Why specific choices were made
- Trade-offs accepted
- Alternatives rejected and why

**Focus on:** Decision rationale and trade-offs
**Don't document:** Implementation details, failures, or insights (other agents handle this)

---

## decisions.log Format

Create `.context/decisions.log` with this structure:

```
# Decisions Log

This file documents key decisions made during development with full rationale and trade-offs.

## Why This Matters

Understanding WHY decisions were made prevents future agents from:
- Questioning choices without context
- Suggesting already-rejected alternatives
- Breaking carefully considered trade-offs
- Undoing decisions without understanding consequences

---

## Decision #1: [Clear Decision Statement]

**Date:** [When decided]

**Status:** [Active | Superseded | Under Review]

**Context:**
[What situation prompted this decision?]
[What problem were we trying to solve?]
[What constraints existed?]

**Options Considered:**

### Option A: [Name]
**Description:** [What this option involves]
**Pros:**
- [Advantage 1]
- [Advantage 2]

**Cons:**
- [Disadvantage 1]
- [Disadvantage 2]

**Why Rejected:**
[Specific reason this wasn't chosen]

### Option B: [Name]
[Same structure...]

### Option C: [Name] ✅ CHOSEN
**Description:** [What this option involves]
**Pros:**
- [Advantage 1]
- [Advantage 2]

**Cons:**
- [Disadvantage 1 - how we're mitigating]
- [Disadvantage 2 - how we're mitigating]

**Why Chosen:**
[Specific rationale for this choice]
[What factors were most important?]

**Trade-offs Accepted:**
- **Giving up:** [What capability/benefit we're sacrificing]
- **Gaining:** [What we get in return]
- **Mitigation:** [How we're handling the downside]

**Consequences:**
- ✅ **Enables:** [What this decision makes possible]
- ⚠️ **Constrains:** [What limitations this creates]
- 🔒 **Commits to:** [What we're locked into]

**If This Decision Changes:**
[What would need to be refactored?]
[How much work to reverse?]

---

[Repeat for each decision...]

---

## Decision Dependencies

Document how decisions relate:

**Decision Tree:**
```
Decision #1 (Auth: JWT vs Sessions)
    ↓ requires
Decision #3 (Token Storage: DB vs In-Memory)
    ↓ enables
Decision #5 (Mobile Client Support)
```

**Conflicting Decisions:**
[Are there tensions between decisions?]
[How are conflicts being managed?]

---

## Evolution of Decisions

**Superseded Decisions:**

### [Original Decision] → [New Decision]
**When Changed:** [Date]
**Why Changed:** [What new information prompted the change?]
**Migration:** [How are we handling the transition?]

```

---

## Execution Steps

1. **Review conversation for decision points:**
   - Look for discussions of alternatives
   - Find comparisons of approaches
   - Identify trade-off discussions
   - Note explicit choices made

2. **For each decision, document:**
   - What options were considered
   - What factors influenced the choice
   - What trade-offs were accepted
   - What this enables/constrains

3. **Analyze relationships:**
   - Do decisions depend on each other?
   - Are there conflicts or tensions?
   - Have decisions evolved?

4. **Create .context/decisions.log:**
   - Use clear decision statements
   - Provide full rationale
   - Document all alternatives
   - Explain trade-offs explicitly

5. **Report completion:**
   - Count of decisions documented
   - Key dependencies noted
   - File location

---

## Quality Guidelines

### Clear Decision Statements
❌ "Using JWT"
✅ "Decision: Use JWT tokens instead of server-side sessions for API authentication"

### Full Rationale
Include WHY, not just WHAT:
- What problem does this solve?
- Why this option over alternatives?
- What factors were most important?

### Explicit Trade-offs
❌ "JWT is better"
✅ "JWT enables stateless scaling but can't be invalidated before expiry. Mitigating with 15min expiry + refresh tokens."

### Rejected Alternatives
Document why other options weren't chosen:
"Sessions rejected because: Requires sticky sessions or Redis, adds operational complexity"

---

Now execute: Create .context/decisions.log with comprehensive decision documentation."
```

### Agent 4: Insight Extractor

```
subagent_type: "general-purpose"
description: "Extract insights → .context/learnings.log"
model: "sonnet"
run_in_background: true
prompt: "You are Agent 4 of 4 in a parallel handoff creation system. Your job is to create .context/learnings.log that extracts deep insights and patterns from the work.

## Your Role

Analyze the conversation and work to identify:
- Key insights about how the system works
- Non-obvious patterns discovered
- Mental model refinements
- Deep understanding that took time to build
- Tribal knowledge worth preserving

**Focus on:** Deep insights and patterns
**Don't document:** Failures, decisions, or status (other agents handle this)

---

## learnings.log Format

Create `.context/learnings.log` with this structure:

```
# Learnings Log

This file captures key insights, patterns, and deep understanding gained during development.

## Why This Matters

Some knowledge takes hours or days to build:
- How components really interact
- Non-obvious system behaviors
- Patterns that aren't documented
- Mental models that crystallize with experience

This log preserves that hard-won understanding.

---

## Category: System Behavior

### Learning #1: [Insight Title]

**Discovery Date:** [When realized]

**The Insight:**
[Clear statement of what was learned]

**Why This Matters:**
[How does this insight change understanding?]
[What does this enable or prevent?]

**How We Discovered This:**
[What led to this realization?]
[Was it from a failure? Testing? Code reading?]

**Practical Implications:**
- [How does this affect implementation?]
- [What should future work account for?]
- [What mistakes does this prevent?]

**Example:**
```
[Code or scenario that demonstrates this insight]
```

**Related Concepts:**
- [Connected to Learning #X]
- [Builds on Decision #Y]

---

## Category: Mental Model Refinements

### Learning #2: [Model Evolution]

**Initial Mental Model:**
[What I thought was happening]

**Refined Mental Model:**
[What's actually happening]

**What Changed My Understanding:**
[What evidence led to refinement?]

**Critical Distinction:**
[What's the key difference between models?]

Example:
```
Initial Model: "JWT middleware validates tokens globally"

Refined Model: "JWT middleware would create circular dependency
if applied globally because auth routes need to run before tokens
exist. Route-specific middleware solves this."

What Changed: Failed attempt at app-level middleware revealed
the circular dependency issue.

Critical Distinction: The difference between protecting all routes
by default (push model) vs protecting specific routes as needed
(pull model).
```

---

## Category: Non-Obvious Patterns

### Learning #3: [Pattern Name]

**Pattern Observed:**
[Description of recurring pattern or behavior]

**Where This Appears:**
- [Location 1]
- [Location 2]
- [Location 3]

**Why This Pattern Exists:**
[Underlying reason for this pattern]

**How to Work With This Pattern:**
[Best practices for handling this]

---

## Category: Tribal Knowledge

### Learning #4: [Hidden Knowledge]

**What Isn't Documented:**
[Thing that only experienced developers know]

**Where This Matters:**
[Situations where this knowledge is critical]

**How to Discover This:**
[How would someone learn this without this log?]
[Probably: painfully, through trial and error]

**Examples of Getting Bitten:**
[Scenarios where not knowing this causes problems]

---

## Meta-Patterns

### Cognitive Themes

**What Was Hardest to Understand:**
[Aspects that took longest to grasp]
[Why were these difficult?]

**Most Valuable Insights:**
[Top 3 learnings that had biggest impact]

**Knowledge Gaps Remaining:**
[What do we still not fully understand?]
[What needs more investigation?]

### System Characteristics

**This System Tends To:**
[Behavioral tendencies observed]
[How does the system behave under different conditions?]

**Common Gotchas:**
[Repeated pitfalls or surprises]

**Power User Tips:**
[Advanced techniques discovered]
[Shortcuts or patterns that work well]

---

## Cross-References

**Learnings From Failures:**
[Which insights came from failures.log entries?]

**Learnings That Informed Decisions:**
[Which insights led to decisions in decisions.log?]

```

---

## Execution Steps

1. **Deep analysis of conversation:**
   - What insights emerged over time?
   - What was surprising or non-obvious?
   - What took effort to understand?
   - What "aha!" moments occurred?

2. **Identify patterns:**
   - Are there recurring themes?
   - What system behaviors are notable?
   - What knowledge isn't documented elsewhere?

3. **Extract mental model evolution:**
   - How did understanding change?
   - What corrections were made?
   - What distinctions matter?

4. **Capture tribal knowledge:**
   - What would only experienced devs know?
   - What causes problems if unknown?
   - What isn't in official docs?

5. **Create .context/learnings.log:**
   - Organize by category
   - Focus on NON-OBVIOUS insights
   - Explain practical implications
   - Show how insights connect

6. **Report completion:**
   - Count of learnings captured
   - Key patterns identified
   - File location

---

## Quality Guidelines

### Focus on Non-Obvious
Don't document obvious facts:
❌ "JWT is used for authentication"
✅ "JWT verification is synchronous and blocks event loop - OK for <1000 req/s, problematic above that"

### Explain Implications
Connect insights to practice:
❌ "Tokens expire after 15 minutes"
✅ "15min expiry means mobile apps must handle background refresh, or users get logged out mid-session"

### Show Mental Model Evolution
Document how understanding changed:
"Initial Model: X → Refined Model: Y → Key Distinction: Z"

### Preserve Hard-Won Knowledge
Focus on insights that took time/effort to discover.

---

Now execute: Create .context/learnings.log with deep insights and patterns."
```

---

## Step 3: Wait for All Agents to Complete

Use TaskOutput to retrieve results from all 4 background agents:

```
TaskOutput for Agent 1 (Resume Builder)
TaskOutput for Agent 2 (Failure Analyzer)
TaskOutput for Agent 3 (Decision Tracker)
TaskOutput for Agent 4 (Insight Extractor)
```

---

## Step 4: Cross-Reference and Synthesize

After all agents complete, perform coordinator analysis:

1. **Read all generated files:**
   - RESUME.md
   - .context/failures.log
   - .context/decisions.log
   - .context/learnings.log

2. **Identify cross-references:**
   - Which failures led to which decisions?
   - Which learnings emerged from which failures?
   - Which decisions were informed by which insights?

3. **Detect patterns:**
   - Are there themes across files?
   - Do failures cluster around certain areas?
   - Are decisions interconnected?

4. **Generate summary report for user**

---

## Step 5: Report Results to User

Provide comprehensive summary:

```
✅ Created comprehensive handoff documentation with multi-agent analysis

**Primary Document:**
- RESUME.md (X sections, Y KB)

**Diagnostic Logs:**
- .context/failures.log (N failures analyzed)
- .context/decisions.log (M decisions documented)
- .context/learnings.log (K insights captured)

**Cross-Reference Patterns Detected:**
- [Pattern 1: e.g., "3 failures led to Decision #2 about token handling"]
- [Pattern 2: e.g., "Learning about async behavior influenced 2 architectural decisions"]
- [Pattern 3: e.g., "Authentication failures clustered around middleware lifecycle"]

**What Was Captured:**
- Current state and 60% progress estimate
- Mental model of system data flow
- 3 failed approaches with root causes
- 5 architectural decisions with trade-offs
- 7 key insights about non-obvious behavior
- Prioritized next steps with file:line references

**To Resume:**
Use `/reheat:resume` - it will load RESUME.md first, then lazily reference .context/ logs as needed.

**To Share:**
Commit RESUME.md and .context/ to git, or share with any AI agent for seamless continuation.
```

---

## Remember

This multi-agent approach provides:
- **Parallel execution** - 4x faster than sequential
- **Specialized focus** - Each agent optimizes for their domain
- **Rich context** - Primary doc + 3 diagnostic logs
- **Pattern detection** - Coordinator spots connections across findings
- **Lazy loading** - Resume reads RESUME.md first, only loads .context/ logs when needed

The result is comprehensive handoff documentation that enables seamless continuation by any AI agent.
