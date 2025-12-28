#!/bin/bash
# List today's to-dos organized by area
# Usage: list-today-by-area.sh
# Returns JSON with areas containing their respective today tasks

set -e

SCRIPT='tell application "Things3"
    set output to "{"
    set todayList to to dos of list "Today"
    set areaTasksMap to {}
    set areaNames to {}
    set noAreaTodos to {}

    -- Categorize each today task by area
    repeat with t in todayList
        set taskAreaName to "No Area"

        -- Check if task has direct area
        try
            set taskArea to area of t
            if taskArea is not missing value then
                set taskAreaName to name of taskArea
            end if
        end try

        -- If no direct area, check if task is in a project with area
        if taskAreaName is "No Area" then
            try
                set taskProject to project of t
                if taskProject is not missing value then
                    try
                        set projectArea to area of taskProject
                        if projectArea is not missing value then
                            set taskAreaName to name of projectArea
                        end if
                    end try
                end if
            end try
        end if

        -- Track this area if new
        if taskAreaName is not in areaNames then
            set end of areaNames to taskAreaName
        end if
    end repeat

    set firstArea to true

    -- Output tasks grouped by area
    repeat with areaName in areaNames
        set areaTodos to {}

        repeat with t in todayList
            set taskAreaName to "No Area"
            set projectName to ""

            try
                set taskArea to area of t
                if taskArea is not missing value then
                    set taskAreaName to name of taskArea
                end if
            end try

            if taskAreaName is "No Area" then
                try
                    set taskProject to project of t
                    if taskProject is not missing value then
                        set projectName to name of taskProject
                        try
                            set projectArea to area of taskProject
                            if projectArea is not missing value then
                                set taskAreaName to name of projectArea
                            end if
                        end try
                    end if
                end try
            else
                try
                    set taskProject to project of t
                    if taskProject is not missing value then
                        set projectName to name of taskProject
                    end if
                end try
            end if

            if taskAreaName is equal to (areaName as string) then
                set end of areaTodos to {t, projectName}
            end if
        end repeat

        if (count of areaTodos) > 0 then
            if not firstArea then
                set output to output & ", "
            end if
            set firstArea to false

            -- Escape quotes in area name
            set escapedAreaName to areaName as string
            set AppleScript'\''s text item delimiters to "\""
            set escapedAreaName to text items of escapedAreaName
            set AppleScript'\''s text item delimiters to "\\\""
            set escapedAreaName to escapedAreaName as string
            set AppleScript'\''s text item delimiters to ""

            set output to output & "\"" & escapedAreaName & "\": ["

            set todoCount to count of areaTodos
            repeat with j from 1 to todoCount
                set todoItem to item j of areaTodos
                set t to item 1 of todoItem
                set projectName to item 2 of todoItem

                set todoId to id of t
                set todoName to name of t
                set todoNotes to notes of t
                set todoStatus to status of t as string

                -- Get tags
                set todoTags to ""
                try
                    set taskTags to tags of t
                    set tagList to {}
                    repeat with tg in taskTags
                        set end of tagList to "\\\"" & (name of tg) & "\\\""
                    end repeat
                    set AppleScript'\''s text item delimiters to ", "
                    set todoTags to tagList as string
                    set AppleScript'\''s text item delimiters to ""
                end try

                -- Escape quotes in name, notes, project
                set AppleScript'\''s text item delimiters to "\""
                set todoName to text items of todoName
                set AppleScript'\''s text item delimiters to "\\\""
                set todoName to todoName as string
                set AppleScript'\''s text item delimiters to "\""
                set todoNotes to text items of todoNotes
                set AppleScript'\''s text item delimiters to "\\\""
                set todoNotes to todoNotes as string
                set AppleScript'\''s text item delimiters to "\""
                set projectName to text items of projectName
                set AppleScript'\''s text item delimiters to "\\\""
                set projectName to projectName as string
                set AppleScript'\''s text item delimiters to ""

                -- Escape newlines
                set AppleScript'\''s text item delimiters to ASCII character 10
                set todoNotes to text items of todoNotes
                set AppleScript'\''s text item delimiters to "\\n"
                set todoNotes to todoNotes as string
                set AppleScript'\''s text item delimiters to ""

                set output to output & "{\"id\": \"" & todoId & "\", \"name\": \"" & todoName & "\", \"notes\": \"" & todoNotes & "\", \"project\": \"" & projectName & "\", \"status\": \"" & todoStatus & "\", \"tags\": [" & todoTags & "]}"
                if j < todoCount then
                    set output to output & ", "
                end if
            end repeat
            set output to output & "]"
        end if
    end repeat

    set output to output & "}"
    return output
end tell'

RESULT=$(osascript -e "$SCRIPT" 2>&1) || {
    echo "{\"success\": false, \"message\": \"AppleScript error: $RESULT\", \"data\": null}"
    exit 1
}

echo "{\"success\": true, \"message\": \"Listed today tasks by area\", \"data\": $RESULT}"
