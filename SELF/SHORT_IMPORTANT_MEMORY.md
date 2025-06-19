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

## Latest Session Notes (2025-06-19) - ASYNC ARCHITECTURE COMPLETE ✅

### CRITICAL FIX: Full Async Conversion Successfully Implemented
- **ROOT ISSUE**: Fixed "asyncio.run() cannot be called from a running event loop" error
- **APPROACH**: Complete async architecture migration throughout service layer  
- **DECISION**: Abandoned sync interface backward compatibility for clean design

### Critical Fixes Applied
1. **Database JobService**: Removed all `asyncio.run()` calls, direct async operations
2. **Route Handlers**: Fixed syntax errors and missing `await` statements  
3. **Background Worker**: Fixed job failure handling to prevent crashes
4. **Performance**: Fixed list_jobs to use proper database pagination instead of in-memory
5. **Code Quality**: Removed pip artifacts, updated gitignore

### Architecture Validation - CORRECTED zen:precommit Analysis
- **In-Memory Service**: `threading.Lock()` CORRECT for sync internals (not asyncio.Lock)
- **Database Service**: Full async for I/O operations
- **Hybrid Design**: Async interface + appropriate internal implementation  
- **Factory Pattern**: Seamless switching between implementations

### Production Status
✅ **Both Modes Working**: In-memory and database backends fully functional  
✅ **Performance Optimized**: Proper pagination eliminates database inefficiencies  
✅ **Error Handling**: Background worker stable with async job operations  
✅ **Clean Architecture**: Consistent async/await patterns throughout  

**DEPLOYMENT READY**: Complete async architecture with database integration

### Earlier: Database Migration Complete ✅
- **MAJOR MILESTONE**: Complete database implementation from DATABASE_IMPLEMENTATION_PLAN.md
- **PHASE 1-4**: All phases completed - Infrastructure, Services, Integration, Migration
- **NEW ARCHITECTURE**: Database-backed JobService with factory pattern for seamless migration
- **DEPLOYMENT**: Zero-downtime deployment via `USE_DATABASE_JOBS=true` environment variable
- **SCALABILITY**: Multi-worker support, atomic job operations, database-as-queue pattern
- **MIGRATION**: Alembic setup with initial migration for Job and JobLog tables
- **PRODUCTION FEATURES**: Connection pooling, zombie job cleanup, comprehensive logging

### Database Implementation Highlights
- **DatabaseJobService**: Drop-in replacement maintaining exact API compatibility
- **JobWorker**: Background worker with database-as-queue processing
- **Factory Pattern**: `job_service_factory.py` enables gradual rollout
- **Session Management**: Async SQLAlchemy 2.0 with proper connection pooling
- **Atomic Operations**: Thread-safe job state changes with proper locking
- **Zombie Recovery**: Automatic cleanup of interrupted jobs on application restart

### Previous Session (2025-06-18) - Jobs.py Enhancement ✅
- **MILESTONE**: Successfully completed ALL 8 jobs.py TODOs using parallel agents with git worktrees
- **PHASE 1**: Job cancellation, result retrieval, enhanced details (3 TODOs) - STABILIZED  
- **PHASE 2**: Job deletion, retry mechanism, logging, file downloads, export (5 TODOs) - COMPLETED
- **ARCHITECTURE**: Added FormatConverter & JobExporter utility classes for production features
- **THREADING**: Implemented atomic operations with threading.Lock for race condition prevention
- **QUALITY**: Applied "Stabilize, then Advance" methodology with Zen MCP code review integration

### Complete v2 API Job Management Endpoints
1. `GET /api/v2/jobs` - List all jobs with filtering (NOW WITH PROPER PAGINATION)
2. `GET /api/v2/jobs/{job_id}` - Enhanced job details with comprehensive information
3. `POST /api/v2/jobs/{job_id}/cancel` - Atomic job cancellation with proper error handling
4. `GET /api/v2/jobs/{job_id}/result` - Job result retrieval with validation
5. `DELETE /api/v2/jobs/{job_id}` - Job deletion with terminal state validation
6. `POST /api/v2/jobs/{job_id}/retry` - Job retry mechanism with configuration cloning
7. `GET /api/v2/jobs/{job_id}/logs` - Real-time job logging with timestamped entries
8. `GET /api/v2/jobs/{job_id}/download/{format}` - File downloads (JSON, v2, TavernAI formats)
9. `GET /api/v2/jobs/{job_id}/export` - Comprehensive export (JSON, YAML, CSV with debug data)

**STATUS**: ✅ ASYNC ARCHITECTURE + DATABASE + JOB MANAGEMENT COMPLETE - Production-ready system!

## Critical Execution Notes
- **⚠️ VIRTUAL ENVIRONMENT**: ALWAYS run `source .venv/bin/activate` before ANY Python commands in character-card-generator-api
- **Database Dependencies**: Project requires specific versions in venv - system packages won't work

## The Surprise Factor
Before adding info here, ask: "Would a competent engineer be surprised by this?"

---
*Last Updated: 2025-06-19*