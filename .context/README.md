# .context/ Directory

This directory contains diagnostic logs that supplement the main [RESUME.md](../RESUME.md) handoff document.

## Purpose

While `RESUME.md` provides the primary handoff (current state, mental model, next steps), these logs capture deeper analysis that would make the main document too large and unwieldy:

- **failures.log** - Chronological record of failed approaches with root cause analysis
- **decisions.log** - Architectural decisions with full rationale and trade-offs
- **learnings.log** - Key insights, patterns, and mental model refinements

## How It Works

### During Save (`/reheat:save`)

The save command spawns 4 parallel agents:
1. **Agent 1** - Builds RESUME.md (primary document)
2. **Agent 2** - Analyzes failures → failures.log
3. **Agent 3** - Tracks decisions → decisions.log
4. **Agent 4** - Extracts insights → learnings.log

All agents run simultaneously in fresh context for speed and quality.

### During Resume (`/reheat:resume`)

**Lazy loading strategy:**
1. Resume agent reads RESUME.md first (always)
2. Diagnostic logs are loaded only when needed:
   - Check **failures.log** before trying new approaches
   - Check **decisions.log** when questioning design choices
   - Check **learnings.log** for deep system insights

This saves time and tokens during resume while keeping rich context available.

## File Descriptions

### failures.log

**What:** Detailed forensic analysis of every failed approach

**Contains:**
- Exact error messages and stack traces
- Root causes (not just symptoms)
- Mental model corrections (expected vs reality)
- Why retry would fail
- Alternative approaches

**When to read:**
- Before attempting a new technical approach
- When debugging similar issues
- When you encounter repeated failures

**Example entry:**
```
## Failure #1: Global JWT Middleware

**What I Tried:**
app.use(jwtMiddleware);  // Apply to all routes

**Error:**
TokenExpiredError: jwt expired at verify.js:147

**Root Cause:**
Middleware runs on EVERY request including auth routes.
Auth routes need to work BEFORE tokens exist.
Circular dependency: refresh endpoint needs valid token to refresh token.

**Mental Model Correction:**
Expected: Protect everything by default, whitelist auth routes
Reality: Allow everything by default, protect specific routes as needed

**Alternative:**
Route-specific middleware: router.get('/protected', authMiddleware, handler)
```

### decisions.log

**What:** Architectural Decision Records (ADRs) with full rationale

**Contains:**
- Options considered for each decision
- Why specific choices were made
- Trade-offs accepted and how they're mitigated
- Rejected alternatives with specific reasons
- Consequences and constraints

**When to read:**
- When questioning why something was built a certain way
- Before suggesting alternative approaches
- When considering refactoring
- To understand trade-offs and constraints

**Example entry:**
```
## Decision #1: JWT Tokens vs Server Sessions

**Status:** Active

**Context:**
Need authentication for REST API consumed by mobile apps and web clients

**Options Considered:**
A. Server-side sessions with Redis
B. JWT tokens (stateless) ✅ CHOSEN
C. Database-backed sessions

**Why Chosen:**
- Stateless: easier to scale horizontally
- Works naturally with mobile clients
- No Redis dependency to manage
- Industry standard for API authentication

**Trade-offs Accepted:**
- Giving up: Ability to invalidate tokens before expiry
- Gaining: Stateless scaling, no session store
- Mitigation: Short 15min expiry + refresh tokens

**Consequences:**
✅ Enables: Horizontal scaling without session affinity
⚠️ Constrains: All clients must implement refresh logic
🔒 Commits to: Token-based authentication flow
```

### learnings.log

**What:** Deep insights and patterns discovered during development

**Contains:**
- Non-obvious system behaviors
- Mental model refinements
- Patterns that aren't documented elsewhere
- Tribal knowledge worth preserving
- Hard-won understanding

**When to read:**
- When you need deep understanding of how system works
- After encountering confusing behavior
- To understand system characteristics and tendencies
- For advanced techniques and power user tips

**Example entry:**
```
## Learning #1: JWT Verification Blocks Event Loop

**Discovery Date:** 2026-01-01

**The Insight:**
jwt.verify() is synchronous and blocks Node.js event loop.
For high-traffic APIs (>1000 req/s), this creates latency spikes.

**Why This Matters:**
Initial implementation used jwt.verify() on every protected request.
At scale, this would cause p99 latency issues.

**Practical Implications:**
- OK for current load (<100 req/s)
- Need async verification before scaling to 1000+ req/s
- Consider moving to jsonwebtoken's async verify() or worker threads
- Or: Cache decoded tokens in memory for short duration

**How We Discovered:**
Performance testing revealed event loop lag under load.
Profiling showed jwt.verify() consuming significant CPU time.
```

## Cross-References

The logs are interconnected:

**Failures → Decisions:**
Failed approaches often lead to architectural decisions.
Example: Global middleware failure → Decision to use route-specific middleware

**Failures → Learnings:**
Failures reveal insights about system behavior.
Example: Token expiry error → Learning about JWT verification lifecycle

**Learnings → Decisions:**
Insights inform future decisions.
Example: Learning about event loop blocking → Decision on scaling strategy

## File Lifecycle

### Creation
- Generated automatically by `/reheat:save`
- Each log is created independently by specialized agent
- Logs are appended to on subsequent saves (not overwritten)

### Archiving
- When creating new handoff, entire `.context/` directory is archived
- Archived to `resume-archive/.context-YYYYMMDD-HHMM/`
- Fresh `.context/` directory is created for new session

### Version Control
- `.context/` is **git-ignored** by default (like RESUME.md)
- These are ephemeral session state, not project documentation
- If insights are valuable long-term, extract them to project docs

## Best Practices

### For Creating Handoffs

**Be forensically detailed in failures:**
- Include EXACT error messages (copy/paste)
- Document root causes, not symptoms
- Explain mental model corrections
- Show why retry would fail

**Document decision rationale fully:**
- List all options considered
- Explain why chosen option is best
- Be explicit about trade-offs
- Note what alternatives were rejected and why

**Focus on non-obvious insights:**
- Don't document obvious facts
- Capture knowledge that took time to build
- Explain implications, not just facts
- Connect insights to practical consequences

### For Resuming Work

**Read strategically:**
1. Always read RESUME.md first (comprehensive overview)
2. Check failures.log before trying new approaches
3. Consult decisions.log when questioning design
4. Review learnings.log for deep insights when needed

**Don't read everything upfront:**
- Lazy loading saves time and cognitive load
- Load diagnostic logs on-demand
- Trust references in RESUME.md to guide you

## Comparison with RESUME.md

| Aspect | RESUME.md | .context/ logs |
|--------|-----------|----------------|
| **Purpose** | Primary handoff | Detailed diagnostics |
| **Audience** | Any resuming agent | Deep context when needed |
| **Size** | Concise (10-20 KB) | Comprehensive (30-100 KB) |
| **Read timing** | Always read first | Lazy load as needed |
| **Content** | Current state, next steps, high-level mental model | Forensic failures, detailed decisions, deep insights |
| **Structure** | Fixed 9 sections | Chronological logs |
| **Updates** | Replaced on each save | Appended to over time |

## Example Workflow

### Creating Handoff

```bash
# You've been working on auth implementation
# Multiple approaches failed, key decisions made
# Ready to end session

$ /reheat:save

# Plugin spawns 4 parallel agents:
# - Agent 1: Building RESUME.md...
# - Agent 2: Analyzing failures...
# - Agent 3: Documenting decisions...
# - Agent 4: Extracting insights...

✅ Created comprehensive handoff documentation

Primary Document:
- RESUME.md (9 sections, 15 KB)

Diagnostic Logs:
- .context/failures.log (3 failures analyzed)
- .context/decisions.log (5 decisions documented)
- .context/learnings.log (7 insights captured)
```

### Resuming Work

```bash
# New session, continuing work

$ /reheat:resume

# Agent reads RESUME.md (fast)
# Understands: 60% complete, next step is implement refresh endpoint

# Later during work:
# "Should I use global middleware?"
# → Checks failures.log: "No - global middleware failed due to circular dependency"

# "Why JWT instead of sessions?"
# → Checks decisions.log: "JWT chosen for stateless scaling with mobile clients"

# "How does token verification work under load?"
# → Checks learnings.log: "JWT verify() is synchronous, blocks event loop at >1000 req/s"
```

## Technical Notes

### File Format

All logs use markdown with:
- Clear headings (##)
- Structured sections
- Code blocks for examples
- Inline file references with line numbers

### Log Appending

On subsequent `/reheat:save` calls:
- RESUME.md is replaced (represents current state)
- .context/ logs are appended (accumulate history)
- This allows tracking evolution over multiple sessions

### Archive Format

When archived:
```
resume-archive/
├── RESUME-20260101-0900.md
├── RESUME-20260101-1500.md
├── .context-20260101-0900/
│   ├── failures.log
│   ├── decisions.log
│   └── learnings.log
└── .context-20260101-1500/
    ├── failures.log
    ├── decisions.log
    └── learnings.log
```

## Philosophy

> **Failed approaches are discoveries, not failures.**

The most valuable documentation isn't what worked—it's what **didn't work and why**.

These logs preserve that hard-won knowledge:
- **failures.log** prevents repeating mistakes
- **decisions.log** prevents undoing reasoned choices
- **learnings.log** preserves hard-won understanding

Together with RESUME.md, they enable seamless handoff to any AI agent or developer, even weeks or months later.

---

*This directory is managed automatically by the Reheat plugin.*
