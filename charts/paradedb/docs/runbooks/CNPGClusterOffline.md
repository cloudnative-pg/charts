CNPGClusterOffline
==================

Meaning
-------

The `CNPGClusterOffline` alert is triggered when there are no ready CloudNativePG instances.

Impact
------

Having an offline cluster means your applications will not be able to access the database, leading to potential service
disruption.

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
