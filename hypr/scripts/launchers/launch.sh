#!/bin/bash

# Hyprland Context Manager
# Usage: ./myscript <config.json> -<context_number>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    command -v jq >/dev/null 2>&1 || missing_deps+=("jq")
    command -v hyprctl >/dev/null 2>&1 || missing_deps+=("hyprctl")
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_error "Install with: sudo pacman -S ${missing_deps[*]}"
        exit 1
    fi
}

# Parse command line arguments
parse_args() {
    if [ $# -ne 2 ]; then
        log_error "Usage: $0 <config.json> -<context_number>"
        log_error "Example: $0 claude-workspace.json -3"
        exit 1
    fi
    
    CONFIG_FILE="$1"
    CONTEXT_ARG="$2"
    
    # Validate config file exists
    if [ ! -f "$CONFIG_FILE" ]; then
        log_error "Config file not found: $CONFIG_FILE"
        exit 1
    fi
    
    # Parse context number
    if [[ ! "$CONTEXT_ARG" =~ ^-([1-9]|1[0-2])$ ]]; then
        log_error "Invalid context number. Must be -1 through -12"
        exit 1
    fi
    
    CONTEXT_NUMBER="${CONTEXT_ARG#-}"
    CONTEXT_BASE=$(( (CONTEXT_NUMBER - 1) * 10 ))
    
    log_info "Using config: $CONFIG_FILE"
    log_info "Target context: $CONTEXT_NUMBER (workspaces $((CONTEXT_BASE + 1))-$((CONTEXT_BASE + 10)))"
}

# Validate JSON config structure
validate_config() {
    local config_file="$1"
    
    log_info "Validating config structure..."
    
    # Check if file is valid JSON
    if ! jq empty "$config_file" 2>/dev/null; then
        log_error "Invalid JSON in config file"
        exit 1
    fi
    
    # Check required fields
    local required_fields=("name" "workspaces")
    for field in "${required_fields[@]}"; do
        if ! jq -e "has(\"$field\")" "$config_file" >/dev/null; then
            log_error "Missing required field: $field"
            exit 1
        fi
    done
    
    # Validate workspace numbers (should be 1-10)
    local invalid_workspaces
    invalid_workspaces=$(jq -r '.workspaces | keys[] | select(. | tonumber < 1 or tonumber > 10)' "$config_file")
    if [ -n "$invalid_workspaces" ]; then
        log_error "Invalid workspace numbers found. Must be 1-10: $invalid_workspaces"
        exit 1
    fi
    
    # Validate application entries
    local workspaces
    workspaces=$(jq -r '.workspaces | keys[]' "$config_file")
    for ws in $workspaces; do
        local apps_count
        apps_count=$(jq -r ".workspaces[\"$ws\"] | length" "$config_file")
        for ((i=0; i<apps_count; i++)); do
            local app_type
            app_type=$(jq -r ".workspaces[\"$ws\"][$i].type" "$config_file")
            local app_name
            app_name=$(jq -r ".workspaces[\"$ws\"][$i].app" "$config_file")
            
            if [ "$app_type" == "null" ] || [ "$app_name" == "null" ]; then
                log_error "Application in workspace $ws missing required 'type' or 'app' field"
                exit 1
            fi
            
            # Validate app type
            case "$app_type" in
                "webapp"|"browser"|"terminal"|"editor"|"application") ;;
                *) log_error "Invalid application type '$app_type' in workspace $ws" && exit 1 ;;
            esac
        done
    done
    
    log_success "Config validation passed"
}

# Wait for a new window of specific class to appear
wait_for_new_window() {
    local class_name="$1"
    local timeout="${2:-20}"
    local initial_count
    initial_count=$(hyprctl clients -j | jq "[.[] | select(.class == \"$class_name\")] | length")
    
    local count=0
    while [ $count -lt $timeout ]; do
        local current_count
        current_count=$(hyprctl clients -j | jq "[.[] | select(.class == \"$class_name\")] | length")
        if [ "$current_count" -gt "$initial_count" ]; then
            # Return the address of the newest window
            hyprctl clients -j | jq -r "[.[] | select(.class == \"$class_name\")] | sort_by(.pid) | last | .address"
            return 0
        fi
        sleep 0.05
        ((count++))
    done
    return 1
}

# Launch a single application
launch_application() {
    local workspace="$1"
    local app_config="$2"
    local absolute_workspace=$(( CONTEXT_BASE + workspace ))
    
    local app_type app_name url args shell commands delay wait_for_prev
    app_type=$(echo "$app_config" | jq -r '.type')
    app_name=$(echo "$app_config" | jq -r '.app')
    url=$(echo "$app_config" | jq -r '.url // empty')
    args=$(echo "$app_config" | jq -r '.args[]? // empty' | tr '\n' ' ')
    shell=$(echo "$app_config" | jq -r '.shell // "bash"')
    commands=$(echo "$app_config" | jq -r '.commands[]? // empty')
    delay=$(echo "$app_config" | jq -r '.delay // 100')
    wait_for_prev=$(echo "$app_config" | jq -r '.wait_for_previous // false')
    
    log_info "Launching $app_type ($app_name) in workspace $absolute_workspace"
    
    # Switch to target workspace
    hyprctl dispatch workspace "$absolute_workspace"
    
    # Build and execute command based on app type
    case "$app_type" in
        "webapp")
            local cmd="$app_name --app=$url $args"
            log_info "Executing: $cmd"
            $cmd &
            local window_class="google-chrome"
            ;;
        "browser")
            local cmd="$app_name $url $args"
            log_info "Executing: $cmd"
            $cmd &
            local window_class="google-chrome"
            ;;
        "terminal")
            if [ -n "$commands" ]; then
                local cmd="$app_name -e $shell -c \"$commands\""
                log_info "Executing: $cmd"
                eval "$cmd" &
            else
                log_info "Executing: $app_name"
                $app_name &
            fi
            local window_class="com.mitchellh.ghostty"
            ;;
        "editor")
            local project_path
            project_path=$(echo "$app_config" | jq -r '.project_path // empty')
            if [ -n "$project_path" ]; then
                local cmd="$app_name $project_path"
                log_info "Executing: $cmd"
                $cmd &
            else
                log_info "Executing: $app_name"
                $app_name &
            fi
            local window_class="code"
            ;;
        "application")
            local cmd="$app_name $args"
            log_info "Executing: $cmd"
            $cmd &
            local window_class="$app_name"
            ;;
    esac
    
    # Wait for delay
    sleep "$(awk "BEGIN {printf \"%.1f\", $delay/1000}")"
    
    # Wait for window and move it to correct workspace
    log_info "Waiting for window to appear..."
    if new_window=$(wait_for_new_window "$window_class" 10); then
        hyprctl dispatch movetoworkspacesilent "$absolute_workspace,address:$new_window"
        log_success "Moved $app_type to workspace $absolute_workspace"
    else
        log_warning "Could not find new $window_class window to move"
    fi
}

# Launch application directly in target workspace using native Hyprland support
launch_application_native() {
    local workspace="$1"
    local app_config="$2"
    local absolute_workspace=$(( CONTEXT_BASE + workspace ))
    
    local app_type app_name url args shell commands delay
    app_type=$(echo "$app_config" | jq -r '.type')
    app_name=$(echo "$app_config" | jq -r '.app')
    url=$(echo "$app_config" | jq -r '.url // empty')
    args=$(echo "$app_config" | jq -r '.args[]? // empty' | tr '\n' ' ')
    shell=$(echo "$app_config" | jq -r '.shell // "bash"')
    commands=$(echo "$app_config" | jq -r '.commands[]? // empty')
    delay=$(echo "$app_config" | jq -r '.delay // 100')
    
    log_info "Launching $app_type ($app_name) in workspace $absolute_workspace"
    
    # Build command based on app type and execute directly in workspace
    case "$app_type" in
        "webapp")
            local cmd="$app_name --app=$url $args"
            log_info "Executing: [workspace $absolute_workspace silent] $cmd"
            hyprctl dispatch exec "[workspace $absolute_workspace silent] $cmd"
            ;;
        "browser")
            local cmd="$app_name $url $args"
            log_info "Executing: [workspace $absolute_workspace silent] $cmd"
            hyprctl dispatch exec "[workspace $absolute_workspace silent] $cmd"
            ;;
        "terminal")
            if [ -n "$commands" ]; then
                local cmd="$app_name -e $shell -c \"$commands\""
                log_info "Executing: [workspace $absolute_workspace silent] $cmd"
                hyprctl dispatch exec "[workspace $absolute_workspace silent] $cmd"
            else
                log_info "Executing: [workspace $absolute_workspace silent] $app_name"
                hyprctl dispatch exec "[workspace $absolute_workspace silent] $app_name"
            fi
            ;;
        "editor")
            local project_path
            project_path=$(echo "$app_config" | jq -r '.project_path // empty')
            if [ -n "$project_path" ]; then
                local cmd="$app_name $project_path"
                log_info "Executing: [workspace $absolute_workspace silent] $cmd"
                hyprctl dispatch exec "[workspace $absolute_workspace silent] $cmd"
            else
                log_info "Executing: [workspace $absolute_workspace silent] $app_name"
                hyprctl dispatch exec "[workspace $absolute_workspace silent] $app_name"
            fi
            ;;
        "application")
            local cmd="$app_name $args"
            log_info "Executing: [workspace $absolute_workspace silent] $cmd"
            hyprctl dispatch exec "[workspace $absolute_workspace silent] $cmd"
            ;;
    esac
    
    # Small delay between launches
    sleep "$(awk "BEGIN {printf \"%.2f\", $delay/1000}")"
    
    log_success "Launched $app_type in workspace $absolute_workspace"
}

# Process all applications in the config
process_config() {
    local config_file="$1"
    local config_name
    config_name=$(jq -r '.name' "$config_file")
    
    log_info "Processing config: $config_name"
    
    local workspaces
    workspaces=$(jq -r '.workspaces | keys[] | tonumber' "$config_file" | sort -n)
    
    for workspace in $workspaces; do
        local apps_count
        apps_count=$(jq -r ".workspaces[\"$workspace\"] | length" "$config_file")
        
        log_info "Setting up workspace $workspace (absolute: $((CONTEXT_BASE + workspace))) with $apps_count application(s)"
        
        for ((i=0; i<apps_count; i++)); do
            local app_config
            app_config=$(jq -c ".workspaces[\"$workspace\"][$i]" "$config_file")
            launch_application_native "$workspace" "$app_config"
        done
    done
    
    # Switch to first workspace when done
    local first_workspace
    first_workspace=$(echo "$workspaces" | head -1)
    hyprctl dispatch workspace $((CONTEXT_BASE + first_workspace))
    
    log_success "Setup complete for context $CONTEXT_NUMBER!"
}

# Main execution
main() {
    log_info "Starting Hyprland Context Manager"
    
    check_dependencies
    parse_args "$@"
    validate_config "$CONFIG_FILE"
    process_config "$CONFIG_FILE"
    
    log_success "All done!"
}

# Run main function with all arguments
main "$@"