#!/bin/bash

# Hardcoded test script for workspace 26
# Opens Claude.ai as web app + Claude Code in Ghostty

echo "Setting up workspace 26 with Claude.ai and Claude Code..."

# Switch to workspace 26
echo "Switching to workspace 26..."
hyprctl dispatch workspace 26

# Launch Claude.ai as a web app (using your existing binding style)
echo "Launching Claude.ai as web app..."
google-chrome-stable --app=https://claude.ai/new --new-window --ozone-platform=wayland &

# Small delay to let Chrome start
sleep 1.5

# Launch Ghostty terminal with Claude Code
echo "Launching Ghostty with Claude Code..."
ghostty -e fish -c "claude" &

# Wait a moment for windows to appear
sleep 2

# Get the newest Chrome window (should be our Claude app)
echo "Moving Claude.ai app to workspace 26..."
# Using your existing approach - find Chrome windows and move the newest one
newest_chrome=$(hyprctl clients -j | jq -r '[.[] | select(.class == "google-chrome")] | sort_by(.pid) | last | .address')
if [ "$newest_chrome" != "null" ] && [ -n "$newest_chrome" ]; then
    hyprctl dispatch movetoworkspacesilent 26,address:$newest_chrome
    echo "Moved Chrome app (address: $newest_chrome) to workspace 26"
else
    echo "Warning: Could not find Chrome window to move"
fi

# Get the newest Ghostty window
echo "Moving Ghostty terminal to workspace 26..."
newest_ghostty=$(hyprctl clients -j | jq -r '[.[] | select(.class == "com.mitchellh.ghostty")] | sort_by(.pid) | last | .address')
if [ "$newest_ghostty" != "null" ] && [ -n "$newest_ghostty" ]; then
    hyprctl dispatch movetoworkspacesilent 26,address:$newest_ghostty
    echo "Moved Ghostty terminal (address: $newest_ghostty) to workspace 26"
else
    echo "Warning: Could not find Ghostty window to move"
fi

# Switch back to workspace 26 to see the result
hyprctl dispatch workspace 26

echo "Setup complete! Workspace 26 should now have:"
echo "- Claude.ai web app"
echo "- Ghostty terminal running Claude Code"

# Debug: Show what windows are actually in workspace 26
echo ""
echo "Current windows in workspace 26:"
hyprctl clients -j | jq -r '.[] | select(.workspace.id == 26) | "- \(.class): \(.title)"'