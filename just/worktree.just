# Isolated git worktrees for agent work: one branch per task under git/<repo>-worktrees/.

# Create an isolated git worktree for development
worktree repo name:
    #!/usr/bin/env bash
    set -euo pipefail
    repo={{quote(repo)}}
    name={{quote(name)}}
    if [[ "$repo" =~ [^a-zA-Z0-9._-] || "$repo" == *..* ]]; then
        echo "Error: invalid repo name '$repo'" >&2; exit 1
    fi
    if [[ "$name" =~ [^a-zA-Z0-9._/-] || "$name" == *..* || "$name" == -* ]]; then
        echo "Error: invalid worktree name '$name'" >&2; exit 1
    fi
    dir_name="${name//\//-}"
    repo_path="{{justfile_directory()}}/git/${repo}"
    wt_path="{{justfile_directory()}}/git/${repo}-worktrees/${dir_name}"
    [ -d "$repo_path/.git" ] || { echo "Error: repo not found at $repo_path (run: just target-clone)" >&2; exit 1; }
    if [ -d "$wt_path" ]; then
        echo "Worktree already exists at $wt_path (reusing branch $name)"
    else
        base_ref="$(git -C "$repo_path" symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null || git -C "$repo_path" rev-parse --verify HEAD)"
        mkdir -p "{{justfile_directory()}}/git/${repo}-worktrees"
        if git -C "$repo_path" show-ref --verify --quiet "refs/heads/$name"; then
            git -C "$repo_path" worktree add "$wt_path" "$name"
        else
            git -C "$repo_path" worktree add -b "$name" "$wt_path" "$base_ref"
        fi
        echo "✓ worktree created on branch $name"
    fi
    echo "Open it: opencode --agent dev ${wt_path}"

# List agent worktrees for a repo
worktree-list repo:
    #!/usr/bin/env bash
    set -euo pipefail
    repo={{quote(repo)}}
    if [[ "$repo" =~ [^a-zA-Z0-9._-] || "$repo" == *..* ]]; then echo "Error: invalid repo name" >&2; exit 1; fi
    repo_path="{{justfile_directory()}}/git/${repo}"
    [ -d "$repo_path/.git" ] || { echo "Error: repo not found at $repo_path" >&2; exit 1; }
    echo "Worktrees for ${repo}:"
    git -C "$repo_path" worktree list | grep -F "${repo}-worktrees" || echo "  (none)"

# Remove worktrees whose branch is merged into the default branch (never touches dirty or unmerged ones)
worktree-clean repo:
    #!/usr/bin/env bash
    set -euo pipefail
    repo={{quote(repo)}}
    if [[ "$repo" =~ [^a-zA-Z0-9._-] || "$repo" == *..* ]]; then echo "Error: invalid repo name" >&2; exit 1; fi
    repo_path="{{justfile_directory()}}/git/${repo}"
    [ -d "$repo_path/.git" ] || { echo "Error: repo not found at $repo_path" >&2; exit 1; }
    default_ref="$(git -C "$repo_path" symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null || echo HEAD)"
    removed=0
    while IFS= read -r wt; do
        [ -n "$wt" ] || continue
        branch="$(git -C "$wt" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
        if [ -n "$(git -C "$wt" status --porcelain 2>/dev/null)" ]; then
            echo "  Keeping: $wt (uncommitted changes)"; continue
        fi
        if git -C "$repo_path" merge-base --is-ancestor "$branch" "$default_ref" 2>/dev/null; then
            git -C "$repo_path" worktree remove "$wt"
            git -C "$repo_path" branch -d "$branch" >/dev/null 2>&1 || true
            echo "  Removed merged worktree: $wt ($branch)"; removed=$((removed + 1))
        else
            echo "  Keeping: $wt ($branch not merged)"
        fi
    done < <(git -C "$repo_path" worktree list --porcelain | awk '/^worktree /{print $2}' | grep -F "${repo}-worktrees" || true)
    git -C "$repo_path" worktree prune
    echo "Done. Removed $removed worktree(s)."
