CNPGClusterHACritical
=====================

Meaning
-------

The `CNPGClusterHACritical` alert is triggered when the CloudNativePG cluster has no ready standby replicas.

This can happen during either a normal failover or automated minor version upgrades in a cluster with 2 or less
instances. The replaced instance may need some time to catch-up with the cluster primary instance.

This alarm will be always triggered if your cluster is configured to run with only 1 instance. In this case you
may want to silence it.

Impact
------

Having no available replicas puts your cluster at a severe risk if the primary instance fails. The primary instance is
still online and able to serve queries, although connections to the `-ro` endpoint will fail.

Diagnosis
---------

Use the [CloudNativePG Grafana Dashboard](https://grafana.com/grafana/dashboards/20417-cloudnativepg/).

Get the status of the CloudNativePG cluster instances:

```bash
kubectl get pods -A -l "cnpg.io/podRole=instance" -o wide
```

Check the logs of the affected CloudNativePG instances:

```bash
kubectl logs --namespace <namespace> pod/<instance-pod-name>
```

Check the CloudNativePG operator logs:

```bash
kubectl logs --namespace cnpg-system -l "app.kubernetes.io/name=cloudnative-pg"
```

Mitigation
----------

Refer to the [CloudNativePG Failure Modes](https://cloudnative-pg.io/documentation/current/failure_modes/)
and [CloudNativePG Troubleshooting](https://cloudnative-pg.io/documentation/current/troubleshooting/) documentation for
more information on how to troubleshoot and mitigate this issue.
