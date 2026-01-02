# CNPGClusterHighPhysicalReplicationLagWarning

## Description

The `CNPGClusterHighPhysicalReplicationLagWarning` alert is triggered when physical replication lag in the CloudNativePG cluster exceeds 1 second.

## Impact

High physical replication lag can cause the cluster replicas to become out of sync. Queries to the `-r` and `-ro` endpoints may return stale data. In the event of a failover, the data that has not yet been replicated from the primary to the replicas may be lost during failover..

## Diagnosis

Check replication status in the [CloudNativePG Grafana Dashboard](https://grafana.com/grafana/dashboards/20417-cloudnativepg/) or by running:

```bash
kubectl exec --namespace <namespace> --stdin --tty services/<cluster_name>-rw -- psql -c "SELECT * FROM pg_stat_replication;"
```

High physical replication lag can be caused by a number of factors, including:

- Network congestion on the node interface

Inspect the network interface statistics using the `Kubernetes Cluster` section of the [CloudNativePG Grafana Dashboard](https://grafana.com/grafana/dashboards/20417-cloudnativepg/).

- High CPU or memory load on primary or replicas

Inspect the CPU and Memory usage of the CloudNativePG cluster instances using the [CloudNativePG Grafana Dashboard](https://grafana.com/grafana/dashboards/20417-cloudnativepg/).

- Disk I/O bottlenecks on replicas

Inspect the disk IO statistics using the [CloudNativePG Grafana Dashboard](https://grafana.com/grafana/dashboards/20417-cloudnativepg/).

- Long-running queries

Inspect the `Stat Activity` section of the [CloudNativePG Grafana Dashboard](https://grafana.com/grafana/dashboards/20417-cloudnativepg/).

- Suboptimal PostgreSQL configuration, e.g. too `few max_wal_senders`. Set this to at least the number of cluster instances (default 10 is usually sufficient).

Inspect the `PostgreSQL Parameters` section of the [CloudNativePG Grafana Dashboard](https://grafana.com/grafana/dashboards/20417-cloudnativepg/).

## Mitigation

- Terminate long-running transactions that generate excessive changes.

```bash
kubectl exec -it services/cluster-rw --namespace <namespace> -- psql
```

- Increase the Memory and CPU resources of the instances under heavy load. This can be done by setting `cluster.resources.requests` and `cluster.resources.limits` in your Helm values. Set both `requests` and `limits` to the same value to achieve QoS Guaranteed. This will require a restart of the CloudNativePG cluster instances and a primary switchover, which will cause a brief service disruption.

- Enable `wal_compression` by setting the `cluster.postgresql.parameters.wal_compression` parameter to `on`. Doing so will reduce the size of the WAL files and can help reduce replication lag in a congested network. Changing `wal_compression` does not require a restart of the CloudNativePG cluster.

- Increase IOPS or throughput of the storage used by the cluster to alleviate disk I/O bottlenecks. This requires creating a new storage class with higher IOPS/throughput and rebuilding cluster instances and their PVCs one by one using the new storage class. This is a slow process that will also affect the cluster's availability.

If you decide to go this route:

1. Start by creating a new storage class. Storage classes are immutable, so you cannot change the storage class of existing Persistent Volume Claims (PVCs).

2. Make sure to only replace one instance at a time to avoid service disruption.

3. Double check you are deleting the correct pod.

4. Don't start with the active primary instance. Delete one of the standby replicas first.

```bash
kubectl delete --namespace <namespace> pod/<pod-name> pvc/<pod-name> pvc/<pod-name>-wal
```

- In the event that the cluster has 9+ instances, ensure that the `max_wal_senders` parameter is set to a value greater than or equal to the total number of instances in your cluster.
