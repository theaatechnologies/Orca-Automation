# Orca Automation Workshop - single entrypoint for every workflow.
# Run `just` to list recipes. First time? Run `just setup`.

set shell := ["bash", "-euo", "pipefail", "-c"]

env_name := "dev"

import 'just/snap-openstack.just'

# List all recipes
help:
    @just --list

# Light setup, no containers: checks Orca, links skills, registers automations (disabled until you enable them)
setup: doctor config skills-install automations-install
    @echo ""
    @echo "✓ Setup complete. Try: just skills | just automations | just so-check | just agent"

# Check what the light setup needs (git, jq, Orca running)
doctor:
    #!/usr/bin/env bash
    fails=0
    for t in git jq orca opencode; do
        if command -v "$t" >/dev/null 2>&1; then echo "✓ $t"; else echo "✗ $t missing" >&2; fails=$((fails+1)); fi
    done
    if opencode providers list 2>/dev/null | grep -qE '[1-9][0-9]* credentials'; then echo "✓ opencode has a model provider"
    else echo "✗ opencode has no credentials: run 'opencode providers login'" >&2; fails=$((fails+1)); fi
    if orca status 2>/dev/null | grep -q 'runtimeReachable: true'; then echo "✓ Orca runtime reachable"
    else echo "✗ Orca is not running: open the Orca app" >&2; fails=$((fails+1)); fi
    [ "$fails" -eq 0 ] && echo "✓ ready" || { echo "✗ $fails problem(s)" >&2; exit 1; }

# Extra checks for the optional workshop container
doctor-workshop:
    #!/usr/bin/env bash
    fails=0
    command -v workshop >/dev/null 2>&1 && echo "✓ workshop" || { echo "✗ workshop: sudo snap install --classic workshop" >&2; fails=$((fails+1)); }
    command -v lxc >/dev/null 2>&1 && echo "✓ lxc" || { echo "✗ lxc: sudo snap install lxd --channel=6/stable" >&2; fails=$((fails+1)); }
    id -nG | tr ' ' '\n' | grep -qx lxd && echo "✓ lxd group" || { echo "✗ add yourself to lxd: sudo usermod -aG lxd $USER" >&2; fails=$((fails+1)); }
    [ "$fails" -eq 0 ] || exit 1

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

# Make skills/ visible to every agent (opencode, Claude, Codex read .agents/skills and .opencode/skills)
skills-install:
    #!/usr/bin/env bash
    set -euo pipefail
    for dir in .agents/skills .opencode/skills; do
        mkdir -p "$dir"
        for s in skills/*/; do ln -sfn "../../skills/$(basename "$s")" "$dir/$(basename "$s")"; done
    done
    echo "✓ linked $(ls -d skills/*/ | wc -l) skills into .agents/skills and .opencode/skills"

# Register the scheduled Orca automations in automations/ (created DISABLED; ENABLE=1 just automations-install to enable)
automations-install:
    #!/usr/bin/env bash
    set -euo pipefail
    existing="$(orca automations list --json 2>/dev/null || echo '[]')"
    for f in automations/*.json; do
        name=$(jq -r .name "$f")
        if echo "$existing" | jq -e --arg n "$name" '.. | objects | select(.name? == $n)' >/dev/null 2>&1; then
            echo "✓ exists: $name"; continue
        fi
        model=$(jq -r '.model // empty' "$f")
        args=(--name "$name" --trigger "$(jq -r .trigger "$f")" --time "$(jq -r .time "$f")" \
              --provider "$(jq -r .provider "$f")" --prompt "$(jq -r .prompt "$f")")
        day=$(jq -r '.day // empty' "$f"); [ -n "$day" ] && args+=(--day "$day")
        [ -n "$model" ] && args+=(--extra-agent-args="--model $model")
        [ "${ENABLE:-0}" = 1 ] && args+=(--enabled) || args+=(--disabled)
        orca automations create "${args[@]}" >/dev/null && echo "✓ created: $name"
    done

# List the registered automations
automations:
    orca automations list

# Optional: launch the isolated workshop container (so-* checks do this automatically)
setup-workshop: doctor-workshop
    #!/usr/bin/env bash
    set -euo pipefail
    status="$(workshop info {{env_name}} 2>/dev/null | awk '/^status:/{print $2}' || true)"
    case "$status" in
        ready|Ready) echo "✓ workshop '{{env_name}}' already running" ;;
        "")          workshop launch {{env_name}} --verbose ;;
        *)           workshop start {{env_name}} ;;
    esac

# Run tests inside the workshop: all | unit | integration
test kind="all": setup-workshop
    workshop exec {{env_name}} -- ./scripts/run-tests.sh {{kind}}

# Interactive shell inside the workshop
shell:
    workshop shell {{env_name}}

# Start the opencode agent in this project (it sees skills/ and runs `just so-*` in the workshop)
agent:
    opencode

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
