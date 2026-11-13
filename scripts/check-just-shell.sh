#!/usr/bin/env bash
# Lint every shell recipe body in the Justfile and just/*.just.
#
# Recipe bodies are invisible to shellcheck: they sit indented inside a Justfile with
# {{...}} interpolations that are not shell. This extracts each shebang body to a real
# script and runs shellcheck over it. It also rejects an apostrophe inside the
# single-quoted `workshop exec ... bash -lc '...'` payloads, which closes the payload
# early and truncates the command that reaches the container.
#
# Without shellcheck on PATH the gate re-runs itself in the workshop container.

set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v shellcheck >/dev/null 2>&1; then
    if [ "${CHECK_IN_WORKSHOP:-0}" = 1 ] || ! command -v workshop >/dev/null 2>&1; then
        echo "shellcheck is required (sudo apt install -y shellcheck)" >&2
        exit 1
    fi
    exec workshop exec dev -- bash -lc \
        "command -v shellcheck >/dev/null || sudo apt-get install -y -qq shellcheck >/dev/null; CHECK_IN_WORKSHOP=1 ./scripts/$(basename "${BASH_SOURCE[0]}")"
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

python3 - "$project_dir" "$work" << 'PYEOF'
import glob
import os
import re
import sys

project_dir, work = sys.argv[1], sys.argv[2]
sources = [os.path.join(project_dir, "Justfile")] + sorted(glob.glob(os.path.join(project_dir, "just", "*.just")))

count = 0
for path in sources:
    lines = open(path, encoding="utf-8").read().split("\n")
    i = 0
    while i < len(lines):
        match = re.match(r"^([a-z0-9_-]+)(\s+[^:]*)?:(?!=)", lines[i])
        if match and i + 1 < len(lines) and lines[i + 1].strip().startswith("#!"):
            name, shebang = match.group(1), lines[i + 1].strip()
            i += 2
            body = []
            while i < len(lines) and (lines[i].startswith("    ") or lines[i].strip() == ""):
                body.append(lines[i][4:] if lines[i].startswith("    ") else "")
                i += 1
            if "python" in shebang:
                continue
            text = re.sub(r"\{\{.*?\}\}", "JUSTVAR", "\n".join(body).rstrip())
            stem = os.path.basename(path).replace(".", "_")
            with open(os.path.join(work, f"{stem}__{name}.sh"), "w") as handle:
                handle.write(shebang + "\n" + text + "\n")
            count += 1
        else:
            i += 1
print(f"extracted {count} recipe bodies")
PYEOF

failed=0
for script in "$work"/*.sh; do
    if ! output="$(shellcheck -s bash -f gcc "$script" 2>&1)" || [ -n "$output" ]; then
        echo "== $(basename "$script" .sh)"
        echo "$output"
        failed=1
    fi
done

for script in "$project_dir"/scripts/*.sh; do
    if ! output="$(shellcheck -s bash -f gcc "$script" 2>&1)" || [ -n "$output" ]; then
        echo "== scripts/$(basename "$script")"
        echo "$output"
        failed=1
    fi
done

python3 - "$project_dir" << 'PYEOF' || failed=1
import glob
import os
import re
import sys

project_dir = sys.argv[1]
sources = [os.path.join(project_dir, "Justfile")] + sorted(glob.glob(os.path.join(project_dir, "just", "*.just")))
payload = re.compile(r"\{\{in_ws\}\}\s+'(.*)'\s*$")
bad = 0
for src in sources:
    for n, line in enumerate(open(src).read().split("\n"), 1):
        if "{{in_ws}}" not in line:
            continue
        m = payload.search(line)
        if not m or "'" in m.group(1):
            print(f"{os.path.relpath(src, project_dir)}:{n}: in_ws payload must be one single-quoted "
                  f"string without apostrophes")
            bad += 1
sys.exit(1 if bad else 0)
PYEOF

if [ "$failed" -ne 0 ]; then
    echo "shell gate found problems" >&2
    exit 1
fi
echo "OK: shellcheck clean over all recipe bodies and scripts"
