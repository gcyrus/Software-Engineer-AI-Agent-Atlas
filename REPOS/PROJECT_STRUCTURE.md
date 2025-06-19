# PROJECT STRUCTURE

This document maintains the structural memory of all repositories and projects. It must be updated whenever files/folders are added, moved, or restructured to serve as efficient navigation and understanding guide.

## Current Projects

### CardForge AI Studio
**Frontend Application - React + TypeScript + Vite**

```
cardforge-ai-studio/
├── src/
│   ├── components/         # Reusable UI components
│   │   ├── ui/            # shadcn/ui components (button, dialog, etc.)
│   │   ├── CharacterCardDisplay.tsx
│   │   ├── ConfigurationPanel.tsx
│   │   ├── EnhancedFileUpload.tsx
│   │   ├── JobMonitor.tsx
│   │   └── ProfileFormDialog.tsx
│   ├── config/            # Application configuration
│   │   └── api.config.ts  # API endpoints and settings
│   ├── hooks/             # Custom React hooks
│   │   ├── use-api.ts
│   │   └── use-toast.ts
│   ├── services/          # API client services
│   │   ├── api.ts         # Main API service
│   │   └── websocket.ts   # WebSocket client
│   ├── types/             # TypeScript type definitions
│   │   └── api.ts         # API response/request types
│   ├── views/             # Main view components
│   │   ├── CharacterGenerator.tsx
│   │   ├── JobHistory.tsx
│   │   └── ProfileManagement.tsx
│   ├── App.tsx            # Main application component
│   └── main.tsx           # Application entry point
├── public/                # Static assets
├── package.json           # Node.js dependencies
├── vite.config.ts        # Vite configuration
├── tailwind.config.ts    # Tailwind CSS configuration
└── tsconfig.json         # TypeScript configuration
```

**Key Technologies:**
- **Framework**: React 18 with TypeScript
- **Build Tool**: Vite
- **UI Library**: shadcn/ui + Radix UI primitives
- **Styling**: Tailwind CSS
- **State Management**: React Query (TanStack Query)
- **HTTP Client**: Axios
- **Form Handling**: React Hook Form + Zod validation
- **File Upload**: react-dropzone

**Key Configuration:**
- API URL: `http://localhost:8001` (configurable via `VITE_API_URL`)
- API Version: `/api/v2` (configurable via `VITE_API_VER`)

**Important Files:**
- `src/config/api.config.ts` - Centralized API configuration
- `src/services/api.ts` - API client implementation
- `src/services/websocket.ts` - WebSocket connection management
- `src/types/api.ts` - TypeScript interfaces for API

**Last Updated:** 2025-06-19

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

**Last Updated:** 2025-06-19