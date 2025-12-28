# Things 3 AppleScript API Reference

Complete reference for Things 3 AppleScript commands and properties.

## Object Types

### To Do
The primary task object in Things 3.

**Properties:**
| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `id` | text | read-only | Unique identifier |
| `name` | text | read/write | Task title |
| `notes` | text | read/write | Task notes/description |
| `status` | enum | read/write | open, completed, canceled |
| `creation date` | date | read-only | When task was created |
| `modification date` | date | read-only | Last modified date |
| `completion date` | date | read-only | When task was completed |
| `cancellation date` | date | read-only | When task was canceled |
| `due date` | date | read/write | When task is due |
| `activation date` | date | read/write | When task appears in Today |
| `tag names` | text | read/write | Comma-separated tag names |
| `project` | project | read/write | Parent project |
| `area` | area | read/write | Parent area |

### Project
A collection of related to-dos with a goal.

**Properties:**
| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `id` | text | read-only | Unique identifier |
| `name` | text | read/write | Project title |
| `notes` | text | read/write | Project notes |
| `status` | enum | read/write | open, completed, canceled |
| `due date` | date | read/write | Project deadline |
| `area` | area | read/write | Parent area |
| `tag names` | text | read/write | Comma-separated tags |
| `to dos` | list | read-only | List of to-dos in project |

### Area
A high-level category for organizing projects and to-dos.

**Properties:**
| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `id` | text | read-only | Unique identifier |
| `name` | text | read/write | Area name |
| `to dos` | list | read-only | Direct to-dos in area |
| `projects` | list | read-only | Projects in area |

### Tag
A label for categorizing items.

**Properties:**
| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `id` | text | read-only | Unique identifier |
| `name` | text | read/write | Tag name |
| `parent tag` | tag | read/write | Parent tag (for hierarchy) |

### List
Built-in lists in Things 3.

**Available lists:**
- `Inbox` - Default capture location
- `Today` - Tasks for today
- `Upcoming` - Future scheduled tasks
- `Anytime` - Available anytime tasks
- `Someday` - Someday/maybe tasks
- `Logbook` - Completed tasks
- `Trash` - Deleted items

## Commands

### Creating Items

```applescript
-- Create to-do
tell application "Things3"
    make new to do with properties {name:"Task name", notes:"Details"}
end tell

-- Create to-do with all properties
tell application "Things3"
    make new to do with properties {name:"Task", notes:"Details", due date:date "2025-01-15", tag names:"work, urgent"}
end tell

-- Create project
tell application "Things3"
    make new project with properties {name:"My Project", notes:"Project description"}
end tell

-- Create area
tell application "Things3"
    make new area with properties {name:"Work"}
end tell

-- Create tag
tell application "Things3"
    make new tag with properties {name:"urgent"}
end tell

-- Create child tag
tell application "Things3"
    set parentTag to tag "work"
    make new tag with properties {name:"meetings", parent tag:parentTag}
end tell
```

### Finding Items

```applescript
-- Get to-do by name
tell application "Things3"
    set t to to do "Task name"
end tell

-- Get to-do by ID
tell application "Things3"
    set t to to do id "ABC123"
end tell

-- Get all to-dos from a list
tell application "Things3"
    set todayTodos to to dos of list "Today"
end tell

-- Get to-dos from a project
tell application "Things3"
    set projectTodos to to dos of project "My Project"
end tell

-- Get to-dos with specific tag
tell application "Things3"
    set taggedTodos to to dos whose tag names contains "urgent"
end tell
```

### Modifying Items

```applescript
-- Update to-do name
tell application "Things3"
    set t to to do "Old name"
    set name of t to "New name"
end tell

-- Add notes
tell application "Things3"
    set t to to do "My Task"
    set notes of t to "Added details here"
end tell

-- Set due date
tell application "Things3"
    set t to to do "My Task"
    set due date of t to date "2025-01-20"
end tell

-- Set tags
tell application "Things3"
    set t to to do "My Task"
    set tag names of t to "work, urgent, followup"
end tell

-- Complete a to-do
tell application "Things3"
    set t to to do "My Task"
    set status of t to completed
end tell

-- Cancel a to-do
tell application "Things3"
    set t to to do "My Task"
    set status of t to canceled
end tell
```

### Moving Items

```applescript
-- Move to built-in list
tell application "Things3"
    set t to to do "My Task"
    move t to list "Today"
end tell

-- Move to project
tell application "Things3"
    set t to to do "My Task"
    set project of t to project "My Project"
end tell

-- Move to area
tell application "Things3"
    set t to to do "My Task"
    set area of t to area "Work"
end tell

-- Schedule for specific date (moves to Upcoming)
tell application "Things3"
    set t to to do "My Task"
    set activation date of t to date "2025-01-10"
end tell
```

### Deleting Items

```applescript
-- Delete to-do (moves to Trash)
tell application "Things3"
    set t to to do "My Task"
    delete t
end tell

-- Delete project
tell application "Things3"
    set p to project "Old Project"
    delete p
end tell
```

### UI Commands

```applescript
-- Show and select a to-do
tell application "Things3"
    show to do "My Task"
end tell

-- Open to-do for editing
tell application "Things3"
    set t to to do "My Task"
    edit t
end tell

-- Show Quick Entry panel
tell application "Things3"
    show quick entry panel
end tell

-- Get currently selected to-dos
tell application "Things3"
    set selectedItems to selected to dos
end tell
```

## Date Handling

AppleScript dates use natural language parsing:

```applescript
-- Specific date
date "2025-01-15"
date "January 15, 2025"
date "1/15/2025"

-- Relative dates
current date
(current date) + (7 * days)  -- 7 days from now

-- Date arithmetic
set today to current date
set nextWeek to today + (7 * days)
set nextMonth to today + (30 * days)
```

## Error Handling

```applescript
tell application "Things3"
    try
        set t to to do "Nonexistent Task"
    on error errMsg
        -- Handle error: task not found
        log "Error: " & errMsg
    end try
end tell
```

## Batch Operations

```applescript
-- Complete multiple to-dos
tell application "Things3"
    set todayTodos to to dos of list "Today"
    repeat with t in todayTodos
        if name of t contains "done" then
            set status of t to completed
        end if
    end repeat
end tell

-- Move all to-dos from one project to another
tell application "Things3"
    set oldProject to project "Old Project"
    set newProject to project "New Project"
    set projectTodos to to dos of oldProject
    repeat with t in projectTodos
        set project of t to newProject
    end repeat
end tell
```

## Sources
- [Things AppleScript Guide (PDF)](https://culturedcode.com/things/download/Things3AppleScriptGuide.pdf)
- [Things AppleScript Commands](https://culturedcode.com/things/support/articles/4562654/)
- [Using AppleScript with Things](https://culturedcode.com/things/support/articles/2803572/)
