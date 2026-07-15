# CNPGInstanceMetricsAbsent

## Description

This alert fires when a running CloudNativePG instance has stopped exporting its `cnpg_*` collector metrics — the exporter is hung rather than restarting. It is built to ride out routine restarts, upgrades, drains and scale-downs, so when it fires the instance is up but its metrics are no longer being collected.

## Impact

The risk is what this hides. The lag, HA and replication alerts all read metrics from this exporter:

- `CNPGClusterPhysicalReplicationLag*` → `cnpg_pg_replication_lag`
- `CNPGClusterHA*` → `cnpg_pg_replication_streaming_replicas`, `cnpg_pg_replication_is_wal_receiver_up`
- logical replication alerts → `cnpg_pg_stat_subscription_*`

They are `expr > threshold` rules, so once the exporter goes silent there are no samples to evaluate and they never fire. While this alert is active, treat the other replication and HA alerts for this instance as blind.

A hung exporter can coincide with a frozen standby, which is when replication is stuck with no notification because the metric that measures it had stopped reporting.

## Diagnosis

### Step 1: Confirm the pod is up

The alert labels carry `namespace`, `cluster` and `pod`.

```bash
kubectl get pods --namespace <namespace> -l "cnpg.io/podRole=instance" -o wide
kubectl describe pod --namespace <namespace> <pod-name>
```

If the pod is `Running` and `Ready`, it is alive but blind.

### Step 2: Check the metrics endpoint

The collector serves `/metrics` on port `9187`. A hung exporter times out here while the pod stays Ready:

```bash
kubectl exec --namespace <namespace> <pod-name> -- \
  curl -sS --max-time 5 http://localhost:9187/metrics | grep cnpg_collector_up
```

A timeout or empty response confirms the collector is stuck.

### Step 3: Look for a blocked backend

The exporter runs SQL on the local instance. A stuck collector query shows up in `pg_stat_activity`:

```bash
kubectl exec --namespace <namespace> <pod-name> -- psql -c "
SELECT pid, state, wait_event_type, wait_event,
       now() - query_start AS duration, left(query, 120) AS query
FROM pg_stat_activity
WHERE state <> 'idle'
ORDER BY duration DESC NULLS LAST;
"
```

On a standby, check whether replay is actually frozen by looking from the primary:

```bash
kubectl exec --namespace <namespace> services/<cluster_name>-rw -- psql -c "
SELECT application_name, state, replay_lsn, replay_lag FROM pg_stat_replication;
"
```

### Step 4: Inspect logs

```bash
kubectl logs --namespace <namespace> <pod-name> --tail=200
kubectl logs --namespace cnpg-system -l "app.kubernetes.io/name=cloudnative-pg" --tail=200
```

Look for collector errors, statement timeouts, or recovery-conflict / deadlock messages.

## Resolution

1. Terminate the stuck backend found in Step 3, if applicable:

   ```bash
   kubectl exec --namespace <namespace> <pod-name> -- psql -c "SELECT pg_terminate_backend(<pid>);"
   ```

2. If the hang comes from a monitoring query, disable that instrumentation in the cluster's `.spec.monitoring` config until a fixed version is rolled out, then re-enable it after upgrading.

3. As a last resort, recycle the pod. Start with a standby, never the primary, to avoid an unnecessary failover:

   ```bash
   kubectl delete pod --namespace <namespace> <replica-pod-name>
   ```

4. The alert resolves once `cnpg_collector_up` is reported again. Confirm metrics are flowing:

   ```bash
   kubectl exec --namespace <namespace> <pod-name> -- \
     curl -sS --max-time 5 http://localhost:9187/metrics | grep -E "cnpg_collector_up|cnpg_pg_replication_lag"
   ```

## Prevention

- When this fires, audit whether other replication or HA alerts should have fired and were silenced.

## Quick Reference Commands

```bash
# Is the pod up and Ready?
kubectl get pods --namespace <namespace> -l "cnpg.io/podRole=instance" -o wide

# Is the metrics endpoint responding?
kubectl exec --namespace <namespace> <pod-name> -- curl -sS --max-time 5 http://localhost:9187/metrics | grep cnpg_collector_up

# What is the collector backend stuck on?
kubectl exec --namespace <namespace> <pod-name> -- psql -c "
SELECT pid, state, wait_event_type, wait_event, now() - query_start AS duration, left(query,120)
FROM pg_stat_activity WHERE state <> 'idle' ORDER BY duration DESC NULLS LAST;"

# Is replication actually frozen (run against the primary)?
kubectl exec --namespace <namespace> services/<cluster_name>-rw -- psql -c "
SELECT application_name, state, replay_lsn, replay_lag FROM pg_stat_replication;"

# Last-resort restart (standby first)
kubectl delete pod --namespace <namespace> <replica-pod-name>
```

## When to Escalate

- The metrics endpoint stays unresponsive after terminating stuck backends.
- `pg_stat_replication` on the primary shows replay frozen for the affected standby (replication is stuck, not just unmonitored).
- The collector hangs repeatedly after restart or recurs across instances, suggesting a systemic instrumentation or engine bug.
