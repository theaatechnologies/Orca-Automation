#!/usr/bin/env python3
"""Validate automations/*.json: schema, provider allow-list and a read-only guard in every prompt."""
import json
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else pathlib.Path(__file__).resolve().parent.parent
PRESETS = {"hourly", "daily", "weekdays", "weekly"}
PROVIDERS = {"opencode"}
GUARD = re.compile(r"\b(do not|don't|never|read-only|report only|draft only)\b", re.I)
KNOWN = {"name", "trigger", "time", "day", "provider", "prompt", "model"}
errors, names = [], set()
files = sorted((root / "automations").glob("*.json"))

for path in files:
    where = f"automations/{path.name}"
    try:
        a = json.loads(path.read_text())
    except ValueError as exc:
        errors.append(f"{where}: invalid JSON ({exc})")
        continue
    for key in ("name", "trigger", "provider", "prompt"):
        if not a.get(key):
            errors.append(f"{where}: missing '{key}'")
    for key in a:
        if key not in KNOWN:
            errors.append(f"{where}: unknown field '{key}'")
    if a.get("name") in names:
        errors.append(f"{where}: duplicate name")
    names.add(a.get("name"))
    trig = str(a.get("trigger", ""))
    if trig not in PRESETS and len(trig.split()) != 5:
        errors.append(f"{where}: trigger must be one of {sorted(PRESETS)} or a 5-field cron")
    if trig in {"daily", "weekdays", "weekly"} and not re.fullmatch(r"([01]\d|2[0-3]):[0-5]\d", str(a.get("time", ""))):
        errors.append(f"{where}: '{trig}' needs time HH:MM")
    if trig == "weekly" and a.get("day") not in range(7):
        errors.append(f"{where}: weekly needs day 0-6 (Sunday=0)")
    if a.get("provider") not in PROVIDERS:
        errors.append(f"{where}: provider must be one of {sorted(PROVIDERS)}")
    prompt = str(a.get("prompt", ""))
    if not GUARD.search(prompt):
        errors.append(f"{where}: prompt needs an explicit guard (do not commit/push, read-only, report only ...)")
    if "reports/" not in prompt and "reviews/" not in prompt:
        errors.append(f"{where}: prompt must name an output file under reports/ or reviews/")

if not files:
    errors.append("no automations found")
for e in errors:
    print(f"ERROR {e}", file=sys.stderr)
if errors:
    sys.exit(1)
print(f"OK: {len(files)} automations valid")
