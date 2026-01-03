# Helper Script Test Suite

This directory contains tests for the conversation extraction helper script (`scripts/extract-conversation.sh`).

## What We're Testing

The helper script is critical infrastructure that:
1. **Encodes paths** to find Claude Code session files
2. **Extracts information** from conversation history (JSONL format)
3. **Works with both** grep and ripgrep for compatibility

We wrote tests because we fixed critical bugs:
- **Issue #1:** Helper script wasn't distributed with the plugin
- **Issue #2:** Path encoding broke with spaces/special characters (CRITICAL)
- **Issue #7:** Grep/ripgrep compatibility issues

## Test Structure

```
tests/
├── test-runner.sh           # Main test framework
├── test_path_encoding.sh    # Tests path encoding logic (Issue #2 fix)
├── test_extraction.sh       # Tests extraction functions
├── test_edge_cases.sh       # Tests error handling
├── fixtures/                # Sample test data
│   └── sample-conversation.jsonl
└── README.md               # This file
```

## Running Tests

### Run all tests:
```bash
cd tests
./test-runner.sh
```

### Run specific test file:
```bash
cd tests
./test_path_encoding.sh
```

## Understanding the Output

Tests output in this format:
```
✓ Test name                    # Passed (green)
✗ Test name                    # Failed (red)
  Reason: why it failed
○ Test name (skipped: reason)  # Skipped (yellow)
```

Summary at the end:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Test Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total:  25
Passed: 23
Failed: 2
```

## Test Categories

### 1. Path Encoding Tests (`test_path_encoding.sh`)
Tests the fix for Issue #2 - path vulnerability.

**What was broken:**
```bash
# OLD METHOD (broken):
echo "/Users/john doe/project" | tr '/' '-'
# Result: "-Users-john doe-project"
# ❌ Still has spaces! Breaks in shell glob patterns!
```

**What we fixed:**
```bash
# NEW METHOD (fixed):
echo "/Users/john doe/project" | sed 's/[^a-zA-Z0-9_-]/_/g'
# Result: "_Users_john_doe_project"
# ✅ No spaces! Shell-safe!
```

**Tests verify:**
- Paths with spaces work correctly
- Paths with special characters are sanitized
- Unicode characters are handled
- Very long paths don't break

### 2. Extraction Tests (`test_extraction.sh`)
Tests the functions that extract data from conversation history.

**What it tests:**
- `extract_user_goals()` - Finds what user wants to accomplish
- `extract_errors()` - Finds error messages
- `extract_next_steps()` - Finds action items
- `extract_failures()` - Finds failed approaches
- `extract_decisions()` - Finds architectural decisions
- `extract_gotchas()` - Finds warnings

**Also tests:**
- Works with both `grep` and `ripgrep` (Issue #7 fix)
- Performance (should be fast)

### 3. Edge Case Tests (`test_edge_cases.sh`)
Tests unusual situations that might break the script.

**What it tests:**
- Empty files (no data)
- Malformed JSON (bad data)
- Missing files (filesystem errors)
- Large files (performance limits)
- Special characters (security)
- Concurrent access (race conditions)

## How Testing Works (Bash Testing 101)

### Basic Concept
A test is a function that:
1. Sets up test data
2. Runs the code
3. Checks if the result is correct
4. Reports pass/fail

### Our Test Framework
```bash
# Start a test
test_start "Test name"

# Check if two things are equal
assert_equals "expected" "actual"

# Check if text contains substring
assert_contains "haystack" "needle"

# Check if command succeeds
assert_success some_command

# Check if command fails
assert_failure some_command
```

### Example Test
```bash
# TEST: Path encoding handles spaces
test_start "Path encoding: path with spaces"

# Run the function
result=$(encode_path "/Users/john doe/project")

# What we expect
expected="_Users_john_doe_project"

# Check if they match
assert_equals "$expected" "$result"
```

## Adding New Tests

To add a new test:

1. **Create test file:** `tests/test_your_feature.sh`
2. **Make it executable:** `chmod +x tests/test_your_feature.sh`
3. **Write tests:**
   ```bash
   #!/bin/bash

   # TEST 1: Description
   test_start "Your test name"
   result=$(your_function)
   assert_equals "expected" "$result"
   ```
4. **Run it:** `./test-runner.sh`

## Why We Test

**Before fixing Issue #2:**
- Users with spaces in paths: BROKEN
- Users with special characters: BROKEN
- No way to catch regressions

**After writing tests:**
- We verify the fix works
- We prevent regressions (if someone breaks it, tests fail)
- We document expected behavior
- We can refactor safely

## Common Test Patterns

### Testing a function
```bash
test_start "Function returns correct value"
result=$(my_function "input")
assert_equals "expected output" "$result"
```

### Testing error handling
```bash
test_start "Function handles bad input gracefully"
assert_failure my_function "bad input"
```

### Testing file operations
```bash
test_start "Function creates expected file"
my_function
if [[ -f "expected_file.txt" ]]; then
    test_pass
else
    test_fail "File was not created"
fi
```

### Testing with sample data
```bash
test_start "Parser handles sample data"
result=$(parse_file "fixtures/sample.json")
assert_contains "$result" "expected content"
```

## Debugging Failed Tests

If a test fails:

1. **Read the error message** - it tells you what failed
2. **Run the specific test file** - isolate the problem
3. **Add debug output:**
   ```bash
   echo "DEBUG: result='$result'" >&2
   ```
4. **Run manually** - execute the command yourself to see what happens

## Best Practices

1. **Test the fix, not the bug** - Write tests that pass with your fix
2. **One assertion per test** - Makes it clear what failed
3. **Use descriptive names** - "Path encoding handles spaces" not "Test 1"
4. **Test edge cases** - Empty strings, null, huge inputs, special chars
5. **Clean up** - Remove temporary files after tests

## Continuous Testing

Run tests:
- **Before committing** - Make sure you didn't break anything
- **After fixing a bug** - Verify the fix works
- **When refactoring** - Ensure behavior doesn't change

## Next Steps

Want to add more tests? Consider:
- Integration tests for full skill workflows
- Performance benchmarks
- Security tests (injection, path traversal)
- Compatibility tests (different OS, different shells)
