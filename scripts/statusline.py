#!/usr/bin/env python3
"""
Python status line script for Claude Code
Usage: Copy to ~/.claude/statusline.py and make executable
"""

import json
import sys
import os
import subprocess

# ANSI Colors
BLUE = '\033[0;34m'
MAGENTA = '\033[0;35m'
CYAN = '\033[0;36m'
GREEN = '\033[0;32m'
YELLOW = '\033[0;33m'
RED = '\033[0;31m'
DIM = '\033[2m'
RESET = '\033[0m'


def get_git_info(directory):
    """Get git branch and change count"""
    try:
        # Check if in git repo
        subprocess.run(
            ['git', '-C', directory, 'rev-parse', '--git-dir'],
            capture_output=True, check=True
        )

        # Get branch name
        result = subprocess.run(
            ['git', '-C', directory, 'branch', '--show-current'],
            capture_output=True, text=True
        )
        branch = result.stdout.strip()

        if not branch:
            return ""

        # Count changes
        result = subprocess.run(
            ['git', '-C', directory, 'status', '--porcelain'],
            capture_output=True, text=True
        )
        changes = len([l for l in result.stdout.split('\n') if l.strip()])

        if changes > 0:
            return f" | {MAGENTA}{branch}{RESET} {CYAN}[{changes}]{RESET}"
        return f" | {MAGENTA}{branch}{RESET}"
    except Exception:
        return ""


def format_tokens(tokens):
    """Format token count (k for thousands, with one decimal)"""
    if tokens >= 1000:
        return f"{tokens / 1000:.1f}k"
    return str(tokens)


def main():
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        print("[Claude] ~")
        return

    # Extract data
    model = data.get('model', {}).get('display_name', 'Claude')
    current_dir = data.get('workspace', {}).get('current_dir', '~')
    dir_name = os.path.basename(current_dir) or '~'

    # Context window
    ctx = data.get('context_window', {})
    context_size = ctx.get('context_window_size', 200000)
    input_tokens = ctx.get('total_input_tokens', 0)
    output_tokens = ctx.get('total_output_tokens', 0)

    # Calculate used tokens
    used_tokens = input_tokens + output_tokens

    # Free tokens (matches /context "Free space" calculation)
    free_tokens = context_size - used_tokens
    if free_tokens < 0:
        free_tokens = 0

    # Calculate percentage (matches /context output precision)
    free_percent = (free_tokens * 100.0 / context_size) if context_size > 0 else 0

    # Autocompact is always enabled in Claude Code
    autocompact_enabled = True

    # Color based on free percentage
    if free_percent > 50:
        ctx_color = GREEN
    elif free_percent > 25:
        ctx_color = YELLOW
    else:
        ctx_color = RED

    # Git info
    git_info = get_git_info(current_dir)

    # Cost
    cost = data.get('cost', {}).get('total_cost_usd', 0)
    cost_info = f" | {DIM}${cost:.4f}{RESET}" if cost else ""

    # Autocompact indicator
    autocompact_info = f"{DIM}[AC]{RESET}" if autocompact_enabled else f"{DIM}[AC:off]{RESET}"

    # Output
    free_display = format_tokens(free_tokens)
    print(f"{DIM}[{model}]{RESET} {BLUE}{dir_name}{RESET}{git_info} | {ctx_color}{free_display} free ({free_percent:.1f}%){RESET} {autocompact_info}{cost_info}")


if __name__ == '__main__':
    main()
