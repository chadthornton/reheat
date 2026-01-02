# Quality Test Baselines

This directory contains baseline RESUME.md outputs for quality comparison testing.

## Test Files

### `baseline-manual-parallel-3agent.md`
**Created:** 2026-01-01
**Method:** Manual execution of parallel 3-agent architecture
**Agent Details:**
- Agent 1 (Haiku): Sections 1-3 (Context & Status) - NO JSONL access
- Agent 2 (Haiku): Sections 4-5 (Action & Files) - NO JSONL access
- Agent 3 (Haiku): Section 6 (Notes) - WITH JSONL access (manually filled by coordinator)

**Performance:** ~45 seconds total
- Agent 1: ~15s
- Agent 2: ~12s
- Agent 3: ~8s (but failed to extract from JSONL)
- Assembly: ~10s

**Issues Found:**
- Agent 3 couldn't read conversation history in fresh context
- Main coordinator had to manually fill section 6

**Quality Metrics:**
- ✅ Specific file paths with clickable links
- ✅ Line number references
- ✅ Concrete next steps with time estimates
- ✅ Clear working/broken state
- ✅ Emoji-based progress tracking
- ⚠️  Section 6 manually filled (not from conversation analysis)

---

## Comparison Tests

After implementing optimized JSONL extraction for all 3 agents, create new test files:

### `test-optimized-jsonl-all-agents.md`
**Method:** Parallel 3-agent with optimized grep+jq JSONL extraction for ALL agents
**Expected improvements:**
- Agent 1: User's stated objectives from conversation
- Agent 2: Explicit next steps mentioned in conversation
- Agent 3: Proper failure/decision/gotcha extraction from JSONL

### `test-helper-script.md`
**Method:** Parallel 3-agent using shared `.context/extract-conversation.sh` helper

---

## Quality Comparison Criteria

When comparing outputs, evaluate:

1. **Accuracy**
   - Does section 1 reflect user's actual stated goal?
   - Are error messages from conversation included?
   - Are decisions accurately captured?

2. **Specificity**
   - File paths with line numbers
   - Actual error messages (not summaries)
   - Concrete reproduction steps

3. **Completeness**
   - All failures documented
   - All decisions with rationale
   - All gotchas captured

4. **Performance**
   - Total time from spawn to assembly
   - Individual agent timing

5. **Consistency**
   - Similar structure across tests
   - Predictable section quality

---

## How to Run Comparison Test

```bash
# 1. Update agent prompts with JSONL extraction
# 2. Reinstall plugin
claude plugin marketplace remove reheat-local
claude plugin marketplace add $(pwd)
claude plugin install reheat@reheat-local

# 3. Run save-quick
/reheat:save-quick

# 4. Save output for comparison
cp RESUME.md .context/quality-tests/test-$(date +%Y%m%d-%H%M).md

# 5. Compare
diff .context/quality-tests/baseline-manual-parallel-3agent.md \
     .context/quality-tests/test-YYYYMMDD-HHMM.md
```

---

**Goal:** Verify that optimized JSONL extraction improves quality without sacrificing performance.
