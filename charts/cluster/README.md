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

## LICENSE

Apache License, Version 2.0
