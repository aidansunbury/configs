function cssh --description "Cmux SSH - Wraps cmux ssh with auto-generated remote name"
    if test (count $argv) -eq 0
        echo "Usage: cssh <workspace>"
        echo "Example: cssh main.aidan-test-env-vars.aidansunbury.coder"
        return 1
    end

    set -l workspace $argv[1]
    
    # Generate a friendly remote name from the workspace
    # Convert dots to spaces and title-case each word
    set -l remote_name (echo $workspace | tr '.' ' ' | sed 's/\b\([a-z]\)/\u\1/g')
    
    # Execute cmux ssh with the generated name and port 22
    cmux ssh $workspace --name "$remote_name" --port 22
end
