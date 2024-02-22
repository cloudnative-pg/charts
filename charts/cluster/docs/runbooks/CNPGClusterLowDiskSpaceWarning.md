CNPGClusterLowDiskSpaceWarning
==============================

Meaning
-------

This alert is triggered when the disk space on the CNPG cluster is running low. It can be triggered by either:

* Data PVC
* WAL PVC
* Tablespace PVC

Impact
------

Use the [CloudNativePG Grafana Dashboard](https://grafana.com/grafana/dashboards/20417-cloudnativepg/).

Excessive disk space usage can lead fragmentation negatively impacting performance. Reaching 100% disk usage will result
in downtime and data loss.

Diagnosis
---------

Mitigation
----------
