# RESUME.md

## 1. WHAT WE'RE DOING

Building a handoff documentation plugin for Claude Code that captures context (failed approaches, decisions, mental models) to enable seamless AI agent collaboration across coding sessions. The plugin creates structured RESUME.md files plus diagnostic logs (.context/) for continued work without losing context.

## 2. PROGRESS

- ✅ Core plugin structure with 3 skills (save, save-quick, resume)
- ✅ Multi-agent architecture for comprehensive handoffs
- ✅ Plugin manifest and metadata configuration
- ✅ Documentation (README, QUICKSTART, CLAUDE.md)
- ✅ Plugin naming finalized ("reheat" instead of "reheating")
- ✅ Hook reference implementation (auto-handoff.ts)
- 🔄 Plugin marketplace integration and publishing
- ⏳ Testing with real projects of varying complexity
- ⏳ CI/CD pipeline for distribution

## 3. CURRENT STATE

**Working:**
- Three skills fully functional: /reheat:save (comprehensive), /reheat:save-quick (minimal), /reheat:resume (adaptive)
- RESUME.md generation with 9 primary sections
- Diagnostic logs (.context/): failures.log, decisions.log, learnings.log
- Auto-archiving of previous handoffs to resume-archive/
- Multi-agent parallel execution for comprehensive saves
- Adaptive resume that analyzes handoff depth

**Broken/Not Implemented:**
- SessionStart hook doesn't trigger (Claude Code hook system in transition - documented as reference implementation only)
- Plugin marketplace publishing not yet available
- Limited real-world testing on diverse project types

## 4. NEXT ACTION

Complete documentation updates after recent refactoring commits to ensure all references are consistent across the codebase.

**Steps:**
1. Verify README.md still references "HANDOFF.md" instead of "RESUME.md" (lines 36, 149)
2. Update README.md lines 36, 149 to reference RESUME.md instead of HANDOFF.md
3. Search for any remaining references to old naming (reheating, create, HANDOFF) in examples/ directory
4. Update QUICKSTART.md if any outdated references exist
5. Verify .gitignore patterns match current file names (RESUME.md vs HANDOFF.md, RESUME-*.md vs HANDOFF-*.md)

**Expected:** 15-20 minutes

## 5. KEY FILES

- README.md:36,149 - Documentation references old "HANDOFF.md" filename that should be "RESUME.md"
- .claude-plugin/plugin.json - Plugin manifest with skills path configuration
- skills/save/SKILL.md - Comprehensive save operation (multi-agent orchestration)
- skills/save-quick/SKILL.md - Quick save operation (streamlined handoff)
- skills/resume/SKILL.md - Adaptive resume (analyzes and spawns appropriate subagent)
- .gitignore - Ignore patterns for generated RESUME.md and .context/ files (needs verification)

## 6. NOTES

**Failed approaches:**
- ❌ SessionStart hook automation - Hook system in transition; agent hooks don't trigger in current Claude Code version (use manual `/reheat:resume` instead)
- ❌ Hook command references misaligned - Stale references to `/reheat:create` instead of `/reheat:save` after refactoring (systematic grep needed during renames)

**Decisions:**
- Using `reheat` plugin name with `save/save-quick/resume` commands (matches save/resume mental model, better UX than "create")
- RESUME.md as primary handoff file, `.context/` for diagnostic logs (lazy loading strategy: quick resumes read only RESUME.md)
- Automatic archiving with timestamps (resume-archive/RESUME-YYYYMMDD-HHMM.md) preserves all previous handoffs
- Fresh context for all major operations via subagent spawn (prevents conversation pollution, enables true parallelization)

**Gotchas:**
- `.gitignore` must ignore RESUME.md and `.context/*.log` (ephemeral session state, not permanent docs); commit only `.context/README.md`
- Renaming affects multiple layers: skill directories, plugin.json, marketplace.json, documentation, hooks (use systematic grep to catch all references)
- Plugin marketplace expects directory path, not file path (`claude plugin marketplace add /path/to/project`, not `/path/to/marketplace.json`)
- JSONL conversation history stored in `~/.claude/projects/` allows parallel agents to access session context without parent conversation access

---

*Quick handoff created by /reheat:save-quick*
*For comprehensive documentation with failure analysis, use /reheat:save*
