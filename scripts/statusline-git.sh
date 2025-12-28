#!/bin/bash
# Git-aware status line - shows model, directory, and git branch
# Usage: Copy to ~/.claude/statusline.sh and make executable

# Colors
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

input=$(cat)

MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name // "Claude"')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // "~"')
DIR_NAME="${CURRENT_DIR##*/}"

# Git branch detection
GIT_INFO=""
if git -C "$CURRENT_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "$CURRENT_DIR" branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        # Count uncommitted changes
        CHANGES=$(git -C "$CURRENT_DIR" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        if [ "$CHANGES" -gt 0 ]; then
            GIT_INFO=" | ${MAGENTA}${BRANCH}${RESET} ${CYAN}[${CHANGES}]${RESET}"
        else
            GIT_INFO=" | ${MAGENTA}${BRANCH}${RESET}"
        fi
    fi
fi

echo -e "[${MODEL_DISPLAY}] ${BLUE}${DIR_NAME}${RESET}${GIT_INFO}"
