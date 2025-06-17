# SHORT IMPORTANT MEMORY

## Boss Information
- **Name**: [To be filled]
- **Communication Style**: [To be filled]
- **Review Preferences**: [To be filled]

## Project Overview
- **Project Name**: Character Card Generator API
- **Main Purpose**: OpenRouter-powered REST API for AI character card generation with world-building focus
- **Target Users**: Developers integrating character generation, AI character creators, world builders
- **Current Phase**: v2.0.0 - Complete CLI parity API with 54+ options mapped to REST endpoints
- **Major Update**: v2 API implemented at `/api/v2` with full CLI functionality

## Technology Stack
- **Frontend**: CardForge AI Studio (React + TypeScript + Vite) - Integration project
- **Backend**: FastAPI with Python 3.8+, OpenRouter integration
- **Database**: SQLite (default) with async support, PostgreSQL compatible
- **Deployment**: Docker with docker-compose, supports production deployment
- **Version Control**: Git
- **Key Dependencies**: FastAPI, SQLAlchemy, Pydantic, OpenAI client, WebSockets

## Key Conventions
- **Code Style**: Black formatting (line-length 88), Ruff linting
- **API Routes**: RESTful design under `/api/v1` prefix
- **Database**: Async SQLAlchemy with proper connection pooling
- **Error Handling**: Structured error responses with ErrorResponse models
- **Rate Limiting**: Tiered (strict/standard/generous) based on endpoint criticality

## Important Resources
- **Main Repository**: `/home/grant/Software-Engineer-AI-Agent-Atlas/character-card-generator-api`
- **API Documentation**: `/api/v1/docs` (v1) and `/api/v2/docs` (v2 with CLI parity)
- **Configuration**: Dual profile system (configs/profiles + configs/prompts)
- **CLI Entry Point**: `python -m card_generator_app.main_cli`
- **API Entry Point**: `card_generator_app.api.main:app`
- **v2 API Implementation**: `card_generator_app/api/v2/` (models, routes, services)
- **v2 Test Suite**: `test_v2_api_endpoints.py`, `V2_API_TEST_GUIDE.md`

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

## Latest Session Notes (2025-06-17)
- **CRITICAL**: Fixed systematic v2 API double-prefixing bug affecting all endpoints
- **RESOLVED**: Config profile validation error (max_tokens limit increased to 100K)
- **UI IMPROVED**: Permanent configuration details panel with technical parameters
- **SIMPLIFIED**: Removed character details input block per user request
- **MAJOR FIX**: Background job processor not starting - moved lifespan from mounted v2 app to main app
- **RESOLVED**: Missing JobProgressUpdate class added to models
- **CONFIRMED**: Jobs now transition pending → running → completed correctly
- **STATUS**: Complete system functional - background processing, APIs, UI all working

---
*Last Updated: 2025-06-17*