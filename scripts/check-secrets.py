#!/usr/bin/env python3
"""Fail on committed secrets: known token formats, private keys, forbidden file names."""
import pathlib
import re
import subprocess
import sys

root = pathlib.Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else pathlib.Path(__file__).resolve().parent.parent
PATTERNS = {
    "GitHub token": r"\b(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{30,}\b",
    "GitHub fine-grained token": r"\bgithub_pat_[A-Za-z0-9_]{40,}\b",
    "AWS access key": r"\bAKIA[0-9A-Z]{16}\b",
    "Slack token": r"\bxox[baprs]-[A-Za-z0-9-]{10,}\b",
    "OpenAI/OpenRouter style key": r"\bsk-(or-v1-)?[A-Za-z0-9]{32,}\b",
    "Private key": r"-----BEGIN (RSA |EC |OPENSSH |DSA |PGP )?PRIVATE KEY( BLOCK)?-----",
    "Credentialed URL": r"https?://[^/\s:@]+:[^/\s@]{6,}@",
}
FORBIDDEN_NAMES = [r"(^|/)\.env(\..*)?$", r"\.pem$", r"(^|/)id_(rsa|ed25519)$", r"\.git-credentials$",
                   r"(^|/)auth\.json$", r"^config/config\.json$"]
SKIP_DIRS = {".git", "node_modules", "git", ".tox", "coverage", "test-results"}


def candidates():
    if (root / ".git").exists():
        out = subprocess.run(["git", "-C", str(root), "ls-files", "-co", "--exclude-standard", "-z"],
                             capture_output=True, check=True).stdout.decode().split("\0")
        return [p for p in out if p]
    return [str(p.relative_to(root)) for p in root.rglob("*")
            if p.is_file() and not (set(p.relative_to(root).parts) & SKIP_DIRS)]


errors = []
for rel in candidates():
    if rel.startswith("scripts/check-secrets.py") or rel.startswith("scripts/test-gates"):
        continue
    for pat in FORBIDDEN_NAMES:
        if re.search(pat, rel):
            errors.append(f"{rel}: forbidden file must not be committed")
    path = root / rel
    if not path.is_file() or path.stat().st_size > 2_000_000:
        continue
    try:
        text = path.read_text(errors="ignore")
    except OSError:
        continue
    for label, pat in PATTERNS.items():
        for m in re.finditer(pat, text):
            line = text.count("\n", 0, m.start()) + 1
            errors.append(f"{rel}:{line}: looks like a {label}")

for e in errors:
    print(f"ERROR {e}", file=sys.stderr)
if errors:
    sys.exit(1)
print("OK: no secrets found")
