# Getting Started

The CNPG cluster chart follows a convention over configuration approach. This means that the chart will create a reasonable 
CNPG setup with sensible defaults. However, you can override these defaults to create a more customized setup. Note that
you still need to configure backups and monitoring separately. The chart will not install a Prometheus stack for you.

_**Note,**_ that this is an opinionated chart. It does not support all configuration options that CNPG supports. If you
need a highly customized setup, you should manage your cluster via a Kubernetes CNPG cluster manifest instead of this chart.
Refer to the [CNPG documentation](https://cloudnative-pg.io/documentation/current/) in that case.

## Installing the operator

To begin, make sure you install the CNPG operator in you cluster. It can be installed via a Helm chart as shown below or
ir can be installed via a Kubernetes manifest. For more information see the [CNPG documentation](https://cloudnative-pg.io/documentation/current/installation_upgrade/).

```console
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg \
  --namespace cnpg-system \
  --create-namespace \
  cnpg/cloudnative-pg
```

## Creating a cluster configuration

Once you have the operator installed, the next step is to prepare the cluster configuration. Whether this will be manged
via a GitOps solution or directly via Helm is up to you. The following sections outlines the important steps in both cases.

### Choosing the database type

Currently the chart supports two database types. These are configured via the `type` parameter. These are:
* `postgresql` - A standard PostgreSQL database.
* `postgis` - A PostgreSQL database with the PostGIS extension installed.

Depending on the type the chart will use a different Docker image and fill in some initial setup, like extension installation.

### Choosing the mode of operation

The chart has three modes of operation. These are configured via the `mode` parameter. If this is your first cluster, you
are likely looking for the `standalone` option.
* `standalone` - Creates new or updates an existing CNPG cluster. This is the default mode.
* `replica` - Creates a replica cluster from an existing CNPG cluster. **_Note_ that this mode is not yet supported.**
* `recovery` - Recovers a CNPG cluster from a backup, object store or via pg_basebackup.

### Backup configuration

Most importantly you should configure your backup storage. 

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

Each backup adapter takes it's own set of parameters, listed in the [Configuration options](../README.md#Configuration-options) section
below. Refer to the table for the full list of parameters and place the configuration under the appropriate key: `backup.s3`,
`backup.azure`, or `backup.google`.

### Cluster configuration

There are several important cluster options. Here are the most important ones:

`cluster.instances` - The number of instances in the cluster. Defaults to `1`, but you should set this to `3` for production.
`cluster.imageName` - This allows you to override the Docker image used for the cluster. The chart will choose a default
  for you based on the setting you chose for `type`. If you need to run a configuration that is not supported, you can 
  create your own Docker image. You can use the [postgres-containers](https://github.com/cloudnative-pg/postgres-containers)
  repository for a starting point.
  You will likely need to set your own repository access credentials via: `cluster.imagePullPolicy` and `cluster.imagePullSecrets`.
`cluster.storage.size` - The size of the persistent volume claim for the cluster. Defaults to `8Gi`. Every instance will
  have it's own persistent volume claim.
`cluster.storage.storageClass` - The storage class to use for the persistent volume claim.
`cluster.resources` - The resource limits and requests for the cluster. You are strongly advised to use the same values
  for both limits and requests to ensure a [Guaranteed QoS](https://kubernetes.io/docs/concepts/workloads/pods/pod-qos/#guaranteed).
`cluster.affinity.topologyKey` - The chart sets it to `topology.kubernetes.io/zone` by default which is useful if you are
  running a production cluster in a multi AZ cluster (highly recommended). If you are running a single AZ cluster, you may
  want to change that to `kubernetes.io/hostname` to ensure that cluster instances are not provisioned on the same node.
`cluster.postgresql` - Allows you to override PostgreSQL configuration parameters example:
  ```yaml
  cluster:
    postgresql:
      max_connections: "200"
      shared_buffers: "2GB"  
  ```
`cluster.initSQL` - Allows you to run custom SQL queries during the cluster initialization. This is useful for creating
extensions, schemas and databases. Note that these are as a superuser.

For a full list - refer to the Helm chart [configuration options](../README.md#Configuration-options).

## Examples

There are several configuration examples in the [examples](../examples) directory. Refer to them for a basic setup and
refer to  the [CloudNativePG Documentation](https://cloudnative-pg.io/documentation/current/) for more advanced configurations.
