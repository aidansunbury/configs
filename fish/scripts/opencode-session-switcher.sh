#!/bin/bash
#
# OpenCode Session Switcher with fzf
# Usage: ops

set -e

DB_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/opencode.db"

if ! command -v sqlite3 &> /dev/null || ! command -v fzf &> /dev/null || ! command -v opencode &> /dev/null; then
    echo "Error: requires sqlite3, fzf, and opencode"
    exit 1
fi

if [ ! -f "$DB_PATH" ]; then
    echo "Error: database not found at $DB_PATH"
    exit 1
fi

CURRENT_DIR=$(pwd)

# Function for relative time
rel_time() {
    local now=$(date +%s)
    local diff=$((now - $1))
    if [ $diff -lt 60 ]; then echo "just now"
    elif [ $diff -lt 3600 ]; then echo "$((diff/60))m"
    elif [ $diff -lt 86400 ]; then echo "$((diff/3600))h"
    elif [ $diff -lt 604800 ]; then echo "$((diff/86400))d"
    elif [ $diff -lt 2592000 ]; then echo "$((diff/604800))w"
    else echo "$((diff/2592000))mo"; fi
}

# Function to get last 2 directories
last_two_dirs() {
    local path="$1"
    path="${path/#$HOME/~}"
    path="${path%/}"
    local base=$(basename "$path")
    local parent=$(basename "$(dirname "$path")")
    if [ "$parent" = "." ] || [ "$parent" = "/" ]; then
        echo "$base"
    else
        echo "$parent/$base"
    fi
}

# Query sessions - no sorting, let fzf rank by relevance
TMP_FILE=$(mktemp)
trap "rm -f $TMP_FILE" EXIT

idx=0
sqlite3 "$DB_PATH" "
SELECT s.directory, s.title, s.id, s.time_updated / 1000
FROM session s
WHERE s.parent_id IS NULL AND s.time_archived IS NULL;
" | while IFS='|' read -r dir title id ts; do
    # Icon for current directory (visual only, not sorted)
    if [ "$dir" = "$CURRENT_DIR" ]; then icon="📍"; else icon="  "; fi
    
    # Get last 2 directories only
    short_dir=$(last_two_dirs "$dir")
    
    # Time (short format)
    time_str=$(rel_time "$ts")
    
    # Store: index|icon|time|dir|title|full_dir|id
    echo "$idx|$icon|$time_str|$short_dir|$title|$dir|$id" >> "$TMP_FILE"
    
    idx=$((idx + 1))
done

if [ ! -s "$TMP_FILE" ]; then
    echo "No sessions found."
    exit 0
fi

# Show intro
clear
echo "OpenCode Session Switcher"
echo "Type to search by directory or title"
echo "📍 = Current directory"
echo ""

# Format with wrapping-friendly layout: Time | Dir | Title
# Let fzf handle ranking naturally (no --tac, no --no-sort)
selection=$(cat "$TMP_FILE" | while IFS='|' read -r idx icon time dir title full_dir id; do
    # Format: icon + time (8) + 2 spaces + dir (25) + 2 spaces + full title
    line=$(printf "%s%-8s  %-25s  %s" "$icon" "$time" "$dir" "$title")
    
    # Output with hidden data
    printf "%s|%s|%s|%s|%s\n" "$line" "$idx" "$full_dir" "$id" "$title"
done | \
    fzf --prompt="Search: " \
        --header="Updated   Directory                   Session Name" \
        --header-first \
        --delimiter='|' \
        --with-nth=1 \
        --nth=1 \
        --wrap \
        --height='95%' \
        --layout=reverse \
        --border=rounded \
        --info=inline)

if [ -z "$selection" ]; then
    echo "No session selected."
    exit 0
fi

# Parse: formatted|index|full_dir|id|original_title
target_dir=$(echo "$selection" | cut -d'|' -f3)
session_id=$(echo "$selection" | cut -d'|' -f4)
title=$(echo "$selection" | cut -d'|' -f5)

# Verify directory
if [ ! -d "$target_dir" ]; then
    echo ""
    read -p "Directory missing. Create $target_dir? (y/N): " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
    mkdir -p "$target_dir"
fi

echo ""
echo "Opening: $title"
echo ""

cd "$target_dir" || exit 1
exec opencode . --session "$session_id"
