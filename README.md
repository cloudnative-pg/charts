# ParadeDB Helm Chart

[![GitHub License](https://img.shields.io/github/license/cloudnative-pg/charts)][license]

Getting Started
---------------

### Installing the CloudNativePG Operator
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
helm repo add paradedb https://paradedb.github.io/charts
helm upgrade --install paradedb \
--namespace paradedb-database \
--create-namespace \
--values values.yaml \
paradedb/cluster
```

Refer to the [Cluster Chart documentation](charts/cluster/README.md) for advanced configuration options.

## Contributing

Please read the [code of conduct](CODE-OF-CONDUCT.md) and the
[guidelines](CONTRIBUTING.md) to contribute to the project.

## Copyright

Helm charts for CloudNativePG are distributed under [Apache License 2.0](LICENSE).

[stackoverflow]: https://stackoverflow.com/questions/tagged/cloudnative-pg
[license]: https://github.com/cloudnative-pg/charts?tab=Apache-2.0-1-ov-file
