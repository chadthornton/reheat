#!/bin/bash
# Fast JSONL conversation extractor for parallel agent architecture
# Uses grep/rg (filter) + jq (parse) for 2-3x faster extraction than jq-only
# All 3 agents (Context, Action, Notes) use this shared helper
# Auto-detects ripgrep (rg) for 2-5x performance improvement on large files

set -euo pipefail

# Auto-detect ripgrep for better performance (fallback to grep)
if command -v rg &> /dev/null; then
    GREP_CMD="rg"
    USE_RG=true
else
    GREP_CMD="grep"
    USE_RG=false
fi

# Find current session JSONL file
get_session_file() {
    local cwd encoded_path session_file
    cwd=$(pwd)

    # More robust path encoding - handles spaces, special chars, Unicode
    # Replace any non-alphanumeric characters with underscores
    encoded_path=$(echo "$cwd" | sed 's/[^a-zA-Z0-9_-]/_/g')

    # Use find instead of ls with glob expansion for better safety
    # This handles paths with spaces and special characters properly
    session_file=$(find ~/.claude/projects/"${encoded_path}" -maxdepth 1 -name '*.jsonl' ! -name 'agent-*' -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)

    # Fallback for systems without -printf (like macOS)
    if [[ -z "$session_file" ]]; then
        session_file=$(find ~/.claude/projects/"${encoded_path}" -maxdepth 1 -name '*.jsonl' ! -name 'agent-*' -type f 2>/dev/null | while read -r file; do
            echo "$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null) $file"
        done | sort -rn | head -1 | cut -d' ' -f2-)
    fi

    if [[ -z "$session_file" ]]; then
        echo "ERROR: No session file found for path: $cwd (encoded as: $encoded_path)" >&2
        return 1
    fi

    echo "$session_file"
}

# Extract user's stated goals/objectives (for Agent 1)
extract_user_goals() {
    local session_file="$1"
    # First 10 user messages capture initial objectives
    jq -rc 'select(.type=="user") | .message.content' "$session_file" 2>/dev/null | head -10
}

# Extract error messages and broken state (for Agent 1)
extract_errors() {
    local session_file="$1"
    # Use tool-specific regex patterns for compatibility
    if [[ "$USE_RG" == true ]]; then
        # ripgrep (Rust regex)
        rg -iE 'error|failed|exception|broken|not working|returns [45][0-9]{2}' "$session_file" 2>/dev/null | \
        jq -r 'select(.type=="assistant" or .type=="user") |
               if .type == "user" then .message.content
               else (.message.content[]? | select(.type=="text") | .text) end' 2>/dev/null | \
        head -20
    else
        # grep (POSIX ERE)
        grep -iE 'error|failed|exception|broken|not working|returns [45][0-9]{2}' "$session_file" 2>/dev/null | \
        jq -r 'select(.type=="assistant" or .type=="user") |
               if .type == "user" then .message.content
               else (.message.content[]? | select(.type=="text") | .text) end' 2>/dev/null | \
        head -20
    fi
}

# Extract explicit next steps mentioned (for Agent 2)
extract_next_steps() {
    local session_file="$1"
    # Look for action-oriented language in recent messages
    $GREP_CMD -iE 'next|todo|need to|should|will|going to|let me|lets' "$session_file" 2>/dev/null | \
    jq -r 'select(.type=="user" or .type=="assistant") |
           if .type == "user" then .message.content
           else (.message.content[]? | select(.type=="text") | .text) end' 2>/dev/null | \
    tail -15
}

# Extract file importance discussions (for Agent 2)
extract_key_files() {
    local session_file="$1"
    # Look for file mentions in conversation
    $GREP_CMD -E '\.(ts|js|py|go|rs|java|jsx|tsx|vue|rb|php|cpp|c|h|css|html|json|yaml|yml)' "$session_file" 2>/dev/null | \
    jq -r 'select(.type=="assistant" or .type=="user") |
           if .type == "user" then .message.content
           else (.message.content[]? | select(.type=="text") | .text) end' 2>/dev/null | \
    grep -oE '[a-zA-Z0-9/_.-]+\.(ts|js|py|go|rs|java|jsx|tsx|vue|rb|php|cpp|c|h|css|html|json|yaml|yml)' | \
    sort | uniq -c | sort -rn | head -10
}

# Extract failed approaches and decisions (for Agent 3)
extract_failures() {
    local session_file="$1"
    # Look for explicit failure/rejection language
    $GREP_CMD -iE 'tried|attempt|didnt work|failed|doesnt work|not working|instead|gave up|abandoned' "$session_file" 2>/dev/null | \
    jq -r 'select(.type=="assistant") |
           (.message.content[]? | select(.type=="text") | .text)' 2>/dev/null | \
    head -15
}

# Extract architectural decisions (for Agent 3)
extract_decisions() {
    local session_file="$1"
    # Look for decision language
    $GREP_CMD -iE 'decided|chose|going with|using|opted for|instead of|better than|prefer' "$session_file" 2>/dev/null | \
    jq -r 'select(.type=="assistant" or .type=="user") |
           if .type == "user" then .message.content
           else (.message.content[]? | select(.type=="text") | .text) end' 2>/dev/null | \
    head -15
}

# Extract gotchas and warnings (for Agent 3)
extract_gotchas() {
    local session_file="$1"
    # Look for warning/gotcha language
    $GREP_CMD -iE 'gotcha|warning|careful|important|must|critical|dont|avoid|remember' "$session_file" 2>/dev/null | \
    jq -r 'select(.type=="assistant") |
           (.message.content[]? | select(.type=="text") | .text)' 2>/dev/null | \
    head -10
}

# Main execution: call function based on first argument
case "${1:-}" in
    session)
        get_session_file
        ;;
    user_goals)
        session_file=$(get_session_file)
        extract_user_goals "$session_file"
        ;;
    errors)
        session_file=$(get_session_file)
        extract_errors "$session_file"
        ;;
    next_steps)
        session_file=$(get_session_file)
        extract_next_steps "$session_file"
        ;;
    key_files)
        session_file=$(get_session_file)
        extract_key_files "$session_file"
        ;;
    failures)
        session_file=$(get_session_file)
        extract_failures "$session_file"
        ;;
    decisions)
        session_file=$(get_session_file)
        extract_decisions "$session_file"
        ;;
    gotchas)
        session_file=$(get_session_file)
        extract_gotchas "$session_file"
        ;;
    *)
        echo "Usage: $0 {session|user_goals|errors|next_steps|key_files|failures|decisions|gotchas}" >&2
        exit 1
        ;;
esac
