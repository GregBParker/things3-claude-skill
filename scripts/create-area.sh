#!/bin/bash
# Create a new area in Things 3
# Usage: create-area.sh "Area Name"

set -e

NAME="${1:-}"
if [ -z "$NAME" ]; then
    echo '{"success": false, "message": "Area name is required", "data": null}'
    exit 1
fi

SCRIPT="tell application \"Things3\"
    set newArea to make new area with properties {name:\"$NAME\"}
    set areaId to id of newArea
    set areaName to name of newArea
    return areaId & \"|\" & areaName
end tell"

RESULT=$(osascript -e "$SCRIPT" 2>&1) || {
    echo "{\"success\": false, \"message\": \"AppleScript error: $RESULT\", \"data\": null}"
    exit 1
}

ID=$(echo "$RESULT" | cut -d'|' -f1)
CREATED_NAME=$(echo "$RESULT" | cut -d'|' -f2)

echo "{\"success\": true, \"message\": \"Area created\", \"data\": {\"id\": \"$ID\", \"name\": \"$CREATED_NAME\"}}"
