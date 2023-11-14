# Recovery Target

## About
By default, the recovery process applies all the available WAL files in the archive (full recovery). However, you can also end the recovery as soon as a consistent state is reached.

## Example
```yaml
      recoveryTarget:
        backupID: 20220616T142236
        targetName: "maintenance-activity"
        exclusive: true
```

## Links
- https://github.com/cloudnative-pg/cloudnative-pg/blob/9aae2264c0cf1e5efdf525e2c2a8b7b626e4eb8b/config/crd/bases/postgresql.cnpg.io_clusters.yaml#L1563
- https://www.enterprisedb.com/docs/postgres_for_kubernetes/latest/pg4k.v1/#recoverytarget