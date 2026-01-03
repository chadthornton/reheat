#!/bin/bash
# Simple Test Runner for Bash Scripts
# This is a minimal testing framework to teach testing concepts

set -euo pipefail

# Color codes for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test statistics
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Current test being run
CURRENT_TEST=""

#######################################
# CORE TESTING FUNCTIONS
#######################################

# Start a new test
# Usage: test_start "Test name"
test_start() {
    CURRENT_TEST="$1"
    TESTS_RUN=$((TESTS_RUN + 1))
}

# Assert that two values are equal
# Usage: assert_equals "expected" "actual" "optional message"
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"

    if [[ "$expected" == "$actual" ]]; then
        test_pass
    else
        test_fail "Expected: '$expected', Got: '$actual' $message"
    fi
}

# Assert that a value contains a substring
# Usage: assert_contains "haystack" "needle" "optional message"
assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-}"

    if [[ "$haystack" == *"$needle"* ]]; then
        test_pass
    else
        test_fail "Expected '$haystack' to contain '$needle' $message"
    fi
}

# Assert that a command succeeds (exit code 0)
# Usage: assert_success some_command args
assert_success() {
    if "$@" &>/dev/null; then
        test_pass
    else
        test_fail "Command failed: $*"
    fi
}

# Assert that a command fails (non-zero exit code)
# Usage: assert_failure some_command args
assert_failure() {
    if "$@" &>/dev/null; then
        test_fail "Command should have failed but succeeded: $*"
    else
        test_pass
    fi
}

# Mark current test as passed
test_pass() {
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} $CURRENT_TEST"
}

# Mark current test as failed
# Usage: test_fail "reason for failure"
test_fail() {
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $CURRENT_TEST"
    if [[ -n "${1:-}" ]]; then
        echo -e "  ${RED}Reason:${NC} $1"
    fi
}

# Skip a test with a reason
# Usage: test_skip "reason for skipping"
test_skip() {
    echo -e "${YELLOW}○${NC} $CURRENT_TEST (skipped: $1)"
}

#######################################
# TEST RUNNER
#######################################

# Print test summary at the end
print_summary() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Test Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Total:  $TESTS_RUN"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "${RED}Failed: $TESTS_FAILED${NC}"
        echo ""
        return 1
    else
        echo ""
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    fi
}

# Run all test files
run_all_tests() {
    local test_dir="${1:-.}"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Running Tests"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Find and run all test files
    for test_file in "$test_dir"/test_*.sh; do
        if [[ -f "$test_file" ]]; then
            echo "Running $(basename "$test_file")..."
            # Execute the test file (not source - we want isolation)
            bash "$test_file"
            echo ""
        fi
    done

    print_summary
}

# Export functions so test files can use them
export -f test_start
export -f assert_equals
export -f assert_contains
export -f assert_success
export -f assert_failure
export -f test_pass
export -f test_fail
export -f test_skip

# If this script is run directly (not sourced), run all tests
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    cd "$(dirname "${BASH_SOURCE[0]}")"
    run_all_tests .
fi
