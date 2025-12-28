#!/usr/bin/env node
/**
 * Node.js status line script for Claude Code
 * Usage: Copy to ~/.claude/statusline.js and make executable
 */

const { execSync } = require('child_process');
const path = require('path');

// ANSI Colors
const BLUE = '\x1b[0;34m';
const MAGENTA = '\x1b[0;35m';
const CYAN = '\x1b[0;36m';
const GREEN = '\x1b[0;32m';
const YELLOW = '\x1b[0;33m';
const RED = '\x1b[0;31m';
const DIM = '\x1b[2m';
const RESET = '\x1b[0m';

function getGitInfo(directory) {
    try {
        // Check if in git repo
        execSync('git rev-parse --git-dir', {
            cwd: directory,
            stdio: ['pipe', 'pipe', 'pipe']
        });

        // Get branch
        const branch = execSync('git branch --show-current', {
            cwd: directory,
            encoding: 'utf8'
        }).trim();

        if (!branch) return '';

        // Count changes
        const status = execSync('git status --porcelain', {
            cwd: directory,
            encoding: 'utf8'
        });
        const changes = status.split('\n').filter(l => l.trim()).length;

        if (changes > 0) {
            return ` | ${MAGENTA}${branch}${RESET} ${CYAN}[${changes}]${RESET}`;
        }
        return ` | ${MAGENTA}${branch}${RESET}`;
    } catch {
        return '';
    }
}

function formatTokens(tokens) {
    if (tokens >= 1000) {
        return `${(tokens / 1000).toFixed(1)}k`;
    }
    return String(tokens);
}

let input = '';

process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => input += chunk);

process.stdin.on('end', () => {
    let data;
    try {
        data = JSON.parse(input);
    } catch {
        console.log('[Claude] ~');
        return;
    }

    // Extract data
    const model = data.model?.display_name || 'Claude';
    const currentDir = data.workspace?.current_dir || '~';
    const dirName = path.basename(currentDir) || '~';

    // Context window
    const ctx = data.context_window || {};
    const contextSize = ctx.context_window_size || 200000;
    const inputTokens = ctx.total_input_tokens || 0;
    const outputTokens = ctx.total_output_tokens || 0;

    // Calculate used tokens
    const usedTokens = inputTokens + outputTokens;

    // Free tokens (matches /context "Free space" calculation)
    let freeTokens = contextSize - usedTokens;
    if (freeTokens < 0) {
        freeTokens = 0;
    }

    // Calculate percentage (matches /context output precision)
    const freePercent = contextSize > 0 ? (freeTokens * 100.0 / contextSize) : 0;

    // Autocompact is always enabled in Claude Code
    const autocompactEnabled = true;

    // Color based on free percentage
    let ctxColor;
    if (freePercent > 50) {
        ctxColor = GREEN;
    } else if (freePercent > 25) {
        ctxColor = YELLOW;
    } else {
        ctxColor = RED;
    }

    // Git info
    const gitInfo = getGitInfo(currentDir);

    // Cost
    const cost = data.cost?.total_cost_usd || 0;
    const costInfo = cost ? ` | ${DIM}$${cost.toFixed(4)}${RESET}` : '';

    // Autocompact indicator
    const autocompactInfo = autocompactEnabled ? `${DIM}[AC]${RESET}` : `${DIM}[AC:off]${RESET}`;

    // Output
    const freeDisplay = formatTokens(freeTokens);
    console.log(`${DIM}[${model}]${RESET} ${BLUE}${dirName}${RESET}${gitInfo} | ${ctxColor}${freeDisplay} free (${freePercent.toFixed(1)}%)${RESET} ${autocompactInfo}${costInfo}`);
});
