#!/bin/bash
# Display workspaces 1-10 for current context only

current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')
all_workspaces=$(hyprctl workspaces -j)

# Determine context and base (same logic as above)
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

# Get workspaces that exist in current context
context_workspaces=$(echo "$all_workspaces" | jq -r --arg start "$((base + 1))" --arg end "$((base + 10))" '.[] | select(.id >= ($start | tonumber) and .id <= ($end | tonumber)) | .id')

# Build workspace display
workspace_buttons=""
for i in {1..10}; do
    actual_workspace=$((base + i))
    if echo "$context_workspaces" | grep -q "^$actual_workspace$"; then
        if [ $actual_workspace -eq $current_workspace ]; then
            workspace_buttons+="[$i] "
        else
            workspace_buttons+="$i "
        fi
    else
        workspace_buttons+="· "
    fi
done

echo "{\"text\":\"$workspace_buttons\", \"class\":\"context-workspaces\"}"
