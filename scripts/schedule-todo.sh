#!/bin/bash
# Schedule a to-do for a specific date
# Usage: schedule-todo.sh "task name or id" "YYYY-MM-DD"

set -e

IDENTIFIER="${1:-}"
DATE="${2:-}"

if [ -z "$IDENTIFIER" ]; then
    echo '{"success": false, "message": "Task name or ID is required", "data": null}'
    exit 1
fi

if [ -z "$DATE" ]; then
    echo '{"success": false, "message": "Date is required (YYYY-MM-DD format)", "data": null}'
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
    set activation date of t to date \"$DATE\"
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

echo "{\"success\": true, \"message\": \"Task scheduled for $DATE\", \"data\": {\"name\": \"$RESULT\", \"scheduled\": \"$DATE\"}}"
