# Reheat Plugin for Claude Code

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/chadthornton/reheat)

Create handoff documents that let **any AI coding agent** continue your work across sessions. No more lost context or repeated mistakes.

## The Problem

AI coding sessions have limited context windows. When you switch tools, hit token limits, or just need to continue work later, you lose all the context about:
- What approaches failed and why
- Key decisions and their rationale
- Current state and next steps
- Specific errors and how to reproduce them

## The Solution

The Reheat plugin creates structured handoff documents (`RESUME.md`) that capture everything needed for seamless continuation. Think of it like reheating leftover food—you're warming up the context so it's ready to serve again.

## Features

### Three Commands

- **`/reheat:save`** - Generate comprehensive handoff documentation with full context
- **`/reheat:save-quick`** - Create minimal handoff for straightforward tasks
- **`/reheat:resume`** - Resume work from existing handoff (automatically adapts to handoff depth)

| Command | Use When | Time | Output |
|---------|----------|------|--------|
| `/reheat:save` | Complex work, multiple attempts | ~1-2 min | RESUME.md + diagnostic logs in `.context/` |
| `/reheat:save-quick` | Simple tasks, linear progress | ~30 sec | RESUME.md only |
| `/reheat:resume` | Starting new session | Auto-adapts | Intelligently continues work |

### What Gets Captured

✅ **Failed approaches** with specific error messages (so they're not retried)
✅ **Key decisions** and their rationale (so they're respected)
✅ **Current state** - what's working, what's broken, what's next
✅ **Code locations** - specific files, functions, and line numbers
✅ **Reproduction steps** - exact commands and expected vs actual results
✅ **Technical context** - setup, dependencies, environment variables

### Agent-Agnostic Format

The `RESUME.md` format works with any AI coding assistant:
- Claude (any version)
- ChatGPT
- Cursor
- Copilot
- Or any other AI tool

Just share the handoff file and the new agent can pick up right where you left off.

## Installation

### Recommended: Symlink Install

This makes the plugin available permanently in all Claude Code sessions:

```bash
# Clone or download to your preferred location
cd ~/Downloads/claude-reheat  # or wherever you cloned it

# Install via symlink
mkdir -p ~/.claude/skills
ln -s $(pwd) ~/.claude/skills/reheat
```

### Alternative: Test Mode (Development Only)

Use this only when testing changes to the plugin itself:

```bash
cd /path/to/claude-reheat
claude code --plugin-dir .
```

### From GitHub (Coming Soon)

Once published to the marketplace:

```bash
/plugin marketplace add yourusername/claude-reheat
/plugin install reheat
```

### Optional Performance Tools

The plugin works out-of-the-box with standard Unix tools, but you can optionally install performance-enhancing tools for faster operation on large conversations:

**ripgrep (`rg`)** - 2-5x faster than grep for large JSONL files
```bash
# macOS
brew install ripgrep

# Linux
apt-get install ripgrep
```

The helper script auto-detects `rg` and uses it automatically if available. No configuration needed.

**Performance impact:**
- Typical sessions (200-500 messages): Minimal benefit (< 5 seconds saved)
- Long sessions (1000+ messages): Noticeable benefit (10-15 seconds saved)

## Usage

### Creating a Handoff

When you're ready to end a session or want to document progress:

**For complex work with multiple attempts:**
```
/reheat:save
```

**For straightforward tasks:**
```
/reheat:save-quick
```

Claude will analyze the current state, review what's been done, and create a detailed `RESUME.md` file plus diagnostic logs in `.context/`.

### Resuming from a Handoff

In a new session, use:

```
/reheat:resume
```

Claude will:
1. Analyze the handoff to determine if it's a quick or comprehensive handoff
2. Read and understand the handoff document with appropriate depth
3. Confirm understanding with you
4. Avoid repeating documented failures
5. Continue with the documented next steps

The resume command automatically adapts based on:
- Handoff file size and complexity
- How recently it was created
- Number of sections and depth of content

You can also just tell any AI agent: "Read RESUME.md and continue the work" and it will understand the context.

## Best Practices

### When Creating Handoffs

**Be brutally honest about failures:**
```
❌ Vague: "Auth isn't working"
✅ Specific: "POST /api/login returns 401. Error: 'TokenExpiredError at verify.js:147'.
Tried: JWT middleware at app level. Failed because: Token expiration check happens after
verification. Learned: Need refresh token flow first."
```

**Show actual code, don't describe it:**
```
❌ "Created a validation function"
✅ "Created async function validateEmail(email: string): Promise<boolean>
in utils/validation.ts:23 that checks format with /^[^@]+@[^@]+$/"
```

**Provide testable steps:**
```
❌ "Try to log in and see if it works"
✅ "1. Run: curl -X POST http://localhost:3000/api/login -d '{\"email\":\"test@test.com\"}'
2. Expected: 200 with {\"token\":\"...\"}
3. Actual: 500 with {\"error\":\"Database connection failed at db.ts:45\"}"
```

### When Resuming

**Actually read and use the handoff** - don't just skim it. The documented failures save you hours of repeating mistakes.

**Confirm understanding** before starting work. Make sure you and the AI are aligned on what's been done and what's next.

**Update the handoff** as you make progress so it stays current for the next session.

## Example Handoff Structure

Here's what a comprehensive handoff looks like:

```markdown
# RESUME.md

## OBJECTIVE
Implement JWT-based authentication with token refresh for user API

## CURRENT STATUS
- ✅ 60% complete
- ✅ Login endpoint working
- ✅ Token generation implemented
- 🔄 Refresh token flow in progress
- ⏳ Middleware integration not started

## RECENT CHANGES
- Added POST /api/login endpoint in routes/auth.ts:12-45
- Created generateToken() in services/jwt.ts:8
- Updated User model with refreshToken field in models/User.ts:15

## WHAT FAILED
❌ Tried: App-level JWT middleware
Error: "TokenExpiredError: jwt expired at verify (node_modules/jsonwebtoken/verify.js:147)"
Why: Middleware runs before token refresh logic can handle expiration
Learned: Need to implement refresh endpoint first, then add middleware

## KEY DECISIONS
- Using JWT instead of sessions (stateless, scales better)
- Access tokens expire in 15min, refresh tokens in 7 days
- Storing refresh tokens in database (allows invalidation)

## CURRENT ISSUES
- Token refresh endpoint not implemented yet
- No test coverage for auth flows

## NEXT STEPS
1. Create POST /api/refresh endpoint to exchange refresh token for new access token
2. Add token validation middleware after refresh is working
3. Write integration tests for login + refresh flow

## KEY FILES
- routes/auth.ts - Login endpoint
- services/jwt.ts - Token generation/verification
- models/User.ts - User model with refresh token field
- middleware/auth.ts - Auth middleware (not working yet)

[... more sections ...]
```

## Tips

### When to Use Create vs Quick

**Use `/reheat:save`** when:
- Multiple approaches have been tried
- Complex decisions were made
- Many files are involved
- You want maximum context preserved

**Use `/reheat:save-quick`** when:
- Task is straightforward
- Limited experimentation
- Progress is linear
- Time-sensitive

### Updating Handoffs

As work progresses, update the handoff with:
- New completed tasks
- Additional failed approaches
- Updated next steps
- New issues or blockers

You can run `/reheat:save` or `/reheat:save-quick` again to refresh the handoff at any time. The previous handoff will be automatically archived with a timestamp.

### Sharing Handoffs

The handoff file is plain markdown and agent-agnostic. You can:
- Commit it to git
- Share it with team members
- Use it across different AI tools
- Include it in project documentation

## Philosophy

**Failed approaches are not failures—they're valuable documentation.**

The most important part of a handoff isn't what worked, it's what *didn't* work and why. This knowledge prevents the next agent (or you in a future session) from wasting time repeating the same mistakes.

By documenting specific errors, reproduction steps, and lessons learned, we create a continuous learning process across sessions and tools.

## Examples

### Example 1: Mid-Feature Development

You're halfway through implementing a feature but need to switch contexts:

```
You: /reheat:save
Claude: [Analyzes current state, creates comprehensive handoff]
Claude: ✅ Created comprehensive handoff at RESUME.md
```

Later, in a new session:

```
You: /reheat:resume
Claude: I've reviewed the handoff document. Here's what I understand:

Objective: Implement user authentication with JWT
Status: 60% complete - login working, refresh token flow in progress
Current issue: App-level middleware caused token expiration errors
Next action: Implement POST /api/refresh endpoint first

I note that app-level JWT middleware failed due to token expiration
happening before the middleware could handle it. I'll implement the
refresh endpoint first, then add middleware after.

Does this match your understanding?
```

### Example 2: Bug Investigation

You've been debugging but need to stop:

```
You: /reheat:save-quick
Claude: ✅ Created quick handoff at RESUME.md

Essential context captured:
- Investigating 500 error on checkout endpoint
- Error: "Cannot read property 'id' of undefined at checkout.ts:67"
- Found issue in cart validation logic
- Next: Fix cart.items check before accessing properties
```

Later, you or another developer can pick it up immediately with full context.

## Contributing

Contributions welcome! To improve the plugin:

1. Fork the repository
2. Make your changes to the skill prompts or plugin structure
3. Test with real handoff scenarios
4. Submit a pull request

## License

MIT - See LICENSE file for details

## Credits

Inspired by the original `claude-handoff` plugin by Will Seltzer. This is a modern reimplementation designed to work with current Claude Code versions.

---

**Happy Reheating! 🔥**
