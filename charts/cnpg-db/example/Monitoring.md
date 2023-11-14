# Monitoring

## About
The configuration of the monitoring infrastructure of this cluster

## Example
```yaml
  monitoring:
    customQueriesConfigMap:
      - name: example-monitoring
        key: custom-queries
```

## Links
- https://github.com/cloudnative-pg/cloudnative-pg/blob/9aae2264c0cf1e5efdf525e2c2a8b7b626e4eb8b/config/crd/bases/postgresql.cnpg.io_clusters.yaml#L2455
- https://www.enterprisedb.com/docs/postgres_for_kubernetes/latest/monitoring/