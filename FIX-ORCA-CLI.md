# Fixed: Orca CLI breaking change

## Problem (reported by teammate)
`orca automations create` now requires `--repo`, `--workspace`, or `--project` flag.
The old `automations-install` recipe didn't provide any of these, so all 9 automations failed with:
```
Automation requires --repo or --workspace.
```

## Root cause
- Orca CLI changed to require explicit repo targeting
- Old recipe built args with only `--name/--trigger/--time/--provider/--prompt`
- Loop continued on failure (`&& echo "✓ created"` swallowed errors)

## Fix applied
1. **Read target repo from config**: extracts `target_repo` from `config/config.json`
2. **Validate with safe-arg.py**: ensures it looks like `owner/repo`
3. **Check repo is cloned**: fails fast if `git/<repo>` doesn't exist
4. **Pass absolute path**: `--repo "path:/full/path/to/git/snap-openstack"`
5. **Fail loudly**: `exit 1` on create failure instead of continuing

## Updated recipes
- **`automations-install`**: now requires `just target-clone` first, uses `--repo path:<abs_path>`
- **`target-clone`**: registers repo with `orca repo add --path` automatically
- **`setup`**: now includes `target-clone` in the dependency chain

## New flow for users
```bash
just setup  # now automatically runs target-clone and registers with Orca
# Automations created with --repo path:/home/.../git/snap-openstack
```

Or manually:
```bash
just config           # creates config/config.json
# edit config/config.json to set target_repo
just target-clone     # clones and registers with Orca
just automations-install  # now works with --repo
```

## Tested
- ✅ `just check` passes
- ✅ Recipe correctly extracts path and validates
- ✅ Exits immediately on first failure instead of looping through all 9

## For your teammate
Tell them to pull latest, then run:
```bash
just target-clone  # if they haven't already
just automations-install  # will now pass --repo correctly
```
