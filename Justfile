# Orca Automation Workshop - single entrypoint for every workflow.
# Run `just` to list recipes. First time? Run `just setup`.

set shell := ["bash", "-euo", "pipefail", "-c"]

env_name := "dev"

import 'just/snap-openstack.just'

# List all recipes
help:
    @just --list

# One-command setup: checks host, creates local config, launches the workshop
setup: doctor config
    #!/usr/bin/env bash
    set -euo pipefail
    status="$(workshop info {{env_name}} 2>/dev/null | awk '/^status:/{print $2}' || true)"
    case "$status" in
        ready|Ready) echo "✓ workshop '{{env_name}}' already running" ;;
        "")          echo "Launching workshop '{{env_name}}'..."; workshop launch {{env_name}} --verbose ;;
        *)           echo "Starting workshop '{{env_name}}' ($status)..."; workshop start {{env_name}} ;;
    esac
    echo ""
    echo "✓ Setup complete. Try: just test | just shell | just agent"

# Read-only check of host prerequisites
doctor:
    #!/usr/bin/env bash
    fails=0
    check() { # name, fix
        if command -v "$1" >/dev/null 2>&1; then printf '✓ %s\n' "$1"
        else printf '✗ %s missing  fix: %s\n' "$1" "$2" >&2; fails=$((fails+1)); fi
    }
    check git      "sudo apt install -y git"
    check jq       "sudo apt install -y jq"
    check workshop "sudo snap install --classic workshop"
    check lxc      "sudo snap install lxd --channel=6/stable"
    if command -v lxc >/dev/null 2>&1; then
        if id -nG | tr ' ' '\n' | grep -qx lxd; then echo "✓ user in lxd group"
        else echo "✗ not in lxd group  fix: sudo usermod -aG lxd $USER (then re-login)" >&2; fails=$((fails+1)); fi
    fi
    [ -f orca.yaml ] && echo "✓ orca.yaml" || { echo "✗ orca.yaml missing" >&2; fails=$((fails+1)); }
    [ "$fails" -eq 0 ] && echo "✓ host ready" || { echo "✗ $fails problem(s) above" >&2; exit 1; }

# Create gitignored local config from the example (idempotent)
config:
    #!/usr/bin/env bash
    mkdir -p config
    if [ ! -f config/config.json ]; then
        cp config/example/config.json config/config.json
        echo "✓ created config/config.json (edit it, it is gitignored)"
    else
        echo "✓ config/config.json exists"
    fi

# Run tests inside the workshop: all | unit | integration
test kind="all":
    workshop exec {{env_name}} -- ./scripts/run-tests.sh {{kind}}

# Interactive shell inside the workshop
shell:
    workshop shell {{env_name}}

# Start the AI agent inside the workshop
agent:
    workshop exec -i {{env_name}} -- opencode

# Generate AI release notes (optional: since tag)
release-notes since="":
    ./scripts/generate-release-notes.sh {{since}}

# Weekly release: patch | minor | major
release type="patch":
    ./scripts/weekly-release.sh {{type}}

# List available agent skills
skills:
    @for d in skills/*/; do printf '%-24s %s\n' "$(basename "$d")" "$(sed -n 's/^description: *//p' "$d/SKILL.md" | head -1)"; done

# Tear down the workshop (keeps your files)
cleanup:
    -workshop remove {{env_name}}
