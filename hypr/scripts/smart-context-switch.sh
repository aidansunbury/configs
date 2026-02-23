#!/bin/bash
# Smart context switching that preserves workspace offset within context

TARGET_CONTEXT=$1

if [ -z "$TARGET_CONTEXT" ] || [ "$TARGET_CONTEXT" -lt 1 ] || [ "$TARGET_CONTEXT" -gt 12 ]; then
    echo "Usage: $0 <context_number> (1-12)"
    exit 1
fi

# Get current workspace
current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')

# Determine current context and offset within that context
if [ $current_workspace -le 10 ]; then
    current_context=1
    current_offset=$((current_workspace - 0))
elif [ $current_workspace -le 20 ]; then
    current_context=2
    current_offset=$((current_workspace - 10))
elif [ $current_workspace -le 30 ]; then
    current_context=3
    current_offset=$((current_workspace - 20))
elif [ $current_workspace -le 40 ]; then
    current_context=4
    current_offset=$((current_workspace - 30))
elif [ $current_workspace -le 50 ]; then
    current_context=5
    current_offset=$((current_workspace - 40))
elif [ $current_workspace -le 60 ]; then
    current_context=6
    current_offset=$((current_workspace - 50))
elif [ $current_workspace -le 70 ]; then
    current_context=7
    current_offset=$((current_workspace - 60))
elif [ $current_workspace -le 80 ]; then
    current_context=8
    current_offset=$((current_workspace - 70))
elif [ $current_workspace -le 90 ]; then
    current_context=9
    current_offset=$((current_workspace - 80))
elif [ $current_workspace -le 100 ]; then
    current_context=10
    current_offset=$((current_workspace - 90))
elif [ $current_workspace -le 110 ]; then
    current_context=11
    current_offset=$((current_workspace - 100))
elif [ $current_workspace -le 120 ]; then
    current_context=12
    current_offset=$((current_workspace - 110))
else
    # Fallback: assume context 1, offset 1
    current_context=1
    current_offset=1
fi

# Calculate target workspace base for the new context
target_context_base=$(( (TARGET_CONTEXT - 1) * 10 ))

# Calculate target workspace preserving the offset
target_workspace=$((target_context_base + current_offset))

# Debug output (can be removed)
# echo "Current: workspace $current_workspace (context $current_context, offset $current_offset)"
# echo "Target: context $TARGET_CONTEXT -> workspace $target_workspace"

# Switch to target workspace
hyprctl dispatch workspace $target_workspace