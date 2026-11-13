#!/bin/bash
# AI-powered release notes generator using Orca

set -e

SINCE_TAG=${1:-$(git describe --tags --abbrev=0 2>/dev/null || echo "")}
OUTPUT_FILE=${2:-RELEASE_NOTES.md}

echo "Generating release notes since: $SINCE_TAG"

# Get all commits since last tag
if [ -n "$SINCE_TAG" ]; then
    COMMITS=$(git log "$SINCE_TAG"..HEAD --pretty=format:"%H|%s|%an|%ae|%ad" --date=short)
else
    COMMITS=$(git log --pretty=format:"%H|%s|%an|%ae|%ad" --date=short)
fi

# Get closed PRs (if using GitHub)
if command -v gh &> /dev/null; then
    echo "Fetching closed PRs..."
    PRS=$(gh pr list --state merged --limit 100 --json number,title,author,mergedAt)
else
    PRS=""
fi

# Create temporary file with commit data
TEMP_FILE=$(mktemp)
cat > "$TEMP_FILE" << EOF
# Release Notes Generation Task

## Commits since last release:
$COMMITS

## Merged Pull Requests:
$PRS

## Instructions:
Generate comprehensive release notes in Markdown format with the following sections:

### 🚀 New Features
List all new features added

### 🐛 Bug Fixes
List all bug fixes

### ⚡ Performance Improvements
List performance enhancements

### 📚 Documentation
List documentation updates

### 🔧 Maintenance
List maintenance and refactoring work

### 💥 Breaking Changes
Highlight any breaking changes

### 📦 Dependencies
List dependency updates

For each item:
- Use bullet points
- Include commit SHA (abbreviated)
- Reference PR numbers if available
- Credit contributors
- Be concise but informative

Format example:
- ✨ Add user authentication system (#123) - @username (abc1234)
EOF

echo "Calling Orca AI agent to generate release notes..."

# Use Orca to generate release notes with Claude
orca agent run claude \
    --task "$(cat $TEMP_FILE)" \
    --output "$OUTPUT_FILE" 2>/dev/null || {
    
    # Fallback: Generate basic release notes without AI
    echo "AI generation failed, creating basic release notes..."
    
    cat > "$OUTPUT_FILE" << EOF
# Release Notes

## Changes Since $SINCE_TAG

### Commits
$(git log $SINCE_TAG..HEAD --pretty=format:"- %s (%h)" --reverse)

### Contributors
$(git log $SINCE_TAG..HEAD --pretty=format:"%an" | sort -u)

---
Generated on: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
EOF
}

rm -f "$TEMP_FILE"

echo "Release notes generated: $OUTPUT_FILE"
cat "$OUTPUT_FILE"
