# cluster

![Version: 0.0.3](https://img.shields.io/badge/Version-0.0.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

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

A more detailed guide can be found here: [Getting Started](docs/Getting Started.md)

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
| backups.destinationPath | string | `""` | Overrides the provider specific default path. Defaults to: S3: s3://<bucket><path> Azure: https://<storageAccount>.<serviceName>.core.windows.net/<clusterName><path> Google: gs://<bucket><path> |
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
| backups.scheduledBackups[0].name | string | `"daily-backup"` | Scheduled backup name |
| backups.scheduledBackups[0].schedule | string | `"0 0 0 * * *"` | Schedule in cron format |
| backups.wal.compression | string | `"gzip"` | WAL compression method. One of `` (for no compression), `gzip`, `bzip2` or `snappy`. |
| backups.wal.encryption | string | `"AES256"` | Whether to instruct the storage provider to encrypt WAL files. One of `` (use the storage container default), `AES256` or `aws:kms`. |
| backups.wal.maxParallel | int | `1` | Number of WAL files to be archived or restored in parallel. |
| cluster.additionalLabels | object | `{}` |  |
| cluster.affinity | object | `{"topologyKey":"topology.kubernetes.io/zone"}` | Affinity/Anti-affinity rules for Pods. See: https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/#postgresql-cnpg-io-v1-AffinityConfiguration |
| cluster.annotations | object | `{}` |  |
| cluster.certificates | string | `nil` | The configuration for the CA and related certificates. See: https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/#postgresql-cnpg-io-v1-CertificatesConfiguration |
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
| cluster.postgresGID | int | `26` | The GID of the postgres user inside the image, defaults to 26 |
| cluster.postgresUID | int | `26` | The UID of the postgres user inside the image, defaults to 26 |
| cluster.postgresql | object | `{}` | Configuration of the PostgreSQL server. See: https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/#postgresql-cnpg-io-v1-PostgresConfiguration |
| cluster.primaryUpdateMethod | string | `"switchover"` | Method to follow to upgrade the primary server during a rolling update procedure, after all replicas have been successfully updated. It can be switchover (default) or in-place (restart). |
| cluster.primaryUpdateStrategy | string | `"unsupervised"` | Strategy to follow to upgrade the primary server during a rolling update procedure, after all replicas have been successfully updated: it can be automated (unsupervised - default) or manual (supervised) |
| cluster.priorityClassName | string | `""` |  |
| cluster.resources | object | `{}` | Resources requirements of every generated Pod. Please refer to https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ for more information. We strongly advise you use the same setting for limits and requests so that your cluster pods are given a Guaranteed QoS. See: https://kubernetes.io/docs/concepts/workloads/pods/pod-qos/ |
| cluster.storage.size | string | `"8Gi"` |  |
| cluster.storage.storageClass | string | `""` |  |
| cluster.superuserSecret | string | `""` |  |
| fullnameOverride | string | `""` | Override the full name of the chart |
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
| recovery.clusterName | string | `""` | Object Store Recovery Method |
| recovery.destinationPath | string | `""` | Overrides the provider specific default path. Defaults to: S3: s3://<bucket><path> Azure: https://<storageAccount>.<serviceName>.core.windows.net/<clusterName><path> Google: gs://<bucket><path> |
| recovery.endpointCA | object | `{"create":false,"key":"","name":"","value":""}` | Specifies a CA bundle to validate a privately signed certificate. |
| recovery.endpointCA.create | bool | `false` | Creates a secret with the given value if true, otherwise uses an existing secret. |
| recovery.endpointURL | string | `""` | Overrides the provider specific default endpoint. Defaults to: S3: https://s3.<region>.amazonaws.com" Leave empty if using the default S3 endpoint |
| recovery.google.applicationCredentials | string | `""` |  |
| recovery.google.bucket | string | `""` |  |
| recovery.google.gkeEnvironment | bool | `false` |  |
| recovery.google.path | string | `"/"` |  |
| recovery.method | string | `"backup"` | Available recovery methods: * `backup` - Recovers a CNPG cluster from a CNPG backup (PITR supported) Needs to be on the same cluster in the same namespace. * `object_store` - Recovers a CNPG cluster from a barman object store (PITR supported). * `pg_basebackup` - Recovers a CNPG cluster viaa streaming replication protocol. Useful if you want to        migrate databases to CloudNativePG, even from outside Kubernetes. # TODO |
| recovery.pitrTarget.time | string | `""` | Time in RFC3339 format |
| recovery.provider | string | `"s3"` | One of `s3`, `azure` or `google` |
| recovery.s3.accessKey | string | `""` |  |
| recovery.s3.bucket | string | `""` |  |
| recovery.s3.path | string | `"/"` |  |
| recovery.s3.region | string | `""` |  |
| recovery.s3.secretKey | string | `""` |  |
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

