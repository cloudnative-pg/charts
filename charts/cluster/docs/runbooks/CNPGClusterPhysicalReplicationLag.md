# CNPGClusterPhysicalReplicationLag

## Description

The `CNPGClusterPhysicalReplicationLag` alerts indicate that physical replication lag in the CloudNativePG cluster is exceeding acceptable thresholds. Physical replication lag measures how far behind the standby replicas are from the primary instance.

- **Warning level**: Replication lag exceeds 1 second
- **Critical level**: Replication lag exceeds 15 seconds

## Impact

Physical replication lag can cause the cluster replicas to become out of sync. Queries to the `-r` and `-ro` endpoints may return stale data. In the event of a failover, the data that has not yet been replicated from the primary to the replicas may be lost during failover.

- **Warning**: Minor data staleness, acceptable for read-heavy workloads with some tolerance for outdated data
- **Critical**: Significant data loss risk during failover, stale data affecting business operations

## Diagnosis

### Step 1: Check Replication Status

Check replication status in the [CloudNativePG Grafana Dashboard](https://grafana.com/grafana/dashboards/20417-cloudnativepg/) or by running:

```bash
kubectl exec --namespace <namespace> --stdin --tty services/<cluster_name>-rw -- psql -c "SELECT * FROM pg_stat_replication;"
```

### Step 2: Identify Common Causes

High physical replication lag can be caused by a number of factors:

**Network Issues:**
- Network congestion on the node interface
- Insufficient bandwidth between primary and replicas

```bash
# Inspect network interface statistics
kubectl exec -it <pod-name> -- ss -i
```

**Resource Contention:**
- High CPU or memory load on primary or replicas
- Disk I/O bottlenecks on replicas

```bash
# Check resource usage
kubectl top pods -n <namespace> -l cnpg.io/podRole=instance

# Check disk I/O
kubectl exec -it <pod-name> -- iostat -x 1 5
```

**Database Issues:**
- Long-running queries blocking replication
- Suboptimal PostgreSQL configuration

```bash
# Check for long-running queries
kubectl exec -it services/<cluster_name>-rw -- psql -c "
SELECT pid, now() - pg_stat_activity.query_start AS duration, query
FROM pg_stat_activity
WHERE state = 'active'
  AND now() - query_start > interval '5 minutes'
ORDER BY duration DESC;
"
```

### Step 3: Check PostgreSQL Configuration

Inspect the `PostgreSQL Parameters` section of the [CloudNativePG Grafana Dashboard](https://grafana.com/grafana/dashboards/20417-cloudnativepg/) or check directly:

```bash
kubectl exec -it services/<cluster_name>-rw -- psql -c "
SHOW max_wal_senders;
SHOW wal_compression;
SHOW max_replication_slots;
"
```

## Resolution

### For Warning Level Alerts (1-15 seconds lag)

1. **Monitor Resource Usage:**
   - Check CPU and Memory usage of the CloudNativePG cluster instances
   - Monitor network traffic between primary and replicas
   - Review disk I/O statistics

2. **Identify and Address Minor Issues:**
   - Look for and optimize long-running queries
   - Check for temporary resource spikes
   - Ensure adequate network bandwidth

### For Critical Level Alerts (>15 seconds lag)

1. **Immediate Actions:**
   ```bash
   # Terminate long-running transactions that generate excessive changes
   kubectl exec -it services/<cluster_name>-rw -- psql -c "
   SELECT pg_terminate_backend(pid)
   FROM pg_stat_activity
   WHERE state = 'active'
     AND now() - query_start > interval '30 minutes'
     AND query NOT LIKE '%autovacuum%';
   "
   ```

2. **Scale Up Resources:**
   Increase the Memory and CPU resources of the instances under heavy load. This can be done by setting `cluster.resources.requests` and `cluster.resources.limits` in your Helm values. Set both `requests` and `limits` to the same value to achieve QoS Guaranteed.

   ```yaml
   cluster:
     resources:
       requests:
         cpu: 4
         memory: 16Gi
       limits:
         cpu: 4
         memory: 16Gi
   ```

3. **Enable WAL Compression:**
   ```yaml
   cluster:
     postgresql:
       parameters:
         wal_compression: "on"
   ```
   This will reduce the size of the WAL files and can help reduce replication lag in congested networks. Changing `wal_compression` does not require a restart.

4. **Upgrade Storage Performance:**
   Increase IOPS or throughput of the storage used by the cluster to alleviate disk I/O bottlenecks.

   **Process:**
   1. Create a new storage class with higher IOPS/throughput
   2. Replace cluster instances one by one using the new storage class
   3. Start with standby replicas, not the primary
   4. Delete and recreate each instance with new storage:

   ```bash
   kubectl delete --namespace <namespace> pod/<pod-name> pvc/<pod-name> pvc/<pod-name>-wal
   ```

5. **Increase WAL Senders:**
   For clusters with 9+ instances, ensure `max_wal_senders` is adequate:
   ```yaml
   cluster:
     postgresql:
       parameters:
         max_wal_senders: 15  # Should be >= number of instances
   ```

## Prevention

1. **Resource Planning:**
   - Allocate adequate CPU, memory, and storage IOPS
   - Monitor resource utilization regularly
   - Set appropriate resource limits and requests

2. **Network Optimization:**
   - Ensure sufficient network bandwidth between replicas
   - Consider placing replicas in the same availability zone
   - Monitor network latency and throughput

3. **Configuration Tuning:**
   - Enable WAL compression to reduce replication bandwidth
   - Ensure adequate `max_wal_senders` for cluster size
   - Monitor and tune checkpoint settings

4. **Regular Maintenance:**
   - Monitor replication lag trends
   - Review long-running query patterns
   - Plan capacity upgrades before reaching limits

## Quick Reference Commands

```bash
# Check replication status
kubectl exec -n <namespace> services/<cluster_name>-w -- psql -c "SELECT * FROM pg_stat_replication;"

# Check resource usage
kubectl top pods -n <namespace> -l cnpg.io/podRole=instance

# Check long-running queries
kubectl exec -it services/<cluster_name>-rw -- psql -c "
SELECT pid, now() - pg_stat_activity.query_start AS duration, query
FROM pg_stat_activity
WHERE state = 'active'
  AND now() - query_start > interval '5 minutes'
ORDER BY duration DESC;
"

# Restart a replica (if needed)
kubectl delete pod <replica-pod-name> -n <namespace>

# Check PostgreSQL parameters
kubectl exec -it services/<cluster_name>-rw -- psql -c "SHOW max_wal_senders; SHOW wal_compression;"
```

## When to Escalate

- Contact support if:
  - Replication lag continues to increase despite optimization
  - Network issues persist between cluster instances
  - Resource utilization is at maximum but lag continues
  - You experience frequent replication failures
  - Lag remains critical for more than 30 minutes