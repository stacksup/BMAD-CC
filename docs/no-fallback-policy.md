# NO FALLBACK OR DUMMY DATA POLICY

## CRITICAL CODING PRINCIPLE FOR BMAD-CC

This is a **NON-NEGOTIABLE** policy that applies to ALL code written for this project.

## THE RULE

**NEVER** implement fallback or dummy data solutions that make features appear to work when they're actually failing.

## WHY THIS MATTERS

Silent failures create technical debt that compounds over time:
- Bugs become harder to diagnose when errors are hidden
- Users lose trust when features fail silently
- Development slows down debugging phantom issues
- Production incidents become catastrophic when multiple hidden failures cascade

## PROHIBITED PATTERNS

### ❌ NEVER Return Dummy Data on Failure
```javascript
// PROHIBITED - Silent fallback to dummy data
try {
  const users = await fetchUsers();
  return users;
} catch (error) {
  return [{ id: 1, name: 'Default User' }]; // ❌ NEVER DO THIS
}
```

### ❌ NEVER Hide Failures Behind Fake Success
```javascript
// PROHIBITED - Pretending success on failure
async function saveData(data) {
  try {
    await api.save(data);
    return { success: true };
  } catch (error) {
    return { success: true }; // ❌ NEVER DO THIS - Lies about success
  }
}
```

### ❌ NEVER Use Hardcoded Data in Production Code
```javascript
// PROHIBITED - Hardcoded test data
function getProducts() {
  // ❌ NEVER DO THIS unless building actual mock service
  return [
    { id: 1, name: 'Test Product', price: 99.99 },
    { id: 2, name: 'Another Product', price: 149.99 }
  ];
}
```

### ❌ NEVER Swallow Errors Without Action
```javascript
// PROHIBITED - Silent error swallowing
try {
  await criticalOperation();
} catch (error) {
  // ❌ NEVER DO THIS - Error disappears into void
}
```

## REQUIRED PATTERNS

### ✅ Let Failures Be Visible
```javascript
// CORRECT - Propagate errors properly
try {
  const users = await fetchUsers();
  if (!users || users.length === 0) {
    throw new Error('No users found');
  }
  return users;
} catch (error) {
  console.error('Failed to fetch users:', error);
  throw error; // Let caller handle the failure
}
```

### ✅ Return Explicit Error States
```javascript
// CORRECT - Clear failure indication
async function saveData(data) {
  try {
    const result = await api.save(data);
    return { success: true, data: result };
  } catch (error) {
    console.error('Save failed:', error);
    return { 
      success: false, 
      error: error.message,
      code: error.code 
    };
  }
}
```

### ✅ Separate Test Data from Production
```javascript
// CORRECT - Proper separation of concerns
function getProducts() {
  if (process.env.NODE_ENV === 'test') {
    return getMockProducts(); // Only in test environment
  }
  return fetchRealProducts(); // Always real data in production
}
```

### ✅ Handle Errors with User Feedback
```javascript
// CORRECT - Inform user of actual state
try {
  await criticalOperation();
} catch (error) {
  console.error('Operation failed:', error);
  notifyUser('Operation failed. Please try again.');
  trackError(error); // Monitor in production
  throw error; // Still propagate for handling
}
```

## EXCEPTION CASES

The ONLY acceptable uses of mock/dummy data are:

1. **Actual Mock Services**: When building a dedicated mock service for testing
2. **Test Files**: In test suites (`*.test.js`, `*.spec.ts`)
3. **Development Tools**: Clearly marked development-only utilities
4. **Documentation Examples**: Code examples in documentation

All exceptions must be:
- Clearly labeled with comments
- Isolated from production code paths
- Conditionally loaded based on environment

## ENFORCEMENT

This policy is enforced through:

1. **Development Time**: Dev agent instructions prohibit dummy implementations
2. **Code Review**: QA agent actively searches for violations
3. **Automated Checks**: `quality-gate-no-dummies.ps1` hook scans for patterns
4. **Architecture Review**: System architect ensures designs avoid fallback patterns
5. **Workflow Gates**: Story cycles include validation checkpoints

## CONSEQUENCES OF VIOLATIONS

Code containing dummy data or fallback patterns will be:
1. **Automatically Rejected**: QA will mark as NEEDS_DEV_WORK
2. **Blocked from Merge**: Quality gates prevent progression
3. **Required to Refactor**: Must implement proper error handling
4. **Subject to Review**: Architecture review for systemic issues

## BEST PRACTICES

### During Development
1. Start with error cases - design failure handling first
2. Use proper logging to track all error conditions
3. Write tests that verify error handling works correctly
4. Never commit "temporary" dummy data - it becomes permanent

### During Testing
1. Test failure scenarios explicitly
2. Verify errors propagate correctly
3. Ensure user sees appropriate error messages
4. Check logs capture sufficient debugging information

### During Code Review
1. Search for catch blocks that return success
2. Look for hardcoded data arrays/objects
3. Verify external calls have error handling
4. Check that errors are logged before re-throwing

## COMMON SCENARIOS

### API Call Failures
```javascript
// ✅ CORRECT APPROACH
async function fetchUserData(userId) {
  try {
    const response = await api.get(`/users/${userId}`);
    if (!response.ok) {
      throw new Error(`User fetch failed: ${response.status}`);
    }
    return response.data;
  } catch (error) {
    logger.error('User fetch error:', { userId, error });
    // Let UI handle the error appropriately
    throw new UserFetchError(error.message, userId);
  }
}
```

### Database Connection Issues
```javascript
// ✅ CORRECT APPROACH
async function queryDatabase(query) {
  const connection = await getConnection();
  if (!connection) {
    // Don't pretend we have data
    throw new DatabaseConnectionError('Unable to connect to database');
  }
  
  try {
    return await connection.execute(query);
  } catch (error) {
    logger.error('Query failed:', { query, error });
    throw new QueryExecutionError(error.message, query);
  }
}
```

### Missing Configuration
```javascript
// ✅ CORRECT APPROACH
function loadConfig() {
  const config = process.env.API_KEY;
  if (!config) {
    // Don't use a dummy key
    throw new ConfigurationError('API_KEY is required but not set');
  }
  return config;
}
```

## REMEMBER

**Better to fail loudly in development than silently in production.**

Every dummy implementation is a future production incident waiting to happen. Take the time to implement proper error handling from the start - your future self and your users will thank you.
