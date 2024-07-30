CNPGClusterHAWarning
====================

Meaning
-------

The `CNPGClusterHAWarning` alert is triggered when the CloudNativePG cluster ready standby replicas are less than `2`.

This alarm will be always triggered if your cluster is configured to run with less than `3` instances. In this case you
may want to silence it.

Impact
------

Having less than two available replicas puts your cluster at risk if another instance fails. The cluster is still able
to operate normally, although the `-ro` and `-r` endpoints operate at reduced capacity.

This can happen during a normal failover or automated minor version upgrades. The replaced instance may need some time
to catch-up with the cluster primary instance which will trigger the alert if the operation takes more than 5 minutes.

At `0` available ready replicas, a `CNPGClusterHACritical` alert will be triggered.

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
