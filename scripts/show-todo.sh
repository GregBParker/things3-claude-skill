#!/bin/bash
# Show and select a to-do in Things 3 UI
# Usage: show-todo.sh "task name or id"

set -e

IDENTIFIER="${1:-}"
if [ -z "$IDENTIFIER" ]; then
    echo '{"success": false, "message": "Task name or ID is required", "data": null}'
    exit 1
fi

SCRIPT="tell application \"Things3\"
    try
        set t to to do \"$IDENTIFIER\"
    on error
        try
            set t to to do id \"$IDENTIFIER\"
        on error
            return \"NOT_FOUND\"
        end try
    end try
    show t
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

echo "{\"success\": true, \"message\": \"Showing task in Things 3\", \"data\": {\"name\": \"$RESULT\"}}"
