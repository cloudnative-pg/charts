# Barman Object Store

## About
The configuration for the barman-cloud tool suite

## Example

```yaml
  barmanObjectStore:
    endpointURL: "http://minio.lintilla-minio"
    serverName: ""
    destinationPath: "s3://cnpgbackups"
    data: 
      compression: "gzip"
      encryption: "AES256"
      immediateCheckpoint: false
      jobs: 2
    wal:
      compression: "gzip"
      encryption: "AES256"
      maxParallel: 8
    googleCredentials:
      gkeEnvironment: false
      applicationCredentials:
        name: "minio-creds"
        key: "ACCESS_KEY_APPLICATIONCREDENTIALS"
    azureCredentials:
      inheritFromAzureAD: false
      connectionString:
        name: "minio-creds"
        key: "ACCESS_KEY_CONNECTIONSTRING"
      storageAccount:
        name: "minio-creds"
        key: "ACCESS_KEY_STORAGEACCOUNT"
      storageKey:
        name: "minio-creds"
        key: "ACCESS_KEY_STORAGEKEY"
      storageSasToken:
        name: "minio-creds"
        key: "ACCESS_KEY_STORAGESASTOKEN"
    s3Credentials: 
      inheritFromIAMRole: false
      accessKeyId: 
        name: "minio-creds"
        key: ACCESS_KEY_ID
      secretAccessKey:
        name: "minio-creds"
        key: ACCESS_KEY_SECRET
      sessionToken:
        name: "minio-creds"
        key: "ACCESS_KEY_SESSIONTOKEN"
      region:
        name: "minio-creds"
        key: "ACCESS_KEY_REGION"
    endpointCA:
      name: "minio-creds"
      key: "ACCESS_KEY_ENDPOINTCA"
    tags: 
      backupRetentionPolicy: "expire"
    historyTags: 
      backupRetentionPolicy: "keep"
```

## Link
- https://github.com/cloudnative-pg/cloudnative-pg/blob/6c3982cd51cab3377d2244895a55a2e5dc0717e6/config/crd/bases/postgresql.cnpg.io_clusters.yaml#L957C5-L957C5
- https://www.enterprisedb.com/docs/postgres_for_kubernetes/latest/backup_barmanobjectstore/ 
