CNPGClusterHighReplicationLag
=============================

Meaning
-------

This alert is triggered when the replication lag of the CloudNativePG cluster exceed `1s`.

Impact
------

High replication lag can cause the cluster replicas become out of sync. Queries to the `-r` and `-ro` endpoints may return stale data.
In the event of a failover, there may be data loss for the time period of the lag.

Diagnosis
---------

Use the [CloudNativePG Grafana Dashboard](https://grafana.com/grafana/dashboards/20417-cloudnativepg/).

High replication lag can be caused by a number of factors, including:
* Network issues
* High load on the primary or replicas
* Long running queries
* Suboptimal PostgreSQL configuration, in particular small numbers of `max_wal_senders`.

```yaml
kubectl exec --namespace <namespace> --stdin --tty services/<cluster_name>-rw -- psql -c "SELECT * from pg_stat_replication;"
```

Mitigation
----------
