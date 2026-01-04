#!/bin/bash
# Update properties of an existing to-do
# Usage: update-todo.sh "task name or id" ["name:New Name"] ["notes:New notes"] ["tags:tag1,tag2"] ["due:YYYY-MM-DD"]

set -e

IDENTIFIER="${1:-}"
if [ -z "$IDENTIFIER" ]; then
    echo '{"success": false, "message": "Task name or ID is required", "data": null}'
    exit 1
fi

# Parse optional arguments
NEW_NAME=""
NOTES=""
TAGS=""
DUE_DATE=""

shift
for arg in "$@"; do
    case "$arg" in
        name:*) NEW_NAME="${arg#name:}" ;;
        notes:*) NOTES="${arg#notes:}" ;;
        tags:*) TAGS="${arg#tags:}" ;;
        due:*) DUE_DATE="${arg#due:}" ;;
    esac
done

# Build AppleScript
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
    end if"

[ -n "$NEW_NAME" ] && SCRIPT="$SCRIPT
    set name of t to \"$NEW_NAME\""

[ -n "$NOTES" ] && SCRIPT="$SCRIPT
    set notes of t to \"$NOTES\""

[ -n "$TAGS" ] && SCRIPT="$SCRIPT
    set tag names of t to \"$TAGS\""

if [ -n "$DUE_DATE" ]; then
    SCRIPT="$SCRIPT
    set due date of t to date \"$DUE_DATE\""
fi

SCRIPT="$SCRIPT
    set todoName to name of t
    set todoId to id of t
    return todoId & \"|\" & todoName
end tell"

RESULT=$(osascript -e "$SCRIPT" 2>&1) || {
    echo "{\"success\": false, \"message\": \"AppleScript error: $RESULT\", \"data\": null}"
    exit 1
}

if [ "$RESULT" = "NOT_FOUND" ]; then
    echo "{\"success\": false, \"message\": \"Task not found: $IDENTIFIER\", \"data\": null}"
    exit 1
fi

ID=$(echo "$RESULT" | cut -d'|' -f1)
NAME=$(echo "$RESULT" | cut -d'|' -f2)

echo "{\"success\": true, \"message\": \"Task updated\", \"data\": {\"id\": \"$ID\", \"name\": \"$NAME\"}}"
