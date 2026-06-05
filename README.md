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

Refer to the [Operator Chart documentation](charts/cloudnative-pg/README.md) for installation advanced 
configuration and monitoring.

## Barman Cloud CNPG-I plugin chart

Helm chart to install the CNPG-I Barman Cloud Plugin.

Refer to the [Barman Cloud Plugin Chart documentation](charts/plugin-barman-cloud/README.md) for installation 
and advanced configuration.

## Cluster chart

Helm chart to install a CloudNativePG database cluster.

Refer to the [Cluster Chart documentation](charts/cluster/README.md) for Installtion and advanced configuration options.

## Contributing

Please read the [code of conduct](CODE-OF-CONDUCT.md) and the
[guidelines](CONTRIBUTING.md) to contribute to the project.

## Copyright

Helm charts for CloudNativePG are distributed under [Apache License 2.0](LICENSE).

[stackoverflow]: https://stackoverflow.com/questions/tagged/cloudnative-pg
[license]: https://github.com/cloudnative-pg/charts?tab=Apache-2.0-1-ov-file
