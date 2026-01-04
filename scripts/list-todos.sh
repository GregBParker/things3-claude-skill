#!/bin/bash
# List to-dos from a specific list or all open to-dos
# Usage: list-todos.sh [list_name]
# list_name: Today, Inbox, Upcoming, Anytime, Someday, or project/area name

set -e

LIST_NAME="${1:-Today}"

SCRIPT="tell application \"Things3\"
    set output to \"[\"

    -- Try list first, then project, then area
    try
        set todoList to to dos of list \"$LIST_NAME\"
    on error
        try
            set todoList to to dos of project \"$LIST_NAME\"
        on error
            try
                set todoList to to dos of area \"$LIST_NAME\"
            on error
                return \"[]\"
            end try
        end try
    end try
    set todoCount to count of todoList
    repeat with i from 1 to todoCount
        set t to item i of todoList
        set todoId to id of t
        set todoName to name of t
        set todoNotes to notes of t
        set todoStatus to status of t as string

        -- Get scheduled date (activation date)
        set todoScheduled to \"\"
        try
            set schedDate to activation date of t
            if schedDate is not missing value then
                set todoScheduled to short date string of schedDate
            end if
        end try

        -- Escape quotes in name and notes
        set AppleScript's text item delimiters to \"\\\"\"
        set todoName to text items of todoName
        set AppleScript's text item delimiters to \"\\\\\\\"\"
        set todoName to todoName as string
        set AppleScript's text item delimiters to \"\\\"\"
        set todoNotes to text items of todoNotes
        set AppleScript's text item delimiters to \"\\\\\\\"\"
        set todoNotes to todoNotes as string
        set AppleScript's text item delimiters to \"\"

        -- Escape newlines
        set AppleScript's text item delimiters to ASCII character 10
        set todoNotes to text items of todoNotes
        set AppleScript's text item delimiters to \"\\\\n\"
        set todoNotes to todoNotes as string
        set AppleScript's text item delimiters to \"\"

        set output to output & \"{\\\"id\\\": \\\"\" & todoId & \"\\\", \\\"name\\\": \\\"\" & todoName & \"\\\", \\\"notes\\\": \\\"\" & todoNotes & \"\\\", \\\"status\\\": \\\"\" & todoStatus & \"\\\", \\\"scheduled\\\": \\\"\" & todoScheduled & \"\\\"}\"
        if i < todoCount then
            set output to output & \", \"
        end if
    end repeat
    set output to output & \"]\"
    return output
end tell"

RESULT=$(osascript -e "$SCRIPT" 2>&1) || {
    echo "{\"success\": false, \"message\": \"AppleScript error: $RESULT\", \"data\": null}"
    exit 1
}

echo "{\"success\": true, \"message\": \"Listed to-dos from $LIST_NAME\", \"data\": $RESULT}"
