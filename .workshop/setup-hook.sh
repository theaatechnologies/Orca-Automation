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

# Clone target repo INSIDE workshop (not mounted)
echo "==> Cloning target repo inside workshop"
target_repo=$(jq -r '.target_repo // "canonical/snap-openstack"' config/config.json 2>/dev/null || echo "canonical/snap-openstack")
repo_name="${target_repo##*/}"
repo_dir="/project/repos/$repo_name"

mkdir -p /project/repos
if [ -d "$repo_dir/.git" ]; then
    echo "✓ Target repo already cloned at $repo_dir"
    (cd "$repo_dir" && git pull -q && echo "✓ Updated to latest")
else
    git clone -q "https://github.com/$target_repo" "$repo_dir"
    echo "✓ Cloned $target_repo to $repo_dir"
fi

# Create reports directory
mkdir -p /project/reports

echo ""
echo "========================================"
echo "Workshop automation environment ready!"
echo "========================================"
echo ""
echo "Skills: $skill_count linked"
echo "Target repo: $repo_dir"
echo "Reports: /project/reports/"
echo ""
echo "Next steps (ON YOUR HOST MACHINE):"
echo "  1. Register automations: just automations-install"
echo "  2. Enable them: ENABLE=1 just automations-install"
echo ""
echo "Automations will run via: workshop exec automation -- opencode ..."
echo "Everything is isolated and reproducible."
echo ""
