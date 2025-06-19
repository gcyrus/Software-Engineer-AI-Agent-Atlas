# Database Implementation Plan for Character Card Generator API

## Executive Summary

The Character Card Generator API currently stores all job data in memory, causing complete data loss on server restart. This plan implements a robust SQLAlchemy 2.0 async database layer supporting both SQLite (development) and PostgreSQL (production), with proper multi-worker support and atomic job processing.

## Critical Issues Addressed

1. **No Persistence** - All job data is lost on server restart
2. **Threading.Lock in Async Code** - Current implementation uses `threading.Lock` which blocks the event loop
3. **Multi-Worker Conflicts** - In-memory queue fails with multiple worker processes
4. **Memory Inefficiency** - Job listing loads all jobs into memory before filtering

## Architecture Overview

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   FastAPI App   │────▶│   JobService    │────▶│    Database     │
│   (Endpoints)   │     │   (Stateless)   │     │  (PostgreSQL/   │
└─────────────────┘     └─────────────────┘     │    SQLite)     │
                               ▲                 └─────────────────┘
                               │                          ▲
                        ┌──────┴────────┐                │
                        │  Worker Loop  │────────────────┘
                        │ (Background)  │
                        └───────────────┘
```

## Implementation Phases

### Phase 1: Database Models & Infrastructure

#### 1.1 Database Models (`card_generator_app/db/models.py`)

```python
from sqlalchemy import String, DateTime, Float, Integer, ForeignKey, JSON
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy.ext.asyncio import AsyncAttrs
import uuid
from datetime import datetime
from typing import List, Any

class Base(AsyncAttrs, DeclarativeBase):
    """Base class for SQLAlchemy models with async support."""
    pass

class Job(Base):
    __tablename__ = "jobs"

    # Primary key
    id: Mapped[uuid.UUID] = mapped_column(
        PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    
    # Job metadata
    job_type: Mapped[str] = mapped_column(String(100), index=True, nullable=False)
    status: Mapped[str] = mapped_column(String(50), index=True, nullable=False)
    priority: Mapped[str] = mapped_column(String(50), nullable=False, default="normal")
    progress: Mapped[float] = mapped_column(Float, default=0.0)
    
    # Job data (JSONB in PostgreSQL, JSON in SQLite)
    job_data: Mapped[dict[str, Any] | None] = mapped_column(JSON)
    result: Mapped[dict[str, Any] | None] = mapped_column(JSON)
    error_message: Mapped[str | None] = mapped_column(String)
    error_details: Mapped[dict[str, Any] | None] = mapped_column(JSON)
    
    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow, index=True
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow
    )
    started_at: Mapped[datetime | None] = mapped_column(DateTime)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime)
    
    # Configuration
    timeout_seconds: Mapped[int] = mapped_column(Integer, default=300)
    retry_of_job_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("jobs.id"), nullable=True
    )
    
    # Relationships
    logs: Mapped[List["JobLog"]] = relationship(
        "JobLog", back_populates="job", cascade="all, delete-orphan", 
        lazy="selectin"  # Eagerly load logs with job
    )

class JobLog(Base):
    __tablename__ = "job_logs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    job_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("jobs.id"), index=True, nullable=False
    )
    timestamp: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    message: Mapped[str] = mapped_column(String, nullable=False)
    
    # Relationship
    job: Mapped["Job"] = relationship("Job", back_populates="logs")
```

#### 1.2 Database Session Manager (`card_generator_app/db/database.py`)

```python
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from typing import AsyncGenerator
import logging

logger = logging.getLogger(__name__)

class DatabaseSessionManager:
    """Manages database connections and sessions."""
    
    def __init__(self, database_url: str, engine_kwargs: dict = None):
        if engine_kwargs is None:
            engine_kwargs = {}
            
        self._engine = create_async_engine(database_url, **engine_kwargs)
        self._sessionmaker = async_sessionmaker(
            autocommit=False,
            expire_on_commit=False,  # Critical for async operations
            bind=self._engine
        )

    async def close(self):
        """Close all database connections."""
        if self._engine is None:
            raise Exception("DatabaseSessionManager is not initialized")
        await self._engine.dispose()
        logger.info("Database connections closed")

    async def get_session(self) -> AsyncGenerator[AsyncSession, None]:
        """Get a database session with automatic transaction management."""
        async with self._sessionmaker() as session:
            try:
                yield session
                await session.commit()
            except Exception:
                await session.rollback()
                raise
            finally:
                await session.close()

    async def create_all(self):
        """Create all database tables."""
        from .models import Base
        async with self._engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
            logger.info("Database tables created")
```

#### 1.3 FastAPI Dependency (`card_generator_app/db/session.py`)

```python
from fastapi import Request
from typing import AsyncGenerator
from sqlalchemy.ext.asyncio import AsyncSession

async def get_db_session(request: Request) -> AsyncGenerator[AsyncSession, None]:
    """FastAPI dependency to provide database sessions."""
    session_manager = request.app.state.db_session_manager
    async with session_manager.get_session() as session:
        yield session
```

#### 1.4 Configuration (`card_generator_app/core/config.py`)

```python
from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    # Database
    DATABASE_URL: str = "sqlite+aiosqlite:///./jobs.db"
    DATABASE_ECHO: bool = False
    
    # PostgreSQL-specific settings
    DATABASE_POOL_SIZE: int = 5
    DATABASE_MAX_OVERFLOW: int = 10
    
    # Worker settings
    WORKER_POLL_INTERVAL: float = 2.0
    WORKER_MAX_CONCURRENT_JOBS: int = 5
    
    # Job settings
    JOB_DEFAULT_TIMEOUT: int = 300
    JOB_CLEANUP_DAYS: int = 30
    
    class Config:
        env_file = ".env"

settings = Settings()
```

### Phase 2: Refactor JobService

#### 2.1 Remove In-Memory State

The current `JobService` needs complete refactoring:

**Before:**
```python
class JobService:
    def __init__(self):
        self.jobs: Dict[str, JobData] = {}  # REMOVE
        self.job_queue: List[str] = []      # REMOVE
        self.running_jobs: Dict[str, asyncio.Task] = {}  # REMOVE
        self._lock = threading.Lock()       # REPLACE with asyncio.Lock
```

**After:**
```python
class JobService:
    def __init__(self, session_manager: DatabaseSessionManager):
        self.session_manager = session_manager
        self._task_lock = asyncio.Lock()  # For managing running tasks only
        self._running_tasks: Dict[str, asyncio.Task] = {}  # Track active tasks
```

#### 2.2 Database CRUD Operations (`card_generator_app/db/crud_jobs.py`)

```python
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, and_
from typing import List, Optional
from datetime import datetime
from ..models import Job, JobLog
from ...api.v2.models.enums import JobStatus

async def create_job(
    db: AsyncSession,
    job_type: str,
    job_data: dict,
    priority: str = "normal",
    timeout_seconds: int = 300
) -> Job:
    """Create a new job in the database."""
    job = Job(
        job_type=job_type,
        status=JobStatus.PENDING,
        priority=priority,
        job_data=job_data,
        timeout_seconds=timeout_seconds
    )
    db.add(job)
    await db.flush()  # Get the ID without committing
    return job

async def get_job(db: AsyncSession, job_id: str) -> Optional[Job]:
    """Get a job by ID with its logs."""
    result = await db.execute(
        select(Job).where(Job.id == job_id)
    )
    return result.scalar_one_or_none()

async def list_jobs(
    db: AsyncSession,
    status: Optional[JobStatus] = None,
    job_type: Optional[str] = None,
    limit: int = 50,
    offset: int = 0
) -> List[Job]:
    """List jobs with database-side filtering and pagination."""
    query = select(Job)
    
    # Build filters
    filters = []
    if status:
        filters.append(Job.status == status.value)
    if job_type:
        filters.append(Job.job_type == job_type)
    
    if filters:
        query = query.where(and_(*filters))
    
    # Order and paginate
    query = query.order_by(Job.created_at.desc()).offset(offset).limit(limit)
    
    result = await db.execute(query)
    return result.scalars().all()

async def update_job_status(
    db: AsyncSession,
    job_id: str,
    status: JobStatus,
    error_message: Optional[str] = None,
    result: Optional[dict] = None
) -> Optional[Job]:
    """Update job status and related fields."""
    job = await get_job(db, job_id)
    if not job:
        return None
    
    job.status = status.value
    job.updated_at = datetime.utcnow()
    
    if status == JobStatus.RUNNING:
        job.started_at = datetime.utcnow()
    elif status in [JobStatus.COMPLETED, JobStatus.FAILED, JobStatus.CANCELLED]:
        job.completed_at = datetime.utcnow()
    
    if error_message:
        job.error_message = error_message
    if result:
        job.result = result
    
    await db.flush()
    return job

async def add_job_log(
    db: AsyncSession,
    job_id: str,
    message: str
) -> JobLog:
    """Add a log entry to a job."""
    log = JobLog(job_id=job_id, message=message)
    db.add(log)
    await db.flush()
    return log

async def claim_next_job(db: AsyncSession) -> Optional[Job]:
    """Atomically claim the next pending job for processing."""
    # PostgreSQL-specific query with SKIP LOCKED
    if "postgresql" in str(db.bind.url):
        query = (
            select(Job)
            .where(Job.status == JobStatus.PENDING)
            .order_by(Job.priority.desc(), Job.created_at.asc())
            .limit(1)
            .with_for_update(skip_locked=True)
        )
    else:
        # SQLite fallback - less concurrent but functional
        query = (
            select(Job)
            .where(Job.status == JobStatus.PENDING)
            .order_by(Job.priority.desc(), Job.created_at.asc())
            .limit(1)
        )
    
    result = await db.execute(query)
    job = result.scalar_one_or_none()
    
    if job:
        job.status = JobStatus.RUNNING
        job.started_at = datetime.utcnow()
        await db.flush()
    
    return job
```

#### 2.3 Worker Loop (`card_generator_app/worker.py`)

```python
import asyncio
import logging
from datetime import datetime
from typing import Optional
from .db.crud_jobs import claim_next_job
from .db.database import DatabaseSessionManager
from .api.v2.models.enums import JobStatus

logger = logging.getLogger(__name__)

class JobWorker:
    """Background worker that processes jobs from the database queue."""
    
    def __init__(
        self,
        session_manager: DatabaseSessionManager,
        job_service,  # The refactored JobService
        max_concurrent_jobs: int = 5,
        poll_interval: float = 2.0
    ):
        self.session_manager = session_manager
        self.job_service = job_service
        self.max_concurrent_jobs = max_concurrent_jobs
        self.poll_interval = poll_interval
        self._running_jobs: set[str] = set()
        self._shutdown = False

    async def process_job(self, job_id: str):
        """Process a single job."""
        try:
            self._running_jobs.add(job_id)
            logger.info(f"Starting job {job_id}")
            
            # JobService.execute_job will handle all the job logic
            async with self.session_manager.get_session() as session:
                await self.job_service.execute_job(job_id, session)
                
        except Exception as e:
            logger.error(f"Error processing job {job_id}: {e}", exc_info=True)
        finally:
            self._running_jobs.discard(job_id)

    async def run(self):
        """Main worker loop."""
        logger.info("Job worker started")
        
        while not self._shutdown:
            try:
                # Check if we can process more jobs
                if len(self._running_jobs) >= self.max_concurrent_jobs:
                    await asyncio.sleep(self.poll_interval)
                    continue
                
                # Try to claim a job
                async with self.session_manager.get_session() as session:
                    job = await claim_next_job(session)
                    
                if job:
                    # Launch job processing as background task
                    asyncio.create_task(self.process_job(str(job.id)))
                else:
                    # No jobs available, wait before polling again
                    await asyncio.sleep(self.poll_interval)
                    
            except Exception as e:
                logger.error(f"Worker loop error: {e}", exc_info=True)
                await asyncio.sleep(self.poll_interval)
        
        # Wait for running jobs to complete
        while self._running_jobs:
            logger.info(f"Waiting for {len(self._running_jobs)} jobs to complete...")
            await asyncio.sleep(1)
        
        logger.info("Job worker stopped")

    def shutdown(self):
        """Signal the worker to shut down."""
        self._shutdown = True
```

### Phase 3: Application Integration

#### 3.1 Main Application Setup (`card_generator_app/api/main.py`)

```python
from fastapi import FastAPI
from contextlib import asynccontextmanager
import asyncio
import logging
from ..db.database import DatabaseSessionManager
from ..db.crud_jobs import update_job_status
from ..core.config import settings
from ..worker import JobWorker
from .v2.services.job_service import JobService
from .v2.models.enums import JobStatus

logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage application lifecycle."""
    # Startup
    logger.info("Starting application...")
    
    # Initialize database
    app.state.db_session_manager = DatabaseSessionManager(
        settings.DATABASE_URL,
        {
            "echo": settings.DATABASE_ECHO,
            "pool_size": settings.DATABASE_POOL_SIZE,
            "max_overflow": settings.DATABASE_MAX_OVERFLOW,
        }
    )
    
    # Create tables if they don't exist
    await app.state.db_session_manager.create_all()
    
    # Handle zombie jobs (mark RUNNING jobs as FAILED)
    async with app.state.db_session_manager.get_session() as session:
        from sqlalchemy import select
        from ..db.models import Job
        
        result = await session.execute(
            select(Job).where(Job.status == JobStatus.RUNNING)
        )
        zombie_jobs = result.scalars().all()
        
        for job in zombie_jobs:
            await update_job_status(
                session,
                str(job.id),
                JobStatus.FAILED,
                error_message="Job failed due to system restart"
            )
        
        if zombie_jobs:
            logger.info(f"Marked {len(zombie_jobs)} zombie jobs as FAILED")
    
    # Initialize services
    app.state.job_service = JobService(app.state.db_session_manager)
    
    # Start worker
    app.state.job_worker = JobWorker(
        app.state.db_session_manager,
        app.state.job_service,
        max_concurrent_jobs=settings.WORKER_MAX_CONCURRENT_JOBS,
        poll_interval=settings.WORKER_POLL_INTERVAL
    )
    app.state.worker_task = asyncio.create_task(app.state.job_worker.run())
    
    yield
    
    # Shutdown
    logger.info("Shutting down application...")
    
    # Stop worker
    app.state.job_worker.shutdown()
    await app.state.worker_task
    
    # Close database connections
    await app.state.db_session_manager.close()

app = FastAPI(
    title="Character Card Generator API",
    version="2.0.0",
    lifespan=lifespan
)
```

#### 3.2 Updated API Endpoints

Example of updated endpoint pattern:

```python
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from ....db.session import get_db_session
from ....db.crud_jobs import get_job, list_jobs, create_job
from ..models.job_models import JobResponse, JobCreateRequest

router = APIRouter(prefix="/api/v2/jobs", tags=["jobs"])

@router.get("/", response_model=List[JobResponse])
async def get_jobs(
    status: Optional[str] = None,
    job_type: Optional[str] = None,
    limit: int = 50,
    offset: int = 0,
    db: AsyncSession = Depends(get_db_session)
):
    """List all jobs with optional filtering."""
    jobs = await list_jobs(
        db,
        status=JobStatus(status) if status else None,
        job_type=job_type,
        limit=limit,
        offset=offset
    )
    return [JobResponse.from_orm(job) for job in jobs]

@router.get("/{job_id}", response_model=JobResponse)
async def get_job_details(
    job_id: str,
    db: AsyncSession = Depends(get_db_session)
):
    """Get detailed information about a specific job."""
    job = await get_job(db, job_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    return JobResponse.from_orm(job)
```

### Phase 4: Testing Strategy

#### 4.1 Test Configuration

```python
# tests/conftest.py
import pytest
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
import asyncio

@pytest.fixture(scope="session")
def event_loop():
    """Create an instance of the default event loop for the test session."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()

@pytest.fixture
async def test_db():
    """Create a test database."""
    engine = create_async_engine("sqlite+aiosqlite:///:memory:")
    
    # Create tables
    from card_generator_app.db.models import Base
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    # Create session
    async_session = sessionmaker(
        engine, class_=AsyncSession, expire_on_commit=False
    )
    
    async with async_session() as session:
        yield session
        await session.rollback()
    
    await engine.dispose()
```

#### 4.2 Multi-Worker Test

```python
# tests/test_worker_concurrency.py
import asyncio
import pytest
from card_generator_app.db.crud_jobs import create_job, claim_next_job

@pytest.mark.asyncio
async def test_concurrent_job_claiming(test_db):
    """Test that multiple workers don't claim the same job."""
    # Create 10 jobs
    for i in range(10):
        await create_job(
            test_db,
            job_type="test",
            job_data={"index": i}
        )
    await test_db.commit()
    
    # Simulate 3 workers trying to claim jobs concurrently
    claimed_jobs = []
    
    async def worker():
        while True:
            job = await claim_next_job(test_db)
            if job:
                claimed_jobs.append(str(job.id))
                await test_db.commit()
            else:
                break
    
    # Run workers concurrently
    await asyncio.gather(
        worker(),
        worker(),
        worker()
    )
    
    # Verify no duplicates
    assert len(claimed_jobs) == len(set(claimed_jobs))
    assert len(claimed_jobs) == 10
```

## Key Design Decisions

### 1. Database as Queue
- **Rationale**: Eliminates multi-worker conflicts and provides transactional guarantees
- **Implementation**: Uses `SELECT ... FOR UPDATE SKIP LOCKED` (PostgreSQL) for atomic job claiming
- **Fallback**: SQLite uses regular SELECT with transaction isolation

### 2. Separate Log Table
- **Rationale**: Prevents row bloat from frequent log appends
- **Benefits**: Efficient log queries, better update performance
- **Trade-off**: Additional join required when fetching job with logs

### 3. JSONB for Flexibility
- **Rationale**: Maintains API compatibility while allowing schema evolution
- **Usage**: Stores `job_data`, `result`, and `error_details`
- **Performance**: PostgreSQL JSONB provides indexing capabilities

### 4. Session Per Request/Task
- **Rationale**: Follows SQLAlchemy async best practices
- **Benefits**: Clean transaction boundaries, no session sharing
- **Implementation**: FastAPI dependency injection for endpoints

## Performance Considerations

### Database Connection Pool
```python
# PostgreSQL production settings
engine_kwargs = {
    "pool_size": 20,        # Number of persistent connections
    "max_overflow": 10,     # Maximum overflow connections
    "pool_timeout": 30,     # Timeout for getting connection
    "pool_recycle": 1800,   # Recycle connections after 30 minutes
}
```

### Query Optimization
- Indexes on `status`, `created_at`, and `job_type` for efficient filtering
- `lazy="selectin"` for logs to avoid N+1 queries
- Pagination built into all list operations

### SQLite vs PostgreSQL
| Feature | SQLite | PostgreSQL |
|---------|--------|------------|
| Concurrent Writers | 1 | Many |
| SKIP LOCKED | No | Yes |
| JSONB Indexing | No | Yes |
| Production Ready | Development only | Yes |

## Monitoring & Maintenance

### Health Check Endpoint
```python
@app.get("/health")
async def health_check(db: AsyncSession = Depends(get_db_session)):
    """Check database connectivity and worker status."""
    try:
        # Test database connection
        await db.execute(text("SELECT 1"))
        
        # Check worker status
        worker_status = "running" if app.state.worker_task and not app.state.worker_task.done() else "stopped"
        
        return {
            "status": "healthy",
            "database": "connected",
            "worker": worker_status,
            "timestamp": datetime.utcnow()
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "error": str(e),
            "timestamp": datetime.utcnow()
        }
```

### Job Cleanup
```python
# Periodic task to clean old jobs
async def cleanup_old_jobs(db: AsyncSession, days: int = 30):
    """Delete jobs older than specified days."""
    cutoff_date = datetime.utcnow() - timedelta(days=days)
    
    await db.execute(
        delete(Job).where(
            and_(
                Job.completed_at < cutoff_date,
                Job.status.in_([JobStatus.COMPLETED, JobStatus.FAILED, JobStatus.CANCELLED])
            )
        )
    )
    await db.commit()
```

## Success Metrics

1. **Zero Data Loss**: Jobs persist across server restarts
2. **Multi-Worker Safety**: No duplicate job processing
3. **Query Performance**: Job listing < 100ms with indexes
4. **Reliability**: 99.9% job completion rate
5. **Scalability**: Linear scaling with additional workers

## Implementation Checklist

- [ ] Create database models with proper async support
- [ ] Implement session manager with connection pooling
- [ ] Set up Alembic for migrations
- [ ] Refactor JobService to remove in-memory state
- [ ] Implement atomic job claiming logic
- [ ] Create worker loop for background processing
- [ ] Update all API endpoints to use database
- [ ] Add comprehensive tests including concurrency
- [ ] Document SQLite limitations for development
- [ ] Set up health check and monitoring endpoints
- [ ] Configure production PostgreSQL settings
- [ ] Test multi-worker deployment scenarios

## Conclusion

This implementation transforms the Character Card Generator API from an in-memory prototype to a production-ready system with proper persistence, scalability, and reliability. The architecture supports horizontal scaling through multiple workers while maintaining data consistency through database transactions.