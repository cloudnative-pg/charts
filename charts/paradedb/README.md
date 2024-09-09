# ParadeDB CloudNativePG Cluster

The [ParadeDB](https://github.com/paradedb/paradedb) Helm Chart is based on the official [CloudNativePG Helm Chart](https://cloudnative-pg.io/). CloudNativePG is a Kubernetes operator that manages the full lifecycle of a highly available PostgreSQL database cluster with a primary/standby architecture using Postgres streaming replication.

Kubernetes, and specifically the CloudNativePG operator, is the recommended approach for deploying ParadeDB in production, with high availability. ParadeDB also provides a [Docker image](https://hub.docker.com/r/paradedb/paradedb) and [prebuilt binaries](https://github.com/paradedb/paradedb/releases) for Debian, Ubuntu and Red Hat Enterprise Linux.

The chart is also available on [Artifact Hub](https://artifacthub.io/packages/helm/paradedb/paradedb).

## Getting Started

First, install [Helm](https://helm.sh/docs/intro/install/). The following steps assume you have a Kubernetes cluster running v1.25+. If you are testing locally, we recommend using [Minikube](https://minikube.sigs.k8s.io/docs/start/).

### Installing the Prometheus Stack

The ParadeDB Helm chart supports monitoring via Prometheus and Grafana. To enable this, you need to have the Prometheus CRDs installed before installing the CloudNativePG operator. If you do not yet have the Prometheus CRDs installed on your Kubernetes cluster, you can install it with:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --atomic --install prometheus-community \
--create-namespace \
--namespace prometheus-community \
--values https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/main/docs/src/samples/monitoring/kube-stack-config.yaml \
prometheus-community/kube-prometheus-stack
```

### Installing the CloudNativePG Operator

Skip this step if the CloudNativePG operator is already installed in your cluster. If you do not wish to monitor your cluster, omit the `--set` commands.

```bash
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --atomic --install cnpg \
--create-namespace \
--namespace cnpg-system \
--set monitoring.podMonitorEnabled=true \
--set monitoring.grafanaDashboard.create=true \
cnpg/cloudnative-pg
```

### Setting up a ParadeDB CNPG Cluster

Create a `values.yaml` and configure it to your requirements. Here is a basic example:

```yaml
type: paradedb
mode: standalone

cluster:
  instances: 3
  storage:
    size: 256Mi
```

Then, launch the ParadeDB cluster. If you do not wish to monitor your cluster, omit the `--set` command.

```bash
helm repo add paradedb https://paradedb.github.io/charts
helm upgrade --atomic --install paradedb \
--namespace paradedb \
--create-namespace \
--values values.yaml \
--set cluster.monitoring.enabled=true \
paradedb/paradedb
```

If `--values values.yaml` is omitted, the default values will be used. For additional configuration options for the `values.yaml` file, including configuring backups and PgBouncer, please refer to the [ParadeDB Helm Chart documentation](https://artifacthub.io/packages/helm/paradedb/paradedb#values). For advanced cluster configuration options, please refer to the [CloudNativePG Cluster Chart documentation](charts/paradedb/README.md).

### Connecting to a ParadeDB CNPG Cluster

The command to connect to the primary instance of the cluster will be printed in your terminal. If you do not modify any settings, it will be:

```bash
kubectl --namespace paradedb exec --stdin --tty services/paradedb-rw -- bash
```

This will launch a Bash shell inside the instance. You can connect to the ParadeDB database via `psql` with:

```bash
psql -d paradedb
```

### Connecting to the Grafana Dashboard

To connect to the Grafana dashboard for your cluster, we suggested port forwarding the Kubernetes service running Grafana to localhost:

```bash
kubectl --namespace prometheus-community port-forward svc/prometheus-community-grafana 3000:80
```

You can then access the Grafana dasbhoard at [http://localhost:3000/](http://localhost:3000/) using the credentials `admin` as username and `prom-operator` as password. These default credentials are
defined in the [`kube-stack-config.yaml`](https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/main/docs/src/samples/monitoring/kube-stack-config.yaml) file used as the `values.yaml` file in [Installing the Prometheus CRDs](#installing-the-prometheus-stack) and can be modified by providing your own `values.yaml` file.

## Development

To test changes to the Chart on a local Minikube cluster, follow the instructions from [Getting Started](#getting-started), replacing the `helm upgrade` step by the path to the directory of the modified `Chart.yaml`.

```bash
helm upgrade --atomic --install paradedb --namespace paradedb --create-namespace ./charts/paradedb
```

## Cluster Configuration

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

## Recovery

There is a separate document outlining the recovery procedure here: **[Recovery](docs/Recovery.md)**

## Examples

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
| backups.s3.inheritFromIAMRole | bool | `false` | Use the role based authentication without providing explicitly the keys |
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
| cluster.enablePDB | bool | `true` | Allow to disable PDB, mainly useful for upgrade of single-instance clusters or development purposes See: https://cloudnative-pg.io/documentation/current/kubernetes_upgrade/#pod-disruption-budgets |
| cluster.enableSuperuserAccess | bool | `true` | When this option is enabled, the operator will use the SuperuserSecret to update the postgres user password. If the secret is not present, the operator will automatically create one. When this option is disabled, the operator will ignore the SuperuserSecret content, delete it when automatically created, and then blank the password of the postgres user by setting it to NULL. |
| cluster.imageCatalogRef | object | `{}` | Reference to `ImageCatalog` of `ClusterImageCatalog`, if specified takes precedence over `cluster.imageName` |
| cluster.imageName | string | `""` | Name of the container image, supporting both tags (<image>:<tag>) and digests for deterministic and repeatable deployments: <image>:<tag>@sha256:<digestValue> |
| cluster.imagePullPolicy | string | `"IfNotPresent"` | Image pull policy. One of Always, Never or IfNotPresent. If not defined, it defaults to IfNotPresent. Cannot be updated. More info: https://kubernetes.io/docs/concepts/containers/images#updating-images |
| cluster.imagePullSecrets | list | `[]` | The list of pull secrets to be used to pull the images. See: https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/#postgresql-cnpg-io-v1-LocalObjectReference |
| cluster.initdb | object | `{"database":"paradedb"}` | BootstrapInitDB is the configuration of the bootstrap process when initdb is used. See: https://cloudnative-pg.io/documentation/current/bootstrap/ See: https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/#postgresql-cnpg-io-v1-bootstrapinitdb |
| cluster.instances | int | `3` | Number of instances |
| cluster.logLevel | string | `"info"` | The instances' log level, one of the following values: error, warning, info (default), debug, trace |
| cluster.monitoring.customQueries | list | `[]` | Custom Prometheus metrics Will be stored in the ConfigMap |
| cluster.monitoring.customQueriesSecret | list | `[]` | The list of secrets containing the custom queries |
| cluster.monitoring.disableDefaultQueries | bool | `false` | Whether the default queries should be injected. Set it to true if you don't want to inject default queries into the cluster. |
| cluster.monitoring.enabled | bool | `true` | Whether to enable monitoring |
| cluster.monitoring.podMonitor.enabled | bool | `true` | Whether to enable the PodMonitor |
| cluster.monitoring.podMonitor.metricRelabelings | list | `[]` | The list of metric relabelings for the PodMonitor. Applied to samples before ingestion. |
| cluster.monitoring.podMonitor.relabelings | list | `[]` | The list of relabelings for the PodMonitor. Applied to samples before scraping. |
| cluster.monitoring.prometheusRule.enabled | bool | `true` | Whether to enable the PrometheusRule automated alerts |
| cluster.monitoring.prometheusRule.excludeRules | list | `[]` | Exclude specified rules |
| cluster.postgresGID | int | `-1` | The GID of the postgres user inside the image, defaults to 26 |
| cluster.postgresUID | int | `-1` | The UID of the postgres user inside the image, defaults to 26 |
| cluster.postgresql.ldap | object | `{}` | PostgreSQL LDAP configuration (see https://cloudnative-pg.io/documentation/current/postgresql_conf/#ldap-configuration) |
| cluster.postgresql.parameters | object | `{"cron.database_name":"postgres"}` | PostgreSQL configuration options (postgresql.conf) |
| cluster.postgresql.pg_hba | list | `[]` | PostgreSQL Host Based Authentication rules (lines to be appended to the pg_hba.conf file) |
| cluster.postgresql.pg_ident | list | `[]` | PostgreSQL User Name Maps rules (lines to be appended to the pg_ident.conf file) |
| cluster.postgresql.shared_preload_libraries | list | `[]` | Lists of shared preload libraries to add to the default ones |
| cluster.postgresql.synchronous | object | `{}` | Quorum-based Synchronous Replication |
| cluster.primaryUpdateMethod | string | `"switchover"` | Method to follow to upgrade the primary server during a rolling update procedure, after all replicas have been successfully updated. It can be switchover (default) or restart. |
| cluster.primaryUpdateStrategy | string | `"unsupervised"` | Strategy to follow to upgrade the primary server during a rolling update procedure, after all replicas have been successfully updated: it can be automated (unsupervised - default) or manual (supervised) |
| cluster.priorityClassName | string | `""` |  |
| cluster.resources | object | `{}` | Resources requirements of every generated Pod. Please refer to https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ for more information. We strongly advise you use the same setting for limits and requests so that your cluster pods are given a Guaranteed QoS. See: https://kubernetes.io/docs/concepts/workloads/pods/pod-qos/ |
| cluster.roles | list | `[]` | This feature enables declarative management of existing roles, as well as the creation of new roles if they are not already present in the database. See: https://cloudnative-pg.io/documentation/current/declarative_role_management/ |
| cluster.serviceAccountTemplate | object | `{}` | Configure the metadata of the generated service account |
| cluster.services | object | `{}` | Customization of service definitions. Please refer to https://cloudnative-pg.io/documentation/1.24/service_management/ |
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
| namespaceOverride | string | `""` | Override the namespace of the chart |
| poolers | list | `[]` | List of PgBouncer poolers |
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
| recovery.database | string | `"app"` | Name of the database used by the application. Default: `app`. |
| recovery.destinationPath | string | `""` | Overrides the provider specific default path. Defaults to: S3: s3://<bucket><path> Azure: https://<storageAccount>.<serviceName>.core.windows.net/<containerName><path> Google: gs://<bucket><path> |
| recovery.endpointCA | object | `{"create":false,"key":"","name":"","value":""}` | Specifies a CA bundle to validate a privately signed certificate. |
| recovery.endpointCA.create | bool | `false` | Creates a secret with the given value if true, otherwise uses an existing secret. |
| recovery.endpointURL | string | `""` | Overrides the provider specific default endpoint. Defaults to: S3: https://s3.<region>.amazonaws.com" Leave empty if using the default S3 endpoint |
| recovery.google.applicationCredentials | string | `""` |  |
| recovery.google.bucket | string | `""` |  |
| recovery.google.gkeEnvironment | bool | `false` |  |
| recovery.google.path | string | `"/"` |  |
| recovery.import.databases | list | `[]` | Databases to import |
| recovery.import.pgDumpExtraOptions | list | `[]` | List of custom options to pass to the `pg_dump` command. IMPORTANT: Use these options with caution and at your own risk, as the operator does not validate their content. Be aware that certain options may conflict with the operator's intended functionality or design. |
| recovery.import.pgRestoreExtraOptions | list | `[]` | List of custom options to pass to the `pg_restore` command. IMPORTANT: Use these options with caution and at your own risk, as the operator does not validate their content. Be aware that certain options may conflict with the operator's intended functionality or design. |
| recovery.import.postImportApplicationSQL | list | `[]` | List of SQL queries to be executed as a superuser in the application database right after is imported. To be used with extreme care. Only available in microservice type. |
| recovery.import.roles | list | `[]` | Roles to import |
| recovery.import.schemaOnly | bool | `false` | When set to true, only the pre-data and post-data sections of pg_restore are invoked, avoiding data import. |
| recovery.import.source.database | string | `""` |  |
| recovery.import.source.host | string | `""` |  |
| recovery.import.source.passwordSecret.create | bool | `false` | Whether to create a secret for the password |
| recovery.import.source.passwordSecret.key | string | `"password"` | The key in the secret containing the password |
| recovery.import.source.passwordSecret.name | string | `""` | Name of the secret containing the password |
| recovery.import.source.passwordSecret.value | string | `""` | The password value to use when creating the secret |
| recovery.import.source.port | int | `5432` |  |
| recovery.import.source.sslCertSecret.key | string | `""` |  |
| recovery.import.source.sslCertSecret.name | string | `""` |  |
| recovery.import.source.sslKeySecret.key | string | `""` |  |
| recovery.import.source.sslKeySecret.name | string | `""` |  |
| recovery.import.source.sslMode | string | `"verify-full"` |  |
| recovery.import.source.sslRootCertSecret.key | string | `""` |  |
| recovery.import.source.sslRootCertSecret.name | string | `""` |  |
| recovery.import.source.username | string | `""` |  |
| recovery.import.type | string | `"microservice"` | One of `microservice` or `monolith`. See: https://cloudnative-pg.io/documentation/1.24/database_import/#how-it-works |
| recovery.method | string | `"backup"` | Available recovery methods: * `backup` - Recovers a CNPG cluster from a CNPG backup (PITR supported) Needs to be on the same cluster in the same namespace. * `object_store` - Recovers a CNPG cluster from a barman object store (PITR supported). * `pg_basebackup` - Recovers a CNPG cluster via streaming replication protocol. Useful if you want to        migrate databases to CloudNativePG, even from outside Kubernetes. * `import` - Import one or more databases from an existing Postgres cluster. |
| recovery.pgBaseBackup.database | string | `"paradedb"` | Name of the database used by the application. Default: `paradedb`. |
| recovery.pgBaseBackup.owner | string | `""` | Name of the secret containing the initial credentials for the owner of the user database. If empty a new secret will be created from scratch |
| recovery.pgBaseBackup.secret | string | `""` | Name of the owner of the database in the instance to be used by applications. Defaults to the value of the `database` key. |
| recovery.pgBaseBackup.source.database | string | `"paradedb"` |  |
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
| recovery.s3.inheritFromIAMRole | bool | `false` | Use the role based authentication without providing explicitly the keys |
| recovery.s3.path | string | `"/"` |  |
| recovery.s3.region | string | `""` |  |
| recovery.s3.secretKey | string | `""` |  |
| recovery.secret.create | bool | `true` | Whether to create a secret for the backup credentials |
| recovery.secret.name | string | `""` | Name of the backup credentials secret |
| type | string | `"paradedb"` | Type of the CNPG database. Available types: * `paradedb` |
| version.paradedb | string | `"0.11.0"` | We default to v0.11.0 for testing and local development |
| version.postgresql | string | `"16"` | PostgreSQL major version to use |
| poolers[].name | string | `` | Name of the pooler resource |
| poolers[].instances | number | `1` | The number of replicas we want |
| poolers[].type | [PoolerType][PoolerType] | `rw` | Type of service to forward traffic to. Default: `rw`. |
| poolers[].poolMode | [PgBouncerPoolMode][PgBouncerPoolMode] | `session` | The pool mode. Default: `session`. |
| poolers[].authQuerySecret | [LocalObjectReference][LocalObjectReference] | `{}` | The credentials of the user that need to be used for the authentication query. |
| poolers[].authQuery | string | `{}` | The credentials of the user that need to be used for the authentication query. |
| poolers[].parameters | map[string]string | `{}` | Additional parameters to be passed to PgBouncer - please check the CNPG documentation for a list of options you can configure |
| poolers[].template | [PodTemplateSpec][PodTemplateSpec] | `{}` | The template of the Pod to be created |
| poolers[].template | [ServiceTemplateSpec][ServiceTemplateSpec] | `{}` | Template for the Service to be created |
| poolers[].pg_hba | []string | `{}` | PostgreSQL Host Based Authentication rules (lines to be appended to the pg_hba.conf file) |
| poolers[].monitoring.enabled | bool | `false` | Whether to enable monitoring for the Pooler. |
| poolers[].monitoring.podMonitor.enabled | bool | `true` | Create a podMonitor for the Pooler. |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| ParadeDB | <support@paradedb.com> | <https://paradedb.com> |

## License

ParadeDB is licensed under the [GNU Affero General Public License v3.0](LICENSE) and as commercial software. For commercial licensing, please contact us at [sales@paradedb.com](mailto:sales@paradedb.com).
