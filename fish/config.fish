if status is-interactive
    # Commands to run in interactive sessions can go here
end

fish_add_path /usr/local/sbin
fish_add_path /usr/local/bin
fish_add_path /usr/bin

# Abbreviations

# Source all scripts in ~/.config/fish/scripts/
for script in ~/.config/fish/scripts/*.fish
  source $script
end

# General
abbr c "code ."
abbr z "zed ."
abbr o "opencode"
abbr cl "clear"
abbr b "cd ../"
abbr bb "cd ../../"
abbr mkdir "mkdir -p"

# Git
abbr gpu "git push origin (git branch --show-current)"
abbr gpl "git pull origin (git branch --show-current)"
abbr gho "git remote get-url origin | xargs xdg-open"  # changed 'open' to 'xdg-open' for Linux
abbr gs "git status"
abbr gc "git branch | fzf --preview 'git show --color=always {-1}' | cut -c 3- | xargs git checkout"
abbr gr "git branch -r | grep -v HEAD | sed 's/origin\\///' | fzf --preview 'git show --color=always origin/{}' | xargs git checkout"
abbr gcb "git checkout -b"
abbr gd "git branch | fzf --multi --preview 'git log --oneline --color=always {-1}' | cut -c 3- | xargs -r git branch -D"
abbr gcpw "git add . && git commit -m 'wip' && git push origin (git branch --show-current)"
abbr gf "git fetch"
abbr gcl "git checkout -- . && git clean -fd"


function gcp
    git add . && git commit -m "$argv" && git push origin (git branch --show-current)
end

function gcm
    git add . && git commit -m "$argv"
end

# Graphite
abbr gtm "git add . && gt modify -m''"
abbr gtc "git add . && gt create -m''"

# Fish (replacing zsh ones)
abbr fishc "code ~/.config/fish/config.fish"
abbr fishs "source ~/.config/fish/config.fish && echo 'Fish config reloaded'"

# Other
abbr scripts "cat package.json | jq '.scripts'"
abbr secret "openssl rand -base64 32"
abbr bd "bun dev"
abbr dcu "docker compose up"
abbr k "kill (lsof -ti:4983,3000,5173)"
abbr claude "claude --dangerously-skip-permissions"

# hyrpland only
abbr hwr "systemctl --user restart hyprwhspr"

# Sync bash PATH to fish (using login shell to include .bashrc)
set -gx PATH (bash -l -c 'echo $PATH' | tr ':' '\n')

source ~/.config/fish/secrets.fish

starship init fish | source

zoxide init --cmd cd fish | source

# Add custom bin directories (after bash PATH sync to preserve them)
fish_add_path ~/.local/share/omarchy/bin
fish_add_path /home/aidan/.opencode/bin
fish_add_path /home/aidan/.sst/bin


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
test -r '/home/aidan/.opam/opam-init/init.fish' && source '/home/aidan/.opam/opam-init/init.fish' > /dev/null 2> /dev/null; or true
# END opam configuration

ssh-add ~/.ssh/id_ed25519
# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
