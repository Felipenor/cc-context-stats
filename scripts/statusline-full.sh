#!/bin/bash
# Full-featured status line with context window usage
# Usage: Copy to ~/.claude/statusline.sh and make executable

# Read JSON input from stdin
input=$(cat)

# Extract information from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir')
model=$(echo "$input" | jq -r '.model.display_name')

# Get directory name
dir_name=$(basename "$cwd")

# Git information (skip optional locks for performance)
if [[ -d "$project_dir/.git" ]]; then
    git_branch=$(cd "$project_dir" 2>/dev/null && git --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
    git_status_count=$(cd "$project_dir" 2>/dev/null && git --no-optional-locks status --porcelain 2>/dev/null | wc -l | tr -d ' ')
else
    git_branch=""
    git_status_count="0"
fi

# Calculate context window - show remaining free space
# Matches /context output: Free space = context_window_size - used_tokens
context_free=""
total_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
current_usage=$(echo "$input" | jq '.context_window.current_usage')

if [[ "$total_size" -gt 0 && "$current_usage" != "null" ]]; then
    # Get tokens from current_usage (includes cache)
    input_tokens=$(echo "$current_usage" | jq -r '.input_tokens // 0')
    cache_creation=$(echo "$current_usage" | jq -r '.cache_creation_input_tokens // 0')
    cache_read=$(echo "$current_usage" | jq -r '.cache_read_input_tokens // 0')

    # Total used from current request
    used_tokens=$((input_tokens + cache_creation + cache_read))

    # Free = total - used (matches /context "Free space" display)
    # Note: /context shows autocompact buffer separately, not subtracted from free
    free_tokens=$((total_size - used_tokens))
    if [[ "$free_tokens" -lt 0 ]]; then
        free_tokens=0
    fi
    free_pct=$((free_tokens * 100 / total_size))

    # Format tokens in k
    free_k=$((free_tokens / 1000))
    context_free="${free_k}k (${free_pct}%)"
fi

# Build status line with colors
output=""

# Directory in blue
output+=$(printf "\033[1;34m[%s]\033[0m" "$dir_name")

# Git branch in magenta
if [[ -n "$git_branch" ]]; then
    output+=$(printf " \033[1;35m%s\033[0m" "$git_branch")

    # Git status count in cyan if there are changes
    if [[ "$git_status_count" != "0" ]]; then
        output+=$(printf " \033[36m●%s\033[0m" "$git_status_count")
    fi
fi

# Model in dim white
output+=$(printf " \033[2m• %s\033[0m" "$model")

# Context free space in green if available
if [[ -n "$context_free" ]]; then
    output+=$(printf " \033[1;32m[%s free]\033[0m" "$context_free")
fi

# Autocompact indicator (always enabled in Claude Code)
output+=$(printf " \033[2m[AC]\033[0m")

# Output the final status line
echo "$output"
