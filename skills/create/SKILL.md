---
name: create
description: Create comprehensive handoff documentation with full context, mental models, and failure analysis
model: sonnet
---

# Create Comprehensive Handoff Documentation

**EXECUTION STRATEGY: This task requires focused analysis in a clean context window for best results.**

## Step 1: Spawn Focused Subagent

Use the Task tool to execute this handoff creation in a fresh context:

```
Use Task tool with these parameters:

subagent_type: "general-purpose"
description: "Create comprehensive handoff in fresh context"
model: "sonnet"
prompt: "You are creating a comprehensive handoff document that enables any AI coding agent to seamlessly continue work from where you left off.

## Why This Matters

Research shows that context switching can consume up to 20% of cognitive capacity, and poor knowledge transfer costs organizations $2.1M annually. This handoff preserves both explicit knowledge (facts, locations) and tacit knowledge (reasoning, mental models) to enable immediate productivity in the next session.

## Your Task

Create a detailed HANDOFF.md file in the project root that documents the current state, progress, and complete cognitive context of the work.

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
```

## Document Structure

### 1. OBJECTIVE & CONTEXT

**What we're building:**
- Main goal or feature being worked on
- Why this work matters (business value, user impact)
- What problem it solves

**Domain context:**
- Key domain concepts a newcomer needs to understand
- Critical business rules or constraints
- User workflows or use cases this touches

**Success criteria:**
- How will we know this is done?
- What does "working" look like?
- Any acceptance criteria or requirements

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

---

### 4. WHAT FAILED (Critical for Learning)

> **This is the most valuable section.** Failed approaches save hours of future work.

For each failed attempt, document:

**❌ Attempt [N]: [Brief description]**

**What I tried:**
```
[Actual code or approach attempted]
```

**Error encountered:**
```
[Exact error message - copy/paste, don't paraphrase]
```

**Why it failed:**
- Root cause (not just symptoms)
- What assumption was wrong?
- What did I misunderstand?

**What I learned:**
- Key insight from this failure
- What I'd do differently now
- What this reveals about the system

**Why retry would fail:**
- What would need to be different?
- Is there a better approach?

Example:
```
❌ Attempt 1: App-level JWT middleware

What I tried:
app.use(jwtMiddleware);  // Apply globally to all routes

Error:
TokenExpiredError: jwt expired
    at JsonWebTokenError.verify (node_modules/jsonwebtoken/verify.js:147:19)
    at middleware/auth.ts:23:28

Why it failed:
- Middleware runs on EVERY request, including auth routes
- Auth routes need to work BEFORE tokens exist
- Token refresh endpoint couldn't run because it needed a valid token to refresh a token (circular dependency)

What I learned:
- Middleware needs to exclude certain routes, OR
- Auth routes should be defined before middleware, OR
- Better: Only protect specific routes that need auth

Mental model correction:
My mental model was "protect everything by default, allow some routes"
Reality: "Allow everything by default, protect specific routes that need it"

Why retry would fail:
Simply moving middleware order won't fix this. Need route-specific middleware instead:
router.get('/protected', authMiddleware, handler)
```

---

### 5. KEY DECISIONS (Architecture Decision Records)

> **Document WHY, not just what**

For each significant decision, use this format:

**Decision:** [What was decided]

**Context:** What situation prompted this decision?

**Options considered:**
1. Option A - [description]
2. Option B - [description]
3. Option C - [description]

**Chosen:** Option [X]

**Rationale:**
- Why this option over others?
- What factors were most important?
- What trade-offs are we accepting?

**Consequences:**
- Positive: What does this enable?
- Negative: What limitations does this create?
- Neutral: What does this commit us to?

**Rejected alternatives and why:**
- Option Y rejected because: [specific reason]
- Option Z rejected because: [specific reason]

Example:
```
Decision: Use JWT tokens instead of server-side sessions

Context: Need authentication for REST API consumed by mobile apps and web clients

Options considered:
1. Server-side sessions with Redis
2. JWT tokens (stateless)
3. Database-backed sessions

Chosen: JWT tokens

Rationale:
- Stateless: easier to scale horizontally
- Works naturally with mobile clients
- No Redis dependency to manage
- Industry standard for API authentication

Consequences:
- Positive: Can scale without session store, works across services
- Negative: Can't invalidate access tokens before expiry (solved with short 15min expiry + refresh tokens)
- Neutral: Commits us to token-based flow, all clients must handle refresh logic

Rejected alternatives:
- Server sessions: Would require sticky sessions or Redis, adds operational complexity
- DB sessions: Adds database load on every request, defeats purpose of stateless API
```

---

### 6. ROOT CAUSE ANALYSIS (Not Just Symptoms)

> **Critical:** Document ROOT CAUSES, not surface symptoms

**Active Issues:**

**Issue [N]: [Brief description]**

**Surface symptom:**
- What's the visible problem?

**Actual root cause:**
- What's really causing this?
- Use "5 Whys" if needed

**Reproduction steps (minimal):**
```
1. [Exact command or action]
2. [Expected behavior]
3. [Actual behavior]
4. [Error message or unexpected output]
```

**Why this breaks the mental model:**
- What expectation does this violate?
- What should happen vs. what does happen?

**Debugging already tried:**
- What did I check?
- What did I rule out?
- Where did the trail go cold?

Example:
```
Issue 1: POST /api/refresh returns 500

Surface symptom:
Endpoint crashes with 500 error

Actual root cause:
JWT verification throws when decoding but error isn't caught, crashing the handler before we can return proper error response

Reproduction:
1. curl -X POST http://localhost:3000/api/refresh -d '{"refreshToken":"invalid"}'
2. Expected: 401 {"error": "Invalid refresh token"}
3. Actual: 500 {"error": "Cannot read property 'id' of undefined"}
4. Stack trace points to auth.ts:67 where we access decoded.id

Why this breaks the mental model:
I assumed jwt.verify() would return null on invalid token
Reality: It throws an exception that needs try/catch

Debugging tried:
✓ Confirmed token is reaching the endpoint (logged req.body)
✓ Verified JWT_SECRET is set correctly
✓ Checked that jwt.verify is imported properly
✗ Haven't tried: wrapping in try/catch block
✗ Haven't tried: using jwt.decode() first to inspect token
```

---

### 7. HIDDEN DEPENDENCIES & ASSUMPTIONS

> **Make implicit knowledge explicit**

**Assumptions currently made:**
- [ ] [Assumption 1] - Verified? Yes/No
- [ ] [Assumption 2] - Verified? Yes/No

**Hidden dependencies:**
- What must be true for this to work?
- What external systems are involved?
- What timing or order dependencies exist?

**Undocumented constraints:**
- Performance limits?
- Data size limits?
- Concurrency assumptions?

**Tribal knowledge:**
- What would only someone familiar with this codebase know?
- What workarounds or quirks exist?
- What "obvious" things aren't documented?

Example:
```
Assumptions:
- [X] Database is PostgreSQL 12+ (Verified: using RETURNING clause)
- [ ] Email service is reliable (Not verified: no retry logic)
- [X] Users have unique emails (Verified: DB constraint exists)
- [ ] Tokens fit in HTTP header (Not verified: could exceed limits with claims)

Hidden dependencies:
- JWT_SECRET must be same across all instances (or tokens break)
- Database must be initialized with migrations before app starts
- Email service requires SMTP credentials in environment

Tribal knowledge:
- The "users" table was renamed from "accounts" in migration 003
- We're soft-deleting users (deleted_at column) not actually removing
- The API responses include snake_case for legacy client compatibility
```

---

### 8. NEXT STEPS (Prioritized & Concrete)

> **Actionable, specific, ordered by importance**

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

**Questions that need answering:**
1. [Question] - affects: [what decision]
2. [Question] - blocks: [what task]

**Blockers:**
- [ ] [Blocker description] - who can unblock?

Example:
```
Priority 1: Fix refresh token endpoint [CRITICAL]
- [ ] Wrap jwt.verify() in try/catch in routes/auth.ts:65
  - Why urgent: Crashing in production on invalid tokens
  - Unblocks: Can't test token refresh flow until this works
  - Complexity: Low (5 min fix)
  - Start at: routes/auth.ts:65

Priority 2: Implement auth middleware [IMPORTANT]
- [ ] Create middleware/auth.ts with verifyAccessToken() function
  - Depends on: Priority 1 (need working token verification)
  - Success: Can protect routes with authMiddleware
  - Complexity: Medium (1 hour)
  - Pattern: See middleware/cors.ts for structure

Priority 3: Add rate limiting [NICE TO HAVE]
- [ ] Install express-rate-limit and add to auth routes
  - Prevents: Brute force attacks
  - Complexity: Low (30 min)
  - Docs: https://npmjs.com/package/express-rate-limit

Questions:
1. Should tokens persist across password changes? - affects: token invalidation strategy
2. Do we need multi-device sessions? - affects: whether refresh tokens are per-device

Blockers:
None currently
```

---

### 9. TECHNICAL CONTEXT

#### Code Architecture

**Project structure:**
```
src/
├── routes/auth.ts          - Login, register, refresh endpoints
├── services/jwt.ts         - Token generation/verification
├── middleware/auth.ts      - Auth middleware (NOT IMPLEMENTED)
└── models/User.ts          - User model with Sequelize
```

**Key files and their roles:**

**[routes/auth.ts](routes/auth.ts)**
- What it does: Handles authentication endpoints
- Entry points: POST /register (line 8), POST /login (line 34), POST /refresh (line 60)
- Dependencies: services/jwt.ts, models/User.ts
- Status: Login works, refresh is broken

**[services/jwt.ts](services/jwt.ts)**
- What it does: JWT token operations
- Key functions:
  - `generateAccessToken(userId: string): string` (line 12)
  - `generateRefreshToken(userId: string): string` (line 20)
  - `verifyAccessToken(token: string): {id: string} | null` (line 28)
- Status: Generation works, verification needs try/catch

**Important functions with signatures:**
```typescript
// services/jwt.ts:12
function generateAccessToken(userId: string): string
// Creates 15min JWT with payload {id: userId}, signed with JWT_SECRET

// models/User.ts:45
async function User.findByEmail(email: string): Promise<User | null>
// Queries users table with WHERE email = $1

// models/User.ts:52
async function User.comparePassword(password: string): Promise<boolean>
// Uses bcrypt.compare() with stored hash
```

#### Data Models

**User Model:**
```typescript
{
  id: UUID (primary key)
  email: string (unique)
  password_hash: string
  refresh_token?: string  // Current refresh token
  created_at: timestamp
  updated_at: timestamp
}
```

**JWT Payload (Access Token):**
```typescript
{
  id: string,          // User ID
  iat: number,         // Issued at
  exp: number          // Expires (15 min from iat)
}
```

#### Environment & Setup

**Required environment variables:**
```bash
JWT_SECRET=your-secret-key              # For access tokens
JWT_REFRESH_SECRET=your-refresh-secret  # For refresh tokens (MUST BE DIFFERENT)
DATABASE_URL=postgresql://localhost/myapp
NODE_ENV=development
```

**Dependencies:**
- jsonwebtoken@^9.0.0 - JWT operations
- bcrypt@^5.1.0 - Password hashing
- express@^4.18.0 - Web framework
- sequelize@^6.35.0 - ORM

**Setup commands:**
```bash
npm install                    # Install dependencies
npm run migrate               # Run database migrations
npm run seed                  # Create test user
npm run dev                   # Start server on :3000
```

**Database state:**
```bash
# Applied migrations:
20260101_create_users_table.sql
20260101_add_refresh_token_to_users.sql

# Test data:
User: test@example.com / password123
```

#### Testing

**Current test coverage:**
- No automated tests exist yet

**How to test manually:**
```bash
# Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"new@example.com","password":"test123"}'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Refresh (currently broken)
curl -X POST http://localhost:3000/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refreshToken":"eyJ..."}'
```

**Tests that need writing:**
- [ ] POST /register success
- [ ] POST /register with duplicate email (should 400)
- [ ] POST /login with valid credentials
- [ ] POST /login with invalid credentials
- [ ] POST /refresh with valid token
- [ ] POST /refresh with expired token
- [ ] POST /refresh with invalid token

---

### 10. IMPORTANT NOTES & GOTCHAS

**Non-obvious behavior:**
- JWT_SECRET and JWT_REFRESH_SECRET MUST be different values
  - Security issue: if same, refresh token can be used as access token
  - Location: config/env.ts:12-13

- Password hashing uses bcrypt with 10 rounds
  - Don't change without re-hashing all passwords
  - Location: services/auth.ts:8

- Token expiry uses string format ("15m", "7d"), not milliseconds
  - Easy to get wrong: 900 (number) vs "15m" (string)
  - Library: jsonwebtoken

**Performance considerations:**
- JWT verification is synchronous (blocks event loop)
- For >1000 req/s, consider async version
- Current load: <100 req/s, so not a concern yet

**Security concerns:**
- ⚠️ Refresh tokens stored as plaintext in database
  - Should hash them like passwords
  - Risk: DB compromise leaks long-lived tokens
  - Mitigation: Short refresh expiry (7 days)

- ⚠️ No rate limiting on login endpoint
  - Vulnerable to brute force
  - Add express-rate-limit before production

- Error messages leak user existence
  - "Invalid password" vs "User not found"
  - Should both return "Invalid credentials"
  - Location: routes/auth.ts:42

**Technical debt:**
- Quick fix in auth.ts:38 - bypasses validation for admin user
  - Added for testing, should be removed
  - Comment says "FIXME: Remove before production"

- Migration 002 was hand-edited after running
  - Don't trust migration files as source of truth
  - Actual schema may differ slightly

---

### 11. COGNITIVE LOAD HELPERS

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
- [Domain knowledge that's not obvious]

Example:
```
If I could only tell you 3 things:
1. Refresh tokens are stored in DB for invalidation, access tokens are stateless
2. The jwt.verify() throws exceptions, doesn't return null - wrap everything in try/catch
3. Auth routes must be defined BEFORE applying auth middleware, or they'll block themselves

Common misconceptions:
- ❌ You might think: JWT middleware can be applied globally
- ✅ Reality: Would block auth routes from working, use route-specific middleware

- ❌ You might think: refresh() method replaces access token in place
- ✅ Reality: Returns NEW token, client must update their stored token

What takes longest to understand:
- The flow of how tokens are issued, refreshed, and validated
- Why tokens can't be invalidated before expiry (stateless nature)
- The circular dependency problem with protecting the refresh endpoint itself
```

---

### 12. REFERENCES & RESOURCES

**Documentation consulted:**
- [jsonwebtoken npm package](https://npmjs.com/package/jsonwebtoken)
- [JWT.io - Introduction to JWT](https://jwt.io/introduction)
- [OWASP JWT Cheat Sheet](https://cheatsheetseries.owasp.org/)

**Similar implementations:**
- [passport-jwt strategy](https://passportjs.org/packages/passport-jwt/) - Alternative approach
- [auth0/node-jsonwebtoken examples](https://github.com/auth0/node-jsonwebtoken/tree/master/examples)

**Relevant Stack Overflow:**
- [Should refresh tokens be stored in DB?](https://stackoverflow.com/questions/27726066/) - Consensus: Yes

**Related PRs/Issues:**
- [None yet - new project]

---

## Quality Guidelines

### Preserve Mental Models
Document HOW things work, not just WHAT exists:
- ❌ "Token validation middleware exists"
- ✅ "When a request comes in, middleware extracts Bearer token from Authorization header, verifies signature with JWT_SECRET, and attaches decoded user ID to req.user for downstream handlers"

### Distinguish Root Causes from Symptoms
- ❌ "Endpoint returns 500"
- ✅ "jwt.verify() throws exception on invalid token, and no try/catch exists, so exception bubbles up and Express default handler returns 500"

### Make Assumptions Explicit
- ❌ "Users have unique emails"
- ✅ "ASSUMPTION: Users have unique emails (verified by database UNIQUE constraint on users.email column)"

### Document Failed Approaches as Learning
- ❌ "Tried middleware, didn't work"
- ✅ "❌ Global middleware failed because auth routes need to run before tokens exist (circular dependency). LEARNED: Use route-specific middleware: router.get('/protected', authMiddleware, handler)"

### Show Evolution and Change
- ❌ "Using JWT for auth"
- ✅ "DECISION: Switched from server sessions to JWT on Jan 15 because of mobile clients. Trade-off: Can't invalidate tokens before expiry, mitigated with 15min expiry + refresh tokens."

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

3. **Extract tacit knowledge:**
   - What decisions did I make and why?
   - What did I learn from failures?
   - What would someone need to know to continue?

4. **Create the HANDOFF.md file:**
   - Write each section thoroughly
   - Be ruthlessly honest about what failed
   - Include specific details (error messages, line numbers)
   - Make implicit knowledge explicit

5. **Review for cognitive completeness:**
   - Can another agent understand the mental model?
   - Are root causes clear, not just symptoms?
   - Are assumptions stated explicitly?
   - Would this save the next agent from repeating my mistakes?

6. **Confirm with the user:**
   - Show where the handoff was saved
   - Summarize what was captured
   - Ask if critical context is missing

---

## Example Output Message

After creating the handoff, tell the user:

```
✅ Created comprehensive handoff documentation at HANDOFF.md

Key elements captured:
- Mental model: How the JWT auth flow works and why
- 3 failed approaches with root cause analysis
- 5 architectural decisions with trade-offs explained
- 4 explicit assumptions and their verification status
- 7 prioritized next steps with complexity estimates
- Hidden dependencies and tribal knowledge
- Complete cognitive context for resuming

The handoff documents:
- Not just what exists, but HOW it works
- Not just symptoms, but ROOT CAUSES
- Not just facts, but REASONING
- Not just successes, but LEARNINGS from failures

To resume: /reheating:resume or share HANDOFF.md with any AI agent
```

---

## Remember

This handoff is a **cognitive transfer document**, not just a status report.

**Goal:** Enable the next agent to have the same mental model you have now.

**Success criteria:**
- ✅ Next agent understands not just WHAT exists, but HOW it works
- ✅ Failed approaches are documented so they're not repeated
- ✅ Assumptions are explicit, not hidden
- ✅ Root causes are identified, not just symptoms
- ✅ Decisions include reasoning, not just outcomes
- ✅ Tribal knowledge is captured before it's lost
- ✅ Mental models are preserved, not reconstructed

**Key insight from research:**
> Context switching consumes 20% of cognitive capacity. Poor knowledge transfer costs $2.1M/year. Working memory holds only 4-5 items. This handoff must do the heavy lifting of preserving complete context so the next agent can be productive immediately, not spend hours rebuilding your mental model.

**Failed approaches are the most valuable documentation—they represent discoveries that save future time.**"
```

Execute the Task tool now with the prompt above.

---

## Step 2: Report Results to User

After the subagent completes the handoff creation, confirm with the user:

```
✅ Created comprehensive handoff documentation at HANDOFF.md

The handoff was created in a fresh context for maximum focus and quality.

Key elements captured:
- Mental model: How the system works and why
- Failed approaches with root cause analysis
- Architectural decisions with trade-offs explained
- Explicit assumptions and their verification status
- Prioritized next steps with complexity estimates
- Hidden dependencies and tribal knowledge
- Complete cognitive context for resuming

The handoff documents:
- Not just what exists, but HOW it works
- Not just symptoms, but ROOT CAUSES
- Not just facts, but REASONING
- Not just successes, but LEARNINGS from failures

To resume: Use /reheating:resume or share HANDOFF.md with any AI agent
```

Ask the user if they'd like to review the handoff or if there's any critical context they feel is missing.
