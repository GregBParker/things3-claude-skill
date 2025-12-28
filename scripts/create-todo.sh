#!/bin/bash
# Create a new to-do in Things 3
# Usage: create-todo.sh "Task name" ["notes"] ["due:YYYY-MM-DD"] ["tags:tag1,tag2"] ["list:Today|Inbox|..."] ["project:ProjectName"]

set -e

NAME="${1:-}"
if [ -z "$NAME" ]; then
    echo '{"success": false, "message": "Task name is required", "data": null}'
    exit 1
fi

# Parse optional arguments
NOTES=""
DUE_DATE=""
TAGS=""
LIST=""
PROJECT=""

shift
for arg in "$@"; do
    case "$arg" in
        notes:*) NOTES="${arg#notes:}" ;;
        due:*) DUE_DATE="${arg#due:}" ;;
        tags:*) TAGS="${arg#tags:}" ;;
        list:*) LIST="${arg#list:}" ;;
        project:*) PROJECT="${arg#project:}" ;;
        *) [ -z "$NOTES" ] && NOTES="$arg" ;;
    esac
done

# Build AppleScript
SCRIPT="tell application \"Things3\"
    set props to {name:\"$NAME\"}"

[ -n "$NOTES" ] && SCRIPT="$SCRIPT
    set props to props & {notes:\"$NOTES\"}"

[ -n "$TAGS" ] && SCRIPT="$SCRIPT
    set props to props & {tag names:\"$TAGS\"}"

if [ -n "$DUE_DATE" ]; then
    SCRIPT="$SCRIPT
    set dueDate to date \"$DUE_DATE\"
    set props to props & {due date:dueDate}"
fi

SCRIPT="$SCRIPT
    set newToDo to make new to do with properties props"

# Move to list if specified
if [ -n "$LIST" ]; then
    SCRIPT="$SCRIPT
    move newToDo to list \"$LIST\""
fi

# Set project if specified
if [ -n "$PROJECT" ]; then
    SCRIPT="$SCRIPT
    set project of newToDo to project \"$PROJECT\""
fi

SCRIPT="$SCRIPT
    set todoId to id of newToDo
    set todoName to name of newToDo
    return todoId & \"|\" & todoName
end tell"

# Execute and parse result
RESULT=$(osascript -e "$SCRIPT" 2>&1) || {
    echo "{\"success\": false, \"message\": \"AppleScript error: $RESULT\", \"data\": null}"
    exit 1
}

ID=$(echo "$RESULT" | cut -d'|' -f1)
CREATED_NAME=$(echo "$RESULT" | cut -d'|' -f2)

echo "{\"success\": true, \"message\": \"Task created\", \"data\": {\"id\": \"$ID\", \"name\": \"$CREATED_NAME\"}}"
