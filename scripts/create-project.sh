#!/bin/bash
# Create a new project in Things 3
# Usage: create-project.sh "Project Name" ["notes"] ["area:AreaName"] ["tags:tag1,tag2"] ["due:YYYY-MM-DD"]

set -e

NAME="${1:-}"
if [ -z "$NAME" ]; then
    echo '{"success": false, "message": "Project name is required", "data": null}'
    exit 1
fi

# Parse optional arguments
NOTES=""
AREA=""
TAGS=""
DUE_DATE=""

shift
for arg in "$@"; do
    case "$arg" in
        notes:*) NOTES="${arg#notes:}" ;;
        area:*) AREA="${arg#area:}" ;;
        tags:*) TAGS="${arg#tags:}" ;;
        due:*) DUE_DATE="${arg#due:}" ;;
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
    set newProject to make new project with properties props"

# Set area if specified
if [ -n "$AREA" ]; then
    SCRIPT="$SCRIPT
    set area of newProject to area \"$AREA\""
fi

SCRIPT="$SCRIPT
    set projId to id of newProject
    set projName to name of newProject
    return projId & \"|\" & projName
end tell"

RESULT=$(osascript -e "$SCRIPT" 2>&1) || {
    echo "{\"success\": false, \"message\": \"AppleScript error: $RESULT\", \"data\": null}"
    exit 1
}

ID=$(echo "$RESULT" | cut -d'|' -f1)
CREATED_NAME=$(echo "$RESULT" | cut -d'|' -f2)

echo "{\"success\": true, \"message\": \"Project created\", \"data\": {\"id\": \"$ID\", \"name\": \"$CREATED_NAME\"}}"
