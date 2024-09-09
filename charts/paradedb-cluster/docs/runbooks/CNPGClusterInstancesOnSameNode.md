CNPGClusterInstancesOnSameNode
============================

Meaning
-------

The `CNPGClusterInstancesOnSameNode` alert is raised when two or more database pods are scheduled on the same node.

Impact
------

A failure or scheduled downtime of a single node will lead to a potential service disruption and/or data loss.

Diagnosis
---------

Use the [CloudNativePG Grafana Dashboard](https://grafana.com/grafana/dashboards/20417-cloudnativepg/).

```bash
kubectl get pods -A -l "cnpg.io/podRole=instance" -o wide
```

Mitigation
----------

1. Verify you have more than a single node with no taints, preventing pods to be scheduled there.
2. Verify your [affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) configuration.
3. For more information, please refer to the ["Scheduling"](https://cloudnative-pg.io/documentation/current/scheduling/) section in the documentation
