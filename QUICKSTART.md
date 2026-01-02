# Quick Start Guide

Get up and running with Reheating Instructions in 2 minutes.

## Installation

```bash
cd /path/to/claude-reheating-instructions
claude code --plugin install .
```

Or if you're already in the directory:
```bash
claude code --plugin install .
```

## Basic Usage

### 1. Create Your First Handoff

When you're in the middle of work and need to stop:

```
/reheating:create
```

Claude will analyze your project and create a `HANDOFF.md` file with:
- What you're working on
- What's been done
- What failed (with specific errors)
- What's next

### 2. Resume from a Handoff

In a new session:

```
/reheating:resume
```

Claude will:
- Read the handoff
- Confirm understanding
- Continue where you left off
- Avoid repeating documented failures

### 3. Quick Handoff (Optional)

For simple tasks, use the streamlined version:

```
/reheating:quick
```

## Example Workflow

**Session 1:**
```
You: I'm implementing JWT authentication but having issues with the middleware
Claude: [works on the problem, tries several approaches]
You: /reheating:create
Claude: ✅ Created comprehensive handoff at HANDOFF.md
```

**Session 2:**
```
You: /reheating:resume
Claude: I've reviewed the handoff. You're implementing JWT auth, and I see that
       app-level middleware failed due to token expiration. I'll implement the
       refresh endpoint first instead. Shall I proceed?
You: Yes
Claude: [continues work, avoiding the documented failures]
```

## What Makes a Good Handoff?

The quality of your handoff determines how well the next agent can continue. When creating handoffs, Claude will:

✅ **Include specific errors:**
- Not: "Auth isn't working"
- But: "POST /api/login returns 401 with error 'TokenExpiredError at verify.js:147'"

✅ **Document failures:**
- What was tried
- Why it failed
- What was learned

✅ **Provide code locations:**
- File paths
- Function names
- Line numbers

✅ **Show reproduction steps:**
- Exact commands
- Expected vs actual results

## Tips

1. **Create handoffs frequently** - Don't wait until the session ends
2. **Update handoffs as you go** - Run `/reheating:create` again to refresh
3. **Be honest about failures** - They're the most valuable documentation
4. **Use quick mode for simple tasks** - Save time when appropriate

## Troubleshooting

**"Plugin not found"**
- Make sure you're in the plugin directory when installing
- Try: `claude code --plugin install /full/path/to/claude-reheating-instructions`

**"Skill not working"**
- Check that all skill files exist in the `skills/` directory
- Verify [plugin.json](plugin.json) paths are correct

**"Handoff not detailed enough"**
- Use `/reheating:create` instead of `/reheating:quick`
- Provide more context in the conversation before creating the handoff

## Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Check out the [example handoff](examples/HANDOFF-EXAMPLE.md) to see what good output looks like
- See [CONTRIBUTING.md](CONTRIBUTING.md) if you want to improve the plugin

---

**You're ready to go! Try creating your first handoff.** 🔥
