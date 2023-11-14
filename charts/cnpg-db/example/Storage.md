# Storage

## About
Storage is the most critical component in a database workload. Storage should be always available, scale, perform well, and guarantee consistency and durability.

## Example
```yaml
  storage:
    size: ""
    storageClass: ""
    resizeInUseVolumes: true
    pvcTemplate:
      accessModes: []
      dataSource:
        apiGroup: ""
        kind: ""
        name: ""
      dataSourceRef:
        apiGroup: ""
        kind: ""
        name: ""
      resources: {}
      selector: {}
      storageClassName: ""
      volumeMode: ""
      volumeName: ""
```

## Link
- https://github.com/cloudnative-pg/cloudnative-pg/blob/9aae2264c0cf1e5efdf525e2c2a8b7b626e4eb8b/config/crd/bases/postgresql.cnpg.io_clusters.yaml#L1633
- https://www.enterprisedb.com/docs/postgres_for_kubernetes/latest/storage/