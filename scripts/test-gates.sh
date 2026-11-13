#!/usr/bin/env bash
# Negative tests: every gate must reject deliberately bad input.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
fail=0

expect_fail() { # name, command...
    local name="$1"; shift
    if "$@" >/dev/null 2>&1; then echo "✗ $name: gate accepted bad input"; fail=1
    else echo "✓ $name rejected"; fi
}
expect_pass() {
    local name="$1"; shift
    if "$@" >/dev/null 2>&1; then echo "✓ $name accepted"
    else echo "✗ $name: gate rejected good input"; fail=1; fi
}

mkdir -p "$tmp/skills/bad" "$tmp/skills/good" "$tmp/automations"
printf -- '---\nname: wrong\ndescription: short\n---\nx\n' > "$tmp/skills/bad/SKILL.md"
printf -- '---\nname: good\ndescription: A valid skill description. Use when testing the gate itself.\nlicense: Apache-2.0\nmetadata:\n  version: "1.0.0"\n---\n%s\n' "$(printf 'body %.0s' {1..30})" > "$tmp/skills/good/SKILL.md"
expect_fail "skills: bad frontmatter" python3 "$here/check-skills.py" "$tmp"
rm -rf "$tmp/skills/bad"
expect_pass "skills: good skill" python3 "$here/check-skills.py" "$tmp"

echo '{"name":"x","trigger":"weekly","day":1,"time":"10:00","provider":"opencode","prompt":"Write reports/x.md"}' > "$tmp/automations/noguard.json"
expect_fail "automations: prompt without guard" python3 "$here/check-automations.py" "$tmp"
echo '{"name":"x","trigger":"weekly","day":1,"time":"10:00","provider":"claude","prompt":"Do not push. Write reports/x.md"}' > "$tmp/automations/noguard.json"
expect_fail "automations: provider not allowed" python3 "$here/check-automations.py" "$tmp"
echo '{"name":"x","trigger":"weekly","day":1,"time":"10:00","provider":"opencode","prompt":"Do not push. Write reports/x.md"}' > "$tmp/automations/noguard.json"
expect_pass "automations: good" python3 "$here/check-automations.py" "$tmp"

mkdir -p "$tmp/leak"
printf 'token=%s\n' "gh""p_$(printf 'a%.0s' {1..36})" > "$tmp/leak/notes.txt"
expect_fail "secrets: GitHub token" python3 "$here/check-secrets.py" "$tmp/leak"
rm "$tmp/leak/notes.txt"; : > "$tmp/leak/.env"
expect_fail "secrets: .env file" python3 "$here/check-secrets.py" "$tmp/leak"
rm "$tmp/leak/.env"; echo hello > "$tmp/leak/ok.txt"
expect_pass "secrets: clean tree" python3 "$here/check-secrets.py" "$tmp/leak"

expect_fail "safe-arg: shell metacharacters" python3 "$here/safe-arg.py" args "x'; id; echo '"
expect_fail "safe-arg: option-looking ref" python3 "$here/safe-arg.py" ref "--output=/tmp/x"
expect_fail "safe-arg: repo with option" python3 "$here/safe-arg.py" repo "a/b --upload-pack=x"
expect_pass "safe-arg: normal pytest args" python3 "$here/safe-arg.py" args "tests/unit/test_x.py -k name"

[ "$fail" -eq 0 ] && echo "OK: all gates reject bad input and accept good input"
exit "$fail"
