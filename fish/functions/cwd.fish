function cwd --description "Print the current working directory and copy it to the clipboard"
    set -l dir (pwd)

    printf "%s\n" $dir

    if command -q pbcopy
        printf "%s" $dir | pbcopy
    else if command -q wl-copy
        printf "%s" $dir | wl-copy
    else if command -q xclip
        printf "%s" $dir | xclip -selection clipboard
    else if command -q xsel
        printf "%s" $dir | xsel --clipboard --input
    else
        echo "cwd: no clipboard command found; install wl-clipboard, xclip, or xsel" >&2
        return 1
    end
end
