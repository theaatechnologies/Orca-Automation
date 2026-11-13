#!/bin/bash
# Weekly release automation script
# Can be run manually or scheduled via cron/GitHub Actions

set -e

echo "=========================================="
echo "Weekly Release Automation"
echo "=========================================="

# Configuration
RELEASE_BRANCH="main"
RELEASE_TYPE=${1:-patch}  # major, minor, or patch

# Get last release tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
echo "Last release: $LAST_TAG"

# Step 1: Ensure we're on the right branch
echo ""
echo "Step 1: Checking out $RELEASE_BRANCH..."
git checkout "$RELEASE_BRANCH"
git pull origin "$RELEASE_BRANCH"

# Step 2: Run all tests
echo ""
echo "Step 2: Running full test suite..."
if ! ./scripts/run-tests.sh all; then
    echo "❌ Tests failed! Cannot proceed with release."
    exit 1
fi
echo "✅ All tests passed!"

# Step 3: Generate release notes
echo ""
echo "Step 3: Generating release notes..."
./scripts/generate-release-notes.sh "$LAST_TAG" "RELEASE_NOTES.md"

# Step 4: Determine version bump
echo ""
echo "Step 4: Calculating new version..."

# Parse current version
LAST_VERSION=${LAST_TAG#v}  # Remove 'v' prefix
IFS='.' read -r MAJOR MINOR PATCH <<< "$LAST_VERSION"

# Bump version
case $RELEASE_TYPE in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        echo "Unknown release type: $RELEASE_TYPE"
        exit 1
        ;;
esac

NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}"
echo "New version: $NEW_VERSION"

# Step 5: Update version files
echo ""
echo "Step 5: Updating version files..."

# Update package.json
if [ -f "package.json" ]; then
    if command -v jq &> /dev/null; then
        jq --arg version "${NEW_VERSION#v}" '.version = $version' package.json > package.json.tmp
        mv package.json.tmp package.json
        echo "  - Updated package.json"
    fi
fi

# Update go files
if [ -f "version.go" ]; then
    sed -i "s/Version = \".*\"/Version = \"$NEW_VERSION\"/" version.go
    echo "  - Updated version.go"
elif [ -f "main.go" ]; then
    sed -i "s/const Version = \".*\"/const Version = \"$NEW_VERSION\"/" main.go
    echo "  - Updated main.go"
fi

# Create VERSION file
echo "$NEW_VERSION" > VERSION
echo "  - Created VERSION file"

# Step 6: Commit changes
echo ""
echo "Step 6: Creating release commit..."
git add -A
git commit -m "chore: release $NEW_VERSION" \
    -m "$(cat RELEASE_NOTES.md)" || echo "No changes to commit"

# Step 7: Create git tag
echo ""
echo "Step 7: Creating git tag..."
git tag -a "$NEW_VERSION" -m "Release $NEW_VERSION" -m "$(cat RELEASE_NOTES.md)"

# Step 8: Push changes
echo ""
echo "Step 8: Pushing changes..."
read -p "Push to remote? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git push origin "$RELEASE_BRANCH"
    git push origin "$NEW_VERSION"
    echo "✅ Pushed to remote"
else
    echo "⚠️  Skipped push. Run manually:"
    echo "   git push origin $RELEASE_BRANCH"
    echo "   git push origin $NEW_VERSION"
fi

# Step 9: Create GitHub release (if gh CLI is available)
echo ""
echo "Step 9: Creating GitHub release..."
if command -v gh &> /dev/null; then
    read -p "Create GitHub release? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        gh release create "$NEW_VERSION" \
            --title "Release $NEW_VERSION" \
            --notes-file RELEASE_NOTES.md
        echo "✅ GitHub release created"
    fi
else
    echo "⚠️  GitHub CLI not installed. Create release manually."
fi

# Summary
echo ""
echo "=========================================="
echo "✅ Release $NEW_VERSION Complete!"
echo "=========================================="
echo ""
echo "Summary:"
echo "  - Previous version: $LAST_TAG"
echo "  - New version: $NEW_VERSION"
echo "  - Release type: $RELEASE_TYPE"
echo "  - Release notes: RELEASE_NOTES.md"
echo ""
echo "Next steps:"
echo "  1. Verify the release on GitHub"
echo "  2. Notify the team"
echo "  3. Deploy to production"
