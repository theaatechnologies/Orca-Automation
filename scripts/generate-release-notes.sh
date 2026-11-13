#!/bin/bash
# Release notes generator: collects commits, asks opencode to write polished notes
# (skill: release-notes), falls back to a plain commit list if opencode is unavailable.
# Usage: generate-release-notes.sh [since-tag] [output-file]   (run in the repo to document)

set -euo pipefail

SINCE_TAG=${1:-$(git describe --tags --abbrev=0 2>/dev/null || echo "")}
OUTPUT_FILE=${2:-RELEASE_NOTES.md}

if [[ -n "$SINCE_TAG" && ! "$SINCE_TAG" =~ ^[A-Za-z0-9][A-Za-z0-9._/-]*$ ]]; then
    echo "Invalid tag: $SINCE_TAG" >&2; exit 1
fi
if [[ ! "$OUTPUT_FILE" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
    echo "Invalid output file name: $OUTPUT_FILE" >&2; exit 1
fi

if [ -n "$SINCE_TAG" ]; then
    RANGE="$SINCE_TAG..HEAD"; LABEL="since $SINCE_TAG"
else
    RANGE="HEAD"; LABEL="(no tags yet: last 50 commits)"
fi
COMMITS=$(git log "$RANGE" -n 50 --no-merges --pretty=format:"- %s (%h, %an)" --reverse)
if [ -z "$COMMITS" ]; then
    echo "No commits $LABEL: nothing to write." >&2
    exit 1
fi
echo "Generating release notes $LABEL"

basic_notes() {
    {
        echo "# Release Notes"; echo; echo "## Changes $LABEL"; echo
        echo "$COMMITS"; echo
        echo "---"; echo "Generated on: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    } > "$OUTPUT_FILE"
}

if command -v opencode >/dev/null 2>&1; then
    rm -f "$OUTPUT_FILE"
    PROMPT="Use the release-notes skill. Write release notes in Markdown to $OUTPUT_FILE, grouped into Features, Fixes and Chores, one line per change, no noise. Commits $LABEL:
$COMMITS"
    if timeout 300 opencode run "$PROMPT" >/dev/null 2>&1 && [ -s "$OUTPUT_FILE" ]; then
        echo "✓ AI release notes written to $OUTPUT_FILE"
        exit 0
    fi
    echo "opencode failed or wrote nothing; using plain commit list" >&2
fi
basic_notes
echo "✓ Basic release notes written to $OUTPUT_FILE"
