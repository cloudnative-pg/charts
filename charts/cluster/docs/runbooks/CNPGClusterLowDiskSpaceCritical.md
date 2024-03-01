CNPGClusterLowDiskSpaceCritical
===============================

Meaning
-------

This alert is triggered when the disk space on the CloudNativePG cluster exceeds 90%. It can be triggered by either:

* the PVC hosting the `PGDATA` (`storage` section)
* the PVC hosting WAL files (`walStorage` section), where applicable
* any PVC hosting a tablespace (`tablespaces` section)

Impact
------

Use the [CloudNativePG Grafana Dashboard](https://grafana.com/grafana/dashboards/20417-cloudnativepg/).

Excessive disk space usage can lead fragmentation negatively impacting performance. Reaching 100% disk usage will result
in downtime and data loss.

Diagnosis
---------

Mitigation
----------

If you experience issues with the WAL (Write-Ahead Logging) volume and have
set up continuous archiving, ensure that WAL archiving is functioning
correctly. This is crucial to avoid a buildup of WAL files in the `pg_wal`
folder. Monitor the `cnpg_collector_pg_wal_archive_status` metric, specifically
ensuring that the number of `ready` files does not increase linearly.
