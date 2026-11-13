# Recipes for canonical/snap-openstack (cloned to git/snap-openstack).
# They mirror the upstream CI: tox pep8/mypy/unit for sunbeam-python,
# make check for the Go sunbeam-microcluster.

so_dir := "git/snap-openstack"
so_py  := so_dir + "/sunbeam-python"
tox    := "uvx --with tox-uv tox"
# Run inside the Ubuntu 24.04 workshop (same OS as upstream CI; host toolchains may differ)
in_ws  := "workshop exec dev -- bash -lc"

# Install build tools in the workshop (idempotent; gcc for netifaces, dqlite PPA for the Go daemon, as upstream CI does)
so-prepare: so-clone setup-workshop
    workshop exec dev -- bash -lc 'command -v gcc >/dev/null && command -v make >/dev/null || sudo apt-get install -y -qq build-essential python3-dev libffi-dev libssl-dev pkg-config >/dev/null'
    workshop exec dev -- bash -lc 'dpkg -s libdqlite1.17-dev >/dev/null 2>&1 || { sudo add-apt-repository -y ppa:dqlite/dev >/dev/null && sudo apt-get install -y -qq libdqlite1.17-dev >/dev/null; }'

# Clone (or fast-forward) canonical/snap-openstack into git/
so-clone:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p git
    if [ -d {{so_dir}}/.git ]; then
        git -C {{so_dir}} pull --ff-only && echo "✓ updated {{so_dir}}"
    else
        git clone https://github.com/canonical/snap-openstack {{so_dir}}
    fi

# Lint + format check (ruff), same as CI pep8
so-lint: so-prepare
    {{in_ws}} 'cd {{so_py}} && {{tox}} -e pep8'

# Type check (mypy)
so-types: so-prepare
    {{in_ws}} 'cd {{so_py}} && {{tox}} -e mypy'

# Python unit tests; pass pytest args, e.g. just so-unit tests/unit/sunbeam/test_utils.py
so-unit *args: so-prepare
    {{in_ws}} 'cd {{so_py}} && {{tox}} -e unit -- {{args}}'

# Go unit + static checks for sunbeam-microcluster
so-go: so-prepare
    {{in_ws}} 'cd {{so_dir}}/sunbeam-microcluster && make check'

# Everything CI runs that is cheap enough locally
so-check: so-lint so-types so-unit so-go

# Parse every YAML under manifests/ and .github/workflows (catches syntax errors)
so-validate-yaml: so-clone
    #!/usr/bin/env bash
    set -euo pipefail
    cd {{so_dir}}
    uvx --with pyyaml python - <<'PY'
    import glob, sys, yaml
    bad = 0
    for f in glob.glob("manifests/**/*.y*ml", recursive=True) + glob.glob(".github/workflows/*.y*ml"):
        try:
            yaml.safe_load(open(f))
        except Exception as e:
            print("INVALID", f, e); bad += 1
    print("✓ all YAML valid" if not bad else f"✗ {bad} invalid")
    sys.exit(bad)
    PY

# Summarise the current branch vs main for review (feeds the so-pr-review skill)
so-diff base="origin/main": so-clone
    git -C {{so_dir}} diff --stat {{base}}...HEAD
    git -C {{so_dir}} log --oneline {{base}}..HEAD

# Commit signature + Signed-off-by report. Local git cannot verify ssh signatures
# without gpg.ssh.allowedSignersFile, so "N"/"E" is not proof of unsigned: upstream CI
# (1Password/check-signed-commits-action) verifies via GitHub. Trailer check is exact.
so-signed base="origin/main": so-clone
    #!/usr/bin/env bash
    set -uo pipefail
    cd {{so_dir}}
    printf '%-9s %-4s %-10s %s\n' COMMIT SIG SIGNED-OFF SUBJECT
    for c in $(git rev-list --reverse {{base}}..HEAD); do
        sig=$(git log -1 --format=%G? "$c" 2>/dev/null || echo ?)
        if git log -1 --format=%B "$c" | grep -q '^Signed-off-by: '; then so=yes; else so=NO; fi
        printf '%-9s %-4s %-10s %s\n' "$(git rev-parse --short "$c")" "${sig:-?}" "$so" "$(git log -1 --format=%s "$c")"
    done
    echo "(SIG: G=good N=none/unverifiable locally; confirm signatures on the PR page)"
