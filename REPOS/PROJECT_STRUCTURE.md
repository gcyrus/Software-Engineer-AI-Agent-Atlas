# PROJECT STRUCTURE

This document maintains the structural memory of all repositories and projects. It must be updated whenever files/folders are added, moved, or restructured to serve as efficient navigation and understanding guide.

## Current Projects

### CardForge AI Studio
**Frontend Application - React + TypeScript + Vite**

```
cardforge-ai-studio/
├── src/
│   ├── components/         # Reusable UI components
│   │   ├── ui/            # shadcn/ui components (complete collection)
│   │   ├── CharacterCardDisplay.tsx
│   │   ├── ConfigurationPanel.tsx
│   │   ├── ConfigurationProfileForm.tsx
│   │   ├── DownloadButton.tsx
│   │   ├── EnhancedCharacterGenerator.tsx
│   │   ├── EnhancedConfigurationPanel.tsx
│   │   ├── EnhancedFileUpload.tsx
│   │   ├── ErrorBoundary.tsx
│   │   ├── FileUploadZone.tsx
│   │   ├── Header.tsx
│   │   ├── JobDetailsDialog.tsx
│   │   ├── JobHistoryCards.tsx
│   │   ├── JobHistoryEmpty.tsx
│   │   ├── JobHistoryFilters.tsx
│   │   ├── JobHistoryHeader.tsx
│   │   ├── JobHistoryList.tsx
│   │   ├── JobHistoryPagination.tsx
│   │   ├── JobHistorySkeleton.tsx
│   │   ├── JobHistoryTable.tsx
│   │   ├── JobMonitor.tsx
│   │   ├── JobMonitorCard.tsx
│   │   ├── JobResultDisplay.tsx
│   │   ├── JobResultModal.tsx
│   │   ├── MainContent.tsx
│   │   ├── MobileCharacterGenerator.tsx
│   │   ├── PreviewPanel.tsx
│   │   ├── ProfileConflictDialog.tsx
│   │   ├── ProfileFormDialog.tsx
│   │   ├── PromptProfileForm.tsx
│   │   ├── QueryErrorBoundary.tsx
│   │   ├── ResponsiveCharacterGenerator.tsx
│   │   ├── Sidebar.tsx
│   │   ├── skeletons/
│   │   │   └── CharacterCardSkeleton.tsx
│   │   └── test/
│   │       └── ComponentTest.tsx
│   ├── config/            # Application configuration
│   │   ├── api.config.ts  # API endpoints and settings
│   │   └── index.ts
│   ├── hooks/             # Custom React hooks
│   │   ├── use-api.ts
│   │   ├── use-mobile.tsx
│   │   ├── use-toast.ts
│   │   ├── useActiveJobPolling.ts
│   │   ├── useCharacterGenerator.ts
│   │   ├── useJobActions.ts
│   │   ├── useJobHistory.ts
│   │   ├── useJobUtils.ts
│   │   ├── useProfileManagement.ts
│   │   └── index.ts
│   ├── lib/               # Utility libraries
│   │   ├── query-client.ts
│   │   └── utils.ts
│   ├── pages/             # Route-level pages
│   │   ├── Index.tsx
│   │   └── NotFound.tsx
│   ├── services/          # API client services
│   │   ├── api.ts         # Main API service
│   │   ├── websocket.ts   # WebSocket client
│   │   ├── api.example.tsx
│   │   ├── README.md
│   │   └── index.ts
│   ├── types/             # TypeScript type definitions
│   │   ├── api.ts         # API response/request types
│   │   └── index.ts
│   ├── utils/             # Utility functions
│   │   └── download.ts
│   ├── views/             # Main view components
│   │   ├── CharacterGenerator.tsx
│   │   ├── HelpSupport.tsx
│   │   ├── JobHistory.tsx
│   │   └── ProfileManagement.tsx
│   ├── App.tsx            # Main application component
│   ├── App.css
│   ├── index.css
│   ├── main.tsx           # Application entry point
│   └── vite-env.d.ts
├── e2e/                   # Playwright E2E tests
│   ├── fixtures/
│   ├── pages/
│   ├── tests/
│   ├── utils/
│   └── README.md
├── public/                # Static assets
├── dist/                  # Build output
├── test-results/          # Test results
├── playwright-report/     # Playwright test reports
├── package.json           # Node.js dependencies
├── bun.lockb             # Bun lock file
├── vite.config.ts        # Vite configuration
├── tailwind.config.ts    # Tailwind CSS configuration
├── tsconfig.json         # TypeScript configuration
├── playwright.config.ts  # Playwright test configuration
├── eslint.config.js      # ESLint configuration
├── postcss.config.js     # PostCSS configuration
├── components.json       # shadcn/ui configuration
└── .mcp.json             # MCP server configuration (Playwright)
```

**Key Technologies:**
- **Framework**: React 18 with TypeScript
- **Build Tool**: Vite
- **Package Manager**: Bun (with npm fallback)
- **UI Library**: shadcn/ui + Radix UI primitives (complete collection)
- **Styling**: Tailwind CSS
- **State Management**: TanStack Query v5 (React Query)
- **HTTP Client**: Axios
- **Form Handling**: React Hook Form + Zod validation
- **File Upload**: react-dropzone
- **Testing**: Playwright E2E tests
- **Router**: React Router DOM v6

**Key Configuration:**
- API URL: `http://localhost:8000` (corrected from 8001, configurable via `VITE_API_URL`)
- API Version: `/api/v2` (configurable via `VITE_API_VER`)
- WebSocket: `ws://localhost:8000/ws`

**Important Files:**
- `src/config/api.config.ts` - Centralized API configuration
- `src/services/api.ts` - API client implementation
- `src/services/websocket.ts` - WebSocket connection management
- `src/types/api.ts` - TypeScript interfaces for API
- `e2e/` - Complete Playwright test suite for all features
- `.env.local` - Environment configuration (corrected API port)
- `.mcp.json` - MCP server configuration (Playwright browser automation)

**Latest Status (2025-06-21):** ✅ PRODUCTION READY
- Phase 1.2: Robust file upload & job processing complete
- Job History feature fully implemented and tested
- Complete API integration with v2 endpoints
- E2E test coverage with Playwright
- Mobile-responsive design

**MCP Integration:** Playwright (locally configured) + Context7 & Zen (globally available)

**Last Updated:** 2025-06-28

---

### Character Card Generator API
**Backend Application - Python FastAPI**

```
character-card-generator-api/
├── card_generator_app/     # Main application package
│   ├── api/               # FastAPI REST API
│   │   ├── main.py       # API server entry point
│   │   └── v2/           # Version 2 API (CLI parity)
│   │       ├── models/   # Pydantic models & schemas
│   │       ├── routes/   # API endpoint handlers
│   │       ├── services/ # Business logic layer
│   │       └── utils/    # Utility functions
│   ├── db/               # Database layer (NEW)
│   │   ├── models.py     # SQLAlchemy models (Job, JobLog)
│   │   └── database.py   # Session management & connection
│   ├── processing/        # Character generation engine
│   │   ├── simple_character_generator.py
│   │   ├── field_generator.py
│   │   └── character_book_updater.py
│   ├── providers/         # AI model integrations
│   │   ├── openrouter.py
│   │   └── simple_router.py
│   ├── ui/               # CLI interface components
│   │   ├── interactive_cli.py
│   │   ├── setup_wizard.py
│   │   └── profile_browser.py
│   ├── utils/            # Shared utilities
│   │   ├── debug_manager.py
│   │   ├── error_handler.py
│   │   └── performance_monitor.py
│   ├── worker.py         # Background job worker (NEW)
│   └── main_cli.py      # CLI entry point
├── alembic/              # Database migrations (NEW)
│   ├── versions/         # Migration files
│   └── env.py           # Alembic environment config
├── configs/              # Configuration files
│   ├── profiles/         # API configuration profiles
│   └── prompts/          # Generation prompt profiles
├── docs/                 # Comprehensive documentation
├── input/                # Input templates and examples
├── data/                 # File uploads and backups
├── requirements.txt      # Python dependencies
├── pyproject.toml       # Python project metadata
├── alembic.ini          # Database migration config (NEW)
├── Dockerfile.backend   # Docker configuration
└── docker-compose.yml   # Docker Compose setup
```

**Key Technologies:**
- **Framework**: FastAPI with async support
- **Database**: SQLAlchemy 2.0 + SQLite (PostgreSQL compatible) with Alembic migrations
- **Job Processing**: Database-backed with factory pattern (in-memory fallback)
- **AI Integration**: OpenRouter API (OpenAI client)
- **WebSockets**: Real-time job progress updates
- **CLI Framework**: Click + Rich + Questionary
- **Validation**: Pydantic v2
- **Rate Limiting**: SlowAPI
- **File Handling**: Pillow for TavernAI PNG export

**Key Features:**
- Dual profile system (config profiles + prompt profiles)
- Background job processing with WebSocket updates
- Multiple export formats (JSON, Character Card V2, TavernAI PNG)
- Comprehensive v2 API with complete CLI feature parity
- Enterprise-grade debugging and monitoring

**API Versions:**
- v1: Original REST API at `/api/v1`
- v2: Enhanced API with CLI parity at `/api/v2` (54+ options)

**Important Files:**
- `card_generator_app/api/main.py` - FastAPI application setup with database lifecycle
- `card_generator_app/api/v2/services/cli_mapper.py` - CLI option mapping
- `card_generator_app/api/v2/services/job_service.py` - Original in-memory job management
- `card_generator_app/api/v2/services/database_job_service.py` - Database-backed job service (NEW)
- `card_generator_app/api/v2/services/job_service_factory.py` - Service factory pattern (NEW)
- `card_generator_app/api/v2/routes/jobs.py` - Job endpoints
- `card_generator_app/db/models.py` - SQLAlchemy database models (NEW)
- `card_generator_app/db/database.py` - Session management (NEW)
- `card_generator_app/worker.py` - Background job worker (NEW)
- `alembic/env.py` - Database migration environment (NEW)
- `alembic.ini` - Migration configuration (NEW)
- `pyproject.toml` - Python project configuration

**Next Feature (2025-06-28):** Retry Logic for Character Book Updater
- Async retry mechanism with exponential backoff
- Configurable retry attempts and delays
- Enhanced error handling for OpenRouter API calls
- Integration with existing fallback behavior

**Last Updated:** 2025-06-28