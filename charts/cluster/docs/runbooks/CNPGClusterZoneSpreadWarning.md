CNPGClusterZoneSpreadWarning
============================

Meaning
-------

The `CNPGClusterZoneSpreadWarning` alert is raised when pods are not evenly distributed across availability zones. To be
more accurate, the alert is raised when the number of `pods > zones < 3`.

Impact
------

The uneven distribution of pods across availability zones can lead to a single point of failure if a zone goes down.

Diagnosis
---------

Use the [CloudNativePG Grafana Dashboard](https://grafana.com/grafana/dashboards/20417-cloudnativepg/).

Get the status of the CloudNativePG cluster instances:

```bash
kubectl get pods -A -l "cnpg.io/podRole=instance" -o wide
```

Get the nodes and their respective zones:

```bash
kubectl get nodes --label-columns topology.kubernetes.io/zone
```

Mitigation
----------

1. Verify you have more than a single node with no taints, preventing pods to be scheduled in each availability zone.
2. Verify your [affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) configuration.
3. Delete the pods and their respective PVC that are not in the desired availability zone and allow the operator to repair the cluster.
