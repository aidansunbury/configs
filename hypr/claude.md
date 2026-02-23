# Hyprland Context Manager - Development Context

## Project Overview

I'm building a declarative workspace management system for Hyprland that uses JSON configuration files to define application layouts across workspace "contexts". Each context represents a 10-workspace offset (context 1 = workspaces 1-10, context 2 = workspaces 11-20, etc.).

## Current Status

✅ **Proof of concept working** - Successfully tested hardcoded script that opens Claude.ai as web app + Claude Code in Ghostty in workspace 26

✅ **JSON config format designed** - Created declarative config structure for defining workspace layouts

✅ **Parser/validator implemented** - Built bash script with full JSON validation and application launching

## Core Architecture

### Context System
- **Context**: Group of 10 consecutive workspaces
- **Context 1**: Workspaces 1-10, **Context 2**: Workspaces 11-20, etc.
- **JSON configs use relative workspaces (1-10)**, context parameter applies offset

### Command Interface
```bash
./myscript <config.json> -<context_number>
# Example: ./myscript claude-workspace.json -3  # Opens in context 3 (workspaces 21-30)
```

## Current Implementation Files

### 1. Main Script: `myscript`
**Location**: Root directory  
**Purpose**: Main executable with JSON parser, validator, and application launcher

**Key Functions**:
- `parse_args()` - Command line parsing and validation
- `validate_config()` - Comprehensive JSON structure validation
- `launch_application()` - Handles different app types (webapp, terminal, editor, etc.)
- `wait_for_new_window()` - Tracks new windows to avoid moving existing ones
- `process_config()` - Main orchestration logic

**Dependencies**: `jq`, `hyprctl`, `bc`

### 2. Example Config: `claude-workspace.json`
**Purpose**: Test configuration that launches Claude.ai web app + Claude Code terminal

```json
{
  "name": "Claude Development Setup",
  "workspaces": {
    "6": [
      {
        "type": "webapp",
        "app": "google-chrome-stable", 
        "url": "https://claude.ai/new",
        "delay": 1500
      },
      {
        "type": "terminal",
        "app": "ghostty",
        "shell": "fish", 
        "commands": ["claude"],
        "delay": 2000
      }
    ]
  }
}
```

## Supported Application Types

### webapp
Chrome in app mode (no browser UI)
```json
{
  "type": "webapp",
  "app": "google-chrome-stable",
  "url": "https://claude.ai/new",
  "args": ["--new-window", "--ozone-platform=wayland"]
}
```

### terminal
Terminal with optional commands
```json
{
  "type": "terminal", 
  "app": "ghostty",
  "shell": "fish",
  "commands": ["cd /path", "npm start"]
}
```

### editor  
Code editor with project path
```json
{
  "type": "editor",
  "app": "code", 
  "project_path": "/home/user/project"
}
```

### browser
Regular browser window
```json
{
  "type": "browser",
  "app": "google-chrome-stable",
  "url": "http://localhost:3000"
}
```

## My Current Hyprland Setup

**Environment**: Arch Linux + Hyprland + Omarchy  
**Terminal**: Ghostty with Fish shell  
**Context system**: Already implemented with smart-workspace.sh scripts

**Existing context scripts**:
- `smart-workspace.sh` - Navigate within current context
- `smart-move.sh` - Move windows within current context  
- `move-between-contexts.sh` - Move windows between contexts

**Current development workspace** (from `hyprctl clients` output):
- Workspace 21: 2x Ghostty terminals (project dir + dev server)
- Workspace 22: Chrome with localhost:3334
- Workspace 23: VS Code with trpc-ui project
- Workspace 24: Discord web app
- etc.

## Key Technical Challenges Solved

### Window Tracking
**Problem**: Moving all windows of a class vs. just newly launched ones  
**Solution**: Track window count before/after launch, get newest by PID

### Context Offset Calculation
**Problem**: Converting relative workspace numbers to absolute  
**Solution**: `absolute_workspace = context_base + relative_workspace`
Where `context_base = (context_number - 1) * 10`

### Application Launch Timing
**Problem**: Apps launch at different speeds, need proper window placement  
**Solution**: Configurable delays + window appearance detection

## Next Development Steps

### Immediate Priorities
1. **Test current implementation** - Verify claude-workspace.json works correctly
2. **Add more app types** - Obsidian, Spotify, etc. based on my workflow
3. **Error handling improvements** - Better validation and user feedback

### Future Features
1. **Config generation** - Generate JSON from current workspace state
2. **Hyprland integration** - Add to hyprland.conf for startup execution
3. **Advanced window properties** - Size, position, floating, etc.
4. **Template system** - Reusable config components

## Testing Instructions

1. Make script executable: `chmod +x myscript`
2. Test with: `./myscript claude-workspace.json -3`
3. Should open Claude.ai + Claude Code in workspace 26 (context 3, workspace 6)

## Project Structure
```
hyprland-context-manager/
├── myscript                    # Main executable  
├── claude-workspace.json       # Test config
├── configs/                    # Future config directory
└── README.md                   # Documentation
```

## Configuration Examples Needed

Based on my workflow, I need configs for:
- **Development setup**: Terminal + browser + VS Code
- **Note-taking**: Obsidian + reference browser tabs
- **Communication**: Discord + Slack web apps
- **Research**: Multiple browser windows + terminal

The system should eventually replace my manual workspace setup and provide consistent, reproducible development environments.