# ~/.config

Dotfiles backup for syncing configuration across a macOS and a Linux machine.

## How the gitignore works

The `.gitignore` uses an **ignore-by-default** strategy. The very first rule is `*`, which ignores everything in `~/.config`. Individual config files and directories are then selectively un-ignored with `!` prefixes to opt them into version control.

This is the opposite of a typical `.gitignore` where you list things to exclude. Here, nothing is tracked unless explicitly whitelisted. This keeps the repo clean since `~/.config` is full of application state, caches, credentials, and other generated files that should never be committed.

### Pattern conventions

- `!dir/` un-ignores the directory itself (required for git to look inside it).
- `!dir/file` un-ignores a specific file within that directory.
- `!dir/**` un-ignores all contents recursively (used when the entire directory should be synced).
- Re-ignoring specific paths after a `!dir/**` rule (e.g. `fish/fish_variables`) excludes runtime state or secrets from an otherwise fully-tracked directory.
- Binary image extensions (`*.png`, `*.jpg`, etc.) are re-ignored at the bottom of the file to catch any images that slip through the whitelists.

### What gets synced

The tracked configs are organized into three groups:

**Cross-platform** -- shared between macOS and Linux:
- Terminal emulators: ghostty, alacritty, kitty
- Shell: fish (excluding `fish_variables`, `secrets.fish`, and `completions/`)
- Editors: nvim (excluding `plugin/` generated state), zed
- OpenCode: config, commands, providers, agents
- Git tooling: git config, global gitignore, gh, lazygit
- Dev tooling: mise, btop, fastfetch

**macOS-only:**
- omniwm, raycast, graphite (excluding auth in `user_config`)

**Linux-only** (omarchy / hyprland):
- hypr, omarchy, waybar, walker, mako

Configs that only exist on one platform are harmless on the other -- they just sit in the repo unused.
