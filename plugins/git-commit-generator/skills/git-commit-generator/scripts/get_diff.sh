#!/bin/bash
# Get staged diff for commit message generation
# Usage: bash get_diff.sh [--all]

set -e

if [[ "$1" == "--all" ]]; then
    # Show all uncommitted changes (staged + unstaged)
    git diff HEAD
else
    # Show only staged changes (default)
    STAGED=$(git diff --cached)
    if [[ -z "$STAGED" ]]; then
        echo "No staged changes. Showing unstaged changes instead:"
        echo "---"
        git diff
    else
        echo "$STAGED"
    fi
fi
