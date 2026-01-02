#!/bin/bash
# Fast JSONL conversation extractor for parallel agent architecture
# Uses grep (filter) + jq (parse) for 2-3x faster extraction than jq-only
# All 3 agents (Context, Action, Notes) use this shared helper

set -euo pipefail

# Find current session JSONL file
get_session_file() {
    local cwd encoded_path session_file
    cwd=$(pwd)
    encoded_path=$(echo "$cwd" | tr '/' '-')
    session_file=$(ls -t ~/.claude/projects/${encoded_path}/*.jsonl 2>/dev/null | grep -v 'agent-' | head -1)

    if [[ -z "$session_file" ]]; then
        echo "ERROR: No session file found" >&2
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
    # grep first (fast filter), then jq (parse JSON)
    grep -iE 'error|failed|exception|broken|not working|returns [45][0-9]{2}' "$session_file" 2>/dev/null | \
    jq -r 'select(.type=="assistant" or .type=="user") |
           if .type == "user" then .message.content
           else (.message.content[]? | select(.type=="text") | .text) end' 2>/dev/null | \
    head -20
}

# Extract explicit next steps mentioned (for Agent 2)
extract_next_steps() {
    local session_file="$1"
    # Look for action-oriented language in recent messages
    grep -iE 'next|todo|need to|should|will|going to|let me|lets' "$session_file" 2>/dev/null | \
    jq -r 'select(.type=="user" or .type=="assistant") |
           if .type == "user" then .message.content
           else (.message.content[]? | select(.type=="text") | .text) end' 2>/dev/null | \
    tail -15
}

# Extract file importance discussions (for Agent 2)
extract_key_files() {
    local session_file="$1"
    # Look for file mentions in conversation
    grep -E '\.(ts|js|py|go|rs|java|jsx|tsx|vue|rb|php|cpp|c|h|css|html|json|yaml|yml)' "$session_file" 2>/dev/null | \
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
    grep -iE 'tried|attempt|didnt work|failed|doesnt work|not working|instead|gave up|abandoned' "$session_file" 2>/dev/null | \
    jq -r 'select(.type=="assistant") |
           (.message.content[]? | select(.type=="text") | .text)' 2>/dev/null | \
    head -15
}

# Extract architectural decisions (for Agent 3)
extract_decisions() {
    local session_file="$1"
    # Look for decision language
    grep -iE 'decided|chose|going with|using|opted for|instead of|better than|prefer' "$session_file" 2>/dev/null | \
    jq -r 'select(.type=="assistant" or .type=="user") |
           if .type == "user" then .message.content
           else (.message.content[]? | select(.type=="text") | .text) end' 2>/dev/null | \
    head -15
}

# Extract gotchas and warnings (for Agent 3)
extract_gotchas() {
    local session_file="$1"
    # Look for warning/gotcha language
    grep -iE 'gotcha|warning|careful|important|must|critical|dont|avoid|remember' "$session_file" 2>/dev/null | \
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
