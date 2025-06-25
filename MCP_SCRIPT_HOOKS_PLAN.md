# MCP Server for Claude Code External Script Hooks

## Overview
Create an MCP (Model Context Protocol) server that runs external scripts when Claude Code needs user input (file edits, planning mode transitions, etc.).

## Architecture

```
Claude Code
    |
    v
MCP Server (claude-script-hooks)
    |
    +-- Tool Overrides (Edit, Write, exit_plan_mode)
    |
    +-- Script Execution Engine
    |
    +-- Configuration System
    |
    v
External Scripts (user-defined)
```

## Implementation Phases

### Phase 1: MCP Foundation
- Set up Python project with MCP SDK
- Create basic server with tool call logging
- Test MCP connection with Claude Code
- Validate tool discovery and calling

### Phase 2: Script Execution Engine
- Implement ScriptRunner class with safety features
- Add timeout and sandboxing capabilities
- Create configuration loading system
- Build example scripts for testing

### Phase 3: Tool Overrides
- Override Edit tool (file modifications)
- Override Write tool (new file creation)
- Override exit_plan_mode tool (planning transitions)
- Maintain original functionality while adding hooks

### Phase 4: Integration & Testing
- End-to-end testing with real Claude Code workflows
- Performance validation (no Claude slowdown)
- Error handling and edge case testing
- User experience validation

## Key Features

### Tool Override Strategy
- Same function signatures as Claude's built-in tools
- Execute original functionality first
- Trigger scripts only on successful operations
- Asynchronous script execution (non-blocking)

### Safety & Security
- Script execution timeouts (configurable)
- Sandboxed execution environment
- Error isolation (script failures don't break Claude)
- User approval for script additions

### User Experience
```bash
# Installation
pip install claude-script-hooks
claude mcp add claude-script-hooks

# Configuration
claude-script-hooks config add file_edit ./scripts/notify.sh
```

## Technical Details

### Script Runner Architecture
```python
class ScriptRunner:
    def __init__(self, config):
        self.timeout = config.get('timeout', 30)  # 30s default
        self.working_dir = config.get('working_dir', os.getcwd())
        self.env_vars = config.get('env_vars', {})
    
    async def execute_scripts(self, event_type: str, context: dict):
        scripts = self.config.get_scripts_for_event(event_type)
        tasks = [self._run_script(script, context) for script in scripts]
        await asyncio.gather(*tasks, return_exceptions=True)
```

### Tool Override Example
```python
@server.call_tool()
async def edit_file(file_path: str, old_string: str, new_string: str, replace_all: bool = False):
    # 1. Execute original functionality
    try:
        result = await original_edit_tool(file_path, old_string, new_string, replace_all)
        
        # 2. If successful, trigger scripts
        context = {
            "file_path": file_path,
            "operation": "edit",
            "old_content": old_string,
            "new_content": new_string,
            "timestamp": datetime.now().isoformat()
        }
        
        # 3. Run scripts asynchronously (don't block Claude)
        asyncio.create_task(script_runner.execute_scripts("file_edit", context))
        
        return result
        
    except Exception as e:
        # Original operation failed - don't run scripts
        raise e
```

### Configuration Format
```json
{
  "events": {
    "file_edit": {
      "scripts": [
        {
          "path": "./scripts/notify_edit.sh",
          "timeout": 10,
          "async": true
        }
      ]
    },
    "plan_exit": {
      "scripts": ["./scripts/save_plan.py"]
    }
  },
  "global": {
    "timeout": 30,
    "working_dir": ".",
    "env_vars": {
      "CLAUDE_EVENT": "true"
    }
  }
}
```

## Example Scripts

### Desktop Notification
```bash
#!/bin/bash
# scripts/notify-edit.sh - Desktop notification on file edit
notify-send "Claude Code" "File edited: $CLAUDE_FILE_PATH"
```

### Auto-backup
```python
#!/usr/bin/env python3
# scripts/backup-on-edit.py - Auto-backup on file changes
import os, shutil
file_path = os.environ['CLAUDE_FILE_PATH']
backup_path = f"{file_path}.backup.{os.environ['CLAUDE_TIMESTAMP']}"
shutil.copy2(file_path, backup_path)
```

### Team Notification
```bash
#!/bin/bash
# scripts/slack-notify.sh - Team notification
curl -X POST "$SLACK_WEBHOOK" -d "{\"text\":\"Claude edited: $CLAUDE_FILE_PATH\"}"
```

## Project Structure
```
claude-script-hooks/
├── src/
│   ├── server.py           # Main MCP server entry point
│   ├── config.py           # Configuration management
│   ├── script_runner.py    # Safe script execution
│   ├── tools/              # Enhanced tool implementations
│   │   ├── edit_tool.py
│   │   ├── write_tool.py
│   │   └── plan_tool.py
│   └── utils/
│       ├── logging.py
│       └── validation.py
├── config/
│   └── hooks.json          # Event-to-script mappings
├── scripts/
│   └── examples/           # Example scripts
└── setup.py
```

## Risk Mitigation

### Risk 1: MCP Tool Override May Not Work
- **Mitigation**: Research MCP protocol thoroughly before starting; create proof-of-concept first
- **Fallback**: Pivot to notification-based MCP tools that Claude explicitly calls

### Risk 2: Performance Impact on Claude Code
- **Mitigation**: Async script execution, timeouts, performance testing in Phase 4
- **Fallback**: Add performance monitoring and script execution throttling

### Risk 3: Security Concerns with Script Execution
- **Mitigation**: Sandboxing, timeout limits, user approval for script additions
- **Fallback**: Restricted execution environment or whitelist-only scripts

### Risk 4: Claude Code Updates Breaking Compatibility
- **Mitigation**: Use official MCP SDK, follow MCP standards, version compatibility testing
- **Fallback**: Maintain compatibility matrix and quick update process

## Success Criteria
1. **Functional**: Scripts execute on 100% of file edits and plan exits
2. **Performance**: No perceptible delay in Claude Code operations
3. **Reliability**: Zero crashes or hangs caused by script execution
4. **Usability**: Users can configure hooks in under 5 minutes
5. **Adoption**: Clear value demonstrated through example use cases

## Development Timeline
- **Phase 1 (MCP Foundation)**: 1-2 days
- **Phase 2 (Script Engine)**: 1 day  
- **Phase 3 (Tool Overrides)**: 2-3 days
- **Phase 4 (Testing & Polish)**: 1-2 days

**Total Estimated Duration**: 5-8 days

## Next Steps
1. Research MCP Python SDK and tool override capabilities
2. Create minimal MCP server that logs tool calls
3. Test if Claude Code will use our tools instead of built-ins
4. Begin implementation following the phased approach outlined above