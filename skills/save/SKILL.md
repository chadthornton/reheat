---
name: save
description: Save comprehensive handoff documentation with parallel 6-agent architecture
model: sonnet
---

# Save Comprehensive Handoff Documentation

**EXECUTION STRATEGY: Parallel 6-agent architecture for 2x faster comprehensive context capture.**

## Overview

This skill spawns 6 specialized agents in parallel to create:
- **RESUME.md** - Primary handoff document (12 sections, created by 3 agents)
- **.context/failures.log** - Chronological failure analysis
- **.context/decisions.log** - Architectural decision records
- **.context/learnings.log** - Key insights and patterns

**Performance:** ~1-1.5 minutes (vs 2-3 minutes with 4-agent architecture)

**Architecture:**
```
Main Coordinator (Sonnet)
        ↓
    Spawn 6 parallel agents (all Haiku)
        ↓
    ┌───┬───┬───┬───┬───┬───┐
    │   │   │   │   │   │   │
    v   v   v   v   v   v   v
   A1  A2  A3  A4  A5  A6
   │   │   │   │   │   │
   │   │   │   │   │   │
RESUME RESUME RESUME failures decisions learnings
sec1-4 sec5-8 sec9-12 .log   .log      .log
```

---

## Step 1: Archive Existing Handoff

Before creating new handoff, archive the old one if it exists using Bash tool:

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

---

## Step 2: Setup Helper Script

Before spawning agents, set up the conversation extraction helper script:

```bash
# Create .context/ directory (prevents race condition with parallel agents)
mkdir -p .context

# Copy helper script from plugin to project
if [ -f ~/.claude/skills/reheat/scripts/extract-conversation.sh ]; then
  cp ~/.claude/skills/reheat/scripts/extract-conversation.sh .context/
  chmod +x .context/extract-conversation.sh
  echo "✅ Helper script ready at .context/extract-conversation.sh"
else
  echo "⚠️  Warning: Helper script not found at ~/.claude/skills/reheat/scripts/extract-conversation.sh"
  echo "    Agents may not be able to extract conversation context"
fi
```

**Why this step is critical:**
- Creates `.context/` directory synchronously before agents spawn (prevents race condition)
- Copies helper script so background agents can access it
- Agents will use this script to extract conversation context efficiently

---

## Step 3: Spawn 6 Parallel Agents

Use the Task tool to spawn all 6 agents **in a single message** with `run_in_background: true`.

### Agent 1: RESUME Builder (Sections 1-4)

````
Task tool parameters:

subagent_type: "general-purpose"
description: "Agent 1: RESUME sections 1-4"
model: "haiku"
run_in_background: true
prompt: "You are Agent 1 of 6 creating comprehensive handoff documentation. Write ONLY sections 1-4 of RESUME.md.

## Accessing Conversation History

Use the shared helper script to extract conversation context:

```bash
# Extract user's stated goals/objectives (for section 1)
bash .context/extract-conversation.sh user_goals

# Extract error messages from conversation (for section 3)
bash .context/extract-conversation.sh errors

# Extract next steps mentioned in conversation (for section 4)
bash .context/extract-conversation.sh next_steps
```

These commands return relevant excerpts from the conversation history to help you write accurate sections.

## Your Sections

### 1. OBJECTIVE & CONTEXT

**What we're building:**
- Main goal or feature
- Why this work matters
- What problem it solves

**Success criteria:**
- How will we know this is done?
- What does \"working\" look like?

Example:
```
## 1. OBJECTIVE & CONTEXT

**What we're building:**
Implementing JWT-based authentication for the Express API with token refresh flow to enable secure, stateless user sessions.

**Success criteria:**
- Users can log in and receive access + refresh tokens
- Protected endpoints reject requests without valid tokens
- Token refresh works before expiry
- Test coverage for auth flows
```

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

Example:
```
## 2. CURRENT STATUS

**Completed:** ✅
- POST /api/login endpoint at routes/auth.ts:12-45
- Token generation in services/jwt.ts:8-23
- User model with refreshToken field at models/User.ts:15

**In Progress:** 🔄
- Token refresh endpoint (80% done, fails with 500 error)
- Error at routes/auth.ts:67 when verifying refresh token

**Not Started:** ⏳
- Auth middleware for protected routes
- Integration tests for complete flow

**Overall progress:** 60% complete

**Confidence level:** Medium - Login works reliably, refresh needs debugging
```

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
## 3. MENTAL MODEL

**How it works (expected behavior):**
User logs in → JWT access token (15min) + refresh token (7d) generated →
Access token sent in Authorization header → Middleware validates on each request →
User ID attached to req.user for protected routes

**Data flow:**
1. POST /api/login: email/password → bcrypt verify → generate tokens → return to client
2. Client stores tokens (localStorage for access, httpOnly cookie for refresh)
3. Protected route: Extract Bearer token → jwt.verify() → attach user to request
4. Token expiring: POST /api/refresh with refresh token → verify against DB → issue new access token

**Key assumptions:**
- Access tokens are stateless (no DB lookup on each request for performance)
- Refresh tokens stored in DB to enable invalidation (logout, password change)
- JWT_SECRET and JWT_REFRESH_SECRET are different values
- Token expiry uses string format (\"15m\", \"7d\") not milliseconds

**Unverified:**
- What happens if user changes password mid-session?
- How do we handle refresh token rotation?
```

**Failed approaches:** See .context/failures.log for detailed analysis of what didn't work.

---

### 4. CURRENT ISSUES

List active bugs or blockers. For each issue, use extracted error messages from conversation:

**Issue [N]: [Brief description]**

**Symptom:**
- What's the visible problem?

**Root cause (if known):**
- What's really causing this?

**Reproduction steps:**
```
1. [Exact command or action]
2. [Expected behavior]
3. [Actual behavior with EXACT error message from conversation]
```

**Debugging status:**
- What's been checked?
- What's been ruled out?

Example:
```
## 4. CURRENT ISSUES

**Issue 1: Refresh token endpoint returns 500**

**Symptom:**
POST /api/refresh fails with Internal Server Error

**Root cause (if known):**
jwt.verify() is being called but decoded payload is undefined at routes/auth.ts:67

**Reproduction steps:**
```
1. curl -X POST http://localhost:3000/api/refresh -d '{\"refreshToken\":\"eyJ...\"}'
2. Expected: 200 with {\"accessToken\":\"...\"}
3. Actual: 500 with {\"error\":\"Cannot read property 'id' of undefined\"}
   Error location: routes/auth.ts:67
   Line: const user = await User.findById(decoded.id)
```

**Debugging status:**
- ✅ Checked: Token format is valid JWT
- ✅ Checked: JWT_REFRESH_SECRET is set
- ❌ Not checked: Whether jwt.verify() is in try/catch block
- ❌ Not checked: If decoded payload structure matches expectation
```

---

## Output Format

Return ONLY the markdown text for sections 1-4. No explanations, just the formatted sections:

```
## 1. OBJECTIVE & CONTEXT

[Content using conversation context from helper script]

## 2. CURRENT STATUS

[Content with ✅ 🔄 ⏳ emojis]

## 3. MENTAL MODEL

[Content describing how system works]

## 4. CURRENT ISSUES

[Content with ACTUAL error messages from conversation]
```

## Critical Rules

- Use helper script to extract user goals, errors, and next steps from conversation
- Be SPECIFIC: Include file paths, line numbers, ACTUAL error messages (not summaries)
- Document HOW things work, not just WHAT exists
- Reference .context/failures.log for failed approaches (don't duplicate here)
- Return ONLY your sections, no preamble"
````

### Agent 2: RESUME Builder (Sections 5-8)

````
Task tool parameters:

subagent_type: "general-purpose"
description: "Agent 2: RESUME sections 5-8"
model: "haiku"
run_in_background: true
prompt: "You are Agent 2 of 6 creating comprehensive handoff documentation. Write ONLY sections 5-8 of RESUME.md.

## Accessing Conversation History

Use the shared helper script to extract conversation context:

```bash
# Extract explicit next steps mentioned in conversation (for section 5)
bash .context/extract-conversation.sh next_steps

# Extract file importance discussions (for section 6)
bash .context/extract-conversation.sh key_files
```

These commands return relevant excerpts from the conversation to help identify what was discussed as next steps and which files were mentioned most frequently.

## Your Sections

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

Example:
```
## 5. NEXT STEPS (Prioritized & Concrete)

**Priority 1: [Critical/Blocking]**
- [ ] Fix refresh token endpoint error at routes/auth.ts:67
  - Why urgent: Blocks token refresh, users get logged out after 15min
  - What it unblocks: Full auth flow testing
  - Estimated complexity: Low (likely missing try/catch)
  - File/line to start: routes/auth.ts:67

**Priority 2: [Important]**
- [ ] Implement auth middleware for protected routes
  - Depends on: Priority 1 (need working refresh first)
  - Success criteria: Protected endpoints return 401 without valid token
  - File/line to start: middleware/auth.ts:1 (create new file)

**Priority 3: [Nice to have]**
- [ ] Add integration tests for complete login → refresh → protected route flow
  - File/line to start: tests/integration/auth.test.ts:1

**Blockers:**
None currently
```

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

Example:
```
## 6. TECHNICAL CONTEXT

#### Code Architecture

**Project structure:**
```
src/
├── routes/       - API endpoints (login, refresh, protected routes)
├── services/     - Business logic (JWT generation, validation)
├── models/       - Database models (User with refreshToken field)
└── middleware/   - Request processors (auth validation)
```

**Key files and their roles:**

**[routes/auth.ts](src/routes/auth.ts)**
- What it does: Auth API endpoints (login, refresh)
- Key functions:
  - login() at line 12 - validates credentials, generates tokens ✅
  - refresh() at line 67 - exchanges refresh for new access token ❌ (broken)
- Status: in-progress

**[services/jwt.ts](src/services/jwt.ts)**
- What it does: Token generation and verification
- Key functions:
  - generateToken(userId) at line 8 - creates access token ✅
  - generateRefreshToken(userId) at line 15 - creates refresh token ✅
  - verifyToken(token) at line 23 - validates token signature ✅
- Status: working

**[models/User.ts](src/models/User.ts)**
- What it does: User database model with auth fields
- Key fields: email, passwordHash, refreshToken (line 15)
- Status: working
```

#### Data Models

Document key data structures with their schemas.

Example:
```
#### Data Models

**User Model:**
```typescript
{
  id: string (UUID)
  email: string (unique)
  passwordHash: string (bcrypt)
  refreshToken?: string (nullable, stores current refresh token)
  createdAt: Date
  updatedAt: Date
}
```

**JWT Access Token Payload:**
```typescript
{
  userId: string
  email: string
  iat: number (issued at)
  exp: number (expires at: iat + 15min)
}
```

**JWT Refresh Token Payload:**
```typescript
{
  userId: string
  iat: number
  exp: number (expires at: iat + 7days)
}
```
```

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

Example:
```
#### Environment & Setup

**Required environment variables:**
```bash
JWT_SECRET=secret for signing access tokens (must be different from refresh secret)
JWT_REFRESH_SECRET=secret for signing refresh tokens
DATABASE_URL=postgres://localhost:5432/myapp
PORT=3000
```

**Setup commands:**
```bash
npm install
npm run migrate    # Apply database migrations
npm run seed       # Optional: Load test data
npm run dev        # Start dev server on port 3000
```

**Database state:**
- Applied migrations: 001_create_users, 002_add_refresh_token_field
- Test data: 3 test users with hashed passwords
```

#### Testing

**How to test manually:**
```bash
# Example commands
curl -X POST http://localhost:3000/api/endpoint
```

**Tests that need writing:**
- [ ] Test description
- [ ] Test description

Example:
```
#### Testing

**How to test manually:**
```bash
# Test login
curl -X POST http://localhost:3000/api/login \
  -H \"Content-Type: application/json\" \
  -d '{\"email\":\"test@test.com\",\"password\":\"password123\"}'

# Test refresh (use refreshToken from login response)
curl -X POST http://localhost:3000/api/refresh \
  -H \"Content-Type: application/json\" \
  -d '{\"refreshToken\":\"eyJ...\"}'

# Test protected route (use accessToken from login response)
curl http://localhost:3000/api/protected \
  -H \"Authorization: Bearer eyJ...\"
```

**Tests that need writing:**
- [ ] Integration test: complete login → refresh → protected route flow
- [ ] Unit test: jwt.verify() error handling
- [ ] Unit test: expired token rejection
```

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

Example:
```
## 7. IMPORTANT NOTES & GOTCHAS

**Non-obvious behavior:**
- jwt.verify() throws exception on invalid token (doesn't return null/false)
  - Location: services/jwt.ts:23
  - Why: jsonwebtoken library design - must wrap in try/catch

- Token expiry format is strings like \"15m\", \"7d\" not milliseconds
  - Location: services/jwt.ts:10
  - Why: jsonwebtoken library convention

**Performance considerations:**
- jwt.verify() is synchronous and blocks event loop
  - Mitigation: OK for <1000 req/s, use async verification for higher load

**Security concerns:**
- ⚠️ JWT_SECRET and JWT_REFRESH_SECRET must be different values (HIGH)
  - If same, compromised access token can be used as refresh token
  - Location: Check .env file

- ⚠️ Refresh tokens stored in plain text in DB (MEDIUM)
  - Consider hashing refresh tokens like passwords
  - Mitigation: Using secure connection, DB access controlled

**Technical debt:**
- No token rotation on refresh (same refresh token reused)
  - Location: routes/auth.ts:67
  - TODO: Implement refresh token rotation for better security
```

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

Example:
```
## 8. COGNITIVE LOAD HELPERS

**If I could only tell you 3 things:**
1. Token refresh is broken at routes/auth.ts:67 - this is the critical blocker preventing the auth flow from working
2. jwt.verify() throws exceptions on invalid tokens - must wrap in try/catch, not if/else checks
3. Access tokens are stateless (no DB lookup) but refresh tokens are stateful (stored in DB) - this is intentional for the security/performance trade-off

**Common misconceptions:**
- ❌ You might think: JWT middleware should be applied at app level to protect all routes
- ✅ Reality: App-level middleware creates circular dependency (auth routes need to run before tokens exist). Use route-specific middleware instead.

- ❌ You might think: jwt.verify() returns null/false on invalid token
- ✅ Reality: It throws TokenExpiredError or JsonWebTokenError - must try/catch

**What takes longest to understand:**
- The difference between access token flow (stateless, fast, short-lived) and refresh token flow (stateful, DB check, long-lived) and why both are needed
```

---

## Output Format

Return ONLY the markdown text for sections 5-8:

```
## 5. NEXT STEPS (Prioritized & Concrete)

[Content with prioritized tasks using conversation context]

## 6. TECHNICAL CONTEXT

[Content with architecture, files, setup, testing]

## 7. IMPORTANT NOTES & GOTCHAS

[Content with non-obvious behavior, gotchas]

## 8. COGNITIVE LOAD HELPERS

[Content with top 3 things, misconceptions]
```

## Critical Rules

- Use helper script to extract next steps and file importance from conversation
- Next steps must be ACTIONABLE: specific file, line number, what to do
- Key files must include LINE NUMBERS and status indicators (✅❌🔄)
- Gotchas should focus on non-obvious behavior that causes problems
- Cognitive load helpers should prioritize the hardest concepts to understand
- Return ONLY your sections, no preamble"
````

### Agent 3: RESUME Builder (Sections 9-12)

````
Task tool parameters:

subagent_type: "general-purpose"
description: "Agent 3: RESUME sections 9-12"
model: "haiku"
run_in_background: true
prompt: "You are Agent 3 of 6 creating comprehensive handoff documentation. Write ONLY sections 9-12 of RESUME.md (section 9 is just cross-references).

## Your Sections

### 9. CROSS-REFERENCES

Standard reference section pointing to diagnostic logs:

```
## 9. CROSS-REFERENCES

**For detailed context, see:**
- **.context/failures.log** - Chronological record of failed approaches with root causes
- **.context/decisions.log** - Architectural decisions with rationale and trade-offs
- **.context/learnings.log** - Key insights, patterns, and mental model refinements

**These logs are loaded lazily during resume - you don't need to read them unless:**
- You're about to try a new approach (check failures.log first)
- You're questioning a design choice (check decisions.log for rationale)
- You need deep insights on system behavior (check learnings.log)
```

---

### 10-12. PLACEHOLDER SECTIONS

These sections are reserved for future expansion. For now, include a note:

```
## 10-12. RESERVED

Reserved for future handoff enhancements. Current handoff captures all essential context in sections 1-9 plus diagnostic logs.
```

---

## Output Format

Return ONLY the markdown text for sections 9-12:

```
## 9. CROSS-REFERENCES

**For detailed context, see:**
- **.context/failures.log** - Chronological record of failed approaches with root causes
- **.context/decisions.log** - Architectural decisions with rationale and trade-offs
- **.context/learnings.log** - Key insights, patterns, and mental model refinements

**These logs are loaded lazily during resume - you don't need to read them unless:**
- You're about to try a new approach (check failures.log first)
- You're questioning a design choice (check decisions.log for rationale)
- You need deep insights on system behavior (check learnings.log)

## 10-12. RESERVED

Reserved for future handoff enhancements. Current handoff captures all essential context in sections 1-9 plus diagnostic logs.
```

## Critical Rules

- Section 9 is always the same cross-reference format
- Sections 10-12 are placeholders for now
- Return ONLY your sections, no preamble"
````

### Agent 4: Failure Analyzer

````
Task tool parameters:

subagent_type: "general-purpose"
description: "Agent 4: failures.log"
model: "haiku"
run_in_background: true
prompt: "You are Agent 4 of 6 in a parallel handoff creation system. Your job is to create .context/failures.log that documents every failed approach with deep root cause analysis.

## Accessing Conversation History

Use the shared helper script to extract conversation context:

```bash
# Extract failed approaches and error patterns (for failures analysis)
bash .context/extract-conversation.sh failures

# Extract error messages (for specific error details)
bash .context/extract-conversation.sh errors
```

These commands use optimized grep+jq patterns to quickly extract relevant conversation excerpts about what didn't work and why.

## Your Role

Analyze the conversation history (using helper script) and codebase to identify:
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
[EXACT error message from conversation - use helper script to extract]
[Include stack trace if relevant]
```

**Context:**
- File/Location: [path:line]
- Goal: [What was I trying to accomplish?]
- Assumption: [What did I think would happen?]

**Root Cause:**
[Not just \"it didn't work\" - WHY didn't it work?]
[Use 5 Whys if needed to get to fundamental issue]

Example:
- Surface: \"Middleware threw error\"
- One level down: \"JWT verification failed\"
- Root cause: \"jwt.verify() throws exceptions on invalid tokens instead of returning null, and no try/catch existed\"

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

[Repeat for each failure found in conversation using helper script...]

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

1. **Use helper script to extract failures from conversation:**
   ```bash
   bash .context/extract-conversation.sh failures
   bash .context/extract-conversation.sh errors
   ```

2. **For each failure found, reconstruct:**
   - What was the actual code/approach?
   - What was the exact error? (from helper script output)
   - What was the root cause?
   - What was learned?

3. **Analyze patterns:**
   - Do certain types of failures recur?
   - What system behaviors caused confusion?

4. **Create failures.log:**
   ```bash
   # Write failures.log content to .context/failures.log
   # (.context/ directory already exists from Step 2)
   ```

5. **Report completion:**
   - Count of failures documented
   - Key patterns identified

---

## Quality Guidelines

### Exact Error Messages
Use helper script to get ACTUAL errors from conversation:
❌ \"Got an auth error\"
✅ \"TokenExpiredError: jwt expired at verify (node_modules/jsonwebtoken/verify.js:147)\"

### Root Causes Not Symptoms
❌ \"Endpoint returned 500\"
✅ \"jwt.verify() throws on invalid token, no try/catch exists, exception bubbles up to Express default handler\"

### Mental Model Corrections
❌ \"Approach didn't work\"
✅ \"Expected: jwt.verify() returns null on invalid token. Reality: It throws exception requiring try/catch\"

---

Now execute: Create .context/failures.log with comprehensive failure analysis using helper script to extract conversation context."
````

### Agent 5: Decision Tracker

````
Task tool parameters:

subagent_type: "general-purpose"
description: "Agent 5: decisions.log"
model: "haiku"
run_in_background: true
prompt: "You are Agent 5 of 6 in a parallel handoff creation system. Your job is to create .context/decisions.log that documents architectural and technical decisions with full rationale.

## Accessing Conversation History

Use the shared helper script to extract conversation context:

```bash
# Extract architectural decisions from conversation (for decisions analysis)
bash .context/extract-conversation.sh decisions
```

This command uses optimized grep+jq patterns to quickly extract relevant conversation excerpts about what was decided and why.

## Your Role

Analyze the conversation (using helper script) and code to identify:
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

### Option B: [Name] ✅ CHOSEN
**Description:** [What this option involves]
**Pros:**
- [Advantage 1]
- [Advantage 2]

**Cons:**
- [Disadvantage 1 - how we're mitigating]
- [Disadvantage 2 - how we're mitigating]

**Why Chosen:**
[Specific rationale for this choice from conversation]
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

[Repeat for each decision found in conversation using helper script...]

---

## Decision Dependencies

Document how decisions relate:

**Decision Tree:**
```
Decision #1 (example)
    ↓ requires
Decision #2 (example)
    ↓ enables
Decision #3 (example)
```

**Conflicting Decisions:**
[Are there tensions between decisions?]
[How are conflicts being managed?]
```

---

## Execution Steps

1. **Use helper script to extract decisions from conversation:**
   ```bash
   bash .context/extract-conversation.sh decisions
   ```

2. **For each decision found, document:**
   - What options were considered (extract from conversation)
   - What factors influenced the choice
   - What trade-offs were accepted
   - What this enables/constrains

3. **Analyze relationships:**
   - Do decisions depend on each other?
   - Are there conflicts or tensions?

4. **Create decisions.log:**
   ```bash
   # Write decisions.log content to .context/decisions.log
   # (.context/ directory already exists from Step 2)
   ```

5. **Report completion:**
   - Count of decisions documented
   - Key dependencies noted

---

## Quality Guidelines

### Clear Decision Statements
Use conversation context from helper script:
❌ \"Using JWT\"
✅ \"Decision: Use JWT tokens instead of server-side sessions for API authentication\"

### Full Rationale
Include WHY from conversation, not just WHAT:
- What problem does this solve?
- Why this option over alternatives?
- What factors were most important?

### Explicit Trade-offs
❌ \"JWT is better\"
✅ \"JWT enables stateless scaling but can't be invalidated before expiry. Mitigating with 15min expiry + refresh tokens.\"

---

Now execute: Create .context/decisions.log with comprehensive decision documentation using helper script to extract conversation context."
````

### Agent 6: Insight Extractor

````
Task tool parameters:

subagent_type: "general-purpose"
description: "Agent 6: learnings.log"
model: "haiku"
run_in_background: true
prompt: "You are Agent 6 of 6 in a parallel handoff creation system. Your job is to create .context/learnings.log that extracts deep insights and patterns from the work.

## Accessing Conversation History

Use the shared helper script to extract conversation context:

```bash
# Extract gotchas and warnings (for learnings/insights)
bash .context/extract-conversation.sh gotchas

# Can also reference failures and decisions for insights
bash .context/extract-conversation.sh failures
bash .context/extract-conversation.sh decisions
```

These commands help identify non-obvious patterns and insights discussed in the conversation.

## Your Role

Analyze the conversation (using helper script) and work to identify:
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
[Clear statement of what was learned from conversation]

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
- [Connected to other learnings or decisions]

---

[More learnings from conversation using helper script...]

---

## Category: Mental Model Refinements

### Learning #N: [Model Evolution]

**Initial Mental Model:**
[What I thought was happening]

**Refined Mental Model:**
[What's actually happening - from conversation insights]

**What Changed My Understanding:**
[What evidence led to refinement?]

**Critical Distinction:**
[What's the key difference between models?]

---

## Category: Non-Obvious Patterns

### Learning #N: [Pattern Name]

**Pattern Observed:**
[Description of recurring pattern from conversation]

**Where This Appears:**
- [Location 1]
- [Location 2]

**Why This Pattern Exists:**
[Underlying reason for this pattern]

**How to Work With This Pattern:**
[Best practices for handling this]

---

## Meta-Patterns

### Cognitive Themes

**What Was Hardest to Understand:**
[Aspects that took longest to grasp from conversation]

**Most Valuable Insights:**
[Top 3 learnings that had biggest impact]

**Common Gotchas:**
[Repeated pitfalls from conversation using helper script]
```

---

## Execution Steps

1. **Use helper script to extract insights from conversation:**
   ```bash
   bash .context/extract-conversation.sh gotchas
   bash .context/extract-conversation.sh failures
   bash .context/extract-conversation.sh decisions
   ```

2. **Identify patterns from extracted content:**
   - What insights emerged?
   - What was surprising or non-obvious?
   - What took effort to understand?

3. **Extract mental model evolution:**
   - How did understanding change?
   - What corrections were made?

4. **Create learnings.log:**
   ```bash
   # Write learnings.log content to .context/learnings.log
   # (.context/ directory already exists from Step 2)
   ```

5. **Report completion:**
   - Count of learnings captured
   - Key patterns identified

---

## Quality Guidelines

### Focus on Non-Obvious
Don't document obvious facts from conversation:
❌ \"JWT is used for authentication\"
✅ \"JWT verification is synchronous and blocks event loop - OK for <1000 req/s, problematic above that\"

### Explain Implications
Connect insights to practice:
❌ \"Tokens expire after 15 minutes\"
✅ \"15min expiry means mobile apps must handle background refresh, or users get logged out mid-session\"

### Show Mental Model Evolution
Document how understanding changed from conversation:
\"Initial Model: X → Refined Model: Y → Key Distinction: Z\"

---

Now execute: Create .context/learnings.log with deep insights and patterns using helper script to extract conversation context."
````

---

## Step 4: Wait for All Agents & Assemble

After spawning all 6 agents in parallel, wait for their outputs using TaskOutput tool with error handling:

```
# Increased timeout to 300000ms (5 minutes) to handle large codebases
# Original 120000ms (2 minutes) was insufficient for comprehensive analysis

agent1_output = TaskOutput(agent1_task_id, block=true, timeout=300000)
agent2_output = TaskOutput(agent2_task_id, block=true, timeout=300000)
agent3_output = TaskOutput(agent3_task_id, block=true, timeout=300000)
agent4_output = TaskOutput(agent4_task_id, block=true, timeout=300000)
agent5_output = TaskOutput(agent5_task_id, block=true, timeout=300000)
agent6_output = TaskOutput(agent6_task_id, block=true, timeout=300000)
```

**Error Handling:**

If any agent fails or times out:
1. **Check the agent output** - Look for error messages or partial results
2. **Determine if partial results are usable** - Many agents can produce useful output even if they didn't complete fully
3. **Decide on action:**
   - If agent returned partial content: Use what exists, note incompleteness in final report
   - If agent completely failed: Generate fallback content with warning
   - If multiple agents failed: Consider aborting and suggesting /reheat:save-quick instead

**Fallback content for failed agents:**
- Agent 1 (RESUME 1-4): Create minimal sections with "⚠️ Limited context - agent failed"
- Agent 2 (RESUME 5-8): Create minimal sections with "⚠️ Limited context - agent failed"
- Agent 3 (RESUME 9-12): Use standard cross-reference template (always safe)
- Agent 4 (failures.log): Create empty log with note about extraction failure
- Agent 5 (decisions.log): Create empty log with note about extraction failure
- Agent 6 (learnings.log): Create empty log with note about extraction failure

**Report any failures to user in final summary.**

Then assemble RESUME.md from 3 parts using Write tool:

```markdown
# RESUME.md

{agent1_output content}

{agent2_output content}

{agent3_output content}

---

*Comprehensive handoff created by /reheat:save with 6-agent parallel architecture*
*For quick handoffs on straightforward tasks, use /reheat:save-quick*
```

Write the assembled file to RESUME.md in project root.

Note: Agents 4, 5, 6 create their own files (.context/failures.log, .context/decisions.log, .context/learnings.log) - no assembly needed.

---

## Step 5: Cross-Reference and Synthesize

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

## Step 6: Report Results to User

Provide comprehensive summary:

```
✅ Created comprehensive handoff documentation with 6-agent parallel analysis

**Primary Document:**
- RESUME.md (12 sections, X KB)

**Diagnostic Logs:**
- .context/failures.log (N failures analyzed)
- .context/decisions.log (M decisions documented)
- .context/learnings.log (K insights captured)

**Architecture:**
- 3 Haiku agents created RESUME.md sections in parallel
- 3 Haiku agents created diagnostic logs in parallel
- All agents used .context/extract-conversation.sh for context
- Total time: ~1-1.5 minutes (vs 2-3 minutes with old 4-agent architecture)

**Cross-Reference Patterns Detected:**
- [Pattern 1: e.g., "3 failures led to Decision #2 about token handling"]
- [Pattern 2: e.g., "Learning about async behavior influenced 2 architectural decisions"]
- [Pattern 3: e.g., "Authentication failures clustered around middleware lifecycle"]

**What Was Captured:**
- Current state and progress estimate
- Mental model of system data flow
- Failed approaches with root causes
- Architectural decisions with trade-offs
- Key insights about non-obvious behavior
- Prioritized next steps with file:line references

**To Resume:**
Use `/reheat:resume` - it will load RESUME.md first, then lazily reference .context/ logs as needed.

**To Share:**
Commit RESUME.md and .context/ to git, or share with any AI agent for seamless continuation.
```

---

## Remember

This 6-agent approach provides:
- **Parallel execution** - 2x faster than old 4-agent sequential RESUME creation
- **Specialized focus** - Each agent optimizes for their domain
- **Consistent architecture** - Matches save-quick's 3-agent RESUME pattern
- **Performance** - All agents use Haiku model for 3-5x faster inference
- **Helper script** - Optimized JSONL extraction with ripgrep auto-detection
- **Rich context** - Primary doc + 3 diagnostic logs
- **Pattern detection** - Coordinator spots connections across findings
- **Lazy loading** - Resume reads RESUME.md first, only loads .context/ logs when needed

The result is comprehensive handoff documentation that enables seamless continuation by any AI agent.
