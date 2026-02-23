#!/bin/bash

# Move window between contexts while maintaining workspace offset
# Usage: move-between-contexts.sh <target_context>

TARGET_CONTEXT=$1

if [[ -z "$TARGET_CONTEXT" || "$TARGET_CONTEXT" -lt 1 || "$TARGET_CONTEXT" -gt 12 ]]; then
    echo "Error: Please provide a target context number (1-12)"
    exit 1
fi

# Get current workspace
CURRENT_WORKSPACE=$(hyprctl activewindow -j | jq -r '.workspace.id')

if [[ -z "$CURRENT_WORKSPACE" || "$CURRENT_WORKSPACE" == "null" ]]; then
    echo "Error: Could not determine current workspace"
    exit 1
fi

# Calculate current context and offset
CURRENT_CONTEXT=$(( (CURRENT_WORKSPACE - 1) / 10 + 1 ))
WORKSPACE_OFFSET=$(( (CURRENT_WORKSPACE - 1) % 10 + 1 ))

# Calculate target workspace (same offset in target context)
TARGET_WORKSPACE=$(( (TARGET_CONTEXT - 1) * 10 + WORKSPACE_OFFSET ))

echo "Moving window from workspace $CURRENT_WORKSPACE (context $CURRENT_CONTEXT, offset $WORKSPACE_OFFSET) to workspace $TARGET_WORKSPACE (context $TARGET_CONTEXT, offset $WORKSPACE_OFFSET)"

# Move the active window to the target workspace
hyprctl dispatch movetoworkspace $TARGET_WORKSPACE