# CNPGClusterLogicalReplicationStopped

## Description

The `CNPGClusterLogicalReplicationStopped` alert indicates that a logical replication subscription is not actively replicating data. This can occur in two scenarios:

1. **Disabled Subscription**: The subscription has been explicitly disabled (`enabled = false`)
2. **Stuck Subscription**: The subscription is enabled but has no active worker process (no PID) with pending data

- **Warning level**: Subscription stopped for 5 minutes
- **Critical level**: Subscription stopped for 15 minutes

## Impact

- **No Data Replication**: The subscriber will not receive any updates from the publisher
- **Data Divergence**: The subscriber data becomes increasingly stale
- **Disk Space**: WAL files may accumulate on the publisher
- **Critical**: Extended downtime may require full resynchronization

## Diagnosis

### Step 1: Check Subscription Status

```bash
# Check all subscriptions and their status
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- psql -c "
SELECT
    pg_subscription.subname,
    pg_subscription.enabled,
    CASE
        WHEN pg_subscription.enabled = false THEN 'Explicitly disabled'
        WHEN pid IS NULL AND buffered_lag_bytes > 0 THEN 'Stuck (no worker)'
        WHEN pid IS NOT NULL THEN 'Active'
        ELSE 'Unknown'
    END as status,
    pg_wal_lsn_diff(received_lsn, latest_end_lsn) as pending_bytes,
    pid IS NOT NULL as has_worker
FROM pg_subscription
LEFT JOIN pg_stat_subscription ON pg_subscription.oid = pg_stat_subscription.subid;
"
```

### Step 2: Check Worker Process

```bash
# Check if replication worker is running
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- psql -c "
SELECT
    pid,
    application_name,
    state,
    backend_type,
    query_start
FROM pg_stat_activity
WHERE application_name LIKE '%subscription%' OR backend_type = 'logical replication worker';
"
```

### Step 3: Verify Subscription Details

```bash
# Get subscription configuration
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- psql -c "
SELECT
    subname,
    srconninfo,
    srsynccommit,
    srslotname,
    srsyncstate as sync_state
FROM pg_subscription;
"
```

### Step 4: Check PostgreSQL Logs

```bash
# Get the pod name
POD=$(kubectl get pods -n NAMESPACE -l app=postgresql -o name | head -1 | cut -d/ -f2)

# Check for subscription-related errors
kubectl logs -n NAMESPACE $POD --tail=200 | grep -i "subscription\|replication\|worker"
```

### Step 5: Test Connectivity to Publisher

```bash
# Extract connection info from subscription
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- psql -c "
SELECT srconninfo FROM pg_subscription WHERE subname = 'your_subscription_name';
" | grep -o "host=[^ ]*" | cut -d= -f2

# Test connection
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- \
  psql "host=PUBLISHER-HOST port=5432 dbname=DATABASE user=USER" -c "SELECT version();"
```

## Resolution

### If Subscription is Disabled

1. **Check if Disable Was Intentional**:
   ```bash
   # Check recent activity
   kubectl get events -n NAMESPACE --field-selector reason=SubscriptionDisabled

   # Check audit logs if RBAC is enabled
   kubectl auth can-i create subscriptions
   ```

2. **Enable the Subscription**:
   ```sql
   -- Enable the subscription
   ALTER SUBSCRIPTION subscription_name ENABLE;
   ```

   Or using kubectl:
   ```bash
   kubectl cnpg subscription enable subscription_name -n NAMESPACE
   ```

### If Subscription is Stuck

1. **Check for Worker Resource Limits**:
   ```bash
   # Check max_logical_replication_workers
   kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- psql -c "
   SHOW max_logical_replication_workers;
   SHOW max_worker_processes;
   "

   # Count active replication workers
   kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- psql -c "
   SELECT COUNT(*) FROM pg_stat_activity WHERE backend_type = 'logical replication worker';
   "
   ```

2. **Increase Worker Limits if Needed**:
   ```yaml
   # In the CNPG cluster configuration
   postgresql:
     parameters:
       max_logical_replication_workers: 10
       max_worker_processes: 20
       max_replication_slots: 10
   ```

3. **Restart the Subscription**:
   ```bash
   # First try to restart just the subscription
   kubectl cnpg subscription restart subscription_name -n NAMESPACE

   # If that doesn't work, restart the entire cluster
   kubectl cnpg restart subscriber-cluster -n NAMESPACE
   ```

4. **Check for Stuck Transactions**:
   ```sql
   -- Check for long-running transactions that might block replication
   SELECT pid, now() - pg_stat_activity.query_start AS duration, query
   FROM pg_stat_activity
   WHERE state = 'active'
     AND now() - query_start > interval '10 minutes'
     AND pid NOT IN (SELECT pid FROM pg_stat_activity WHERE application_name LIKE '%subscription%');

   -- Terminate blocking transactions if necessary
   SELECT pg_terminate_backend(pid);
   ```

### If Connection Issues

1. **Verify Publication Exists**:
   ```bash
   # On publisher
   kubectl exec -it svc/PUBLISHER-CLUSTER-rw -n NAMESPACE -- psql -c "
   SELECT pubname FROM pg_publication;
   "
   ```

2. **Check Replication Slot Status**:
   ```bash
   # On publisher
   kubectl exec -it svc/PUBLISHER-CLUSTER-rw -n NAMESPACE -- psql -c "
   SELECT slot_name, active, pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)) as lag
   FROM pg_replication_slots
   WHERE slot_type = 'logical';
   "
   ```

3. **Recreate Subscription**:
   ```sql
   -- Drop and recreate the subscription
   DROP SUBSCRIPTION IF EXISTS subscription_name;

   CREATE SUBSCRIPTION subscription_name
   CONNECTION 'host=publisher-host port=5432 dbname=database_name user=replication_user password=xxx'
   PUBLICATION publication_name
   WITH (
     copy_data = true,
     synchronized_commit = 'off',
     create_slot = true
   );
   ```

### If WAL Retention Issues

1. **Check WAL Retention**:
   ```bash
   # On publisher, check wal_keep_size
   kubectl exec -it svc/PUBLISHER-CLUSTER-rw -n NAMESPACE -- psql -c "SHOW wal_keep_size;"

   # Check if WAL was removed before subscription could catch up
   kubectl exec -it svc/PUBLISHER-CLUSTER-rw -n NAMESPACE -- psql -c "
   SELECT slot_name, restart_lsn, pg_current_wal_lsn()
   FROM pg_replication_slots;
   "
   ```

2. **Increase WAL Retention**:
   ```yaml
   # In publisher configuration
   postgresql:
     parameters:
       wal_keep_size: '2GB'
       max_slot_wal_keep_size: '4GB'
   ```

## Advanced Troubleshooting

### Manual Worker Creation

```sql
-- If workers aren't starting automatically
SELECT pg_reload_conf();

-- Force subscription to start worker
ALTER SUBSCRIPTION subscription_name ENABLE;
ALTER SUBSCRIPTION subscription_name REFRESH PUBLICATION;
```

### Check System Resources

```bash
# Check for OOM kills or resource constraints
kubectl describe pod -n NAMESPACE POD-NAME

# Check if the pod was restarted
kubectl get pods -n NAMESPACE -l app=postgresql

# Check node resources
kubectl top nodes
```

### Full Resync Procedure

```bash
# Step 1: Mark all tables for resync
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- psql -c "
SELECT schemaname, tablename
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema');
"

# Step 2: Disable subscription
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- psql -c "
ALTER SUBSCRIPTION subscription_name DISABLE;
"

# Step 3: Truncate subscriber tables (if safe)
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- psql -c "
TRUNCATE TABLE table_name CASCADE;  -- Repeat for each table
"

# Step 4: Re-enable with full copy
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- psql -c "
ALTER SUBSCRIPTION subscription_name ENABLE;
ALTER SUBSCRIPTION subscription_name REFRESH PUBLICATION WITH (copy_data = true);
"
```

## Prevention

1. **Monitoring**:
   - Set up alerts for disabled subscriptions
   - Monitor worker process counts
   - Track subscription state changes

2. **Resource Planning**:
   - Ensure adequate worker processes
   - Monitor disk space for WAL retention
   - Set appropriate timeouts

3. **High Availability**:
   ```yaml
   # Configure subscription retry parameters
   postgresql:
     parameters:
       wal_receiver_timeout: '60s'
       wal_receiver_status_interval: '10s'
       wal_retrieve_retry_interval: '5s'
   ```

4. **Backup Strategy**:
   - Regular backups of both publisher and subscriber
   - Document subscription configurations
   - Test recovery procedures

## Quick Reference Commands

```bash
# Check subscription status
kubectl exec -it svc/CLUSTER-rw -n NS -- psql -c "SELECT * FROM pg_stat_subscription;"

# Enable subscription
kubectl exec -it svc/CLUSTER-rw -n NS -- psql -c "ALTER SUBSCRIPTION sub_name ENABLE;"

# Restart subscription
kubectl cnpg subscription restart sub_name -n NS

# Restart cluster
kubectl cnpg restart CLUSTER -n NS

# Check replication slots
kubectl exec -it svc/PUBLISHER-rw -n NS -- psql -c "SELECT * FROM pg_replication_slots;"

# Check workers
kubectl exec -it svc/CLUSTER-rw -n NS -- psql -c "SELECT * FROM pg_stat_activity WHERE backend_type = 'logical replication worker';"
```

## When to Escalate

- Contact support if:
  - Subscription remains stuck after multiple restarts
  - Workers fail to start despite adequate resources
  - WAL retention issues prevent catch-up
  - Frequent disconnections occur
  - Data cannot be resynchronized successfully