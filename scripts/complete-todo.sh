#!/bin/bash
# Mark a to-do as complete
# Usage: complete-todo.sh "task name or id"

set -e

IDENTIFIER="${1:-}"
if [ -z "$IDENTIFIER" ]; then
    echo '{"success": false, "message": "Task name or ID is required", "data": null}'
    exit 1
fi

SCRIPT="tell application \"Things3\"
    set t to missing value

    -- Try by name first
    try
        set t to to do \"$IDENTIFIER\"
    end try

    -- Try by ID
    if t is missing value then
        try
            set t to to do id \"$IDENTIFIER\"
        end try
    end if

    -- Search through all to dos if still not found
    if t is missing value then
        set allTodos to to dos
        repeat with todo in allTodos
            if name of todo is \"$IDENTIFIER\" then
                set t to todo
                exit repeat
            end if
        end repeat
    end if

    if t is missing value then
        return \"NOT_FOUND\"
    end if

    set status of t to completed
    set todoName to name of t
    return todoName
end tell"

RESULT=$(osascript -e "$SCRIPT" 2>&1) || {
    echo "{\"success\": false, \"message\": \"AppleScript error: $RESULT\", \"data\": null}"
    exit 1
}

if [ "$RESULT" = "NOT_FOUND" ]; then
    echo "{\"success\": false, \"message\": \"Task not found: $IDENTIFIER\", \"data\": null}"
    exit 1
fi

echo "{\"success\": true, \"message\": \"Task completed\", \"data\": {\"name\": \"$RESULT\"}}"
