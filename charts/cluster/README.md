# cluster

![Version: 0.0.10](https://img.shields.io/badge/Version-0.0.10-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

> **Warning**
> ### This chart is under active development.
> ### Advised caution when using in production!

A note on the chart's purpose
-----------------------------

This is an opinionated chart that is designed to provide a subset of simple, stable and safe configurations using the
CloudNativePG operator. It is designed to provide a simple way to perform recovery operations to decrease your RTO.

It is not designed to be a one size fits all solution. If you need a more complicated setup we strongly recommend that
you either:

* use the operator directly
* create your own chart
* use Kustomize to modify the chart's resources

**_Note_** that the latter option carries it's own risks as the chart configuration may change, especially before it
reaches a stable release.

That being said, we welcome PRs that improve the chart, but please keep in mind that we don't plan to support every
single configuration that the operator provides and we may reject PRs that add too much complexity and maintenance
difficulty to the chart.

Getting Started
---------------

### Installing the Operator
Skip this step if the CNPG operator is already installed in your cluster.

```console
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg \
--namespace cnpg-system \
--create-namespace \
cnpg/cloudnative-pg
```

### Setting up a CNPG Cluster

```console
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg \
--namespace cnpg-database \
--create-namespace \
--values values.yaml \
cnpg/cluster
```

A more detailed guide can be found in the [Getting Started docs](<./docs/Getting Started.md>).

Cluster Configuration
---------------------

### Database types

Currently the chart supports two database types. These are configured via the `type` parameter. These are:
* `postgresql` - A standard PostgreSQL database.
* `postgis` - A PostgreSQL database with the PostGIS extension installed.

Depending on the type the chart will use a different Docker image and fill in some initial setup, like extension installation.

### Modes of operation

The chart has three modes of operation. These are configured via the `mode` parameter:
* `standalone` - Creates new or updates an existing CNPG cluster. This is the default mode.
* `replica` - Creates a replica cluster from an existing CNPG cluster. **_Note_ that this mode is not yet supported.**
* `recovery` - Recovers a CNPG cluster from a backup, object store or via pg_basebackup.

### Backup configuration

CNPG implements disaster recovery via [Barman](https://pgbarman.org/). The following section configures the barman object
store where backups will be stored. Barman performs backups of the cluster filesystem base backup and WALs. Both are
stored in the specified location. The backup provider is configured via the `backups.objectStorage.provider` parameter.
The following providers are supported:

* S3 or S3-compatible stores, like MinIO or Ceph Rados
* Microsoft Azure Blob Storage
* Google Cloud Storage

Additionally you can specify the following parameters:
* `backups.retentionPolicy` - The retention policy for backups. Defaults to `30d`.
* `backups.scheduledBackups` - An array of scheduled backups containing a name and a crontab schedule. Example:
```yaml
backups:
  scheduledBackups:
    - name: daily-backup
      schedule: "0 0 0 * * *" # Daily at midnight
      backupOwnerReference: self
```

Each backup adapter takes it's own set of parameters, listed in the [Configuration options](#Configuration-options) section
below. Refer to the table for the full list of parameters and place the configuration under the appropriate key:
`backups.objectStorage.providerSettings.s3`, `backups.objectStorage.providerSettings.azure` or `backups.objectStorage.providerSettings.google`.

Recovery
--------

There is a separate document outlining the recovery procedure here: **[Recovery](docs/recovery.md)**

Examples
--------

There are several configuration examples in the [examples](examples) directory. Refer to them for a basic setup and
refer to  the [CloudNativePG Documentation](https://cloudnative-pg.io/documentation/current/) for more advanced configurations.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| backups.existingSecret.name | string | `""` | If the secret name is set, helm chart will create one which needed. Existing secret should contains all required veriables for chosen provider. |
| backups.objectStorage.data.compression | string | `"gzip"` | Data compression method. One of `` (for no compression), `gzip`, `bzip2` or `snappy`. |
| backups.objectStorage.data.encryption | string | `"AES256"` | Whether to instruct the storage provider to encrypt data files. One of `` (use the storage container default), `AES256` or `aws:kms`. |
| backups.objectStorage.data.jobs | int | `2` | Number of data files to be archived or restored in parallel. |
| backups.objectStorage.destinationPath | string | `""` | Overrides the provider specific default path. Defaults to: S3: s3://<bucket><path> Azure: https://<storageAccount>.<serviceName>.core.windows.net/<containerName><path> Google: gs://<bucket><path> |
| backups.objectStorage.endpointCA.create | bool | `false` | Specifies a CA bundle to validate a privately signed certificate. Creates a secret with the given value if true, otherwise uses an existing secret. |
| backups.objectStorage.endpointCA.key | string | `""` |  |
| backups.objectStorage.endpointCA.name | string | `""` |  |
| backups.objectStorage.endpointCA.value | string | `""` |  |
| backups.objectStorage.endpointURL | string | `""` | Overrides the provider specific default endpoint. Defaults to: S3: https://s3.<region>.amazonaws.com" |
| backups.objectStorage.provider | string | `""` | Enables objectStorage provider. One of providers from `providerSettings`, empty string - disables objectStorage backups. https://cloudnative-pg.io/documentation/current/appendixes/object_stores/#appendix-a-common-object-stores-for-backups |
| backups.objectStorage.providerSettings.azure.connectionString | string | `""` | Configures `AZURE_CONNECTION_STRING` in secret |
| backups.objectStorage.providerSettings.azure.containerName | string | `""` |  |
| backups.objectStorage.providerSettings.azure.inheritFromAzureAD | bool | `false` |  |
| backups.objectStorage.providerSettings.azure.path | string | `"/"` |  |
| backups.objectStorage.providerSettings.azure.serviceName | string | `"blob"` |  |
| backups.objectStorage.providerSettings.azure.storageAccount | string | `""` | Configures `AZURE_STORAGE_ACCOUNT` in secret |
| backups.objectStorage.providerSettings.azure.storageKey | string | `""` | Configures `AZURE_STORAGE_KEY` in secret |
| backups.objectStorage.providerSettings.azure.storageSasToken | string | `""` | Configures `AZURE_STORAGE_SAS_TOKEN` in secret |
| backups.objectStorage.providerSettings.google.applicationCredentials | string | `""` | Configures `APPLICATION_CREDENTIALS` in secret |
| backups.objectStorage.providerSettings.google.bucket | string | `""` |  |
| backups.objectStorage.providerSettings.google.gkeEnvironment | bool | `false` |  |
| backups.objectStorage.providerSettings.google.path | string | `"/"` |  |
| backups.objectStorage.providerSettings.s3.accessKey | string | `""` | Configures `ACCESS_KEY_ID` in secret |
| backups.objectStorage.providerSettings.s3.bucket | string | `""` |  |
| backups.objectStorage.providerSettings.s3.path | string | `"/"` |  |
| backups.objectStorage.providerSettings.s3.region | string | `""` |  |
| backups.objectStorage.providerSettings.s3.secretKey | string | `""` | Configures `ACCESS_SECRET_KEY` in secret |
| backups.objectStorage.wal.compression | string | `"gzip"` | WAL compression method. One of `` (for no compression), `gzip`, `bzip2` or `snappy`. |
| backups.objectStorage.wal.encryption | string | `"AES256"` | Whether to instruct the storage provider to encrypt WAL files. One of `` (use the storage container default), `AES256` or `aws:kms`. |
| backups.objectStorage.wal.maxParallel | int | `1` | Number of WAL files to be archived or restored in parallel. |
| backups.retentionPolicy | string | `"30d"` | Retention policy for backups |
| backups.scheduledBackups[0].backupOwnerReference | string | `"self"` | Backup owner reference |
| backups.scheduledBackups[0].method | string | `"barmanObjectStore"` | Backup method, can be `barmanObjectStore` (default) or `volumeSnapshot` |
| backups.scheduledBackups[0].name | string | `"daily-backup"` | Scheduled backup name |
| backups.scheduledBackups[0].schedule | string | `"0 0 0 * * *"` | Schedule in cron format |
| backups.target | string | `"prefer-standby"` | Backup target configuration. One of `prefer-standby`, `primary`. https://cloudnative-pg.io/documentation/current/backup/#backup-from-a-standby |
| backups.volumeSnapshot.className | string | `""` | To enable volumeSnapshot configure className and add scheduledBackup with method `volumeSnapshot` https://cloudnative-pg.io/documentation/current/backup_volumesnapshot/#how-to-configure-volume-snapshot-backups |
| backups.volumeSnapshot.online | bool | `true` | Hot and cold backups https://cloudnative-pg.io/documentation/current/backup_volumesnapshot/#hot-and-cold-backups |
| backups.volumeSnapshot.onlineConfiguration.immediateCheckpoint | bool | `true` |  |
| backups.volumeSnapshot.onlineConfiguration.waitForArchive | bool | `true` |  |
| backups.volumeSnapshot.snapshotOwnerReference | string | `"backup"` | Persistence of volume snapshot objects https://cloudnative-pg.io/documentation/current/backup_volumesnapshot/#persistence-of-volume-snapshot-objects One of `none`, `backup`, `cluster`, note: `retentionPolicy` will work only with `backup` |
| backups.volumeSnapshot.walClassName | string | `""` | WAL snapshots class name, if empty - defaults to `className` |
| cluster.additionalLabels | object | `{}` |  |
| cluster.affinity | object | `{"topologyKey":"topology.kubernetes.io/zone"}` | Affinity/Anti-affinity rules for Pods. See: https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/#postgresql-cnpg-io-v1-AffinityConfiguration |
| cluster.annotations | object | `{}` |  |
| cluster.certificates | object | `{}` | The configuration for the CA and related certificates. See: https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/#postgresql-cnpg-io-v1-CertificatesConfiguration |
| cluster.enableSuperuserAccess | bool | `true` | When this option is enabled, the operator will use the SuperuserSecret to update the postgres user password. If the secret is not present, the operator will automatically create one. When this option is disabled, the operator will ignore the SuperuserSecret content, delete it when automatically created, and then blank the password of the postgres user by setting it to NULL. |
| cluster.imageName | string | `""` | Name of the container image, supporting both tags (<image>:<tag>) and digests for deterministic and repeatable deployments: <image>:<tag>@sha256:<digestValue> |
| cluster.imagePullPolicy | string | `"IfNotPresent"` | Image pull policy. One of Always, Never or IfNotPresent. If not defined, it defaults to IfNotPresent. Cannot be updated. More info: https://kubernetes.io/docs/concepts/containers/images#updating-images |
| cluster.imagePullSecrets | list | `[]` | The list of pull secrets to be used to pull the images. See: https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/#postgresql-cnpg-io-v1-LocalObjectReference |
| cluster.initdb | object | `{}` | BootstrapInitDB is the configuration of the bootstrap process when initdb is used. See: https://cloudnative-pg.io/documentation/current/bootstrap/ See: https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/#postgresql-cnpg-io-v1-bootstrapinitdb |
| cluster.instances | int | `3` | Number of instances |
| cluster.logLevel | string | `"info"` | The instances' log level, one of the following values: error, warning, info (default), debug, trace |
| cluster.monitoring.customQueries | list | `[]` | Custom Prometheus metrics |
| cluster.monitoring.enabled | bool | `false` | Whether to enable monitoring |
| cluster.monitoring.podMonitor.enabled | bool | `true` | Whether to enable the PodMonitor |
| cluster.monitoring.prometheusRule.enabled | bool | `true` | Whether to enable the PrometheusRule automated alerts |
| cluster.monitoring.prometheusRule.excludeRules | list | `[]` | Exclude specified rules |
| cluster.postgresGID | int | `26` | The GID of the postgres user inside the image, defaults to 26 |
| cluster.postgresUID | int | `26` | The UID of the postgres user inside the image, defaults to 26 |
| cluster.postgresql | object | `{}` | Configuration of the PostgreSQL server. See: https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/#postgresql-cnpg-io-v1-PostgresConfiguration |
| cluster.primaryUpdateMethod | string | `"switchover"` | Method to follow to upgrade the primary server during a rolling update procedure, after all replicas have been successfully updated. It can be switchover (default) or restart. |
| cluster.primaryUpdateStrategy | string | `"unsupervised"` | Strategy to follow to upgrade the primary server during a rolling update procedure, after all replicas have been successfully updated: it can be automated (unsupervised - default) or manual (supervised) |
| cluster.priorityClassName | string | `""` |  |
| cluster.resources | object | `{}` | Resources requirements of every generated Pod. Please refer to https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ for more information. We strongly advise you use the same setting for limits and requests so that your cluster pods are given a Guaranteed QoS. See: https://kubernetes.io/docs/concepts/workloads/pods/pod-qos/ |
| cluster.roles | list | `[]` | This feature enables declarative management of existing roles, as well as the creation of new roles if they are not already present in the database. See: https://cloudnative-pg.io/documentation/current/declarative_role_management/ |
| cluster.storage.size | string | `"8Gi"` |  |
| cluster.storage.storageClass | string | `""` |  |
| cluster.superuserSecret | string | `""` |  |
| cluster.walStorage.size | string | `"1Gi"` |  |
| cluster.walStorage.storageClass | string | `""` |  |
| fullnameOverride | string | `""` | Override the full name of the chart |
| import.type | string | `""` | Choose one of types from `typeSettings`, https://cloudnative-pg.io/documentation/current/database_import/ All types require: configure `recovery.method` to `pgBasebackup` and `recovery.methodSettings` accordingly Please be aware off https://cloudnative-pg.io/documentation/current/database_import/#import-optimizations |
| import.typeSettings.microservice.database | string | `""` | Database name to import |
| import.typeSettings.microservice.owner | string | `""` | Configure database owner, defaults to the database name |
| import.typeSettings.microservice.postImportApplicationSQL | list | `[]` | Execute defined SQL queries in the application database after import, optional |
| import.typeSettings.monolith.databases | list | `[]` | List of databases that is required by the imported. Wildcard allow to import all databases. |
| import.typeSettings.monolith.roles | list | `[]` | List of role that is required by the imported databases. Wildcard allow to import all roles. Notes: 1. postgres, streaming_replica & cnp_pooler_pgbouncer roles will not be imported from origin 2. the SUPERUSER option is removed from any imported role |
| mode | string | `"standalone"` | Cluster mode of operation. Available modes: * `standalone` - default mode. Creates new or updates an existing CNPG cluster. * `import` - Creates a cluster by utilizing `pg_dump -Fc` from existing PostgreSQL, allows to migrate even from very old versions of PostgreSQL. * `recovery` - Creates a cluster from a backup, object store, pg_basebackup or volumeSnapshot. * `replica` - Creates a replica cluster from object store or pg_basebackup with settings defined in recovery method. |
| nameOverride | string | `""` | Override the name of the chart |
| pooler.enabled | bool | `false` | Whether to enable PgBouncer |
| pooler.instances | int | `3` | Number of PgBouncer instances |
| pooler.monitoring.enabled | bool | `false` | Whether to enable monitoring |
| pooler.monitoring.podMonitor.enabled | bool | `true` | Whether to enable the PodMonitor |
| pooler.parameters | object | `{"default_pool_size":"25","max_client_conn":"1000"}` | PgBouncer configuration parameters |
| pooler.poolMode | string | `"transaction"` | PgBouncer pooling mode |
| pooler.template | object | `{}` | Custom PgBouncer deployment template. Use to override image, specify resources, etc. |
| pooler.type | string | `"rw"` | PgBouncer type of service to forward traffic to. |
| recovery.existingSecret.name | string | `""` | If the secret name is set, helm chart will create one which needed. Existing secret should contains all required veriables for chosen method or provider. |
| recovery.method | string | `""` | One of methods from `methodSettings`. |
| recovery.methodSettings.backup.name | string | `""` | Recovers a CNPG cluster from a backups.postgresql.cnpg.io custom resource (PITR supported). https://cloudnative-pg.io/documentation/current/recovery/#recovery-from-a-backup-object Needs to be on the same cluster in the same namespace. Name of the backup to recover from. |
| recovery.methodSettings.objectStorage.clusterName | string | `""` | Recovers a CNPG cluster from a barman object store (PITR supported). https://cloudnative-pg.io/documentation/current/recovery/#recovery-from-an-object-store https://cloudnative-pg.io/documentation/current/replica_cluster/#example-of-standalone-replica-cluster-from-an-object-store The original cluster name when used in backups. Also known as serverName. |
| recovery.methodSettings.objectStorage.destinationPath | string | `""` | Overrides the provider specific default path. Defaults to: S3: s3://<bucket><path> Azure: https://<storageAccount>.<serviceName>.core.windows.net/<containerName><path> Google: gs://<bucket><path> |
| recovery.methodSettings.objectStorage.endpointCA | object | `{"create":false,"key":"","name":"","value":""}` | Specifies a CA bundle to validate a privately signed certificate. |
| recovery.methodSettings.objectStorage.endpointCA.create | bool | `false` | Creates a secret with the given value if true, otherwise uses an existing secret. |
| recovery.methodSettings.objectStorage.endpointURL | string | `""` | Overrides the provider specific default endpoint. Defaults to: S3: https://s3.<region>.amazonaws.com" Leave empty if using the default S3 endpoint |
| recovery.methodSettings.objectStorage.provider | string | `""` | Enables objectStorage provider. One of providers from `providerSettings`. https://cloudnative-pg.io/documentation/current/appendixes/object_stores/#appendix-a-common-object-stores-for-backups |
| recovery.methodSettings.objectStorage.providerSettings.azure.connectionString | string | `""` | Configures `AZURE_CONNECTION_STRING` in secret |
| recovery.methodSettings.objectStorage.providerSettings.azure.containerName | string | `""` |  |
| recovery.methodSettings.objectStorage.providerSettings.azure.inheritFromAzureAD | bool | `false` |  |
| recovery.methodSettings.objectStorage.providerSettings.azure.path | string | `"/"` |  |
| recovery.methodSettings.objectStorage.providerSettings.azure.serviceName | string | `"blob"` |  |
| recovery.methodSettings.objectStorage.providerSettings.azure.storageAccount | string | `""` | Configures `AZURE_STORAGE_ACCOUNT` in secret |
| recovery.methodSettings.objectStorage.providerSettings.azure.storageKey | string | `""` | Configures `AZURE_STORAGE_KEY` in secret |
| recovery.methodSettings.objectStorage.providerSettings.azure.storageSasToken | string | `""` | Configures `AZURE_STORAGE_SAS_TOKEN` in secret |
| recovery.methodSettings.objectStorage.providerSettings.google.applicationCredentials | string | `""` | Configures `APPLICATION_CREDENTIALS` in secret |
| recovery.methodSettings.objectStorage.providerSettings.google.bucket | string | `""` |  |
| recovery.methodSettings.objectStorage.providerSettings.google.gkeEnvironment | bool | `false` |  |
| recovery.methodSettings.objectStorage.providerSettings.google.path | string | `"/"` |  |
| recovery.methodSettings.objectStorage.providerSettings.s3.accessKey | string | `""` | Configures `ACCESS_KEY_ID` in secret |
| recovery.methodSettings.objectStorage.providerSettings.s3.bucket | string | `""` |  |
| recovery.methodSettings.objectStorage.providerSettings.s3.path | string | `"/"` |  |
| recovery.methodSettings.objectStorage.providerSettings.s3.region | string | `""` |  |
| recovery.methodSettings.objectStorage.providerSettings.s3.secretKey | string | `""` | Configures `ACCESS_SECRET_KEY` in secret |
| recovery.methodSettings.pgBasebackup.auth | string | `"password"` | Configure one of supported auth types: `password` or `tls` |
| recovery.methodSettings.pgBasebackup.authDetails.password | string | `""` | Configures `password` in secret |
| recovery.methodSettings.pgBasebackup.authDetails.tls.ca | string | `""` | Configures `ca.crt` in secret |
| recovery.methodSettings.pgBasebackup.authDetails.tls.crt | string | `""` | Configures `tls.crt` in secret |
| recovery.methodSettings.pgBasebackup.authDetails.tls.key | string | `""` | Configures `tls.key` in secret |
| recovery.methodSettings.pgBasebackup.connectionParameters | object | `{"database":"","host":"","port":5432,"sslMode":"verify-full","user":""}` | Recovers a CNPG cluster via streaming replication protocol. https://cloudnative-pg.io/documentation/current/bootstrap/#bootstrap-from-a-live-cluster-pg_basebackup https://cloudnative-pg.io/documentation/current/replica_cluster/#example-of-standalone-replica-cluster-using-pg_basebackup |
| recovery.methodSettings.pgBasebackup.connectionParameters.database | string | `""` | Database on source server, optional. If `pgBasebackup.database` set and this setting is empty - will use same database name. |
| recovery.methodSettings.pgBasebackup.connectionParameters.sslMode | string | `"verify-full"` | SSL mode to use while connecting to host. Possible secure options: `verify-full`, `verify-ca`, `require` and insecure: `prefer`, `allow`, `disable`. For more details please see: https://www.postgresql.org/docs/current/libpq-ssl.html#LIBPQ-SSL-PROTECTION |
| recovery.methodSettings.pgBasebackup.database | string | `""` | Configure application database, optional and ignored with replica https://cloudnative-pg.io/documentation/current/bootstrap/#configure-the-application-database |
| recovery.methodSettings.pgBasebackup.owner | string | `""` | Configure database owner, defaults to the database name |
| recovery.methodSettings.pgBasebackup.ownerSecret | string | `""` | Name of the secret containing the initial credentials for the owner of the user database. Secret must contains `username` key that match `owner` and `password` key. If empty - password will be generated randomly and saved to secret generated by Operator. |
| recovery.methodSettings.volumeSnapshot.storageSnapshotName | string | `""` | Recovers a CNPG cluster from a volume snapshot (PITR supported). https://cloudnative-pg.io/documentation/current/recovery/#recovery-from-volumesnapshot-objects |
| recovery.methodSettings.volumeSnapshot.walSnapshotName | string | `""` | WAL snapshot name, optional, need to be set if WAL stored on separate PVC. |
| recovery.pitrTarget.time | string | `""` | Point in time recovery target. Work with backup, objectStorage and volumeSnapshot methods. Time should be set in RFC3339 format. |
| replica.topology | string | `""` | Choose one of topologies from `topologySettings`, https://cloudnative-pg.io/documentation/current/replica_cluster/ standalone: configure `recovery.method` to one of `objectStorage` or `pgBasebackup` and `recovery.methodSettings` accordingly distributed: configure `recovery.method` to `objectStorage` and `recovery.methodSettings` |
| replica.topologySettings.distributed.primary | bool | `true` | Distributed topology requires to use objectStorage in both recovery and backups |
| replica.topologySettings.distributed.promotionToken | string | `""` | Promoting a Replica to a Primary Cluster demotionToken obtrained from demoted primary should set to promotionToken on replica Use `kubectl get cluster cluster-eu-south -o jsonpath='{.status.demotionToken}'` https://cloudnative-pg.io/documentation/current/replica_cluster/#demoting-a-primary-to-a-replica-cluster https://cloudnative-pg.io/documentation/current/replica_cluster/#promoting-a-replica-to-a-primary-cluster |
| replica.topologySettings.standalone.minApplyDelay | string | `""` | Deleyed replication, disabled if empty, set enable set time, f.e: 1h https://cloudnative-pg.io/documentation/current/replica_cluster/#delayed-replicas |
| type | string | `"postgresql"` | Type of the CNPG database. Available types: * `postgresql` * `postgis` |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| itay-grudev | <itay+cloudnativepg-charts+github.com@grudev.com> |  |

Features that require feedback
------------------------------

Please raise a ticket tested any of the following features and they have worked.
Alternatively a ticket and a PR if you have found that something needs a change to work properly.

- [ ] Google Cloud Storage Backups
- [ ] Google Cloud Storage Recovery

TODO
----
* IAM Role for S3 Service Account
* Automatic provisioning of a Alert Manager configuration

