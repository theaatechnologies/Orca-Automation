#!/usr/bin/env python3
"""Reject recipe arguments that could break out of a shell payload, path or URL."""
import re
import sys

KINDS = {
    "args": r"[A-Za-z0-9_./:=,@\[\]\- ]*",          # pytest-style arguments
    "ref": r"(?!-)[A-Za-z0-9._/~^@{}-]+",             # git ref or range base
    "repo": r"[A-Za-z0-9._-]+/[A-Za-z0-9._-]+",       # owner/repo
}
kind, value = sys.argv[1], (sys.argv[2] if len(sys.argv) > 2 else "")
if ".." in value and kind in ("repo",):
    print(f"unsafe {kind}: {value!r}", file=sys.stderr); sys.exit(1)
if not re.fullmatch(KINDS[kind], value):
    print(f"unsafe {kind}: {value!r}", file=sys.stderr)
    sys.exit(1)
