# Quality and security gates. `just check` is what CI runs; run it before every push.

# All gates
check: check-secrets check-config check-skills check-automations check-shell

# No tokens, private keys or forbidden files in the tree
check-secrets:
    ./scripts/check-secrets.py

# JSON and YAML configuration parses
check-config:
    #!/usr/bin/env bash
    set -euo pipefail
    find config automations -name '*.json' -print0 | xargs -0 -n1 jq empty
    find . \( -path ./.git -o -path ./git -o -path ./node_modules \) -prune -o \( -name '*.yaml' -o -name '*.yml' \) -print0 \
        | xargs -0 -r -n1 python3 -c 'import sys, yaml; yaml.safe_load(open(sys.argv[1]))'
    [ ! -e config/dev.yaml ] || { echo "config/dev.yaml must not be committed (it can append root shell to the container setup); use config/dev.local.yaml" >&2; exit 1; }
    echo "OK: JSON and YAML valid"

# Skill frontmatter is valid (opencode silently drops bad skills)
check-skills:
    ./scripts/check-skills.py

# Automation schema, provider allow-list and read-only guards
check-automations:
    ./scripts/check-automations.py

# shellcheck over every recipe body and script (runs in the workshop if shellcheck is missing)
check-shell:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! command -v shellcheck >/dev/null 2>&1; then just setup-workshop; fi
    ./scripts/check-just-shell.sh

# Prove the gates fail on bad input (negative tests)
test-gates:
    ./scripts/test-gates.sh
