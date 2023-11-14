# Pooler

## About
Pooler is the Schema for the poolers API

## Example
```yaml
  enabled: false
  instances: 3
  type: rw
  pgbouncer:
    authQuery: ""
    authQuerySecret: 
      name: ""
    paused: false
    pg_hba: []
    poolMode: transaction
    parameters:
      max_client_conn: "1000"
      default_pool_size: "25"
  template: {}
  monitoring: {}
```

## Links
- https://github.com/cloudnative-pg/cloudnative-pg/blob/main/config/crd/bases/postgresql.cnpg.io_poolers.yaml
- https://www.enterprisedb.com/docs/postgres_for_kubernetes/latest/pg4k.v1/#pooler