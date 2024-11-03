<h1 align="center">
  <img src="https://raw.githubusercontent.com/paradedb/paradedb/dev/docs/logo/readme.svg" alt="ParadeDB" width="368px">
<br>
</h1>

<p align="center">
    <b>Postgres for Search and Analytics</b> <br />
</p>

<h3 align="center">
  <a href="https://paradedb.com">Website</a> &bull;
  <a href="https://docs.paradedb.com">Docs</a> &bull;
  <a href="https://join.slack.com/t/paradedbcommunity/shared_invite/zt-2lkzdsetw-OiIgbyFeiibd1DG~6wFgTQ">Community</a> &bull;
  <a href="https://paradedb.com/blog/">Blog</a> &bull;
  <a href="https://docs.paradedb.com/changelog/">Changelog</a>
</h3>

---

[![Publish Helm Chart](https://github.com/paradedb/charts/actions/workflows/paradedb-publish-chart.yml/badge.svg)](https://github.com/paradedb/charts/actions/workflows/paradedb-publish-chart.yml)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/paradedb)](https://artifacthub.io/packages/search?repo=paradedb)
[![Docker Pulls](https://img.shields.io/docker/pulls/paradedb/paradedb)](https://hub.docker.com/r/paradedb/paradedb)
[![License](https://img.shields.io/github/license/paradedb/paradedb?color=blue)](https://github.com/paradedb/paradedb?tab=AGPL-3.0-1-ov-file#readme)
[![Slack URL](https://img.shields.io/badge/Join%20Slack-purple?logo=slack&link=https%3A%2F%2Fjoin.slack.com%2Ft%2Fparadedbcommunity%2Fshared_invite%2Fzt-2lkzdsetw-OiIgbyFeiibd1DG~6wFgTQ)](https://join.slack.com/t/paradedbcommunity/shared_invite/zt-2lkzdsetw-OiIgbyFeiibd1DG~6wFgTQ)
[![X URL](https://img.shields.io/twitter/url?url=https%3A%2F%2Ftwitter.com%2Fparadedb&label=Follow%20%40paradedb)](https://x.com/paradedb)

# ParadeDB Helm Chart

The [ParadeDB](https://github.com/paradedb/paradedb) Helm Chart is based on the official [CloudNativePG Helm Chart](https://cloudnative-pg.io/). CloudNativePG is a Kubernetes operator that manages the full lifecycle of a highly available PostgreSQL database cluster with a primary/standby architecture using Postgres streaming (physical) replication.

Kubernetes, and specifically the CloudNativePG operator, is the recommended approach for deploying ParadeDB in production, with high availability. ParadeDB also provides a [Docker image](https://hub.docker.com/r/paradedb/paradedb) and [prebuilt binaries](https://github.com/paradedb/paradedb/releases) for Debian, Ubuntu and Red Hat Enterprise Linux.

The ParadeDB Helm Chart supports Postgres 13+ and ships with Postgres 16 by default.

The chart is also available on [Artifact Hub](https://artifacthub.io/packages/helm/paradedb/paradedb).

## Usage

### ParadeDB Bring-Your-Own-Cloud (BYOC)

The most reliable way to run ParadeDB in production is with ParadeDB BYOC, an end-to-end managed solution that runs in the customer’s cloud account. It deploys on managed Kubernetes services and uses the ParadeDB Helm Chart.

ParadeDB BYOC includes built-in integration with managed PostgreSQL services, such as AWS RDS, via logical replication. It also provides monitoring, logging and alerting through Prometheus and Grafana. The ParadeDB team manages the underlying infrastructure and lifecycle of the cluster.

You can read more about the optimal architecture for running ParadeDB in production [here](https://docs.paradedb.com/deploy/overview), and you can contact sales [here](mailto:sales@paradedb.com).

### Self-Hosted

First, install [Helm](https://helm.sh/docs/intro/install/). The following steps assume you have a Kubernetes cluster running v1.25+. If you are testing locally, we recommend using [Minikube](https://minikube.sigs.k8s.io/docs/start/).

#### (Optional) Monitoring

The ParadeDB Helm chart supports monitoring via Prometheus and Grafana. To enable this, you need to have the Prometheus CRDs installed before installing the CloudNativePG operator. The Promotheus CRDs can be found [here](https://prometheus-community.github.io/helm-charts).

TODO: Add link to Prometheus/Grafana docs and mention that it needs to be passed in to the cnpg cluster deployment.

#### Installing the CloudNativePG Operator

Skip this step if the CloudNativePG operator is already installed in your cluster. T

```bash
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --atomic --install cnpg \
--create-namespace \
--namespace cnpg-system \
cnpg/cloudnative-pg
```

#### Setting up a ParadeDB CNPG Cluster

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
paradedb/paradedb
```

If `--values values.yaml` is omitted, the default values will be used. For additional configuration options for the `values.yaml` file, including configuring backups and PgBouncer, please refer to the [ParadeDB Helm Chart documentation](https://artifacthub.io/packages/helm/paradedb/paradedb#values). For advanced cluster configuration options, please refer to the [CloudNativePG Cluster Chart documentation](charts/paradedb/README.md).

#### Connecting to a ParadeDB CNPG Cluster

The command to connect to the primary instance of the cluster will be printed in your terminal. You can also connect to a specific pod via:

```bash
kubectl exec --stdin --tty <pod-name> -n <namespace> -- bash
```

The primary is `paradedb-1`, and the replicas are `paradedb-2` onwards depending on the number of replicas you configured. This will launch a Bash shell inside the instance. You can connect to the ParadeDB database via `psql` with:

```bash
psql -d paradedb
```

## Development

To test changes to the Chart on a local Minikube cluster, follow the instructions from [Self Hosted](#self-hosted), replacing the `helm upgrade` step by the path to the directory of the modified `Chart.yaml`.

```bash
helm upgrade --atomic --install paradedb --namespace paradedb --create-namespace ./charts/paradedb
```

## License

ParadeDB is licensed under the [GNU Affero General Public License v3.0](LICENSE) and as commercial software. For commercial licensing, please contact us at [sales@paradedb.com](mailto:sales@paradedb.com).
