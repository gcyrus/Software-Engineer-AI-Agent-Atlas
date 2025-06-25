# Phase 2 Detailed Technical Specifications

## Overview
This document provides the detailed technical specifications for Phase 2 of the CardForge Integration, addressing the gaps identified in the analysis and providing concrete implementation guidance.

## 1. Batch Operations API Specification

### 1.1 API Endpoints

#### Create Batch Job
```
POST /api/v2/batch-generations
Content-Type: application/json

Request Body:
{
  "generations": [
    {
      "profile_id": "profile_123",
      "source_material": "Character background text...",
      "character_card": {...},  // Optional existing card to update
      "options": {
        "format": ["json", "v2", "tavernai"],
        "include_book": true
      }
    }
  ],
  "batch_options": {
    "max_concurrent": 3,  // Max parallel generations
    "continue_on_error": true,  // Continue if one fails
    "priority": "standard"  // standard, high, low
  }
}

Response (202 Accepted):
{
  "batch_id": "batch_a1b2c3d4",
  "status": "queued",
  "total_items": 5,
  "estimated_completion_time": "2025-06-20T10:30:00Z",
  "status_url": "/api/v2/batch-generations/batch_a1b2c3d4",
  "created_at": "2025-06-20T10:00:00Z"
}
```

#### Get Batch Status
```
GET /api/v2/batch-generations/{batch_id}

Response (200 OK):
{
  "batch_id": "batch_a1b2c3d4",
  "status": "processing",  // queued, processing, completed, failed, cancelled
  "progress": {
    "total": 5,
    "completed": 2,
    "failed": 0,
    "processing": 1,
    "queued": 2
  },
  "items": [
    {
      "item_id": "item_1",
      "profile_id": "profile_123",
      "status": "completed",
      "job_id": "job_xyz123",  // Individual job reference
      "result_url": "/api/v2/jobs/job_xyz123/result",
      "downloads": {
        "json": "/api/v2/jobs/job_xyz123/download/json",
        "v2": "/api/v2/jobs/job_xyz123/download/v2",
        "tavernai": "/api/v2/jobs/job_xyz123/download/tavernai"
      }
    },
    {
      "item_id": "item_2",
      "profile_id": "profile_456",
      "status": "failed",
      "error": {
        "message": "Invalid character attributes",
        "code": "VALIDATION_ERROR",
        "details": {...}
      }
    }
  ],
  "updated_at": "2025-06-20T10:05:00Z"
}
```

### 1.2 Frontend Implementation Pattern

```typescript
// hooks/useBatchGeneration.ts
export function useBatchGeneration() {
  const [batchStatus, setBatchStatus] = useState<BatchStatus | null>(null);
  
  const createBatch = async (items: BatchItem[]) => {
    const response = await api.post('/api/v2/batch-generations', {
      generations: items,
      batch_options: {
        continue_on_error: true,
        max_concurrent: 3
      }
    });
    
    setBatchStatus(response.data);
    startPolling(response.data.batch_id);
    return response.data;
  };
  
  const startPolling = (batchId: string) => {
    const pollInterval = setInterval(async () => {
      const status = await api.get(`/api/v2/batch-generations/${batchId}`);
      setBatchStatus(status.data);
      
      if (['completed', 'failed', 'cancelled'].includes(status.data.status)) {
        clearInterval(pollInterval);
      }
    }, 2000); // Poll every 2 seconds
  };
  
  return { createBatch, batchStatus };
}
```

## 2. Profile Versioning with ETag Pattern

### 2.1 API Implementation

#### Get Profile with Version
```
GET /api/v2/profiles/{profile_id}

Response Headers:
ETag: "v3"
Last-Modified: "2025-06-20T09:00:00Z"

Response Body:
{
  "id": "profile_123",
  "name": "Fantasy Hero Template",
  "version": 3,
  "config": {...},
  "prompts": {...},
  "created_at": "2025-06-01T10:00:00Z",
  "updated_at": "2025-06-20T09:00:00Z",
  "created_by": "user_123",
  "updated_by": "user_456"
}
```

#### Update Profile with Optimistic Locking
```
PUT /api/v2/profiles/{profile_id}
If-Match: "v3"
Content-Type: application/json

Request Body:
{
  "name": "Fantasy Hero Template Updated",
  "config": {...},
  "prompts": {...}
}

Success Response (200 OK):
Headers:
  ETag: "v4"
Body:
  {
    "id": "profile_123",
    "version": 4,
    ...
  }

Conflict Response (412 Precondition Failed):
{
  "error": "PROFILE_VERSION_CONFLICT",
  "message": "Profile has been modified by another user",
  "current_version": 5,
  "your_version": 3,
  "updated_by": "user_789",
  "updated_at": "2025-06-20T09:30:00Z"
}
```

### 2.2 Frontend Conflict Resolution

```typescript
// components/ProfileConflictDialog.tsx
export function ProfileConflictDialog({ 
  conflict, 
  localChanges, 
  onResolve 
}: ConflictDialogProps) {
  return (
    <Dialog open={!!conflict}>
      <DialogHeader>
        <DialogTitle>Profile Update Conflict</DialogTitle>
        <DialogDescription>
          This profile was modified by {conflict.updated_by} at {conflict.updated_at}
        </DialogDescription>
      </DialogHeader>
      
      <DialogContent>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <h4>Your Changes</h4>
            <pre>{JSON.stringify(localChanges, null, 2)}</pre>
          </div>
          <div>
            <h4>Current Version</h4>
            <button onClick={() => fetchLatestVersion()}>
              Load Latest Version
            </button>
          </div>
        </div>
      </DialogContent>
      
      <DialogFooter>
        <Button variant="secondary" onClick={() => onResolve('discard')}>
          Discard My Changes
        </Button>
        <Button variant="primary" onClick={() => onResolve('overwrite')}>
          Overwrite with My Changes
        </Button>
      </DialogFooter>
    </Dialog>
  );
}
```

## 3. Character Book Data Structure

### 3.1 API Response Structure

```typescript
interface CharacterBook {
  id: string;
  name: string;
  description: string;
  version: string;
  entries: CharacterBookEntry[];
  metadata: {
    total_entries: number;
    total_tokens: number;
    created_at: string;
    updated_at: string;
    tags: string[];
  };
}

interface CharacterBookEntry {
  id: string;
  name: string;
  content: string;  // Markdown supported
  keywords: string[];
  priority: number;
  category: string;
  metadata: {
    tokens: number;
    last_accessed: string;
  };
}
```

### 3.2 Character Book API Endpoints

```
GET /api/v2/character-books/{book_id}
GET /api/v2/character-books/{book_id}/entries
GET /api/v2/character-books/{book_id}/entries/{entry_id}
PUT /api/v2/character-books/{book_id}/entries/{entry_id}
DELETE /api/v2/character-books/{book_id}/entries/{entry_id}
POST /api/v2/character-books/{book_id}/search
```

### 3.3 Frontend Visualization Component

```typescript
// components/CharacterBookVisualization.tsx
export function CharacterBookVisualization({ bookId }: { bookId: string }) {
  const { data: book, isLoading } = useQuery({
    queryKey: ['character-book', bookId],
    queryFn: () => api.get(`/api/v2/character-books/${bookId}`),
  });
  
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');
  
  const filteredEntries = useMemo(() => {
    if (!book) return [];
    
    return book.entries.filter(entry => {
      const matchesSearch = entry.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                           entry.content.toLowerCase().includes(searchTerm.toLowerCase()) ||
                           entry.keywords.some(k => k.includes(searchTerm));
                           
      const matchesCategory = selectedCategory === 'all' || 
                             entry.category === selectedCategory;
                             
      return matchesSearch && matchesCategory;
    });
  }, [book, searchTerm, selectedCategory]);
  
  return (
    <div className="character-book-container">
      <header className="book-header">
        <h2>{book?.name}</h2>
        <div className="book-stats">
          <span>{book?.metadata.total_entries} entries</span>
          <span>{book?.metadata.total_tokens} tokens</span>
        </div>
      </header>
      
      <div className="book-controls">
        <Input 
          placeholder="Search entries..." 
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
        <Select value={selectedCategory} onValueChange={setSelectedCategory}>
          <SelectTrigger>
            <SelectValue placeholder="All Categories" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Categories</SelectItem>
            {/* Dynamic categories from book data */}
          </SelectContent>
        </Select>
      </div>
      
      <div className="entries-grid">
        {filteredEntries.map(entry => (
          <CharacterBookEntry key={entry.id} entry={entry} />
        ))}
      </div>
    </div>
  );
}
```

## 4. Real-time Validation Strategy

### 4.1 Validation Endpoint

```
POST /api/v2/validate/profile
Content-Type: application/json

Request:
{
  "field": "name",  // or "config", "prompts", etc.
  "value": "My Profile Name",
  "context": {
    "profile_id": "profile_123",  // For uniqueness checks
    "profile_type": "character"
  }
}

Response (200 OK):
{
  "valid": false,
  "errors": [
    {
      "field": "name",
      "message": "A profile with this name already exists",
      "code": "DUPLICATE_NAME"
    }
  ],
  "warnings": [
    {
      "field": "name", 
      "message": "Consider using a more descriptive name",
      "code": "WEAK_NAME"
    }
  ]
}
```

### 4.2 Frontend Debounced Validation

```typescript
// hooks/useDebounceValidation.ts
export function useDebounceValidation(
  field: string, 
  validateFn: (value: any) => Promise<ValidationResult>,
  delay: number = 500
) {
  const [value, setValue] = useState('');
  const [validation, setValidation] = useState<ValidationResult | null>(null);
  const [isValidating, setIsValidating] = useState(false);
  
  const debouncedValidate = useMemo(
    () => debounce(async (newValue: string) => {
      if (!newValue) {
        setValidation(null);
        return;
      }
      
      setIsValidating(true);
      try {
        const result = await validateFn(newValue);
        setValidation(result);
      } catch (error) {
        console.error('Validation failed:', error);
      } finally {
        setIsValidating(false);
      }
    }, delay),
    [validateFn, delay]
  );
  
  useEffect(() => {
    debouncedValidate(value);
  }, [value, debouncedValidate]);
  
  return {
    value,
    setValue,
    validation,
    isValidating
  };
}
```

## 5. Smart File Naming Patterns

### 5.1 Naming Configuration

```typescript
interface FileNamingConfig {
  pattern: string;  // Template string
  sanitize: boolean;
  maxLength: number;
}

// Default patterns
const NAMING_PATTERNS = {
  default: "{character_name}_{timestamp}",
  detailed: "{character_name}_{world}_{class}_{date}",
  versioned: "{character_name}_v{version}_{format}",
  batch: "batch_{batch_id}_{index}_{character_name}"
};

// Example outputs:
// "gandalf_the_grey_1719023400.json"
// "gandalf_middle_earth_wizard_2025-06-20.json"  
// "gandalf_v3_tavernai.png"
// "batch_a1b2c3_001_gandalf.json"
```

### 5.2 Frontend Implementation

```typescript
// utils/smartFileNaming.ts
export function generateSmartFilename(
  character: CharacterData,
  format: ExportFormat,
  options: FileNamingOptions = {}
): string {
  const {
    pattern = NAMING_PATTERNS.default,
    includeTimestamp = true,
    sanitize = true
  } = options;
  
  const replacements = {
    character_name: sanitizeFilename(character.name),
    world: sanitizeFilename(character.world || 'unknown'),
    class: sanitizeFilename(character.class || 'unknown'),
    timestamp: Date.now(),
    date: new Date().toISOString().split('T')[0],
    format: format,
    version: character.version || '1'
  };
  
  let filename = pattern;
  Object.entries(replacements).forEach(([key, value]) => {
    filename = filename.replace(`{${key}}`, String(value));
  });
  
  return `${filename}.${getExtension(format)}`;
}
```

## 6. Cost Tracking Implementation

### 6.1 Cost Tracking API

```
GET /api/v2/user/usage
GET /api/v2/user/usage/current-month
GET /api/v2/models/pricing

Response:
{
  "usage": {
    "current_month": {
      "tokens_used": 145000,
      "requests_count": 89,
      "total_cost": 1.32,
      "by_model": {
        "gpt-4": { "tokens": 50000, "cost": 0.75 },
        "claude-2": { "tokens": 95000, "cost": 0.57 }
      }
    },
    "daily_limit": {
      "tokens": 1000000,
      "remaining": 855000,
      "resets_at": "2025-06-21T00:00:00Z"
    }
  },
  "pricing": {
    "gpt-4": { "per_1k_tokens": 0.015 },
    "claude-2": { "per_1k_tokens": 0.006 }
  }
}
```

### 6.2 Cost Tracking UI Component

```typescript
// components/CostTracker.tsx
export function CostTracker() {
  const { data: usage } = useQuery({
    queryKey: ['user-usage'],
    queryFn: () => api.get('/api/v2/user/usage'),
    refetchInterval: 30000 // Refresh every 30 seconds
  });
  
  return (
    <div className="cost-tracker">
      <div className="cost-summary">
        <span className="label">Today's Usage:</span>
        <span className="amount">${usage?.current_month.total_cost.toFixed(3)}</span>
      </div>
      
      <Progress 
        value={(usage?.daily_limit.remaining / usage?.daily_limit.tokens) * 100}
        className="w-full"
      />
      
      <button onClick={() => setShowDetails(!showDetails)}>
        <ChevronDown className={showDetails ? 'rotate-180' : ''} />
      </button>
      
      {showDetails && (
        <div className="cost-details">
          {Object.entries(usage?.current_month.by_model || {}).map(([model, data]) => (
            <div key={model} className="model-usage">
              <span>{model}:</span>
              <span>{data.tokens.toLocaleString()} tokens</span>
              <span>${data.cost.toFixed(3)}</span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
```

## 7. Performance Optimization Strategies

### 7.1 Lazy Loading Implementation

```typescript
// Lazy load heavy components
const CharacterBookVisualization = lazy(() => 
  import('./components/CharacterBookVisualization')
);

const ProfileManagement = lazy(() => 
  import('./views/ProfileManagement')
);
```

### 7.2 Caching Strategy

```typescript
// queryClient configuration
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      cacheTime: 10 * 60 * 1000, // 10 minutes
      refetchOnWindowFocus: false,
      retry: (failureCount, error) => {
        if (error.status === 404) return false;
        return failureCount < 3;
      }
    }
  }
});

// Profile caching with invalidation
const profileKeys = {
  all: ['profiles'] as const,
  lists: () => [...profileKeys.all, 'list'] as const,
  list: (filters: string) => [...profileKeys.lists(), { filters }] as const,
  details: () => [...profileKeys.all, 'detail'] as const,
  detail: (id: string) => [...profileKeys.details(), id] as const,
};
```

## Summary

These specifications provide concrete implementation details for Phase 2 features:

1. **Batch Operations**: Async job pattern with polling-based status updates
2. **Profile Versioning**: ETag-based optimistic locking with conflict resolution
3. **Character Books**: Structured data model with search/filter capabilities
4. **Validation**: Hybrid approach with debounced server-side validation
5. **Smart Naming**: Template-based filename generation
6. **Cost Tracking**: Real-time usage monitoring with transparent pricing
7. **Performance**: Lazy loading, intelligent caching, and optimization strategies

Each specification includes both API contracts and frontend implementation patterns to ensure smooth development.