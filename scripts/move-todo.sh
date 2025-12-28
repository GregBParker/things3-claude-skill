#!/bin/bash
# Move a to-do to a different list, project, or area
# Usage: move-todo.sh "task name or id" "destination"
# destination: Today, Inbox, Someday, Anytime, project name, or area name

set -e

IDENTIFIER="${1:-}"
DESTINATION="${2:-}"

if [ -z "$IDENTIFIER" ]; then
    echo '{"success": false, "message": "Task name or ID is required", "data": null}'
    exit 1
fi

if [ -z "$DESTINATION" ]; then
    echo '{"success": false, "message": "Destination is required", "data": null}'
    exit 1
fi

# Check if destination is a built-in list
BUILTIN_LISTS="Inbox Today Upcoming Anytime Someday"

SCRIPT="tell application \"Things3\"
    try
        set t to to do \"$IDENTIFIER\"
    on error
        try
            set t to to do id \"$IDENTIFIER\"
        on error
            return \"NOT_FOUND\"
        end try
    end try"

if echo "$BUILTIN_LISTS" | grep -qw "$DESTINATION"; then
    # Move to built-in list
    SCRIPT="$SCRIPT
    move t to list \"$DESTINATION\""
else
    # Try as project first, then area
    SCRIPT="$SCRIPT
    try
        set p to project \"$DESTINATION\"
        set project of t to p
    on error
        try
            set a to area \"$DESTINATION\"
            set area of t to a
        on error
            return \"DEST_NOT_FOUND\"
        end try
    end try"
fi

SCRIPT="$SCRIPT
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

if [ "$RESULT" = "DEST_NOT_FOUND" ]; then
    echo "{\"success\": false, \"message\": \"Destination not found: $DESTINATION\", \"data\": null}"
    exit 1
fi

echo "{\"success\": true, \"message\": \"Task moved to $DESTINATION\", \"data\": {\"name\": \"$RESULT\"}}"
