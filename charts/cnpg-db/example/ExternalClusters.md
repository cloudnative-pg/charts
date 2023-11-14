# External Cluster

## About 
The externalClusters section allows you to define one or more PostgreSQL clusters that are somehow related to the current one.

## Example
```yaml
externalCluster:
  - name: "clusterA"

    connectionParameters: 
      host: source-db.foo.com
      user: streaming_replica

    password: 
      name: "clusterAsecret"
      key: "CLUSTERASECRET_KEY_PASSWORD"
      optional: true
    sslCert:
      name: "clusterAsecret"
      key: "CLUSTERASECRET_KEY_SSLCERT"
      optional: true
    sslKey:
      name: "clusterAsecret"
      key: "CLUSTERASECRET_KEY_SSLKEY"
      optional: true
    sslRootCert:
      name: "clusterAsecret"
      key: "CLUSTERASECRET_KEY_SSLROOTCERT"
      optional: true
```

## Links
- https://github.com/cloudnative-pg/cloudnative-pg/blob/9aae2264c0cf1e5efdf525e2c2a8b7b626e4eb8b/config/crd/bases/postgresql.cnpg.io_clusters.yaml#L1367
- https://www.enterprisedb.com/docs/postgres_for_kubernetes/latest/bootstrap/#the-externalclusters-section