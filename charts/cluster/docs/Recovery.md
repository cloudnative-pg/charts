Recovery
========

This chart can be used to initiate a recovery operation of a CNPG cluster no matter if it was created with the chart or not.

CNPG does not support recovery in-place. Instead you need to create a new cluster that will be bootstrapped from the existing one or from a backup.

You can find more information about the recovery process in the [CNPG documentation](https://cloudnative-pg.io/documentation/current/backup_recovery).

There are 3 types of recovery possible with CNPG:
* Recovery from a backup object in the same Kubernetes namespace.
* Recovery from a Barman Object Store, that could be located anywhere.
* Streaming replication from an operating cluster using `pg_basebackup`.

When performing a recovery you are strongly advised to use the same configuration and PostgreSQL version as the original cluster.

To begin, create a `values.yaml` that contains the following:

1. Set `mode: recovery` to indicate that you want to perform bootstrap the new cluster from an existing one.
2. Set the `recovery.method` to the type of recovery you want to perform.
3. Set either the `recovery.backupName` or the Barman Object Store configuration - i.e. `recovery.provider` and appropriate S3, Azure or GCS configuration. In case of `pg_basebackup` complete the `recovery.pgBaseBackup` section. 
4. Optionally set the `recovery.pitrTarget.time` in RFC3339 format to perform a point-in-time recovery (not applicable for `pgBaseBackup`).
5. Retain the identical PostgreSQL version and configuration as the original cluster.
6. Make sure you don't use the same backup section name as the original cluster. We advise you change the `path` within the storage location if you want to reuse the same storage location/bucket.
    One pattern is adding a version number at the end of the path, e.g. `/v1` or `/v2` after each recovery procedure.

Example recovery configurations can be found in the [examples](../examples) directory.
