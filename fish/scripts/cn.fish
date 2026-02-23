#!/usr/bin/env fish

function cn --description "Manage waybar context names"
    # Easily replaceable path to waybar config
    set -l waybar_config_dir "/home/aidan/.config/waybar"
    set -l config_file "$waybar_config_dir/context-names.jsonc"
    
    # Get current context
    set -l current_workspace (hyprctl activeworkspace -j | jq -r '.id')
    set -l current_context 1
    
    # Determine current context
    if test $current_workspace -le 10
        set current_context 1
    else if test $current_workspace -le 20
        set current_context 2
    else if test $current_workspace -le 30
        set current_context 3
    else if test $current_workspace -le 40
        set current_context 4
    else if test $current_workspace -le 50
        set current_context 5
    else if test $current_workspace -le 60
        set current_context 6
    else if test $current_workspace -le 70
        set current_context 7
    else if test $current_workspace -le 80
        set current_context 8
    else if test $current_workspace -le 90
        set current_context 9
    else if test $current_workspace -le 100
        set current_context 10
    else if test $current_workspace -le 110
        set current_context 11
    else if test $current_workspace -le 120
        set current_context 12
    else
        set current_context 1
    end
    
    # Handle arguments
    switch (count $argv)
        case 0
            echo "Usage:"
            echo "  cn \"name\"           # Set current context ($current_context) name"
            echo "  cn \"name\" NUMBER    # Set specific context name"
            echo "  cn --clear          # Clear current context ($current_context) name"
            echo "  cn --clear NUMBER   # Clear specific context name"
            echo "  cn --list           # List all context names"
            
        case 1
            if test "$argv[1]" = "--clear"
                # Clear current context
                _cn_clear_context $current_context $config_file
            else if test "$argv[1]" = "--list"
                # List all contexts
                _cn_list_contexts $config_file
            else
                # Set current context name
                _cn_set_context $current_context "$argv[1]" $config_file
            end
            
        case 2
            if test "$argv[1]" = "--clear"
                # Clear specific context
                _cn_clear_context $argv[2] $config_file
            else
                # Set specific context name
                _cn_set_context $argv[2] "$argv[1]" $config_file
            end
            
        case '*'
            echo "Error: Too many arguments"
            return 1
    end
end

function _cn_set_context --argument context_num context_name config_file
    # Create config file if it doesn't exist
    if not test -f $config_file
        echo "{\n  // Context names mapping\n}" > $config_file
    end
    
    # Read current config, add/update the context, write back
    set -l temp_file (mktemp)
    
    # Use jq to update the context name
    cat $config_file | grep -v "^\s*//" | jq --arg ctx "$context_num" --arg name "$context_name" '.[$ctx] = $name' > $temp_file
    
    # Add comments back and format nicely
    echo "{" > $config_file
    echo "  // Context names mapping" >> $config_file
    echo "  // Add or modify context numbers and their names here" >> $config_file
    
    # Extract and format the key-value pairs
    jq -r 'to_entries | sort_by(.key | tonumber) | .[] | "  \"" + .key + "\": \"" + .value + "\","' $temp_file >> $config_file
    
    # Remove trailing comma from last line and close brace
    sed -i '$s/,$//' $config_file
    echo "  // Add more contexts as needed, e.g.:" >> $config_file
    echo "  // \"3\": \"personal\"," >> $config_file
    echo "}" >> $config_file
    
    rm $temp_file
    echo "Set context $context_num to \"$context_name\""
end

function _cn_clear_context --argument context_num config_file
    if not test -f $config_file
        echo "Config file doesn't exist"
        return 1
    end
    
    set -l temp_file (mktemp)
    
    # Use jq to remove the context
    cat $config_file | grep -v "^\s*//" | jq --arg ctx "$context_num" 'del(.[$ctx])' > $temp_file
    
    # Rebuild file with comments
    echo "{" > $config_file
    echo "  // Context names mapping" >> $config_file
    echo "  // Add or modify context numbers and their names here" >> $config_file
    
    # Check if there are any remaining entries
    set -l entry_count (jq 'length' $temp_file)
    if test $entry_count -gt 0
        jq -r 'to_entries | sort_by(.key | tonumber) | .[] | "  \"" + .key + "\": \"" + .value + "\","' $temp_file >> $config_file
        sed -i '$s/,$//' $config_file
    end
    
    echo "  // Add more contexts as needed, e.g.:" >> $config_file
    echo "  // \"3\": \"personal\"," >> $config_file
    echo "}" >> $config_file
    
    rm $temp_file
    echo "Cleared context $context_num"
end

function _cn_list_contexts --argument config_file
    if not test -f $config_file
        echo "No context names configured"
        return 0
    end
    
    echo "Context Names:"
    cat $config_file | grep -v "^\s*//" | jq -r 'to_entries | sort_by(.key | tonumber) | .[] | "  " + .key + ": " + .value'
end