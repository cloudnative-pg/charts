> **Warning**  
> ### This chart is under active development.  
> ### Do not use in production!

## Features that require feedback

Please raise a ticket tested any of the following features and they have worked.  
Alternatively a ticket and a PR if you have found that something needs a change to work properly.

- [ ] Azure Cloud Storage Backups
- [ ] Google Cloud Storage Backups
- [ ] Azure Cloud Storage Recovery
- [ ] Google Cloud Storage Recovery

## A note on the chart's purpose

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

### Setting up a PostgreSQL Cluster

```console
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg \
  --namespace cnpg-database \
  --create-namespace \
  cnpg/cluster
```

### Examples

There are several configuration examples in the [examples](examples) directory. Refer to them for a basic setup and to
the [CloudNativePG Documentation](https://cloudnative-pg.io/documentation/current/) for more advanced configurations.

## TODO
* IAM Role for S3 Service Account 
* Automatic provisioning of a Grafana Dashboard
* Automatic provisioning of a Alert Manager configuration

## Configuration

| Parameter                                       | Default                       | Description                                                                                                                                                                                      |
|-------------------------------------------------|-------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `nameOverride`                                  | `""`                          | Override the name of the chart                                                                                                                                                                   |
| `fullnameOverride`                              | `""`                          | Override the full name of the chart                                                                                                                                                              |
| `type`                                          | `postgresql`                  | The type of the CNPG database. Can be on of: `postgresql`, `postgis`                                                                                                                             |
| `mode`                                          | `standalone`                  | The mode of the CNPG database. Can be on of: `standalone`, `replica`, `recovery`                                                                                                                 |
| `recovery.method`                               | `"backup"`                    | The recovery method to use. Can be one of: `backup`, `object_store`, `pg_basebackup`                                                                                                             |
| `recovery.pitrTarget.time`                      | `""`                          | Point in time recovery target time in RFC3339 format.                                                                                                                                            |
| `recovery.backupName`                           | `""`                          | Backup Name when performing a recovery from a backup.                                                                                                                                            |
| `recovery.clusterName`                          | `""`                          | Name of the original cluster when performing a recovery from a Barman Object Store.                                                                                                              |
| `recovery.endpointURL`                          | `""`                          | Endpoint to be used to download data from the cloud, overriding the automatic endpoint discovery.                                                                                                |
| `recovery.destinationPath`                      | `""`                          | The path where to store the backup (i.e. s3://bucket/path/to/folder) this path, with different destination folders, will be used for WALs and for data.                                          |
| `recovery.provider`                             | `""`                          | The cloud provider to use for the recovery. Can be one of: `s3`, `azure`, `google`.                                                                                                              |
| `recovery.s3.region`                            | `""`                          | The S3 region to be used for recovery.                                                                                                                                                           |
| `recovery.s3.bucket`                            | `""`                          | The S3 bucket to be used for recovery.                                                                                                                                                           |
| `recovery.s3.path`                              | `"/"`                         | The S3 path to be used for recovery.                                                                                                                                                             |
| `recovery.s3.accessKey`                         | `""`                          | The S3 access key to be used for recovery.                                                                                                                                                       |
| `recovery.s3.secretKey`                         | `""`                          | The S3 secret key to be used for recovery.                                                                                                                                                       |
| `recovery.azure.path`                           | `"/"`                         | The Azure path to be used for recovery.                                                                                                                                                          |
| `recovery.azure.connectionString`               | `""`                          | The Azure connection string to be used for recovery.                                                                                                                                             |
| `recovery.azure.storageAccount`                 | `""`                          | The storage account where to upload data.                                                                                                                                                        |
| `recovery.azure.storageKey`                     | `""`                          | The storage account key to be used in conjunction with the storage account name.                                                                                                                 |
| `recovery.azure.storageSasToken`                | `""`                          | A shared-access-signature to be used in conjunction with the storage account name.                                                                                                               |
| `recovery.azure.containerName`                  | `""`                          | The Azure container name to use for recovery.                                                                                                                                                    |
| `recovery.azure.serviceName`                    | `blob`                        | The Azure service name to use for recovery.                                                                                                                                                      |
| `recovery.azure.inheritFromAzureAD`             | `false`                       | Use the Azure AD based authentication without providing explicitly the keys.                                                                                                                     |
| `recovery.google.path`                          | `"/"`                         | The Google path to be used for recovery.                                                                                                                                                         |
| `recovery.google.bucket`                        | `""`                          | The Google bucket to be used for recovery.                                                                                                                                                       |
| `recovery.google.gkeEnvironment`                | `false`                       | If set to true, will presume that it's running inside a GKE environment, default to false.                                                                                                       |
| `recovery.google.applicationCredentials`        | `""`                          | The secret containing the Google Cloud Storage JSON file with the credentials.                                                                                                                   |
| `cluster.instances`                             | `1`                           | The number of instances to deploy.                                                                                                                                                               |
| `cluster.imageName`                             | Depends on `type`             | Name of the container image, supporting both tags and digests for deterministic and repeatable deployments: ` <image>:<tag>@sha256:<digestValue>`                                                |
| `cluster.imagePullPolicy`                       | `IfNotPresent`                | The image pull policy to use.                                                                                                                                                                    |
| `cluster.imagePullSecrets`                      | `[]`                          | The image pull secrets to use.                                                                                                                                                                   |
| `cluster.storage.size`                          | `8Gi`                         | The size of the persistent volume to use.                                                                                                                                                        |
| `cluster.storage.storageClass`                  | `""`                          | The storage class to use for the persistent volume.                                                                                                                                              |
| `cluster.resources`                             | `{}`                          | The resources to allocate for the container. **_Note:_** You are should use the same setting for Resources and Limits to ensure Guaranteed QoS.                                                  |
| `cluster.priorityClassName`                     | `""`                          | The priority class name to use for the container.                                                                                                                                                |
| `cluster.primaryUpdateMethod`                   | `switchover`                  | It can be `switchover` (default) or `in-place` (restart).                                                                                                                                        |
| `cluster.primaryUpdateStrategy`                 | `unsupervised`                | Strategy for upgrading the primary server during a rolling update procedure, after replicas have been updated: it can be `unsupervised` (default) or `supervised` (manual).                      |
| `cluster.logLevel`                              | `info`                        | The log level to use. One of the following values: `error`, `warning`, `info` (default), `debug`, `trace`.                                                                                       |
| `cluster.affinity.topologyKey`                  | `topology.kubernetes.io/zone` | Affinity/Anti-affinity rules for Pods. See [Kubernetes documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) for more details.     |
| `cluster.certificates`                          | `{}`                          | The configuration for the CA and related certificates. See [CertificatesConfiguration](https://cloudnative-pg.io/documentation/current/api_reference/#CertificatesConfiguration).                |
| `cluster.enableSuperuserAccess`                 | `true`                        | Enable superuser access to the database.                                                                                                                                                         |
| `cluster.superuserSecret`                       | `""`                          | Superuser password. If not provided, a random password will be generated.                                                                                                                        |
| `cluster.monitoring.enablePodMonitor`           | `true`                        | Pod monitoring configuration. See [Monitoring](https://cloudnative-pg.io/documentation/current/monitoring/).                                                                                     |
| `cluster.monitoring.customQueries`              | `[]`                          | Custom monitoring metrics. See [Monitoring](https://cloudnative-pg.io/documentation/current/monitoring/).                                                                                        |
| `cluster.postgresql`                            | `{}`                          | Configuration of the PostgreSQL server. See [PostgreSQL Configuration](https://cloudnative-pg.io/documentation/current/api_reference/#PostgresConfiguration).                                    |
| `cluster.initSQL`                               | `[]`                          | SQL Queries run during the initialization of the cluster.                                                                                                                                        |
| `cluster.additionalLabels`                      | `{}`                          |                                                                                                                                                                                                  |
| `cluster.annotations`                           | `{}`                          |                                                                                                                                                                                                  |
| `backups.enabled`                               | `false`                       | Whether to enable backups.                                                                                                                                                                       |
| `backups.scheduledBackups.name`                 | ``                            | Scheduled Backup Name.                                                                                                                                                                           |
| `backups.scheduledBackups.schedule`             | ``                            | Cron Schedule syntax.                                                                                                                                                                            |
| `backups.scheduledBackups.backupOwnerReference` | `self`                        | Indicates which ownerReference should be put inside the created backup resources. See [ScheduledBackupSpec](https://cloudnative-pg.io/documentation/current/api_reference/#ScheduledBackupSpec). |
| `backups.retentionPolicy`                       | `"30d"`                       | Retention policy to be used for backups and WALs (i.e. '60d'). The retention policy is expressed in the form of XXu where XX is a positive integer and u is in [dwm] - days, weeks, months.      |
| `backups.endpointURL`                           | `""`                          | Endpoint to be used to upload data to the cloud, overriding the automatic endpoint discovery.                                                                                                    |
| `backups.destinationPath`                       | `""`                          | The path where to store the backup (i.e. s3://bucket/path/to/folder) this path, with different destination folders, will be used for WALs and for data.                                          |
| `backups.provider`                              | `""`                          | The cloud provider to use for the recovery. Can be one of: `s3`, `azure`, `google`.                                                                                                              |
| `backups.s3.region`                             | `""`                          | The S3 region to be used for backups.                                                                                                                                                            |
| `backups.s3.bucket`                             | `""`                          | The S3 bucket to be used for backups.                                                                                                                                                            |
| `backups.s3.path`                               | `"/"`                         | The S3 path to be used for backups.                                                                                                                                                              |
| `backups.s3.accessKey`                          | `""`                          | The S3 access key to be used for backups.                                                                                                                                                        |
| `backups.s3.secretKey`                          | `""`                          | The S3 secret key to be used for backups.                                                                                                                                                        |
| `backups.azure.path`                            | `"/"`                         | The Azure path to be used for backups.                                                                                                                                                           |
| `backups.azure.connectionString`                | `""`                          | The Azure connection string to be used for backups.                                                                                                                                              |
| `backups.azure.storageAccount`                  | `""`                          | The storage account where to upload data.                                                                                                                                                        |
| `backups.azure.storageKey`                      | `""`                          | The storage account key to be used in conjunction with the storage account name.                                                                                                                 |
| `backups.azure.storageSasToken`                 | `""`                          | A shared-access-signature to be used in conjunction with the storage account name.                                                                                                               |
| `backups.azure.containerName`                   | `""`                          | The Azure container name to use for backups.                                                                                                                                                     |
| `backups.azure.serviceName`                     | `blob`                        | The Azure service name to use for backups.                                                                                                                                                       |
| `backups.azure.inheritFromAzureAD`              | `false`                       | Use the Azure AD based authentication without providing explicitly the keys.                                                                                                                     |
| `backups.google.path`                           | `"/"`                         | The Google path to be used for backups.                                                                                                                                                          |
| `backups.google.bucket`                         | `""`                          | The Google bucket to be used for backups.                                                                                                                                                        |
| `backups.google.gkeEnvironment`                 | `false`                       | If set to true, will presume that it's running inside a GKE environment, default to false.                                                                                                       |
| `backups.google.applicationCredentials`         | `""`                          | The secret containing the Google Cloud Storage JSON file with the credentials                                                                                                                    |

## LICENSE

Apache License, Version 2.0
