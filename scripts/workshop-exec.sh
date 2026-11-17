#!/bin/bash
# Run an agent command inside the workshop container
# Usage: ./scripts/workshop-exec.sh [command]
#
# Example: ./scripts/workshop-exec.sh "opencode 'Run daily standup'"

set -euo pipefail

WORKSHOP_NAME="automation"

# Check workshop exists (info returns 0 if workshop exists, even if off)
if ! workshop info "$WORKSHOP_NAME" >/dev/null 2>&1; then
    echo "✗ Workshop '$WORKSHOP_NAME' doesn't exist. Create it with: just launch-workshop" >&2
    exit 1
fi

# Check if running
status=$(workshop info "$WORKSHOP_NAME" 2>/dev/null | awk '/^status:/{print $2}' || echo "Off")
if [ "$status" != "ready" ] && [ "$status" != "Ready" ]; then
    echo "✗ Workshop '$WORKSHOP_NAME' is $status. Start it with: workshop start $WORKSHOP_NAME" >&2
    exit 1
fi

# Execute inside workshop with proper environment
workshop exec "$WORKSHOP_NAME" -- bash -lc "
    cd /project
    export PATH=\$HOME/.local/bin:\$PATH
    $*
"
