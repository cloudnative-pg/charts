# CNPGClusterLogicalReplicationErrors

## Description

The `CNPGClusterLogicalReplicationErrors` alert indicates that a logical replication subscription is experiencing errors during data replication. This includes:

1. **Apply Errors**: Errors that occur when applying received changes from the publisher
2. **Sync Errors**: Errors that occur during the initial table synchronization phase

- **Warning level**: Any error detected in the last 5 minutes
- **Critical level**: 5 or more errors in the last 5 minutes

## Impact

- **Data Inconsistency**: The subscriber may have missing or incorrect data
- **Replication Paused**: Depending on configuration, replication might stop on errors
- **Growing Lag**: Errors can cause replication to fall behind
- **Critical**: Persistent errors may lead to complete replication failure

## Diagnosis

### Step 1: Check Error Details

```bash
# Connect to the subscriber and check subscription status
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- psql -c "
SELECT
    subname,
    subenabled,
    apply_error_count,
    sync_error_count,
    stats_reset
FROM pg_stat_subscription
WHERE apply_error_count > 0 OR sync_error_count > 0;
"

# Check the last error message
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- psql -c "
SELECT
    subname,
    last_msg_receipt_time,
    latest_end_time,
    CASE
        WHEN apply_error_count > 0 THEN 'Apply errors detected'
        WHEN sync_error_count > 0 THEN 'Sync errors detected'
    END as error_type
FROM pg_stat_subscription;
"
```

### Step 2: Check PostgreSQL Logs

```bash
# Get the pod name
POD=$(kubectl get pods -n NAMESPACE -l app=postgresql -o name | head -1 | cut -d/ -f2)

# Check recent logs for errors
kubectl logs -n NAMESPACE $POD --tail=100 | grep -i "replication\|subscription\|error"

# Stream logs for real-time monitoring
kubectl logs -n NAMESPACE $POD -f | grep -i "replication\|subscription\|error"
```

### Step 3: Identify Common Error Patterns

1. **Constraint Violations**:
   ```bash
   kubectl logs -n NAMESPACE $POD | grep "violates.*constraint"
   ```

2. **Permission Issues**:
   ```bash
   kubectl logs -n NAMESPACE $POD | grep "permission denied\|role"
   ```

3. **Data Type Mismatches**:
   ```bash
   kubectl logs -n NAMESPACE $POD | grep "invalid input syntax\|datatype"
   ```

4. **Connection Issues**:
   ```bash
   kubectl logs -n NAMESPACE $POD | grep "connection\|timeout"
   ```

### Step 4: Verify Publication/Subscription Configuration

```bash
# On publisher - check publication tables
kubectl exec -it svc/PUBLISHER-CLUSTER-rw -n NAMESPACE -- psql -c "
SELECT pubname, puballtables, pubinsert, pubupdate, pubdelete
FROM pg_publication;
"

# On subscriber - check subscription details
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- psql -c "
SELECT
    subname,
    srconninfo,
    srschema,
    srslotname,
    srsynccommit
FROM pg_subscription;
"

# Check which tables are being replicated
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- psql -c "
SELECT
    relid::regclass as table_name,
    srsubstate as state
FROM pg_subscription_rel
JOIN pg_class ON relid = oid
WHERE srsubstate NOT IN ('r', 's');  -- Not ready or synchronizing
"
```

### Step 5: Check for Data Conflicts

```bash
# Check for conflicting primary keys
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- psql -c "
SELECT schemaname, tablename, attname, n_distinct, correlation
FROM pg_stats
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY schemaname, tablename;
"
```

## Resolution

### For Constraint Violations

1. **Identify the Constraint**:
   ```sql
   -- Find the violated constraint
   SELECT conname, contype, pg_get_constraintdef(oid)
   FROM pg_constraint
   WHERE conrelid = 'table_name'::regclass;
   ```

2. **Resolve Data Conflicts**:
   ```sql
   -- Option 1: Remove conflicting data on subscriber
   DELETE FROM table_name WHERE id = conflicting_id;

   -- Option 2: Update conflicting data
   UPDATE table_name
   SET conflicting_column = new_value
   WHERE id = conflicting_id;

   -- Option 3: Temporarily disable constraint (use with caution)
   ALTER TABLE table_name DISABLE TRIGGER ALL;
   -- After sync, re-enable
   ALTER TABLE table_name ENABLE TRIGGER ALL;
   ```

### For Permission Issues

1. **Check Subscription Owner**:
   ```sql
   SELECT usename, usesuper, usecreatedb
   FROM pg_user
   WHERE usename = current_user;
   ```

2. **Grant Necessary Permissions**:
   ```sql
   -- On subscriber, ensure subscription owner has rights
   GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO subscription_user;
   GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO subscription_user;
   ```

### For Data Type Mismatches

1. **Verify Schema Consistency**:
   ```sql
   -- On publisher
   \d+ table_name

   -- On subscriber
   \d+ table_name

   -- Compare columns and types
   SELECT column_name, data_type, is_nullable
   FROM information_schema.columns
   WHERE table_name = 'table_name';
   ```

2. **Fix Schema Issues**:
   ```sql
   -- Alter table to match publisher schema
   ALTER TABLE table_name ALTER COLUMN column_name TYPE new_type;
   ```

### For Initial Sync Errors

1. **Check if Tables Exist**:
   ```sql
   -- On subscriber, ensure tables exist
   SELECT tablename FROM pg_tables WHERE schemaname = 'public';
   ```

2. **Create Missing Tables**:
   ```sql
   -- Export schema from publisher
   pg_dump -h PUBLISHER-HOST -U postgres -s -t table_name database_name

   -- Import into subscriber
   psql -h SUBSCRIBER-HOST -U postgres -d database_name < schema_dump.sql
   ```

3. **Reset Subscription**:
   ```bash
   # WARNING: This will resync all data
   kubectl cnpg subscription restart SUBSCRIPTION-NAME -n NAMESPACE

   # Or completely recreate
   kubectl cnpg subscription delete SUBSCRIPTION-NAME -n NAMESPACE
   # Recreate with proper configuration
   ```

### For Connection/Timeout Issues

1. **Check Connectivity**:
   ```bash
   # Test connection from subscriber to publisher
   kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- \
     psql -h PUBLISHER-HOST -U postgres -d database_name -c "SELECT 1;"
   ```

2. **Increase Timeout Values**:
   ```yaml
   # In subscription configuration
   spec:
     parameters:
       application_name: "my_subscription"
       synchronous_commit: "off"
       # Increase timeout for slow networks
   ```

## Recovery Procedures

Choose one of the following approaches based on your situation:

### Option 1: Resolve Data Conflict (Recommended - Lets Replication Retry Automatically)

**When to use**: When you have a specific constraint violation (e.g., duplicate key) and want to let the publisher's data replicate correctly.

The most common cause of replication errors is conflicting data between publisher and subscriber. PostgreSQL's logical replication **stops** when it encounters a conflict and requires manual intervention.

#### Step 1: Identify the conflicting data

Check the PostgreSQL logs for the conflict details:

```bash
kubectl logs -n NAMESPACE $POD | grep "conflict detected\|duplicate key"
```

You'll see something like:
```
ERROR: duplicate key value violates unique constraint "test_pkey"
DETAIL: Key (c)=(1) already exists.
CONTEXT: processing remote data for replication origin "pg_16395" during "INSERT" 
for replication target relation "public.test" in transaction 725 finished at 0/14C0378
```

This tells you which table and key is causing the conflict.

#### Step 2: Remove or fix the conflicting row on the subscriber

```sql
-- For INSERT conflicts: Delete the conflicting row to let publisher's data replicate
DELETE FROM table_name WHERE id = conflicting_id;
```

**That's it!** Once you remove the conflicting row, logical replication will **automatically retry** the transaction and apply the publisher's data. You do NOT need to manually skip the transaction.

**Important**: Only delete the subscriber's data if you're certain the publisher's version should win.

### Option 2: Skip Transaction Without Applying Publisher's Data (Use With Caution)

**When to use**: When you want to keep the subscriber's version of the data and permanently ignore what the publisher tried to send. This causes data divergence.

If you've decided that the subscriber's conflicting data is correct and you want to ignore the publisher's transaction:

```sql
-- Using ALTER SUBSCRIPTION SKIP
-- The subscription must be enabled for this to work
ALTER SUBSCRIPTION your_subscription SKIP (lsn = '0/14C0378');
```

**WARNING**: This permanently skips the transaction and causes the subscriber to differ from the publisher. Document what was skipped.

### Option 3: Full Resynchronization (For Multiple Conflicts or Unknown State)

**When to use**: When you have many conflicts, corrupted data, or prefer to start fresh rather than manually fixing individual rows.

**WARNING**: This will re-copy all table data and may take a long time for large tables.

```bash
# Mark subscription for full refresh
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- psql -c "
ALTER SUBSCRIPTION your_subscription REFRESH PUBLICATION WITH (copy_data = true);
"

# Or restart the subscription
kubectl cnpg subscription restart your_subscription -n NAMESPACE
```

## Important Notes

- **PostgreSQL logical replication automatically retries after you fix the conflict** - Just delete or fix the conflicting row, and replication will resume on its own
- **Only use SKIP if you want to ignore the publisher's data** - Skipping means you're choosing to keep the subscriber's version and create data divergence
- **For typical constraint violations** - Delete the subscriber's conflicting row (Option 1), don't skip the transaction

## Prevention

1. **Schema Changes**:
   - Always test schema changes in staging first
   - Use DDL replication tools or manually sync schemas
   - Coordinate schema changes between publisher and subscriber

2. **Data Validation**:
   ```sql
   -- Regular data consistency checks
   SELECT COUNT(*) FROM table_name;
   -- Compare counts between publisher and subscriber
   ```

3. **Monitoring**:
   - Set up alerts for error rates
   - Monitor pg_stat_subscription regularly
   - Log error details for faster troubleshooting

4. **Best Practices**:
   - Don't modify subscriber data directly (unless bidirectional replication)
   - Use consistent character sets and collations
   - Ensure sufficient disk space for WAL retention

## Common Error Scenarios

### Primary Key Conflicts
```sql
-- Find duplicates
SELECT id, COUNT(*)
FROM table_name
GROUP BY id
HAVING COUNT(*) > 1;

-- Resolve by updating or removing duplicates
```

### Missing Sequences
```sql
-- Check sequence ownership
SELECT relname, seqrelid::regclass
FROM pg_depend
WHERE refobjid = 'table_name'::regclass
  AND deptype = 'a';

-- Sync sequence values
SELECT setval('sequence_name', (SELECT max(id) FROM table_name));
```

### Trigger Conflicts
```sql
-- Disable problematic triggers during sync
ALTER TABLE table_name DISABLE TRIGGER trigger_name;

-- Re-enable after sync
ALTER TABLE table_name ENABLE TRIGGER trigger_name;
```

## When to Escalate

- Contact support if:
  - Errors persist after all troubleshooting steps
  - You encounter frequent constraint violations
  - The schema cannot be synchronized
  - You need to skip transactions repeatedly
  - Error rate is increasing despite fixes