# CNPGClusterHighConnectionsCritical

## Description

The `CNPGClusterHighConnectionsCritical` alert is triggered when the number of connections on the CloudNativePG cluster instance exceeds 95% of its configured capacity.

## Impact

At 100% capacity, the instance will reject new connections, resulting in a service disruption.

## Diagnosis

Use the [CloudNativePG Grafana Dashboard](https://grafana.com/grafana/dashboards/20417-cloudnativepg/) to inspect the number of connections to the CloudNativePG cluster instances. Identify which instance is over capacity, and determine whether it is the primary or a standby replica.

You can check the current primary instance using the following command:

```bash
kubectl get cluster paradedb -o 'jsonpath={"Current Primary: "}{.status.currentPrimary}{"; Target Primary: "}{.status.targetPrimary}{"\n"}' --namespace <namespace>
```

## Mitigation

> [!IMPORTANT]
> Changing the `max_connections` parameter requires a restart of the CloudNativePG cluster instances. This will cause a restart of a standby instance and a switchover of the primary instance, causing a brief service disruption.

- Increase the maximum number of connections by setting the `max_connections` PostgreSQL parameter:
  - Helm: `cluster.postgresql.parameters.max_connections`

- Use connection pooling by enabling PgBouncer to reduce the number of connections to the database. PgBouncer itself requires connections, so temporarily increase `max_connections` while enabling it to avoid service disruption.

> [!NOTE]
> PostgreSQL sizes certain resources directly based on the value of `max_connections`. Each connection uses a portion of the `shared_buffers` memory as well as additional non-shared memory. As a result, increasing the `max_connections` parameter will increase the memory usage of the CloudNativePG cluster instances.
