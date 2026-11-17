#!/bin/bash
set -euo pipefail

echo "==> Installing just"
if ! command -v just >/dev/null 2>&1; then
    mkdir -p ~/.local/bin
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin
    export PATH="$HOME/.local/bin:$PATH"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

cd /project

echo "==> Running workshop setup"

# Create config if it doesn't exist
if [ ! -f config/config.json ]; then
    mkdir -p config
    cp config/example/config.json config/config.json
    echo "✓ Created config/config.json"
fi

# Link skills 
for dir in .agents/skills .opencode/skills; do
    mkdir -p "$dir"
    for s in skills/*/; do 
        [ -d "$s" ] || continue
        skillname=$(basename "$s")
        ln -sfn "../../skills/$skillname" "$dir/$skillname"
    done
done
skill_count=$(find skills -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
echo "✓ Linked $skill_count skills into .agents/skills and .opencode/skills"

# Clone BOTH target repos inside workshop
echo "==> Cloning target repos inside workshop"

mkdir -p /project/repos

# Repo 1: snap-openstack (GitHub)
if [ -d "/project/repos/snap-openstack/.git" ]; then
    echo "✓ snap-openstack already cloned"
    (cd /project/repos/snap-openstack && git pull -q && echo "✓ Updated to latest")
else
    git clone -q "https://github.com/canonical/snap-openstack" "/project/repos/snap-openstack"
    echo "✓ Cloned snap-openstack"
fi

# Repo 2: sunbeam-charms (OpenDev)
if [ -d "/project/repos/sunbeam-charms/.git" ]; then
    echo "✓ sunbeam-charms already cloned"
    (cd /project/repos/sunbeam-charms && git pull -q && echo "✓ Updated to latest")
else
    git clone -q "https://opendev.org/openstack/sunbeam-charms" "/project/repos/sunbeam-charms"
    echo "✓ Cloned sunbeam-charms"
fi

# Create reports directory
mkdir -p /project/reports

echo ""
echo "========================================"
echo "Workshop automation environment ready!"
echo "========================================"
echo ""
echo "Skills: $skill_count linked"
echo "Repos:"
echo "  - /project/repos/snap-openstack"
echo "  - /project/repos/sunbeam-charms"
echo "Reports: /project/reports/"
echo ""
echo "Next steps (ON YOUR HOST MACHINE):"
echo "  1. Register automations: just automations-install"
echo "  2. Enable them: ENABLE=1 just automations-install"
echo ""
echo "All automations run INSIDE this workshop container."
echo "Everything is isolated and reproducible."
echo ""
