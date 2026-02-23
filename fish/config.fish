if status is-interactive
    # Commands to run in interactive sessions can go here
end

# ── Platform Detection ──────────────────────────────────────
switch (uname)
    case Darwin
        # macOS: Homebrew
        fish_add_path /opt/homebrew/bin
        fish_add_path /opt/homebrew/sbin
        
        # macOS: SSH key (quiet mode)
        ssh-add -q ~/.ssh/id_ed25519_github 2>/dev/null
        
    case Linux
        # Linux: Standard paths
        fish_add_path /usr/local/sbin
        fish_add_path /usr/local/bin
        fish_add_path /usr/bin
        
        # Linux: SSH key
        ssh-add ~/.ssh/id_ed25519 2>/dev/null
        
        # Linux: Sync bash PATH to fish (for .bashrc compatibility)
        set -gx PATH (bash -l -c 'echo $PATH' | tr ':' '\n')
        
        # Linux: Omarchy
        fish_add_path ~/.local/share/omarchy/bin
        
        # Linux: opam (OCaml)
        test -r "$HOME/.opam/opam-init/init.fish" && source "$HOME/.opam/opam-init/init.fish" >/dev/null 2>/dev/null; or true
end

# ── Cross-Platform Paths ────────────────────────────────────
fish_add_path $HOME/.opencode/bin
fish_add_path $HOME/.sst/bin

# Bun
set --export BUN_INSTALL "$HOME/.bun"
fish_add_path $BUN_INSTALL/bin

# ── Source Scripts ──────────────────────────────────────────
# Source all scripts in ~/.config/fish/scripts/
for script in ~/.config/fish/scripts/*.fish
    source $script
end

# Source secrets if exists
test -f ~/.config/fish/secrets.fish && source ~/.config/fish/secrets.fish

# ── Abbreviations: General ──────────────────────────────────
abbr c "code ."
abbr z "zed ."
abbr o "opencode"
abbr cl "clear"
abbr b "cd ../"
abbr bb "cd ../../"
abbr mkdir "mkdir -p"

# ── Abbreviations: Git ──────────────────────────────────────
abbr gpu "git push origin (git branch --show-current)"
abbr gpl "git pull origin (git branch --show-current)"
abbr gs "git status"
abbr gc "git branch | fzf --preview 'git show --color=always {-1}' | cut -c 3- | xargs git checkout"
abbr gr "git branch -r | grep -v HEAD | sed 's/origin\\///' | fzf --preview 'git show --color=always origin/{}' | xargs git checkout"
abbr gcb "git checkout -b"
abbr gd "git branch | fzf --multi --preview 'git log --oneline --color=always {-1}' | cut -c 3- | xargs -r git branch -D"
abbr gcpw "git add . && git commit -m 'wip' && git push origin (git branch --show-current)"
abbr gf "git fetch"
abbr gcl "git checkout -- . && git clean -fd"

# Platform-specific: open URL
switch (uname)
    case Darwin
        abbr gho "git remote get-url origin | xargs open"
    case Linux
        abbr gho "git remote get-url origin | xargs xdg-open"
end

function gcp
    git add . && git commit -m "$argv" && git push origin (git branch --show-current)
end

function gcm
    git add . && git commit -m "$argv"
end

# ── Abbreviations: Graphite ─────────────────────────────────
abbr gtm "git add . && gt modify -m''"
abbr gtc "git add . && gt create -m''"

# ── Abbreviations: Fish Config ──────────────────────────────
abbr fishc "code ~/.config/fish/config.fish"
abbr fishs "source ~/.config/fish/config.fish && echo 'Fish config reloaded'"

# ── Abbreviations: Dev Tools ────────────────────────────────
abbr scripts "cat package.json | jq '.scripts'"
abbr secret "openssl rand -base64 32"
abbr bd "bun dev"
abbr dcu "docker compose up"
abbr k "kill (lsof -ti:4983,3000,5173)"
abbr claude "claude --dangerously-skip-permissions"

# ── Abbreviations: Linux-only (Hyprland) ────────────────────
if test (uname) = "Linux"
    abbr hwr "systemctl --user restart hyprwhspr"
end

# ── Shell Integrations ──────────────────────────────────────
starship init fish | source
zoxide init --cmd cd fish | source
