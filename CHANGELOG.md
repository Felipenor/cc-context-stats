# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Comprehensive test suite with Bats (Bash), pytest (Python), and Jest (Node.js)
- GitHub Actions CI/CD pipeline with multi-platform testing
- Code quality tools: ShellCheck, Ruff, ESLint, Prettier
- Pre-commit hooks for automated code quality checks
- EditorConfig for consistent formatting across editors
- CONTRIBUTING.md with development setup instructions
- Dependabot configuration for automated dependency updates
- Release automation workflow

### Changed

- Updated project structure to follow best practices

## [1.0.0] - Initial Release

### Added

- Full-featured status line script (`statusline-full.sh`)
- Git-aware status line script (`statusline-git.sh`)
- Minimal status line script (`statusline-minimal.sh`)
- Cross-platform Python implementation (`statusline.py`)
- Cross-platform Node.js implementation (`statusline.js`)
- Interactive installer script (`install.sh`)
- Configuration examples for Claude Code
- Autocompact (AC) buffer indicator
- Context window usage with color-coded percentages
- Git branch and uncommitted changes display
