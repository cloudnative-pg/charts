# Barman Object Store

## About
Configuration of the PostgreSQL server

## Example
```yaml
  postgresql:
    parameters: 
      huge_pages: "off"
    pg_hba: 
      - hostssl app streaming_replica all cert
    promotionTimeout: 40000000
    shared_preload_libraries: 
      - auto_explain
    syncReplicaElectionConstraint: 
      enabled: true
      nodeLabelsAntiAffinity: []
    ldap: 
      bindAsAuth:
        prefix: "special"
        suffix: "com"
      bindSearchAuth:
        baseDN: "domainname.root"
        bindDN: "domainname.user"
        bindPassword:
          name: "minio-secret"
          key: "ACCESS_KEY_BINDPASSWORD"
          optional: false
        searchAttributes: "user"
        searchFilter: "user"
```

## Link
- https://github.com/cloudnative-pg/cloudnative-pg/blob/6c3982cd51cab3377d2244895a55a2e5dc0717e6/config/crd/bases/postgresql.cnpg.io_clusters.yaml#L2529
- https://www.postgresql.org/docs/current/sql-show.html
- https://www.enterprisedb.com/docs/postgres_for_kubernetes/latest/postgresql_conf/
- https://www.enterprisedb.com/docs/postgres_for_kubernetes/latest/pg4k.v1/#postgresql-k8s-enterprisedb-io-v1-LDAPConfig