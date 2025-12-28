#!/bin/bash
# Minimal status line - shows model and current directory
# Usage: Copy to ~/.claude/statusline.sh and make executable

input=$(cat)

MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name // "Claude"')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // "~"')
DIR_NAME="${CURRENT_DIR##*/}"

echo "[$MODEL_DISPLAY] $DIR_NAME"
