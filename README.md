# CloudNativePG Helm Chart

## CloudNativePG operator chart

Use this Helm chart to install the
[CloudNativePG operator](https://cloudnative-pg.io), designed by
[EDB](https://www.enterprisedb.com/) to manage PostgreSQL workloads on any
supported Kubernetes cluster running in private, public, or hybrid cloud
environments.

### Deployment using the latest release

```console
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg \
  --namespace cnpg-system \
  --create-namespace \
  cnpg/cloudnative-pg
```

### Deployment using local chart

To deploy the operator from sources you can run the following command:

```console
helm upgrade --install cnpg \
  --namespace cnpg-system \
  --create-namespace \
  charts/cloudnative-pg
```

Refer to the [Operator Chart documentation](https://github.com/cloudnative-pg/charts/blob/main/charts/cloudnative-pg/README.md) for installation,
advanced configuration and monitoring.

## Cluster chart

Use this Helm chart to create a PostgreSQL cluster managed by the CloudNativePG operator.

Needs operator chart to be installed first.

```console
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg \
  --namespace cnpg-database \
  --create-namespace \
  --values values.yaml \
  cnpg/cluster
```

Refer to the [Cluster Chart documentation](https://github.com/cloudnative-pg/charts/blob/main/charts/cluster/README.md) for installation,
cluster configuration and backup options.

## Plugin Barman Cloud chart

Helm chart to install the [Plugin Barman Cloud](https://github.com/cloudnative-pg/plugin-barman-cloud)..

**IMPORTANT**: this chart requires a working installation of [cert-manager](https://cert-manager.io/).
Install it and wait until it is ready before installing this chart.

The chart deploys the plugin only. It does not install the CloudNativePG
operator and does not create any `Cluster` resource. Use the operator and
cluster charts above for that.

```console
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install plugin-barman-cloud \
  --namespace cnpg-system \
  cnpg/plugin-barman-cloud
```

Refer to the [Barman Cloud Plugin Chart documentation](https://github.com/cloudnative-pg/charts/blob/main/charts/plugin-barman-cloud/README.md) for installation
and advanced configuration.

## Contributing

Please read the [code of conduct](CODE-OF-CONDUCT.md) and the
[guidelines](CONTRIBUTING.md) to contribute to the project.

## Copyright

Helm charts for CloudNativePG are distributed under [Apache License 2.0](LICENSE).
