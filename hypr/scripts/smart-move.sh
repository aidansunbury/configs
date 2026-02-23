#!/bin/bash
# Move windows within current context

WORKSPACE_NUM=$1
current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')

# Determine which context we're in based on current workspace (contexts 1-12)
if [ $current_workspace -le 10 ]; then
    context_base=0      # Context 1: workspaces 1-10
elif [ $current_workspace -le 20 ]; then
    context_base=10     # Context 2: workspaces 11-20
elif [ $current_workspace -le 30 ]; then
    context_base=20     # Context 3: workspaces 21-30
elif [ $current_workspace -le 40 ]; then
    context_base=30     # Context 4: workspaces 31-40
elif [ $current_workspace -le 50 ]; then
    context_base=40     # Context 5: workspaces 41-50
elif [ $current_workspace -le 60 ]; then
    context_base=50     # Context 6: workspaces 51-60
elif [ $current_workspace -le 70 ]; then
    context_base=60     # Context 7: workspaces 61-70
elif [ $current_workspace -le 80 ]; then
    context_base=70     # Context 8: workspaces 71-80
elif [ $current_workspace -le 90 ]; then
    context_base=80     # Context 9: workspaces 81-90
elif [ $current_workspace -le 100 ]; then
    context_base=90     # Context 10: workspaces 91-100
elif [ $current_workspace -le 110 ]; then
    context_base=100    # Context 11: workspaces 101-110
elif [ $current_workspace -le 120 ]; then
    context_base=110    # Context 12: workspaces 111-120
else
    context_base=0      # fallback to context 1
fi

target_workspace=$((context_base + WORKSPACE_NUM))
hyprctl dispatch movetoworkspace $target_workspace
