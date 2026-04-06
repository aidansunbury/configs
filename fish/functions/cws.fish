function cws --description "Coder Workspace Selector - List and connect to Coder workspaces via cssh"
    # Check dependencies
    if not command -v coder >/dev/null 2>&1
        echo "Error: coder CLI not found"
        return 1
    end
    if not command -v fzf >/dev/null 2>&1
        echo "Error: fzf not found"
        return 1
    end
    if not functions -q cssh
        echo "Error: cssh function not found"
        return 1
    end
    if not command -v jq >/dev/null 2>&1
        echo "Error: jq not found"
        return 1
    end

    # Fetch workspaces - filter for running workspaces only
    # A workspace is running if: build succeeded AND transition was "start"
    set -l workspaces (coder list -o json 2>/dev/null | jq '[.[] | select(.latest_build.job.status == "succeeded" and .latest_build.transition == "start")]')
    
    if test -z "$workspaces" || test "$workspaces" = "[]"
        echo "No running workspaces found."
        return 0
    end

    # Show header
    clear
    echo "Coder Workspace Selector (Running Only)"
    echo "Type to search workspaces"
    echo ""

    # Format: workspace name | template | last built time
    # Use a simple format with visual padding that fzf can display
    set -l selection (echo $workspaces | jq -r '.[] | 
        "\(.owner_name).\(.name)|\(.template_name)|\(.latest_build.job.completed_at | split(".")[0] + "Z" | fromdateiso8601 | strftime("%Y-%m-%d %H:%M"))"' | \
        fzf --prompt="Workspace: " \
            --header="Workspace                          | Template                  | Last Built" \
            --header-first \
            --delimiter='|' \
            --with-nth=1,2,3 \
            --nth=1,2,3 \
            --height='50%' \
            --layout=reverse \
            --border=rounded \
            --info=inline)

    if test -z "$selection"
        echo "No workspace selected."
        return 0
    end

    # Extract workspace name (format: owner.name)
    set -l workspace_name (echo $selection | cut -d'|' -f1)

    echo ""
    echo "Connecting to: $workspace_name"
    echo ""

    # Convert to full hostname format: main.<workspace-name>.<owner>.coder
    # coder list shows as "owner.name", we need "main.name.owner.coder"
    set -l owner (echo $workspace_name | cut -d'.' -f1)
    set -l name (echo $workspace_name | cut -d'.' -f2-)
    set -l full_hostname "main.$name.$owner.coder"

    # Connect via cssh
    cssh $full_hostname
end
