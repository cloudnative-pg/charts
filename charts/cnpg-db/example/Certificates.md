# Certificates

## About
The configuration for the CA and related certificates

## Example
```yaml
  certificates:
    serverTLSSecret: my-postgres-server-cert
    serverCASecret: my-postgres-server-cert
```

## Link
- https://github.com/cloudnative-pg/cloudnative-pg/blob/9aae2264c0cf1e5efdf525e2c2a8b7b626e4eb8b/config/crd/bases/postgresql.cnpg.io_clusters.yaml#L1679
- https://www.enterprisedb.com/docs/postgres_for_kubernetes/latest/certificates/
