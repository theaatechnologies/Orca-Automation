# Setup

Host requirements and the setup flow. [← README](../README.md)

## Requirements

| Needed for | Install |
|---|---|
| Everything | [Orca](https://github.com/stablyai/orca) running, `sudo apt install -y just git jq` |
| Automations and `just agent` | opencode with a model provider: `INSTALL=1 just setup-opencode` |
| `just so-*`, `just test` (optional) | `sudo snap install --classic workshop`, `sudo snap install lxd --channel=6/stable`, `sudo usermod -aG lxd $USER` |

Install `just` from apt, not snap. `just doctor` verifies all of it, read-only.

## Flow

1. `INSTALL=1 just setup-opencode`: installs opencode from opencode.ai if missing (this runs the vendor installer; read it first if that matters to you), then runs `opencode providers login`.
2. `just setup`: creates `config/config.json`, checks opencode, links skills, registers automations. Idempotent, no containers, no sudo.
3. Set `target_repo` in `config/config.json` (`owner/repo`), then `just target-clone`.
4. `ENABLE=1 just automations-install` turns schedules on; they are created disabled.

## Keeping current

`just check-upgrade` is read-only and records `.state/upgrade-available.json`. `just upgrade` fast-forwards, re-links skills, re-registers automations and runs `just check`; it asks first.

## Teardown

`just cleanup` removes the workshop container. Remove automations with `orca automations remove <id>`.
