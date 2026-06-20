# CNPGClusterLogicalReplicationLagging

## Description

The `CNPGClusterLogicalReplicationLagging` alert indicates that a CloudNativePG cluster with a logical replication subscription is falling behind its publisher. This alert aggregates three types of lag:

1. **Receipt Lag** (`cnpg_pg_stat_subscription_receipt_lag_seconds`): Time since the last WAL message was received from the publisher
2. **Apply Lag** (`cnpg_pg_stat_subscription_apply_lag_seconds`): Time delay between receiving and actually applying changes
3. **LSN Distance** (`cnpg_pg_stat_subscription_buffered_lag_bytes`): Amount of WAL data buffered but not yet applied (measured in bytes)

- **Warning level**: Any lag metric exceeds 60s or 1GB
- **Critical level**: Any lag metric exceeds 300s or 4GB

## Impact

The cluster remains operational, but:
- Queries to the subscriber will return stale data
- Data inconsistency between publisher and subscriber
- In critical cases, disk space on the publisher may fill up with unapplied WAL
- Recovery time increases with lag duration

## Diagnosis

### Step 1: Identify the Lag Type

Connect to the subscriber and check the current state:

```bash
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- psql -c "
SELECT
    subname,
    enabled,
    EXTRACT(EPOCH FROM (NOW() - last_msg_receipt_time)) as receipt_lag_seconds,
    EXTRACT(EPOCH FROM (NOW() - latest_end_time)) as apply_lag_seconds,
    pg_wal_lsn_diff(received_lsn, latest_end_lsn) as pending_bytes,
    CASE
        WHEN EXTRACT(EPOCH FROM (NOW() - last_msg_receipt_time)) > 60 THEN 'High receipt lag'
        WHEN EXTRACT(EPOCH FROM (NOW() - latest_end_time)) > 60 THEN 'High apply lag'
        WHEN pg_wal_lsn_diff(received_lsn, latest_end_lsn) > 1024^3 THEN 'High LSN distance'
    END as primary_issue
FROM pg_stat_subscription;
"
```

### Step 2: Check Network Connectivity

For **receipt lag** issues:

```bash
# Check network latency between publisher and subscriber
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- \
  ping -c 10 PUBLISHER-HOSTNAME

# Check bandwidth (if tools are available)
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- \
  nc -zv PUBLISHER-HOSTNAME 5432
```

### Step 3: Check Resource Utilization

For **apply lag** issues:

```bash
# Check CPU/Memory usage on subscriber
kubectl top pod -n NAMESPACE -l app=postgresql

# Check disk I/O
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- \
  iostat -x 1 5

# Check for long-running queries
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- psql -c "
SELECT pid, now() - pg_stat_activity.query_start AS duration, query
FROM pg_stat_activity
WHERE state = 'active' AND now() - query_start > interval '5 minutes'
ORDER BY duration DESC;
"
```

### Step 4: Check Configuration

```bash
# Verify replication worker settings
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- psql -c "
SHOW max_worker_processes;
SHOW max_logical_replication_workers;
SHOW max_parallel_workers;
"

# Ensure adequate worker processes:
# max_worker_processes >= max_parallel_workers + max_logical_replication_workers
```

### Step 5: Monitor Trends

Use the CloudNativePG Grafana Dashboard:
- Navigate to the Logical Replication section
- Examine all lag graphs over time
- Check if lag is stable, increasing, or fluctuating
- Correlate with workload spikes

## Resolution

### For Receipt Lag (Network Issues)

1. **Check Network Latency**:
   - Verify network connectivity between clusters
   - Consider placing clusters in the same region/availability zone
   - Check for network congestion or throttling

2. **Optimize Network Configuration**:
   ```yaml
   # In the subscriber's postgresql configuration
   postgresql:
     parameters:
       wal_sender_timeout: '60s'
       wal_receiver_status_interval: '10s'
   ```

### For Apply Lag (Resource Issues)

1. **Scale Up Resources**:
   ```yaml
   # Increase CPU/memory for the subscriber
   resources:
     requests:
       cpu: 2
       memory: 8Gi
     limits:
       cpu: 4
       memory: 16Gi
   ```

2. **Optimize Disk I/O**:
   - Use faster storage (SSD if not already)
   - Consider increasing storage IOPS
   - Check for disk bottlenecks

3. **Tune PostgreSQL Settings**:
   ```yaml
   postgresql:
     parameters:
       # Increase for better write performance
       wal_buffers: '16MB'
       checkpoint_completion_target: 0.9
       # Reduce checkpoint frequency
       max_wal_size: '4GB'
       min_wal_size: '1GB'
   ```

### For High Transaction Volume

1. **Batch Large Transactions**:
   - Break large transactions into smaller ones
   - Use `COPY` instead of many INSERT statements

2. **Consider Row Filtering**:
   ```sql
   -- Only replicate needed data
   ALTER PUBLICATION publication_name SET (publish = 'insert, update, delete');
   ALTER PUBLICATION publication_name ADD TABLE table_name WHERE (condition);
   ```

3. **Temporarily Disable Triggers**:
   ```sql
   -- On subscriber for performance-critical periods
   ALTER TABLE table_name DISABLE TRIGGER ALL;
   -- Remember to re-enable after
   ```

### General Tuning

1. **Increase Replication Slots**:
   ```yaml
   # If multiple publications
   postgresql:
     parameters:
       max_replication_slots: 10
       max_wal_senders: 10
   ```

2. **Monitor and Restart**:
   ```bash
   # If subscriber is stuck
   kubectl cnpg subscription restart SUBSCRIPTION-NAME -n NAMESPACE

   # Or restart the entire cluster
   kubectl cnpg restart SUBSCRIBER-CLUSTER -n NAMESPACE
   ```

## Prevention

1. **Right-size Resources**:
   - Allocate adequate CPU, memory, and storage IOPS
   - Monitor resource utilization regularly

2. **Network Optimization**:
   - Place publisher and subscriber close to each other
   - Use dedicated network connections if possible

3. **Regular Monitoring**:
   - Set up proactive monitoring before issues become critical
   - Review lag trends regularly
   - Set up automated scaling based on metrics

4. **Maintenance Windows**:
   - Schedule large data operations during low-traffic periods
   - Consider pausing replication during major maintenance

## Additional Commands

```bash
# Check replication slot status
kubectl exec -it svc/PUBLISHER-CLUSTER-rw -n NAMESPACE -- psql -c "
SELECT slot_name, active, pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)) as lag_bytes
FROM pg_replication_slots
WHERE slot_type = 'logical';
"

# Force sync (if needed)
kubectl cnpg subscription enable SUBSCRIPTION-NAME -n NAMESPACE

# Check subscription details
kubectl exec -it svc/SUBSCRIBER-CLUSTER-rw -n NAMESPACE -- psql -c "\dRs+"
```

## When to Escalate

- Contact support if:
  - Lag continues to increase despite optimization
  - Network issues persist between clusters
  - Resource utilization is at maximum but lag continues
  - You experience frequent replication failures