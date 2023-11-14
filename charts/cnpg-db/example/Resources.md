# Resources

## About
resource management

## Example
```yaml
  resources:
    requests:
      memory: "32Mi"
      hugepages-2Mi: 1Gi
      cpu: "50m"
    limits:
      memory: "128Mi"
      hugepages-2Mi: 1Gi
      cpu: "100m"
```

## Link
- https://github.com/cloudnative-pg/cloudnative-pg/blob/9aae2264c0cf1e5efdf525e2c2a8b7b626e4eb8b/config/crd/bases/postgresql.cnpg.io_clusters.yaml#L3610
- https://www.enterprisedb.com/docs/postgres_for_kubernetes/latest/resource_management/