#!/bin/bash
# Test conversation extraction functions
# These tests verify that the helper script correctly extracts
# different types of information from JSONL conversation history

# Setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELPER_SCRIPT="$SCRIPT_DIR/../scripts/extract-conversation.sh"
TEST_JSONL="$SCRIPT_DIR/fixtures/sample-conversation.jsonl"

# Verify helper script exists
if [[ ! -f "$HELPER_SCRIPT" ]]; then
    echo "ERROR: Helper script not found at $HELPER_SCRIPT"
    exit 1
fi

#######################################
# EXTRACTION FUNCTION TESTS
#######################################
# The helper script has functions to extract:
# - user_goals: What the user wants to accomplish
# - errors: Error messages from the conversation
# - next_steps: Action items discussed
# - failures: Failed approaches
# - decisions: Architectural decisions
# - gotchas: Important warnings

# Helper function to run extraction on test data
run_extraction() {
    local function_name="$1"
    # Create a mock get_session_file that returns our test file
    export TEST_MODE=1
    export TEST_SESSION_FILE="$TEST_JSONL"

    # Read the helper script and inject test mode
    bash -c "
        TEST_SESSION_FILE='$TEST_JSONL'
        get_session_file() { echo \"\$TEST_SESSION_FILE\"; }
        source '$HELPER_SCRIPT'
        extract_${function_name} \"\$TEST_SESSION_FILE\"
    " 2>/dev/null
}

# TEST 1: Extract user goals
test_start "Extract user goals from conversation"
result=$(run_extraction "user_goals")
assert_contains "$result" "JWT authentication" "Should find user's goal"

# TEST 2: Extract errors
test_start "Extract errors from conversation"
result=$(run_extraction "errors")
assert_contains "$result" "Cannot read property 'id' of undefined" "Should find error message"
assert_contains "$result" "routes/auth.ts:67" "Should find error location"

# TEST 3: Extract next steps
test_start "Extract next steps from conversation"
result=$(run_extraction "next_steps")
assert_contains "$result" "Add auth middleware" "Should find next step"

# TEST 4: Extract failures
test_start "Extract failures from conversation"
result=$(run_extraction "failures")
assert_contains "$result" "approach failed" "Should find failed approach"
assert_contains "$result" "abandoned" "Should find abandoned attempts"

# TEST 5: Extract decisions
test_start "Extract decisions from conversation"
result=$(run_extraction "decisions")
assert_contains "$result" "Redis" "Should find architectural decision"
assert_contains "$result" "decided" "Should find decision language"

# TEST 6: Extract gotchas
test_start "Extract gotchas/warnings from conversation"
result=$(run_extraction "gotchas")
assert_contains "$result" "gotcha" "Should find gotcha keyword"
assert_contains "$result" "remember" "Should find warning language"

#######################################
# GREP VS RIPGREP COMPATIBILITY TEST
#######################################

# TEST 7: Test with grep (if available)
test_start "Extraction works with grep"
if command -v grep &>/dev/null; then
    # Force use of grep by hiding rg
    result=$(PATH="/usr/bin:/bin" bash -c "
        TEST_SESSION_FILE='$TEST_JSONL'
        get_session_file() { echo \"\$TEST_SESSION_FILE\"; }
        source '$HELPER_SCRIPT'
        extract_errors \"\$TEST_SESSION_FILE\"
    " 2>/dev/null)

    if [[ -n "$result" ]]; then
        test_pass
    else
        test_fail "grep should produce output"
    fi
else
    test_skip "grep not available"
fi

# TEST 8: Test with ripgrep (if available)
test_start "Extraction works with ripgrep"
if command -v rg &>/dev/null; then
    result=$(bash -c "
        TEST_SESSION_FILE='$TEST_JSONL'
        get_session_file() { echo \"\$TEST_SESSION_FILE\"; }
        source '$HELPER_SCRIPT'
        extract_errors \"\$TEST_SESSION_FILE\"
    " 2>/dev/null)

    if [[ -n "$result" ]]; then
        test_pass
    else
        test_fail "ripgrep should produce output"
    fi
else
    test_skip "ripgrep not available"
fi

#######################################
# PERFORMANCE TEST
#######################################

# TEST 9: Performance check (extraction should be fast)
test_start "Extraction completes in reasonable time"
start_time=$(date +%s)
result=$(run_extraction "user_goals")
end_time=$(date +%s)
duration=$((end_time - start_time))

if [[ $duration -le 2 ]]; then
    test_pass
else
    test_fail "Extraction took ${duration}s (should be < 2s)"
fi

echo ""
echo "📝 Teaching moment:"
echo "   These tests verify that the helper script can extract"
echo "   different types of information from conversation history."
echo "   We test with both grep and ripgrep to ensure compatibility."
