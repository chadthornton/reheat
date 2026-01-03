#!/bin/bash
# Test path encoding logic from extract-conversation.sh
# This tests the fix for Issue #2: Path Vulnerability

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the test framework (defines test_start, assert_equals, etc.)
# We use a guard to prevent re-sourcing if already loaded
if [[ -z "${TEST_FRAMEWORK_LOADED:-}" ]]; then
    # Temporarily disable the auto-run at the end of test-runner.sh
    BASH_SOURCE[0]="sourced"
    source "$SCRIPT_DIR/test-runner.sh" || exit 1
    TEST_FRAMEWORK_LOADED=1
fi

#######################################
# PATH ENCODING TESTS
#######################################
# The helper script encodes project paths to find session files.
# Issue #2 was that paths with spaces/special chars would break.
# We fixed it by using sed to replace non-alphanumeric chars with underscores.

# Function to test (extracted from helper script)
encode_path() {
    echo "$1" | sed 's/[^a-zA-Z0-9_-]/_/g'
}

# TEST 1: Basic path encoding (simple case)
test_start "Path encoding: simple path"
result=$(encode_path "/Users/john/projects/myapp")
expected="_Users_john_projects_myapp"
assert_equals "$expected" "$result"

# TEST 2: Path with spaces (the bug we fixed!)
test_start "Path encoding: path with spaces"
result=$(encode_path "/Users/john doe/my project")
expected="_Users_john_doe_my_project"
assert_equals "$expected" "$result"

# TEST 3: Path with special characters
test_start "Path encoding: path with special chars"
result=$(encode_path "/Users/test/project-2.0/app@latest")
expected="_Users_test_project_2_0_app_latest"
assert_equals "$expected" "$result"

# TEST 4: Path with Unicode (real-world case)
test_start "Path encoding: path with Unicode"
result=$(encode_path "/Users/テスト/プロジェクト")
expected="_Users______________________"
assert_equals "$expected" "$result"

# TEST 5: Path with parentheses and brackets
test_start "Path encoding: path with parens/brackets"
result=$(encode_path "/Users/test/(backup)/[old]/file.txt")
expected="_Users_test__backup___old__file_txt"
assert_equals "$expected" "$result"

# TEST 6: Very long path
test_start "Path encoding: very long path"
long_path="/Users/john/very/long/path/that/goes/on/and/on/and/on/and/on/and/on"
result=$(encode_path "$long_path")
# Should not fail or truncate
assert_contains "$result" "Users"
assert_contains "$result" "john"

# TEST 7: Path with trailing slash
test_start "Path encoding: path with trailing slash"
result=$(encode_path "/Users/john/project/")
expected="_Users_john_project_"
assert_equals "$expected" "$result"

# TEST 8: Empty path (edge case)
test_start "Path encoding: empty path"
result=$(encode_path "")
expected=""
assert_equals "$expected" "$result"

#######################################
# COMPARISON TEST: Old vs New Method
#######################################

# The OLD method (using tr) that had the bug:
encode_path_old() {
    echo "$1" | tr '/' '-'
}

# TEST 9: Show why old method failed with special chars
test_start "Old method fails with spaces (demonstrate bug)"
old_result=$(encode_path_old "/Users/john doe/project")
# Old method would produce: "-Users-john doe-project"
# This breaks in shell glob patterns because of the space!
assert_contains "$old_result" " "  # Proves space is still there

# TEST 10: Show new method fixes it
test_start "New method handles spaces correctly"
new_result=$(encode_path "/Users/john doe/project")
# New method produces: "_Users_john_doe_project"
# No spaces, safe for shell operations
if [[ "$new_result" == *" "* ]]; then
    test_fail "New method should not contain spaces"
else
    test_pass
fi

echo ""
echo "📝 Teaching moment:"
echo "   The OLD method (tr '/' '-') only replaced slashes"
echo "   The NEW method (sed 's/[^a-zA-Z0-9_-]/_/g') replaces ALL"
echo "   non-alphanumeric characters, making paths shell-safe"
