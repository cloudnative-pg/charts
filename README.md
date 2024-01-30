# CloudNativePG Helm Charts

## Operator chart

Helm chart to install the
[CloudNativePG operator](https://cloudnative-pg.io), originally created and sponsored by
[EDB](https://www.enterprisedb.com/) to manage PostgreSQL workloads on any supported Kubernetes cluster
running in private, public, or hybrid cloud environments.

**NOTE**: supports only the latest point release of the CloudNativePG operator.
```console
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg \
  --namespace cnpg-system \
  --create-namespace \
  cnpg/cloudnative-pg
```

Refer to the [Operator Chart documentation](charts/cloudnative-pg/README.md) for advanced configuration and monitoring.

## Cluster chart

Helm chart to install a CloudNativePG database cluster.

```console
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install database \
  --namespace database \
  --create-namespace \
  cnpg/cluster
```

Refer to the [Cluster Chart documentation](charts/cluster/README.md) for advanced configuration options.

## Contributing

Please read the [code of conduct](CODE-OF-CONDUCT.md) and the
[guidelines](CONTRIBUTING.md) to contribute to the project.

## Copyright

Helm charts for CloudNativePG are distributed under [Apache License 2.0](LICENSE).
