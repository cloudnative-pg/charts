# Operator Capabilities

## About

## Example
```yaml
seccompProfile: 
  localhostProfile: ""
  type: ""

serviceAccountTemplate:
  metadata:
    annotations:
    labels:

replicationSlots:
  highAvailability:
    enabled: true
    slotPrefix: "_cnpg_"
  updateInterval: 30

topologySpreadConstraints: []
minSyncReplicas: 0
maxSyncReplicas: 0
```

## Links
- https://www.enterprisedb.com/docs/postgres_for_kubernetes/latest/operator_capability_levels/#topology-spread-constraints
- https://github.com/cloudnative-pg/cloudnative-pg/blob/9aae2264c0cf1e5efdf525e2c2a8b7b626e4eb8b/config/crd/bases/postgresql.cnpg.io_clusters.yaml#L2441
- https://www.enterprisedb.com/docs/postgres_for_kubernetes/latest/replication/#synchronous-replication