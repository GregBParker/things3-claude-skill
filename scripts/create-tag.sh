#!/bin/bash
# Create a new tag in Things 3
# Usage: create-tag.sh "Tag Name" ["parent:ParentTagName"]

set -e

NAME="${1:-}"
if [ -z "$NAME" ]; then
    echo '{"success": false, "message": "Tag name is required", "data": null}'
    exit 1
fi

# Parse optional parent tag
PARENT=""
shift
for arg in "$@"; do
    case "$arg" in
        parent:*) PARENT="${arg#parent:}" ;;
    esac
done

# Build AppleScript
SCRIPT="tell application \"Things3\"
    set newTag to make new tag with properties {name:\"$NAME\"}"

if [ -n "$PARENT" ]; then
    SCRIPT="$SCRIPT
    set parent tag of newTag to tag \"$PARENT\""
fi

SCRIPT="$SCRIPT
    set tagId to id of newTag
    set tagName to name of newTag
    return tagId & \"|\" & tagName
end tell"

RESULT=$(osascript -e "$SCRIPT" 2>&1) || {
    echo "{\"success\": false, \"message\": \"AppleScript error: $RESULT\", \"data\": null}"
    exit 1
}

ID=$(echo "$RESULT" | cut -d'|' -f1)
CREATED_NAME=$(echo "$RESULT" | cut -d'|' -f2)

echo "{\"success\": true, \"message\": \"Tag created\", \"data\": {\"id\": \"$ID\", \"name\": \"$CREATED_NAME\"}}"
