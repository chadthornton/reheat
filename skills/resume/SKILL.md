---
name: resume
description: Resume work from an existing handoff document with deep cognitive rebuilding
model: sonnet
---

# Resume Work from Handoff Documentation

**EXECUTION STRATEGY: Resume operations require deep focus and should be performed in a clean context for optimal cognitive rebuilding.**

## Step 1: Spawn Focused Subagent for Resume

Use the Task tool to execute the resume process in a fresh context:

```
Use Task tool with these parameters:

subagent_type: "general-purpose"
description: "Resume from handoff with deep cognitive rebuilding"
model: "sonnet"
prompt: "You are resuming work on a project using an existing handoff document. Your goal is to rebuild the previous agent's mental model, avoid repeating mistakes, and continue productively.

## Why This Matters

Research shows that developer onboarding takes 3-6 months without proper knowledge transfer, and 60% identify 'not enough time to learn the codebase' as the #1 problem. This handoff represents hours of cognitive work—respect that investment by truly internalizing it, not just skimming.

**Your advantage:** The previous agent did the hard work of building a mental model and documenting what failed. Use it.

## Your Task

1. **Read and thoroughly understand the HANDOFF.md file** in the project root
2. **Rebuild the mental model** - understand HOW things work, not just what exists
3. **Learn from failures** - understand why approaches failed so you don't repeat them
4. **Proceed intelligently** - build on previous work, don't start over

---

## Phase 1: Deep Reading (Don't Rush This - 30 minutes)

### Read in This Order (Cognitive Load Management)

Working memory can only hold 4-5 items. Read strategically to build understanding layer by layer:

**First Pass - Context & Goals (5 min):**
1. **OBJECTIVE & CONTEXT** - What are we building and why?
2. **CURRENT STATUS** - Where are we in the journey?
3. **COGNITIVE LOAD HELPERS** - The 3 most critical things to understand

**Second Pass - Mental Model (10 min):**
4. **MENTAL MODEL** - How does this system work?
5. **KEY DECISIONS** - Why was it built this way?
6. **HIDDEN DEPENDENCIES & ASSUMPTIONS** - What must be true?

**Third Pass - Failures & Issues (10 min):**
7. **WHAT FAILED** - What approaches didn't work and why?
8. **ROOT CAUSE ANALYSIS** - What's actually broken?

**Fourth Pass - Action Plan (5 min):**
9. **NEXT STEPS** - What should I do?
10. **TECHNICAL CONTEXT** - Where is everything?

### Critical Sections (Read These Carefully)

**MENTAL MODEL** ⚠️ Most Important
- This is HOW the system works, not just WHAT exists
- Understand the data flow, component interactions, assumptions
- This is what takes 3-6 months to learn by yourself—it's handed to you

**WHAT FAILED** 💡 Saves Hours
- These are DISCOVERIES, not failures
- Each failed attempt eliminated a dead end
- Understanding WHY something failed prevents retry
- Look for 'mental model correction'—where expectations diverged from reality

**KEY DECISIONS** 🎯 Provides Context
- WHY things are the way they are
- What trade-offs were accepted
- What alternatives were considered and rejected
- Prevents you from suggesting already-rejected approaches

**HIDDEN DEPENDENCIES & ASSUMPTIONS** 🔍 Reveals Complexity
- Things that aren't obvious from code alone
- Tribal knowledge that would take weeks to discover
- Constraints that affect what you can do

---

## Phase 2: Confirm Understanding (REQUIRED Before Proceeding)

Before starting work, **explicitly confirm** your understanding:

**Template Response:**

I've read the handoff documentation and I'm ready to continue.

**What we're building:**
[One-sentence description of objective]

**Current state:**
[X]% complete
- ✅ [Key completed items]
- 🔄 [What's in progress]
- ⏳ [What's next]

**Mental model I've internalized:**
[Briefly describe how the system works - the data flow, key interactions]

**Critical learnings from failures:**
I note that [Approach X] was tried but failed because [root cause].
This taught us that [key insight].

Therefore, I'll [alternative approach that addresses the root cause].

**My understanding of why things are this way:**
[Key decision] was chosen over [alternative] because [rationale].
This means [consequence/constraint I need to respect].

**Immediate next action:**
[Specific next step from Priority 1, with file:line reference]

**Assumptions I'm making:**
- [Assumption 1] - appears to be verified
- [Assumption 2] - I should verify this

**Questions/Clarifications:**
[Any gaps in handoff or things that need clarification]

Does this match your understanding? Anything I'm missing or misinterpreting?

---

## Phase 3: Working with Failed Approaches

> **Critical:** Don't just avoid failures—understand them deeply

**When the handoff documents a failed approach:**

#### ❌ DON'T:
- Ignore it and try the same thing
- Think 'maybe it'll work for me'
- Assume it was tried wrong
- Retry without addressing root cause

#### ✅ DO:
- Understand WHY it failed (root cause)
- Understand what mental model was wrong
- Ask: 'What would need to be different for this to work?'
- Only retry if you have fundamentally new information

#### Example:

Handoff says: '❌ Tried app-level JWT middleware, failed because auth routes need to run before tokens exist (circular dependency)'

Bad response:
'Let me try adding JWT middleware to the app'
[This repeats the same failure]

Good response:
'I see that app-level middleware failed due to circular dependency—auth routes couldn't run because they needed tokens that didn't exist yet. The root cause was applying middleware globally instead of route-specifically.

I'll use route-specific middleware instead:
router.get(\"/protected\", authMiddleware, getUserProfile)

This addresses the root cause by allowing auth routes to run without middleware, while still protecting routes that need it.'

---

## Phase 4: Working with Root Causes vs. Symptoms

The handoff should document root causes, not just symptoms. Your job is to fix root causes.

**Example:**

Symptom documented: 'POST /api/refresh returns 500'

Root cause documented: 'jwt.verify() throws exception on invalid token, no try/catch exists, so exception crashes handler'

Bad fix (treats symptom):
'Let me check what's wrong with the refresh endpoint'
[Might waste time checking database, routes, etc.]

Good fix (addresses root cause):
'The root cause is that jwt.verify() throws instead of returning null, and there's no try/catch block. I'll wrap it in try/catch at auth.ts:65 to handle the exception properly and return 401 instead of crashing.'

---

## Phase 5: Respecting Decisions and Trade-offs

If the handoff documents a decision with rationale, **respect it** unless you have significant new information.

Example:

Handoff says: 'DECISION: Use JWT over sessions because of mobile clients, stateless scaling. Trade-off: Can't invalidate tokens before expiry, mitigated with 15min expiry + refresh tokens.'

Bad response:
'Maybe we should use sessions instead of JWT'
[This ignores documented reasoning]

Good response:
'I understand we're using JWT because of mobile clients and stateless scaling. The trade-off is we can't invalidate tokens before expiry, which is handled with short expiry + refresh tokens. I'll continue with this approach.'

---

## Phase 6: Update Handoff as You Work

As you make progress:
- ✅ Complete a task - mark it done, update status
- ❌ Hit a new failure - document it like previous failures
- 🔄 Make a decision - add to KEY DECISIONS with rationale
- 🎯 Discover new information - update mental model or assumptions
- 🚧 Find a blocker - document it in NEXT STEPS

---

## Meta-Cognition: Signs You're Using the Handoff Well

✅ You reference specific handoff sections in your explanations
✅ You avoid approaches documented as failed
✅ You build on documented decisions instead of questioning them
✅ You understand WHY things are the way they are
✅ You can explain the mental model in your own words
✅ You catch yourself before repeating documented mistakes

## Signs You're NOT Using the Handoff

❌ You suggest approaches already documented as failed
❌ You ask questions answered in the handoff
❌ You question decisions without understanding their rationale
❌ You can't explain why things are structured a certain way
❌ You treat handoff as a checklist, not a mental model
❌ You start debugging things already debugged

If any of these apply: **Stop. Re-read the handoff** focusing on MENTAL MODEL, WHAT FAILED, and KEY DECISIONS.

---

## Remember: This is Cognitive Transfer

The handoff is:
- ✅ A preserved mental model
- ✅ Documented discoveries (including failures)
- ✅ Architectural reasoning
- ✅ Tribal knowledge captured

The handoff is NOT:
- ❌ Just a status update
- ❌ A list of files that changed
- ❌ Only successful approaches
- ❌ Code you can copy/paste

### Your Goal

**Reach the same cognitive state the previous agent had.**

They spent hours:
- Building mental models
- Trying approaches
- Discovering what failed
- Understanding why
- Making decisions
- Learning the domain

You're getting all that compressed into 30 minutes of reading.

**Respect that investment.** Actually use it.

### Success Criteria

You've successfully resumed when:
- ✅ You can explain how the system works without looking at code
- ✅ You understand why failed approaches failed
- ✅ You can justify the key decisions made
- ✅ You know what assumptions are being made
- ✅ You can start being productive immediately
- ✅ You don't repeat documented mistakes

### Research-Backed Insight

> **Context switching costs 20% of cognitive capacity and creates performance hangovers. Tribal knowledge takes 3-6 months to acquire naturally. Working memory holds only 4-5 items. This handoff is designed to bypass those limitations—use it as the powerful tool it is.**

**The handoff represents hours of cognitive work. Honor that by actually internalizing it, not just reading it.**

---

Now execute the resume process following all phases above."
```

Execute the Task tool now with the prompt above.

---

## Step 2: Monitor and Support Resume Process

After the subagent begins the resume process, it will:

1. Read HANDOFF.md thoroughly (30 min deep reading)
2. Confirm understanding with detailed response
3. Ask for your confirmation before proceeding
4. Begin work based on documented next steps

**Your role:**
- Review the subagent's understanding confirmation
- Clarify any gaps or misunderstandings
- Confirm they're ready to proceed
- Let them continue the work

The subagent will work in fresh context, ensuring they truly internalize the handoff without distraction from previous conversation history.
