# Backup

## About

## Example
```yaml
backup:
  enabled: false
  
  annotations: {}
  labels: {}

  retentionPolicy: ""
  target: "primary"

  # see volumesnapshot
  volumeSnapshot: 
 
  # see barmanobjectstore
  barmanObjectStore:
  
  ## see scheduledbackups
  scheduledBackups: []
```

## Links
- https://github.com/cloudnative-pg/cloudnative-pg/blob/main/config/crd/bases/postgresql.cnpg.io_backups.yaml
- https://www.enterprisedb.com/docs/postgres_for_kubernetes/latest/backup/
