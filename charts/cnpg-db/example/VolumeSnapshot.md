# Barman Object Store

## About
VolumeSnapshot provides the configuration for the execution of volume snapshot backups.

## Example

```yaml
  volumeSnapshot: 
    enabled: false

    annotations: {}
    labels: {}

    className: "csi-driver-nfs"
    walClassName: "csi-driver-nfs"
    online: true
    onlineConfiguration:
      immediateCheckpoint: false
      waitForArchive: true

    snapshotOwnerReference: "none"
```


## Link
- https://github.com/cloudnative-pg/cloudnative-pg/blob/6c3982cd51cab3377d2244895a55a2e5dc0717e6/config/crd/bases/postgresql.cnpg.io_clusters.yaml#L1245 
- https://www.enterprisedb.com/docs/postgres_for_kubernetes/latest/backup_volumesnapshot/