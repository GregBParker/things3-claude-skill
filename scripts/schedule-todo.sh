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

    -- Handle special date keywords
    if \"$DATE\" is \"today\" then
        move t to list \"Today\"
    else if \"$DATE\" is \"tomorrow\" then
        set targetDate to (current date) + 1 * days
        set time of targetDate to 0
        set activation date of t to targetDate
    else
        -- Parse YYYY-MM-DD format
        set dateString to \"$DATE\"
        set y to (text 1 thru 4 of dateString) as integer
        set m to (text 6 thru 7 of dateString) as integer
        set d to (text 9 thru 10 of dateString) as integer
        set targetDate to current date
        set year of targetDate to y
        set month of targetDate to m
        set day of targetDate to d
        set time of targetDate to 0
        set activation date of t to targetDate
    end if
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
