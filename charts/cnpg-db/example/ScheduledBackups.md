# Scheduled Backups

## About
ScheduledBackup is the Schema for the scheduledbackups API

## Example
```yaml
  scheduledBackups:
    - name: daily-backup
      schedule: "0 0 0 * * *"
      target: "primary"
      backupOwnerReference: self
      immediate: false
      suspend: false
```

## Links
- https://github.com/cloudnative-pg/cloudnative-pg/blob/main/config/crd/bases/postgresql.cnpg.io_scheduledbackups.yaml
- https://www.enterprisedb.com/docs/postgres_for_kubernetes/latest/backup/#scheduled-backups