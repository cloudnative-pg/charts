# CloudNativePG Helm Charts

[![Stack Overflow](https://img.shields.io/badge/stackoverflow-cloudnative--pg-blue?logo=stackoverflow&logoColor=%23F48024&link=https%3A%2F%2Fstackoverflow.com%2Fquestions%2Ftagged%2Fcloudnative-pg)][stackoverflow]
[![GitHub License](https://img.shields.io/github/license/cloudnative-pg/charts)][license]


[![GitHub Release](https://img.shields.io/github/v/release/cloudnative-pg/charts?filter=cloudnative-pg-*)](https://github.com/cloudnative-pg/charts/tree/main/charts/cloudnative-pg)
[![GitHub Release](https://img.shields.io/github/v/release/cloudnative-pg/charts?filter=cluster-*)](https://github.com/cloudnative-pg/charts/tree/main/charts/cluster)


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

#### Single namespace installation

It is possible to limit the operator's capabilities to solely the namespace in
which it has been installed. With this restriction, the cluster-level
permissions required by the operator will be substantially reduced, and
the security profile of the installation will be enhanced.

You can install the operator in single-namespace mode by setting the
`config.clusterWide` flag to false, as in the following example:

```console
helm upgrade --install cnpg \
  --namespace cnpg-system \
  --create-namespace \
  --set config.clusterWide=false \
  cnpg/cloudnative-pg
```

**IMPORTANT**: the single-namespace installation mode can't coexist
with the cluster-wide operator. Otherwise there would be collisions when
managing the resources in the namespace watched by the single-namespace
operator.
It is up to the user to ensure there is no collision between operators.

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

[stackoverflow]: https://stackoverflow.com/questions/tagged/cloudnative-pg
[license]: https://github.com/cloudnative-pg/charts?tab=Apache-2.0-1-ov-file
