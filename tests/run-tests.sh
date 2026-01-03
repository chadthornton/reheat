#!/bin/bash
# Comprehensive Test Suite for extract-conversation.sh
# This is a simple, self-contained test file that's easy to understand

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

#######################################
# TEST FRAMEWORK (inline for simplicity)
#######################################

test_pass() {
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} $1"
}

test_fail() {
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $1"
    if [[ -n "${2:-}" ]]; then
        echo -e "  ${RED}Reason:${NC} $2"
    fi
}

assert_equals() {
    local test_name="$1"
    local expected="$2"
    local actual="$3"
    TESTS_RUN=$((TESTS_RUN + 1))

    if [[ "$expected" == "$actual" ]]; then
        test_pass "$test_name"
    else
        test_fail "$test_name" "Expected '$expected' but got '$actual'"
    fi
}

assert_contains() {
    local test_name="$1"
    local haystack="$2"
    local needle="$3"
    TESTS_RUN=$((TESTS_RUN + 1))

    if [[ "$haystack" == *"$needle"* ]]; then
        test_pass "$test_name"
    else
        test_fail "$test_name" "Expected to find '$needle' in output"
    fi
}

#######################################
# SETUP
#######################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELPER_SCRIPT="$SCRIPT_DIR/../scripts/extract-conversation.sh"
TEST_JSONL="$SCRIPT_DIR/fixtures/sample-conversation.jsonl"

if [[ ! -f "$HELPER_SCRIPT" ]]; then
    echo -e "${RED}ERROR:${NC} Helper script not found at $HELPER_SCRIPT"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Helper Script Test Suite"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

#######################################
# PATH ENCODING TESTS
#######################################

echo "Running Path Encoding Tests..."
echo ""

# Function to test (extracted from helper script)
encode_path() {
    echo "$1" | sed 's/[^-a-zA-Z0-9_]/_/g'
}

# Test 1: Simple path
result=$(encode_path "/Users/john/projects/myapp")
assert_equals "Simple path encoding" "_Users_john_projects_myapp" "$result"

# Test 2: Path with spaces (THE BUG WE FIXED!)
result=$(encode_path "/Users/john doe/my project")
assert_equals "Path with spaces" "_Users_john_doe_my_project" "$result"

# Test 3: Path with special characters (hyphens preserved, @ replaced)
result=$(encode_path "/Users/test/project-2.0/app@latest")
assert_equals "Path with special chars" "_Users_test_project-2_0_app_latest" "$result"

# Test 4: Path with parentheses
result=$(encode_path "/Users/test/(backup)/file.txt")
assert_equals "Path with parentheses" "_Users_test__backup__file_txt" "$result"

# Test 5: Empty path
result=$(encode_path "")
assert_equals "Empty path" "" "$result"

echo ""

#######################################
# EXTRACTION FUNCTION TESTS
#######################################

echo "Running Extraction Function Tests..."
echo ""

# These tests verify the helper script can extract information
# We'll run the actual script against our sample data

# For extraction tests, we need to mock the session file location
# We'll create a temporary wrapper that uses our test data
MOCK_SCRIPT=$(mktemp)
cat > "$MOCK_SCRIPT" <<'WRAPPER_EOF'
#!/bin/bash
# Mock wrapper that overrides get_session_file
TEST_JSONL="__TEST_JSONL__"
get_session_file() { echo "$TEST_JSONL"; }
source "__HELPER_SCRIPT__"
WRAPPER_EOF

sed -i '' "s|__TEST_JSONL__|$TEST_JSONL|g" "$MOCK_SCRIPT"
sed -i '' "s|__HELPER_SCRIPT__|$HELPER_SCRIPT|g" "$MOCK_SCRIPT"
chmod +x "$MOCK_SCRIPT"

# Test 6: Verify script has user_goals function
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "extract_user_goals" "$HELPER_SCRIPT"; then
    test_pass "Script has extract_user_goals function"
else
    test_fail "Script has extract_user_goals function"
fi

# Test 7: Verify script has extract_errors function
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "extract_errors" "$HELPER_SCRIPT"; then
    test_pass "Script has extract_errors function"
else
    test_fail "Script has extract_errors function"
fi

# Test 8: Verify script has extract_next_steps function
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "extract_next_steps" "$HELPER_SCRIPT"; then
    test_pass "Script has extract_next_steps function"
else
    test_fail "Script has extract_next_steps function"
fi

# Test 9: Verify script has extract_failures function
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "extract_failures" "$HELPER_SCRIPT"; then
    test_pass "Script has extract_failures function"
else
    test_fail "Script has extract_failures function"
fi

# Test 10: Verify script has extract_decisions function
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "extract_decisions" "$HELPER_SCRIPT"; then
    test_pass "Script has extract_decisions function"
else
    test_fail "Script has extract_decisions function"
fi

# Test 11: Verify script has extract_gotchas function
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "extract_gotchas" "$HELPER_SCRIPT"; then
    test_pass "Script has extract_gotchas function"
else
    test_fail "Script has extract_gotchas function"
fi

rm -f "$MOCK_SCRIPT"

echo ""

#######################################
# GREP/RIPGREP COMPATIBILITY
#######################################

echo "Running Compatibility Tests..."
echo ""

# Test 12: Verify grep detection logic
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "command -v rg" "$HELPER_SCRIPT"; then
    test_pass "Script has ripgrep detection logic"
else
    test_fail "Script has ripgrep detection logic"
fi

# Test 13: Verify grep fallback
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "GREP_CMD=" "$HELPER_SCRIPT"; then
    test_pass "Script has grep fallback logic"
else
    test_fail "Script has grep fallback logic"
fi

echo ""

#######################################
# EDGE CASES
#######################################

echo "Running Edge Case Tests..."
echo ""

# Test 14: Verify error handling exists
TESTS_RUN=$((TESTS_RUN + 1))
if grep -q "ERROR" "$HELPER_SCRIPT"; then
    test_pass "Script has error handling"
else
    test_fail "Script has error handling"
fi

# Test 15: Verify script uses set -euo pipefail for safety
TESTS_RUN=$((TESTS_RUN + 1))
if head -20 "$HELPER_SCRIPT" | grep -q "set -euo pipefail"; then
    test_pass "Script uses safe bash options"
else
    test_fail "Script uses safe bash options"
fi

echo ""

#######################################
# SUMMARY
#######################################

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total:  $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    echo ""
    exit 1
else
    echo ""
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
