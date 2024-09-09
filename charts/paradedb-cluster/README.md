# CloudNativePG Cluster

This README documents the Helm chart for deploying and managing [ParadeDB](https://github.com/paradedb/paradedb) on Kubernetes via [CloudNativePG](https://cloudnative-pg.io/), including advanced settings.

Kubernetes, and specifically the CloudNativePG operator, is the recommended approach for deploying ParadeDB in production. ParadeDB also provides a [Docker image](https://hub.docker.com/r/paradedb/paradedb) and [prebuilt binaries](https://github.com/paradedb/paradedb/releases) for Debian, Ubuntu and Red Hat Enterprise Linux.

## Getting Started

### Installing the Operator

Skip this step if the CNPG operator is already installed in your cluster.

```console
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg \
--namespace cnpg-system \
--create-namespace \
cnpg/cloudnative-pg
```

### Setting up a ParadeDB CNPG Cluster

Create a `values.yaml` and configure it to your requirements. Here is a basic example:

```yaml
type: paradedb
mode: standalone

cluster:
  instances: 2
  storage:
    size: 256Mi
```

You can refer to the other examples in the [`charts/cluster/examples`](https://github.com/paradedb/charts/tree/main/charts/cluster/examples) directory.

```console
helm repo add paradedb https://paradedb.github.io/charts
helm upgrade --install paradedb \
--namespace paradedb-database \
--create-namespace \
--values values.yaml \
paradedb/cluster
```

A more detailed guide can be found in the [Getting Started docs](<./docs/Getting Started.md>).

Cluster Configuration
---------------------

### Database types

To use the ParadeDB Helm Chart, specify `paradedb` via the `type` parameter.

### Modes of operation

The chart has three modes of operation. These are configured via the `mode` parameter:
* `standalone` - Creates new or updates an existing CNPG cluster. This is the default mode.
* `replica` - Creates a replica cluster from an existing CNPG cluster. **_Note_ that this mode is not yet supported.**
* `recovery` - Recovers a CNPG cluster from a backup, object store or via pg_basebackup.

### Backup configuration

CNPG implements disaster recovery via [Barman](https://pgbarman.org/). The following section configures the barman object
store where backups will be stored. Barman performs backups of the cluster filesystem base backup and WALs. Both are
stored in the specified location. The backup provider is configured via the `backups.provider` parameter. The following
providers are supported:

* S3 or S3-compatible stores, like MinIO
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
below. Refer to the table for the full list of parameters and place the configuration under the appropriate key: `backup.s3`,
`backup.azure`, or `backup.google`.

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
| backups.azure.connectionString | string | `""` |  |
| backups.azure.containerName | string | `""` |  |
| backups.azure.inheritFromAzureAD | bool | `false` |  |
| backups.azure.path | string | `"/"` |  |
| backups.azure.serviceName | string | `"blob"` |  |
| backups.azure.storageAccount | string | `""` |  |
| backups.azure.storageKey | string | `""` |  |
| backups.azure.storageSasToken | string | `""` |  |
| backups.data.compression | string | `"gzip"` | Data compression method. One of `` (for no compression), `gzip`, `bzip2` or `snappy`. |
| backups.data.encryption | string | `"AES256"` | Whether to instruct the storage provider to encrypt data files. One of `` (use the storage container default), `AES256` or `aws:kms`. |
| backups.data.jobs | int | `2` | Number of data files to be archived or restored in parallel. |
| backups.destinationPath | string | `""` | Overrides the provider specific default path. Defaults to: S3: s3://<bucket><path> Azure: https://<storageAccount>.<serviceName>.core.windows.net/<containerName><path> Google: gs://<bucket><path> |
| backups.enabled | bool | `false` | You need to configure backups manually, so backups are disabled by default. |
| backups.endpointCA | object | `{"create":false,"key":"","name":"","value":""}` | Specifies a CA bundle to validate a privately signed certificate. |
| backups.endpointCA.create | bool | `false` | Creates a secret with the given value if true, otherwise uses an existing secret. |
| backups.endpointURL | string | `""` | Overrides the provider specific default endpoint. Defaults to: S3: https://s3.<region>.amazonaws.com" |
| backups.google.applicationCredentials | string | `""` |  |
| backups.google.bucket | string | `""` |  |
| backups.google.gkeEnvironment | bool | `false` |  |
| backups.google.path | string | `"/"` |  |
| backups.provider | string | `"s3"` | One of `s3`, `azure` or `google` |
| backups.retentionPolicy | string | `"30d"` | Retention policy for backups |
| backups.s3.accessKey | string | `""` |  |
| backups.s3.bucket | string | `""` |  |
| backups.s3.path | string | `"/"` |  |
| backups.s3.region | string | `""` |  |
| backups.s3.secretKey | string | `""` |  |
| backups.scheduledBackups[0].backupOwnerReference | string | `"self"` | Backup owner reference |
| backups.scheduledBackups[0].method | string | `"barmanObjectStore"` | Backup method, can be `barmanObjectStore` (default) or `volumeSnapshot` |
| backups.scheduledBackups[0].name | string | `"daily-backup"` | Scheduled backup name |
| backups.scheduledBackups[0].schedule | string | `"0 0 0 * * *"` | Schedule in cron format |
| backups.secret.create | bool | `true` | Whether to create a secret for the backup credentials |
| backups.secret.name | string | `""` | Name of the backup credentials secret |
| backups.wal.compression | string | `"gzip"` | WAL compression method. One of `` (for no compression), `gzip`, `bzip2` or `snappy`. |
| backups.wal.encryption | string | `"AES256"` | Whether to instruct the storage provider to encrypt WAL files. One of `` (use the storage container default), `AES256` or `aws:kms`. |
| backups.wal.maxParallel | int | `1` | Number of WAL files to be archived or restored in parallel. |
| cluster.additionalLabels | object | `{}` |  |
| cluster.affinity | object | `{"topologyKey":"topology.kubernetes.io/zone"}` | Affinity/Anti-affinity rules for Pods. See: https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/#postgresql-cnpg-io-v1-AffinityConfiguration |
| cluster.annotations | object | `{}` |  |
| cluster.certificates | object | `{}` | The configuration for the CA and related certificates. See: https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/#postgresql-cnpg-io-v1-CertificatesConfiguration |
| cluster.enableSuperuserAccess | bool | `true` | When this option is enabled, the operator will use the SuperuserSecret to update the postgres user password. If the secret is not present, the operator will automatically create one. When this option is disabled, the operator will ignore the SuperuserSecret content, delete it when automatically created, and then blank the password of the postgres user by setting it to NULL. |
| cluster.imageCatalogRef | object | `{}` | Reference to `ImageCatalog` of `ClusterImageCatalog`, if specified takes precedence over `cluster.imageName` |
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
| cluster.postgresGID | int | `-1` | The GID of the postgres user inside the image, defaults to 26 |
| cluster.postgresUID | int | `-1` | The UID of the postgres user inside the image, defaults to 26 |
| cluster.postgresql.parameters | object | `{}` | PostgreSQL configuration options (postgresql.conf) |
| cluster.postgresql.pg_hba | list | `[]` | PostgreSQL Host Based Authentication rules (lines to be appended to the pg_hba.conf file) |
| cluster.postgresql.pg_ident | list | `[]` |  |
| cluster.postgresql.shared_preload_libraries | list | `[]` |  |
| cluster.primaryUpdateMethod | string | `"switchover"` | Method to follow to upgrade the primary server during a rolling update procedure, after all replicas have been successfully updated. It can be switchover (default) or restart. |
| cluster.primaryUpdateStrategy | string | `"unsupervised"` | Strategy to follow to upgrade the primary server during a rolling update procedure, after all replicas have been successfully updated: it can be automated (unsupervised - default) or manual (supervised) |
| cluster.priorityClassName | string | `""` |  |
| cluster.resources | object | `{}` | Resources requirements of every generated Pod. Please refer to https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ for more information. We strongly advise you use the same setting for limits and requests so that your cluster pods are given a Guaranteed QoS. See: https://kubernetes.io/docs/concepts/workloads/pods/pod-qos/ |
| cluster.roles | list | `[]` | This feature enables declarative management of existing roles, as well as the creation of new roles if they are not already present in the database. See: https://cloudnative-pg.io/documentation/current/declarative_role_management/ |
| cluster.storage.size | string | `"8Gi"` |  |
| cluster.storage.storageClass | string | `""` |  |
| cluster.superuserSecret | string | `""` |  |
| cluster.walStorage.enabled | bool | `false` |  |
| cluster.walStorage.size | string | `"1Gi"` |  |
| cluster.walStorage.storageClass | string | `""` |  |
| fullnameOverride | string | `""` | Override the full name of the chart |
| imageCatalog.create | bool | `true` | Whether to provision an image catalog. If imageCatalog.images is empty this option will be ignored. |
| imageCatalog.images | list | `[]` | List of images to be provisioned in an image catalog. |
| mode | string | `"standalone"` | Cluster mode of operation. Available modes: * `standalone` - default mode. Creates new or updates an existing CNPG cluster. * `replica` - Creates a replica cluster from an existing CNPG cluster. # TODO * `recovery` - Same as standalone but creates a cluster from a backup, object store or via pg_basebackup. |
| nameOverride | string | `""` | Override the name of the chart |
| pooler.enabled | bool | `false` | Whether to enable PgBouncer |
| pooler.instances | int | `3` | Number of PgBouncer instances |
| pooler.monitoring.enabled | bool | `false` | Whether to enable monitoring |
| pooler.monitoring.podMonitor.enabled | bool | `true` | Whether to enable the PodMonitor |
| pooler.parameters | object | `{"default_pool_size":"25","max_client_conn":"1000"}` | PgBouncer configuration parameters |
| pooler.poolMode | string | `"transaction"` | PgBouncer pooling mode |
| pooler.template | object | `{}` | Custom PgBouncer deployment template. Use to override image, specify resources, etc. |
| pooler.type | string | `"rw"` | PgBouncer type of service to forward traffic to. |
| recovery.azure.connectionString | string | `""` |  |
| recovery.azure.containerName | string | `""` |  |
| recovery.azure.inheritFromAzureAD | bool | `false` |  |
| recovery.azure.path | string | `"/"` |  |
| recovery.azure.serviceName | string | `"blob"` |  |
| recovery.azure.storageAccount | string | `""` |  |
| recovery.azure.storageKey | string | `""` |  |
| recovery.azure.storageSasToken | string | `""` |  |
| recovery.backupName | string | `""` | Backup Recovery Method |
| recovery.clusterName | string | `""` | The original cluster name when used in backups. Also known as serverName. |
| recovery.destinationPath | string | `""` | Overrides the provider specific default path. Defaults to: S3: s3://<bucket><path> Azure: https://<storageAccount>.<serviceName>.core.windows.net/<containerName><path> Google: gs://<bucket><path> |
| recovery.endpointCA | object | `{"create":false,"key":"","name":"","value":""}` | Specifies a CA bundle to validate a privately signed certificate. |
| recovery.endpointCA.create | bool | `false` | Creates a secret with the given value if true, otherwise uses an existing secret. |
| recovery.endpointURL | string | `""` | Overrides the provider specific default endpoint. Defaults to: S3: https://s3.<region>.amazonaws.com" Leave empty if using the default S3 endpoint |
| recovery.google.applicationCredentials | string | `""` |  |
| recovery.google.bucket | string | `""` |  |
| recovery.google.gkeEnvironment | bool | `false` |  |
| recovery.google.path | string | `"/"` |  |
| recovery.method | string | `"backup"` | Available recovery methods: * `backup` - Recovers a CNPG cluster from a CNPG backup (PITR supported) Needs to be on the same cluster in the same namespace. * `object_store` - Recovers a CNPG cluster from a barman object store (PITR supported). * `pg_basebackup` - Recovers a CNPG cluster viaa streaming replication protocol. Useful if you want to        migrate databases to CloudNativePG, even from outside Kubernetes. # TODO |
| recovery.pgBaseBackup.database | string | `"app"` | Name of the database used by the application. Default: `app`. |
| recovery.pgBaseBackup.owner | string | `""` | Name of the secret containing the initial credentials for the owner of the user database. If empty a new secret will be created from scratch |
| recovery.pgBaseBackup.secret | string | `""` | Name of the owner of the database in the instance to be used by applications. Defaults to the value of the `database` key. |
| recovery.pgBaseBackup.source.database | string | `"app"` |  |
| recovery.pgBaseBackup.source.host | string | `""` |  |
| recovery.pgBaseBackup.source.passwordSecret.create | bool | `false` | Whether to create a secret for the password |
| recovery.pgBaseBackup.source.passwordSecret.key | string | `"password"` | The key in the secret containing the password |
| recovery.pgBaseBackup.source.passwordSecret.name | string | `""` | Name of the secret containing the password |
| recovery.pgBaseBackup.source.passwordSecret.value | string | `""` | The password value to use when creating the secret |
| recovery.pgBaseBackup.source.port | int | `5432` |  |
| recovery.pgBaseBackup.source.sslCertSecret.key | string | `""` |  |
| recovery.pgBaseBackup.source.sslCertSecret.name | string | `""` |  |
| recovery.pgBaseBackup.source.sslKeySecret.key | string | `""` |  |
| recovery.pgBaseBackup.source.sslKeySecret.name | string | `""` |  |
| recovery.pgBaseBackup.source.sslMode | string | `"verify-full"` |  |
| recovery.pgBaseBackup.source.sslRootCertSecret.key | string | `""` |  |
| recovery.pgBaseBackup.source.sslRootCertSecret.name | string | `""` |  |
| recovery.pgBaseBackup.source.username | string | `""` |  |
| recovery.pitrTarget.time | string | `""` | Time in RFC3339 format |
| recovery.provider | string | `"s3"` | One of `s3`, `azure` or `google` |
| recovery.s3.accessKey | string | `""` |  |
| recovery.s3.bucket | string | `""` |  |
| recovery.s3.path | string | `"/"` |  |
| recovery.s3.region | string | `""` |  |
| recovery.s3.secretKey | string | `""` |  |
| recovery.secret.create | bool | `true` | Whether to create a secret for the backup credentials |
| recovery.secret.name | string | `""` | Name of the backup credentials secret |
| type | string | `"paradedb"` | Type of the CNPG database. Available types: * `paradedb` |
| version.paradedb | string | `"0.0.0"` | The ParadeDB version, set in the publish CI workflow from the latest paradedb/paradedb GitHub tag |
| version.postgis | string | `"3.4"` | If using PostGIS, specify the version |
| version.postgresql | string | `"16"` | PostgreSQL major version to use |
| version.timescaledb | string | `"2.15"` | If using TimescaleDB, specify the version |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| ParadeDB | <support@paradedb.com> | <https://paradedb.com> |

