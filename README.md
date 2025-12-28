# Things 3 Skill for Claude Code

A Claude Code skill that enables natural language interaction with Things 3 on macOS using AppleScript.

## Features

- Create, read, update, and delete tasks
- Manage projects and areas
- Schedule and organize tasks
- Move tasks between lists
- Complete and track tasks
- All operations return JSON for easy parsing

## Prerequisites

- macOS
- [Things 3](https://culturedcode.com/things/) installed
- [Claude Code](https://claude.com/claude-code) CLI
- AppleScript permissions granted to your terminal

## Installation

1. Clone this repository:
```bash
git clone https://github.com/YOUR_USERNAME/things3-claude-skill.git
cd things3-claude-skill
```

2. Copy the skill to your Claude skills directory:
```bash
mkdir -p ~/.claude/skills
cp -r . ~/.claude/skills/things3
```

3. Make scripts executable:
```bash
chmod +x ~/.claude/skills/things3/scripts/*.sh
```

4. Grant AppleScript permissions to your terminal app (Terminal.app or iTerm2) in System Settings > Privacy & Security > Automation

## Usage

Once installed, you can use natural language with Claude Code to manage your Things 3 tasks:

- "Add a task to Things to review the quarterly report"
- "Create a project in Things called Website Redesign"
- "Show me my tasks for today"
- "Complete the task about preparing presentation"
- "Move this task to Today"
- "Schedule the meeting task for next Monday"

## Things 3 Concepts

### Built-in Lists
- **Inbox** - Default landing spot for new tasks
- **Today** - Tasks scheduled for today
- **Upcoming** - Tasks with future dates
- **Anytime** - Tasks available anytime (no specific date)
- **Someday** - Tasks for later consideration
- **Logbook** - Completed tasks
- **Trash** - Deleted items

### Organization Hierarchy
- **Areas** - High-level life categories (Work, Personal, Health)
- **Projects** - Collections of related tasks with a goal
- **To-dos** - Individual actionable items

### Task Properties
- `name` - Task title (required)
- `notes` - Additional details
- `due date` - When the task is due
- `when date` - When to start/show the task
- `tag names` - Comma-separated tags
- `status` - open, completed, or canceled

## Available Scripts

All scripts are in the `scripts/` directory and output JSON.

### Task Operations

- **create-todo.sh** - Create a new to-do
- **list-todos.sh** - List to-dos from a specific list or project
- **list-today-by-area.sh** - List today's tasks organized by area
- **update-todo.sh** - Update properties of an existing to-do
- **complete-todo.sh** - Mark a to-do as complete
- **delete-todo.sh** - Move a to-do to trash
- **move-todo.sh** - Move a to-do to a different list, project, or area
- **schedule-todo.sh** - Schedule a to-do for a specific date
- **show-todo.sh** - Show and select a to-do in Things 3 UI

### Project & Area Operations

- **create-project.sh** - Create a new project
- **create-area.sh** - Create a new area

### Tag Operations

- **create-tag.sh** - Create a new tag

## Examples

### Create a task for today
```bash
~/.claude/skills/things3/scripts/create-todo.sh "Review quarterly report" "Check sales figures" "list:Today"
```

### Create a project with tasks
```bash
# Create the project
~/.claude/skills/things3/scripts/create-project.sh "Website Redesign" "Complete by Q2"

# Add tasks to it
~/.claude/skills/things3/scripts/create-todo.sh "Design mockups" "" "" "" "project:Website Redesign"
~/.claude/skills/things3/scripts/create-todo.sh "Review with stakeholders" "" "" "" "project:Website Redesign"
```

### Schedule a task
```bash
~/.claude/skills/things3/scripts/create-todo.sh "Prepare presentation" "" "due:2025-01-03"
```

### Complete a task
```bash
~/.claude/skills/things3/scripts/complete-todo.sh "Review quarterly report"
```

## Response Format

All scripts return JSON with:
- `success`: boolean indicating operation result
- `message`: description of what happened
- `data`: relevant data (task info, list of tasks, etc.)

Example success:
```json
{"success": true, "message": "Task created", "data": {"name": "My Task", "id": "ABC123"}}
```

Example error:
```json
{"success": false, "message": "Task not found", "data": null}
```

## Resources

- [Things 3 AppleScript Guide](https://culturedcode.com/things/support/articles/2803572/)
- [Things AppleScript Commands Reference](https://culturedcode.com/things/support/articles/4562654/)
- Complete API documentation in `references/applescript-api.md`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details

## Acknowledgments

Built for use with [Claude Code](https://claude.com/claude-code), Anthropic's official CLI for Claude.
