# SHORT IMPORTANT MEMORY

## Information Entropy Note
This file should capture **non-obvious, surprising information** that you'll need frequently. Focus on things that differ from standard practices or would surprise a new team member.

## Boss Information
- **Name**: Grant
- **Communication Style**: [To be filled - especially quirks or preferences]
- **Review Preferences**: [To be filled - what they focus on, pet peeves]

## Project Overview
- **Project Name**: Character Card Generator API
- **Main Purpose**: OpenRouter-powered REST API for AI character card generation with world-building focus
- **Target Users**: Developers integrating character generation, AI character creators, world builders
- **Current Phase**: v2.0.0 - Complete CLI parity API with 54+ options mapped to REST endpoints
- **Major Update**: v2 API implemented at `/api/v2` with full CLI functionality
- **Hidden Complexity**: Dual profile system (config vs prompt profiles) that confuses newcomers
- **NEW (2025-06-19)**: Complete database migration implemented - can use persistent storage via `USE_DATABASE_JOBS=true`

## Technology Stack
- **Frontend**: CardForge AI Studio (React + TypeScript + Vite) - Integration project
- **Backend**: FastAPI with Python 3.8+, OpenRouter integration
- **Database**: SQLite (default) with async support, PostgreSQL compatible. NEW: Full database migration implemented with JobService factory pattern
- **Deployment**: Docker with docker-compose, supports production deployment
- **Version Control**: Git
- **Key Dependencies**: FastAPI, SQLAlchemy 2.0, Pydantic, OpenAI client, WebSockets, Alembic (migrations)
- **Gotchas**: OpenRouter API keys required; rate limiting varies by model

## Key Conventions
- **Code Style**: Black formatting (line-length 88), Ruff linting
- **API Routes**: RESTful design under `/api/v1` and `/api/v2` prefixes
- **Branch Naming**: feature/description, fix/issue-description, chore/task-description
- **Commit Message Format**: type: concise description (e.g., 'feat: add job retry endpoint', 'fix: resolve websocket disconnect issue')
- **PR Process**: Create PR with clear description → Self-review changes → Request Grant's review → Address feedback → Merge after approval
- **Database**: Async SQLAlchemy with proper connection pooling
- **Error Handling**: Structured error responses with ErrorResponse models
- **Rate Limiting**: Tiered (strict/standard/generous) based on endpoint criticality
- **Unwritten Rules**: Always test with both SQLite and PostgreSQL before deploying

## Important Resources
- **Main Repository**: `/home/grant/Software-Engineer-AI-Agent-Atlas/character-card-generator-api`
- **API Documentation**: `/api/v1/docs` (v1) and `/api/v2/docs` (v2 with CLI parity)
- **Configuration**: Dual profile system (configs/profiles + configs/prompts)
- **CLI Entry Point**: `python -m card_generator_app.main_cli`
- **API Entry Point**: `card_generator_app.api.main:app`
- **v2 API Implementation**: `card_generator_app/api/v2/` (models, routes, services)
- **v2 Test Suite**: `test_v2_api_endpoints.py`, `V2_API_TEST_GUIDE.md`
- **Staging Environment**: [To be filled]
- **Production Environment**: [To be filled]
- **Hidden Dependencies**: OpenRouter API for all model inference

## Critical Notes
- **Integrated System**: Backend API + CardForge frontend for complete workflow
- **OpenRouter Integration**: Single provider system with task-based model routing
- **Profile System**: Two-tier (config profiles for API settings, prompt profiles for generation instructions)
- **Job Management**: Background processing with WebSocket progress updates
- **File Handling**: Support for multiple formats (JSON, Character Card V2, TavernAI PNG)
- **Security**: Rate limiting, input validation, API key management
- **Database Schema**: JobModel (job tracking), ConfigCacheModel (profile cache), APIKeyUsageModel (usage analytics)
- **CLI Features**: Interactive mode, setup wizard, profile management, debug system
- **v2 API Features**: Complete CLI parity (54+ options), enhanced validation, service layer architecture
- **v2 Key Services**: CLIConfigMapper (option mapping), JobService (background processing), GenerationService (coordination)

## Latest Session Notes (2025-06-28) - SYSTEM STATUS UPDATE ✅

### Current Project Status - PRODUCTION READY SYSTEMS
**CardForge AI Studio Frontend**: ✅ PRODUCTION READY (since 2025-06-21)
- Phase 1.2 implementation complete with robust file upload & job processing
- Complete job history feature with real-time updates
- Full API integration with v2 endpoints verified
- Playwright E2E test coverage implemented
- Mobile-responsive design tested and working
- Environment configuration corrected (API port 8000)

**Character Card Generator API**: ✅ PRODUCTION READY with Database Backend
- Complete async architecture with database integration
- Full v2 API with CLI feature parity (54+ options)
- Database-backed job service with factory pattern
- Zero-downtime deployment capability via environment variables
- Comprehensive job management endpoints (9 total)
- Real-time WebSocket updates for job progress

### Next Development Priority (2025-06-28)
**Retry Logic for Character Book Updater** - Requirements Specification Complete
- Async retry mechanism with configurable exponential backoff
- Enhanced error handling for OpenRouter API transient failures
- Integration with existing fallback behavior
- Configuration via `retry_config` in config files
- Target: Improve character book quality by handling temporary API issues

### Integration Status Summary
✅ **Frontend-Backend Integration**: Complete and tested
✅ **Database Migration**: Fully implemented with Alembic
✅ **Job Processing**: Async architecture with proper error handling
✅ **API Endpoints**: Complete v2 API with CLI parity
✅ **WebSocket Support**: Real-time updates working
✅ **Testing Coverage**: E2E tests with Playwright
✅ **Mobile Support**: Responsive design verified
✅ **Production Features**: Rate limiting, error boundaries, monitoring

### Architecture Highlights
- **Dual Profile System**: Config profiles (API settings) + Prompt profiles (generation instructions)
- **Factory Pattern**: Seamless switching between in-memory and database job services
- **Async Processing**: Complete async/await architecture throughout
- **Error Resilience**: Multi-layer error handling with graceful degradation
- **Scalability**: Database-as-queue pattern supports multi-worker deployment

### Recent Session (2025-06-21) - Job History Implementation Complete ✅
- **CRITICAL FIX**: Environment configuration corrected (port 8000 vs 8001)
- **PAGINATION**: Fixed frontend hooks to use offset/limit instead of page-based pagination
- **API INTEGRATION**: Complete end-to-end functionality verified
- **TESTING**: Real browser testing with Playwright confirmed working
- **PRODUCTION STATUS**: Job History feature ready for production deployment

### Earlier Sessions Summary
**2025-06-19**: Complete async architecture conversion with database integration
**2025-06-18**: All 8 v2 API job management endpoints implemented
**Phase History**: Database migration → Async conversion → Job endpoints → Frontend integration → Testing

**DEPLOYMENT STATUS**: ✅ BOTH SYSTEMS PRODUCTION READY - Ready for user testing and deployment

## Available MCP Servers
- **Playwright**: ✅ Locally configured - Browser automation, testing, screenshots
- **Context7**: ✅ Globally available - Real-time documentation, API references, best practices
- **Zen**: ✅ Globally available - Enhanced reasoning, systematic workflows, multi-model consensus

**Key Zen Commands**: `thinkdeep`, `debug`, `codereview`, `planner`, `consensus`, `precommit`
**Integration Pattern**: Zen planning → Context7 research → Implementation → Zen review → Playwright testing

## Critical Execution Notes
- **⚠️ VIRTUAL ENVIRONMENT**: ALWAYS run `source .venv/bin/activate` before ANY Python commands in character-card-generator-api
- **Database Dependencies**: Project requires specific versions in venv - system packages won't work

## The Surprise Factor
Before adding info here, ask: "Would a competent engineer be surprised by this?"

---
*Last Updated: 2025-06-28*