# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains the "Reheat" plugin for Claude Code - a tool that creates structured handoff documents (RESUME.md) to preserve context across AI coding sessions. The plugin enables seamless continuation of work by capturing failed approaches, architectural decisions, mental models, and next steps.

## Core Architecture

### Plugin Structure

This is a Claude Code plugin with three main components:

1. **Skills** (`/skills/`) - Three user-invocable commands implemented as skill prompts:
   - `save` - Comprehensive handoff creation via parallel multi-agent system
   - `save-quick` - Minimal handoff for straightforward tasks
   - `resume` - Adaptive resume that analyzes handoff depth and spawns appropriate subagent

2. **Hooks** (`/hooks/`) - TypeScript hooks for automation (currently reference implementation):
   - `auto-handoff.ts` - Session lifecycle hooks (beforeExit, onSessionStart, etc.)

3. **Plugin Metadata** (`/.claude-plugin/`) - Configuration:
   - `plugin.json` - Plugin manifest with name, version, description, skills path

### Multi-Agent Architecture (save skill)

The comprehensive save operation uses a **parallel multi-agent system**:

```
Main Agent
    ↓ spawns 6 parallel background agents
    ├─→ Agent 1: RESUME sections 1-4  → RESUME.md (part 1)
    ├─→ Agent 2: RESUME sections 5-8  → RESUME.md (part 2)
    ├─→ Agent 3: RESUME sections 9-12 → RESUME.md (part 3)
    ├─→ Agent 4: Failure Analyzer     → .context/failures.log
    ├─→ Agent 5: Decision Tracker     → .context/decisions.log
    └─→ Agent 6: Insight Extractor    → .context/learnings.log
    ↓ waits for completion
    ↓ assembles RESUME.md from 3 parts
    ↓ cross-references and synthesizes
    └─→ Reports to user
```

**Key Design Principles:**
- Each agent works in fresh context to avoid conversation pollution
- Agents specialize in specific aspects (status, failures, decisions, insights)
- Main agent coordinates and identifies patterns across outputs
- Resume lazily loads .context/ files only when needed

### Document Format

**RESUME.md** - Primary handoff document with 9 active sections (plus 3 reserved for future):
1. OBJECTIVE & CONTEXT - What we're building and why
2. CURRENT STATUS - Progress with ✅ done, 🔄 in progress, ⏳ not started
3. MENTAL MODEL - How the system works (data flow, assumptions)
4. CURRENT ISSUES - Active bugs with reproduction steps
5. NEXT STEPS - Prioritized tasks with file:line references
6. TECHNICAL CONTEXT - Architecture, setup, key files
7. IMPORTANT NOTES & GOTCHAS - Non-obvious behavior
8. COGNITIVE LOAD HELPERS - 3 most critical things to understand
9. CROSS-REFERENCES - Links to .context/ diagnostic logs
10-12. RESERVED - Placeholder sections for future enhancements

**Diagnostic Logs** (`.context/`):
- `failures.log` - Chronological failed approaches with root cause analysis
- `decisions.log` - Architectural decisions with rationale and trade-offs
- `learnings.log` - Deep insights and mental model refinements

### Resume Strategy

The resume skill uses **adaptive handoff analysis**:

1. Reads RESUME.md to determine handoff type (file size, sections, age)
2. Spawns either:
   - **Quick Resume** (<10KB, <4h old, simple) - 5-minute speed read, immediate action
   - **Deep Resume** (>20KB, older, comprehensive) - 30-minute cognitive rebuild

Both resume modes spawn a fresh subagent to ensure proper context isolation.

## Development Commands

### Testing the Plugin

```bash
# Test plugin during development (temporary)
claude code --plugin-dir .

# Install via symlink (recommended for development)
mkdir -p ~/.claude/skills
ln -s $(pwd) ~/.claude/skills/reheat
```

### Using the Plugin

```bash
# In a Claude Code session:
/reheat:save           # Create comprehensive handoff
/reheat:save-quick     # Create minimal handoff
/reheat:resume         # Resume from existing handoff (auto-adapts)
```

### Archiving Behavior

All save commands automatically archive existing RESUME.md files:
```bash
# Creates resume-archive/ directory
# Moves old file to resume-archive/RESUME-YYYYMMDD-HHMM.md
```

## Key Files

- `.claude-plugin/plugin.json` - Plugin manifest, defines skills path
- `skills/save/SKILL.md` - Comprehensive save (multi-agent orchestration)
- `skills/save-quick/SKILL.md` - Quick save (single streamlined handoff)
- `skills/resume/SKILL.md` - Adaptive resume (analyzes and spawns appropriate subagent)
- `hooks/auto-handoff.ts` - Reference implementation for session automation
- `README.md` - Primary user documentation
- `QUICKSTART.md` - 2-minute getting started guide

## Code Patterns

### Skill Implementation Pattern

Skills are markdown files with YAML frontmatter:
```yaml
---
name: skill-name
description: Brief description
model: sonnet
---
```

Skills should:
- Use Task tool to spawn subagents in fresh context
- Set `run_in_background: true` for parallel operations
- Archive existing handoffs before creating new ones
- Provide clear user feedback on completion

### Agent Spawn Pattern

```typescript
// Pattern used in skills
Task tool with parameters:
{
  subagent_type: "general-purpose",
  description: "3-5 word description",
  model: "sonnet",
  run_in_background: true,  // for parallel execution
  prompt: "Detailed instructions for subagent..."
}
```

### Fresh Context Rationale

All major operations (save, resume) spawn subagents in fresh context because:
1. Prevents conversation history pollution
2. Ensures focused cognitive state
3. Enables true parallel execution
4. Maintains clean separation of concerns

## Important Constraints

### What NOT to Do

1. **Don't duplicate functionality** - There are exactly 3 skills (save, save-quick, resume)
2. **Don't inline complex operations** - Use subagents for multi-step processes
3. **Don't skip archiving** - Always preserve previous handoffs
4. **Don't create documentation files** - Unless explicitly requested (this is a documentation tool, not a target for more docs)

### Critical Design Decisions

**Decision: Multi-agent parallel architecture for comprehensive save**
- Rationale: 4x faster than sequential, specialized agents produce better output
- Trade-off: More complex coordination, but worth it for quality/speed

**Decision: Adaptive resume based on handoff analysis**
- Rationale: Different handoffs need different cognitive investment
- Trade-off: More complex logic, but better UX (doesn't over/under-invest time)

**Decision: Fresh context for all operations**
- Rationale: Clean mental state produces better analysis
- Trade-off: Can't reference current conversation, but that's intentional

**Decision: Primary RESUME.md + diagnostic logs**
- Rationale: Quick resume reads just RESUME.md, deep resume can reference logs
- Trade-off: Multiple files, but enables lazy loading

## Plugin Installation Pattern

The plugin follows Claude Code's plugin system:

1. Plugin directory contains `.claude-plugin/plugin.json`
2. Skills directory is specified in plugin.json (`"skills": "./skills/"`)
3. Each skill is a subdirectory with `SKILL.md` file
4. Skill names match directory names (e.g., `skills/save/` → `/reheat:save`)

## Philosophy

From the README's philosophy section - critical to understand:

> **Failed approaches are not failures—they're valuable documentation.**
>
> The most important part of a handoff isn't what worked, it's what *didn't* work and why.

This informs the entire architecture:
- Failures get dedicated agent and log file
- Decisions are documented with rejected alternatives
- Mental models include "what I thought vs. what's real"
- Resume process emphasizes learning from documented failures

## When Working on This Plugin

### Adding/Modifying Skills

1. Skills are prompts in markdown files, not code
2. Test changes by running the skill in a real project
3. Focus on prompt clarity - subagents need explicit instructions
4. Consider token budget for comprehensive operations
5. Always spawn subagents for multi-step operations

### Understanding the Flow

**Save Flow:**
1. User runs `/reheat:save` or `/reheat:save-quick`
2. Main skill spawns subagent(s) in fresh context
3. Subagent(s) analyze project, create documentation
4. Archiving happens automatically before writing new files
5. Main agent reports results to user

**Resume Flow:**
1. User runs `/reheat:resume`
2. Main skill reads RESUME.md to analyze handoff type
3. Spawns appropriate subagent (quick or deep resume)
4. Subagent reads handoff in fresh context
5. Subagent confirms understanding with user
6. Subagent continues work

### Testing Considerations

- Test with real projects of varying complexity
- Verify archiving works correctly
- Ensure parallel agents complete successfully
- Check that resume properly adapts to handoff types
- Validate cross-references between documents

## Agent-Agnostic Format

The RESUME.md format is designed to work with any AI coding assistant (Claude, ChatGPT, Cursor, Copilot, etc.). Keep this in mind:

- Use standard markdown formatting
- No tool-specific references in handoff documents
- Clear, explicit documentation that any agent can understand
- File paths and commands should be universally understandable
