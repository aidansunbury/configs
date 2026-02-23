#!/bin/bash
# Combined context and workspace display

current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')
all_workspaces=$(hyprctl workspaces -j)

# Load context names from config file
config_file="$HOME/.config/waybar/context-names.jsonc"

# Determine context and base
if [ $current_workspace -le 10 ]; then
    context=1; base=0
elif [ $current_workspace -le 20 ]; then
    context=2; base=10
elif [ $current_workspace -le 30 ]; then
    context=3; base=20
elif [ $current_workspace -le 40 ]; then
    context=4; base=30
elif [ $current_workspace -le 50 ]; then
    context=5; base=40
elif [ $current_workspace -le 60 ]; then
    context=6; base=50
elif [ $current_workspace -le 70 ]; then
    context=7; base=60
elif [ $current_workspace -le 80 ]; then
    context=8; base=70
elif [ $current_workspace -le 90 ]; then
    context=9; base=80
elif [ $current_workspace -le 100 ]; then
    context=10; base=90
elif [ $current_workspace -le 110 ]; then
    context=11; base=100
elif [ $current_workspace -le 120 ]; then
    context=12; base=110
else
    context=1; base=0
fi

relative_workspace=$((current_workspace - base))

# Get context name from config file
context_name=""
if [ -f "$config_file" ]; then
    # Remove comments and get the context name using jq
    context_name=$(cat "$config_file" | grep -v "^\s*//" | jq -r --arg ctx "$context" '.[$ctx] // empty' 2>/dev/null)
fi

# Build display text
if [ -n "$context_name" ]; then
    display_text="Context $context: $context_name"
else
    display_text="Context $context"
fi

echo "{\"text\":\"$display_text\", \"tooltip\":\"Context $context, Workspace $relative_workspace\", \"class\":\"context-$context\"}"
