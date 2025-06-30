# Requirements Specification - Retry Logic for Character Book Updater

**Date:** 2025-06-28 21:00
**Author:** ATLAS (Software Engineer AI Entity)
**Reviewer:** Grant

## Problem Statement

The Character Book Updater currently makes async API calls to OpenRouter for topic analysis and entry generation. When these calls fail due to transient issues (network errors, rate limiting, timeouts), the system immediately falls back to simplified entries or empty results. This reduces the quality of generated character books when temporary issues could be resolved with retry attempts.

## Solution Overview

Implement a robust async retry mechanism that:
1. Attempts API calls multiple times before falling back
2. Uses configurable exponential backoff with static delays
3. Handles rate limiting (HTTP 429) appropriately
4. Integrates seamlessly with existing error handling and logging
5. Preserves the current fallback behavior as a last resort

## Functional Requirements

### FR1: Async Retry Utility
- Create an async version of the existing `robust_operation` function
- Support configurable retry attempts and delays
- Use exponential backoff with configurable parameters
- Handle all error types with the same retry strategy (static backoff)

### FR2: Retry Configuration
- Add retry configuration under a `retry_config` key in config files
- Support these parameters:
  - `max_attempts`: Maximum retry attempts (default: 3)
  - `initial_delay`: Initial delay in seconds (default: 1.0)
  - `max_delay`: Maximum delay between retries (default: 60.0)
  - `backoff_factor`: Multiplier for exponential backoff (default: 2.0)
- Configuration should be optional with sensible defaults

### FR3: Apply Retry Logic
- Wrap both `router.generate()` calls in CharacterBookUpdater:
  - Topic analysis in `_analyze_missing_topics()` (line 395)
  - Entry generation in `_generate_entry_batch()` (line 498)
- Retry on all exceptions before falling back to existing behavior

### FR4: Error Handling
- Preserve original exceptions and re-raise after all attempts fail
- Maintain existing fallback behavior (empty list for topics, basic entries for generation)
- Ensure compatibility with existing error handling patterns

### FR5: Logging
- Log retry attempts at INFO level with attempt number and delay
- Log final failures at ERROR level with full stack traces
- Include relevant context (method name, attempt count, error type)

## Technical Requirements

### TR1: Implementation Location
- Add `async_robust_operation` function to `card_generator_app/utils/error_handler.py`
- Modify `CharacterBookUpdater` class in `card_generator_app/processing/character_book_updater.py`

### TR2: Configuration Schema
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

### TR3: Async Implementation
- Use `asyncio.sleep()` for delays (not `time.sleep()`)
- Ensure no blocking operations
- Maintain async/await chain throughout

### TR4: Integration Points
- Load retry config in `CharacterBookUpdater.__init__()` method
- Apply retry wrapper to both `router.generate()` calls
- Use existing logger instance for all logging

## Implementation Hints

### 1. Async Retry Function Structure
```python
async def async_robust_operation(
    operation: Callable,
    operation_name: str = "Operation",
    max_retries: int = 3,
    initial_delay: float = 1.0,
    max_delay: float = 60.0,
    backoff_factor: float = 2.0,
    logger: Optional[logging.Logger] = None
):
    """Async version of robust_operation with exponential backoff."""
    # Implementation here
```

### 2. Configuration Loading Pattern
```python
# In CharacterBookUpdater.__init__
self.retry_config = config.get("retry_config", {})
self.max_retries = self.retry_config.get("max_attempts", 3)
self.initial_delay = self.retry_config.get("initial_delay", 1.0)
# etc.
```

### 3. Usage Pattern
```python
# Wrap the router.generate calls
response = await async_robust_operation(
    lambda: self.router.generate(prompt, gen_config, "analysis"),
    operation_name="topic_analysis",
    max_retries=self.max_retries,
    initial_delay=self.initial_delay,
    logger=self.logger
)
```

## Acceptance Criteria

1. **Retry Behavior**
   - [ ] API calls retry up to configured max_attempts before failing
   - [ ] Exponential backoff is applied between attempts
   - [ ] Rate limit errors (429) are retried with appropriate delays

2. **Configuration**
   - [ ] Retry config can be specified in config files
   - [ ] Defaults work when no retry config is provided
   - [ ] All retry parameters are configurable

3. **Error Handling**
   - [ ] Original exceptions are preserved and re-raised
   - [ ] Existing fallback behavior still works after retries exhausted
   - [ ] No new exception types are introduced

4. **Logging**
   - [ ] Each retry attempt is logged at INFO level
   - [ ] Final failures log at ERROR with stack traces
   - [ ] Log messages include useful context

5. **Performance**
   - [ ] No blocking operations (uses asyncio.sleep)
   - [ ] Retry delays don't block other async operations
   - [ ] Overall generation time increases gracefully with retries

## Assumptions

1. WebSocket functionality is not yet implemented (no progress updates needed)
2. Static backoff strategy is sufficient for all error types
3. Retry configuration will be added to existing config files
4. No retry metrics needed in debug output
5. Existing fallback mechanisms should remain as final resort

## Out of Scope

- WebSocket progress updates for retry attempts
- Different retry strategies for different error types
- Retry logic for other parts of the system
- Changes to existing fallback entry generation
- Database persistence of retry attempts
- Circuit breaker patterns

## Testing Considerations

1. Test retry behavior with mocked failures
2. Verify exponential backoff calculations
3. Ensure fallback still works after retries
4. Test configuration loading and defaults
5. Verify async behavior doesn't block
6. Check logging output format and levels