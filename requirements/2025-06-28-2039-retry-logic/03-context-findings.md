# Context Findings - Retry Logic Implementation

**Date:** 2025-06-28 20:50
**Phase:** Targeted Context Gathering

## Files Analyzed

### Primary Target
- `/REPOS/character-card-generator-api/card_generator_app/processing/character_book_updater.py`

### Related Files
- `/REPOS/character-card-generator-api/card_generator_app/providers/openrouter.py`
- `/REPOS/character-card-generator-api/card_generator_app/utils/error_handler.py`
- `/REPOS/character-card-generator-api/card_generator_app/providers/simple_router.py`
- Configuration files in `/REPOS/character-card-generator-api/configs/profiles/`

## Key Technical Findings

### 1. Async Operations Requiring Retry Logic

In `character_book_updater.py`, there are two main async operations that call `router.generate()`:

1. **Topic Analysis** (line 395):
   ```python
   response = await self.router.generate(prompt, gen_config, "analysis")
   ```
   - Located in `_analyze_missing_topics()` method
   - Falls back to empty list on failure
   - Critical for identifying new character book topics

2. **Entry Generation** (line 498):
   ```python
   response = await self.router.generate(prompt, gen_config, "creative_writing")
   ```
   - Located in `_generate_entry_batch()` method
   - Falls back to `_create_fallback_entries()` on failure
   - Generates actual character book content

### 2. Error Types from OpenRouter

The `openrouter.py` provider handles these error types:

- **Network Errors**: `APIConnectionError` (lines 429-434)
- **Timeout Errors**: `APITimeoutError` (lines 432-434)
- **Rate Limiting**: HTTP 429 (lines 446-448) - "Rate limit exceeded"
- **Model Not Found**: HTTP 404 (lines 449-451)
- **Payload Too Large**: HTTP 413 (lines 452-454)
- **JSON Parse Errors**: `JSONDecodeError` (lines 435-437)
- **Missing Fields**: `KeyError` (lines 438-440)

### 3. Existing Retry Infrastructure

The codebase has a synchronous `robust_operation` function in `error_handler.py` (line 349):
- Uses exponential backoff
- Default 3 retries with 1-second initial delay
- **Limitation**: Uses `time.sleep()`, not suitable for async

### 4. Configuration System Patterns

Configuration files in `configs/profiles/` follow this structure:
```json
{
  "openrouter_api_key": "...",
  "generation_temperature": 0.8,
  "generation_max_tokens": 8000,
  "character_book_batch_size": 3,
  // Other settings...
}
```

Need to add retry configuration section like:
```json
{
  "retry_config": {
    "max_attempts": 3,
    "initial_delay": 1.0,
    "max_delay": 60.0,
    "backoff_factor": 2.0
  }
}
```

### 5. Logging Patterns

The codebase uses:
- `self.logger = logging.getLogger(__name__)` for module-level logging
- Error logging with `exc_info=True` for stack traces
- Warning/info logs for operational status

### 6. Fallback Mechanisms

Current fallback behavior:
- `_analyze_missing_topics()`: Returns empty list on failure
- `_generate_entry_batch()`: Calls `_create_fallback_entries()` which creates basic entries
- No retry attempts before falling back

## Integration Points

1. **Create Async Retry Utility**: Need async version of `robust_operation`
2. **Configuration Loading**: Add retry config to `__init__` method
3. **Wrap API Calls**: Apply retry logic to both `router.generate()` calls
4. **Error Classification**: All errors can use static backoff (per user requirement)
5. **Logging Integration**: Use existing logger pattern for retry attempts

## Technical Constraints

- Must be fully async (no blocking operations)
- Must integrate with existing error handling patterns
- Configuration must be optional with sensible defaults
- Should not break existing fallback behavior (retry first, then fallback)

## Related Features

- Job retry mechanism exists at API level (`/api/v2/jobs/{job_id}/retry`)
- Background worker has retry logic for job processing
- No automatic retry at the provider/generation level currently