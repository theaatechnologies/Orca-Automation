#!/usr/bin/env python3
"""Validate skills/*/SKILL.md: opencode silently drops skills with bad frontmatter."""
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else pathlib.Path(__file__).resolve().parent.parent
skills = sorted((root / "skills").glob("*/SKILL.md"))
errors = []


def frontmatter(text):
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not m:
        return None
    data, key = {}, None
    for line in m.group(1).split("\n"):
        top = re.match(r"^([A-Za-z_-]+):\s*(.*)$", line)
        if top:
            key = top.group(1)
            data[key] = top.group(2).strip()
        elif key == "metadata" and re.match(r"^\s+\S", line):
            data.setdefault("metadata_lines", []).append(line.strip())
    return data


names = set()
for path in skills:
    d = path.parent.name
    fm = frontmatter(path.read_text())
    where = f"skills/{d}/SKILL.md"
    if fm is None:
        errors.append(f"{where}: missing frontmatter")
        continue
    name = fm.get("name", "")
    if name != d:
        errors.append(f"{where}: name '{name}' must equal directory '{d}'")
    if not re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", name) or len(name) > 64:
        errors.append(f"{where}: name must be lowercase-hyphen, max 64 chars")
    if name in names:
        errors.append(f"{where}: duplicate name '{name}'")
    names.add(name)
    desc = fm.get("description", "")
    if len(desc) < 30 or len(desc) > 1024:
        errors.append(f"{where}: description must be 30-1024 chars (is {len(desc)})")
    if not re.search(r"\buse\b", desc, re.I):
        errors.append(f"{where}: description must say when to use the skill ('Use when ...')")
    if not fm.get("license"):
        errors.append(f"{where}: missing license")
    if not any(l.startswith("version:") for l in fm.get("metadata_lines", [])):
        errors.append(f"{where}: missing metadata.version")
    body = path.read_text().split("---\n", 2)[-1]
    if len(body.strip()) < 80:
        errors.append(f"{where}: body is empty or trivial")

if not skills:
    errors.append("no skills found")
for e in errors:
    print(f"ERROR {e}", file=sys.stderr)
if errors:
    sys.exit(1)
print(f"OK: {len(skills)} skills valid")
