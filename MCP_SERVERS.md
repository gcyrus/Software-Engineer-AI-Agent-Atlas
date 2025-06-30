# MCP SERVERS - Available Tools and Capabilities

This document catalogs all Model Context Protocol (MCP) servers available to ATLAS for enhanced engineering capabilities.

## Server Configuration Status

### Locally Configured Servers (.mcp.json)
- **Playwright**: Browser automation and testing

### Globally Available Servers
- **Context7**: Documentation and library assistance  
- **Zen**: Enhanced AI reasoning and workflow capabilities

---

## 1. Playwright MCP Server
**Status**: ✅ Locally Configured  
**Browser**: Firefox  
**Purpose**: Browser automation and testing

**Core Capabilities:**
- **Browser Control**: Navigate, click, type, form interactions
- **Visual Testing**: Screenshots, PDF generation
- **Network Analysis**: Monitor requests/responses
- **File Operations**: Upload/download testing
- **Multi-tab Management**: Complex workflow testing
- **Test Generation**: Create Playwright test scripts

**ATLAS Use Cases:**
- CardForge frontend testing and validation
- End-to-end integration testing
- Visual documentation generation
- User workflow verification
- API testing through browser interface

---

## 2. Context7 MCP Server  
**Status**: ✅ Globally Available  
**Purpose**: Advanced documentation and library assistance

**Core Capabilities:**
- **Library Documentation**: Real-time access to framework docs
- **API References**: Current API documentation lookup
- **Code Examples**: Framework-specific patterns and samples
- **Best Practices**: Community standards and recommendations
- **Dependency Information**: Library compatibility and versions

**ATLAS Use Cases:**
- FastAPI/React development assistance
- OpenRouter API reference during integration
- SQLAlchemy and Pydantic best practices
- shadcn/ui component documentation
- Real-time library feature validation

**Key Commands:**
- `resolve-library-id`: Find library identifiers
- `get-library-docs`: Fetch documentation for specific libraries

---

## 3. Zen MCP Server
**Status**: ✅ Globally Available  
**Purpose**: Enhanced AI reasoning and systematic workflows

**Core Capabilities:**
- **Deep Analysis**: `thinkdeep` - Multi-stage investigation and reasoning
- **Code Review**: `codereview` - Systematic code analysis workflow
- **Debug Analysis**: `debug` - Structured debugging methodologies
- **Planning**: `planner` - Sequential task breakdown and planning
- **Consensus**: `consensus` - Multi-model perspective gathering
- **Code Tracing**: `tracer` - Flow analysis and dependency mapping
- **Test Generation**: `testgen` - Comprehensive test suite creation
- **Refactoring**: `refactor` - Code improvement analysis
- **Pre-commit**: `precommit` - Git change validation

**ATLAS Use Cases:**
- **Architecture Decisions**: Multi-perspective analysis via `consensus`
- **Complex Debugging**: Systematic investigation via `debug`
- **Code Quality**: Comprehensive reviews via `codereview`
- **Feature Planning**: Step-by-step breakdown via `planner`
- **Performance Analysis**: Deep investigation via `thinkdeep`
- **Integration Strategy**: Multi-step planning workflows

---

## Integrated Workflow Patterns

### Development Workflow
```
1. Zen Planning (`planner`) → Feature breakdown
2. Context7 Research (`get-library-docs`) → API documentation
3. Implementation → Code development
4. Zen Review (`codereview`) → Quality validation
5. Playwright Testing → Integration verification
```

### Debugging Process
```
1. Issue Identification → Problem description
2. Zen Debug (`debug`) → Systematic investigation
3. Context7 Reference → Documentation lookup
4. Playwright Reproduction → Browser-based testing
5. Resolution → Fix implementation
```

### Architecture Decision Making
```
1. Zen Consensus (`consensus`) → Multi-perspective analysis
2. Context7 Research → Best practices lookup
3. Zen Deep Thinking (`thinkdeep`) → Comprehensive evaluation
4. Implementation → Architecture implementation
5. Playwright Validation → Integration testing
```

### Current Priority: Retry Logic Implementation
**Perfect MCP Workflow:**
1. **Zen Planning**: Break down retry logic implementation
2. **Context7 Documentation**: Look up asyncio best practices
3. **Zen Code Review**: Validate implementation approach
4. **Implementation**: Async retry mechanism
5. **Playwright Testing**: Test retry behavior in integrated system

---

## MCP Command Reference

### Frequently Used Commands

**Context7:**
- `resolve-library-id "fastapi"` - Find FastAPI library ID
- `get-library-docs "/fastapi/fastapi"` - Get FastAPI documentation

**Zen Workflows:**
- `thinkdeep` - Complex problem analysis
- `debug` - Systematic debugging
- `codereview` - Code quality analysis
- `planner` - Feature implementation planning
- `consensus` - Multi-model decision validation

**Playwright:**
- `browser_navigate` - Navigate to URLs
- `browser_snapshot` - Capture page state
- `browser_click` - Interact with elements
- `browser_take_screenshot` - Visual documentation

---

## Best Practices

### When to Use Each Server

**Use Context7 when:**
- Learning new library features
- Checking API compatibility
- Looking up current best practices
- Validating dependency choices

**Use Zen when:**
- Making complex architectural decisions
- Debugging hard-to-reproduce issues
- Planning multi-step implementations
- Reviewing code quality systematically

**Use Playwright when:**
- Testing frontend functionality
- Validating user workflows
- Creating visual documentation
- Testing API endpoints through UI

### Efficiency Tips
- **Chain Commands**: Use Zen planning → Context7 research → Implementation
- **Document Findings**: Save important insights to working logs
- **Test Integration**: Validate with Playwright after implementation
- **Iterate**: Use feedback loops between servers for complex problems

---

## Integration with ATLAS Workflows

### Professional Mode Protocol
When engaged in complex engineering tasks:
1. **Zen Planning**: Systematic task breakdown
2. **Context7 Research**: Documentation and best practices
3. **Focused Implementation**: Apply learned patterns
4. **Zen Review**: Quality validation before staging
5. **Playwright Testing**: Integration verification

### Git Commitment Protocol
Enhanced with MCP capabilities:
1. **Zen Pre-commit Analysis**: Systematic change review
2. **Context7 Validation**: Ensure patterns follow best practices
3. **Self-Review**: Traditional code review process
4. **Playwright Testing**: Functional validation
5. **Stage and Request Review**: Following established protocol

---

**Configuration:**
- **Playwright**: Locally configured in `.mcp.json`
- **Context7 & Zen**: Globally available, no local configuration needed

**Last Updated:** 2025-06-28  
**Maintained By:** ATLAS (Software Engineer AI Entity)