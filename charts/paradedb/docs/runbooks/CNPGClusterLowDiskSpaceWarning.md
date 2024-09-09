# CNPGClusterLowDiskSpaceWarning

## Description

The `CNPGClusterLowDiskSpaceWarning` alert is triggered when disk usage on any CloudNativePG cluster volume exceeds 80%. It may occur on the following volumes:

- The PVC hosting `PGDATA` (`storage` section)
- The PVC hosting WAL files (`walStorage` section)
- Any PVC hosting a tablespace (`tablespaces` section)

## Impact

At 100% disk usage, the cluster will experience downtime and potential data loss.

High disk usage can also cause fragmentation, where files are split due to insufficient contiguous free space, significantly increasing random I/O and degrading performance. Disk fragmentation can start happening at ~80% disk space usage.

## Diagnosis

Check disk usage metrics in the [CloudNativePG Grafana Dashboard](https://grafana.com/grafana/dashboards/20417-cloudnativepg/) to identify which volume is nearing capacity.

## Mitigation

If the WAL (Write-Ahead Logging) volume is filling and you have continuous archiving enabled, verify that WAL archiving is functioning correctly. A buildup of WAL files in `pg_wal` indicates an issue. Monitor the `cnpg_collector_pg_wal_archive_status` metric and ensure the number of `ready` files is not steadily increasing.

For more details, see the [CloudNativePG documentation on resizing storage](https://cloudnative-pg.io/documentation/current/troubleshooting/#storage-is-full).
