# CloudNativePG Helm Chart

Helm chart to install the
[CloudNativePG operator](https://cloudnative-pg.io), originally created and sponsored by
[EDB](https://www.enterprisedb.com/) to manage PostgreSQL workloads on any supported Kubernetes cluster
running in private, public, or hybrid cloud environments.

**NOTE**: supports only the latest point release of the CloudNativePG operator.

## Deployment using the latest release

```console
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg \
  --namespace cnpg-system \
  --create-namespace \
  cnpg/cloudnative-pg
```

## Deployment using local chart

To deploy the operator from sources you can run the following command:

```console
helm upgrade --install cnpg \
  --namespace cnpg-system \
  --create-namespace \
  charts/cloudnative-pg
```

## Sandbox for CloudNativePG

CloudNativePG Sandbox, aka `cnpg-sandbox`, is now deprecated and has been removed from this project.

All its resources have been moved in the primary `cloudnativepg` repository, in the form of:

- documentation (["Quickstart"](https://cloudnative-pg.io/documentation/current/quickstart/)
  and ["Monitoring"](https://cloudnative-pg.io/documentation/current/monitoring/) sections)
- plugin commands ([`pgbench`](https://cloudnative-pg.io/documentation/current/cnpg-plugin/#benchmarking-the-database-with-pgbench)
- manifests

## Contributing

Please read the [code of conduct](CODE-OF-CONDUCT.md) and the
[guidelines](CONTRIBUTING.md) to contribute to the project.

## Copyright

Helm charts for CloudNativePG are distributed under Apache License 2.0.
