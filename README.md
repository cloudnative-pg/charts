# CloudNativePG Helm Chart

Helm chart to install the
[CloudNativePG operator](https://cloudnative-pg.io),
designed by EnterpriseDB to manage PostgreSQL workloads on any
supported Kubernetes cluster running in private, public, or hybrid cloud
environments.

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

# Sandbox for CloudNativePG

CloudNativePG Sandbox, aka `cnpg-sandbox`, is a Helm chart that
sets up the following components inside a Kubernetes cluster:

- [Prometheus](https://prometheus.io/)
- [Grafana](https://github.com/grafana/grafana)
- [CloudNativePG (CNPG)](https://cloudnative-pg.io) a Kubernetes operator for [PostgreSQL](https://www.postgresql.org/) and
  [EDB Postgres Advanced](https://www.enterprisedb.com/products/edb-postgres-advanced-server-secure-ha-oracle-compatible), with:
    - a selection of PostgreSQL metrics for the native Prometheus exporter in CNPG (see the [`metrics.yaml`](charts/cnpg-sandbox/templates/metrics.yaml) template file)
    - a [custom Grafana dashboard](charts/cnpg-sandbox/dashboard.json) developed by EDB for CloudNativePG

**IMPORTANT:** `cnpg-sandbox` must be run in a staging or pre-production
environment. Do not use `cnpg-sandbox` in a production environment, as we
expect that Prometheus and Grafana are already part of that infrastructure:
there you can install CloudNativePG, the suggested metrics and the
provided Grafana dashboard.

![Example of dashboard](dashboard.png)

## Requirements

- CloudNativePG 1.10.0
- [GNU Make](https://www.gnu.org/software/make/) 3.8
- [Helm](https://helm.sh/) 3.7
- A supported Kubernetes cluster with enough RBAC permissions to deploy the required resources

## Deployment

Deployment using the latest release:

```console
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm repo update
helm upgrade --install cnpg-sandbox \
  cnpg/cnpg-sandbox
```

Then simply follow the instructions that will appear on the terminal once the
installation is completed.

#### Deployment from local source

You can deploy CloudNativePG Sandbox from local source with:

```console
make sandbox-deploy
```

You can remove the installed sandbox by running:

```console
make sandbox-uninstall
```

## Monitoring

From the Grafana interface, you can find the dashboard by selecting: `Dashboards` > `Manage` > `CloudNativePg`.

## Benchmarking

You can use `cnpg-sandbox` in conjuction with
[`cnp-bench`](https://github.com/EnterpriseDB/cnp-bench) to benchmark your
PostgreSQL environment and observe its behaviour in real-time.

## Contributing

Please read the [code of conduct](CODE-OF-CONDUCT.md) and the
[guidelines](CONTRIBUTING.md) to contribute to the project.

## Disclaimer

`cnpg-sandbox`is open source software and comes "as is". Please carefully
read the [license](LICENSE) before you use this software, in particular
the "Disclaimer of Warranty" and "Limitation of Liability" items.

## Copyright

`cnpg-sandbox` is distributed under Apache License 2.0.
`cnpg` is distributed under Apache License 2.0.
