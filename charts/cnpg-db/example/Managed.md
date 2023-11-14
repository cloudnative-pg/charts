# Managed

## About
The configuration that is used by the portions of PostgreSQL that are managed by the instance manager

## Example
```yaml
  managed:
    roles:
    - name: dante
      ensure: present
      comment: Dante Alighieri
      login: true
      superuser: false
      inRoles:
        - pg_monitor
        - pg_signal_backend
```

## Link
- https://github.com/cloudnative-pg/cloudnative-pg/blob/9aae2264c0cf1e5efdf525e2c2a8b7b626e4eb8b/config/crd/bases/postgresql.cnpg.io_clusters.yaml#L2330
- https://www.enterprisedb.com/docs/postgres_for_kubernetes/latest/declarative_role_management/#status-of-managed-roles