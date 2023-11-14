# Node Maintenance Window

## About
Define a maintenance window for the Kubernetes nodes

## Example
```yaml
  nodeMaintenanceWindow:
    inProgress: false
    reusePVC: true
```


## Links
- https://github.com/cloudnative-pg/cloudnative-pg/blob/9aae2264c0cf1e5efdf525e2c2a8b7b626e4eb8b/config/crd/bases/postgresql.cnpg.io_clusters.yaml#L2504
- https://www.enterprisedb.com/docs/postgres_for_kubernetes/latest/pg4k.v1/#nodemaintenancewindow
