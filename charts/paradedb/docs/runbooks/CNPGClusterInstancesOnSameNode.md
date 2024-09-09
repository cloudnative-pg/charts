# CNPGClusterInstancesOnSameNode

## Description

The `CNPGClusterInstancesOnSameNode` alert is triggered when two or more database pods are scheduled on the same node. This is unexpected for CloudNativePG clusters, as each instance should run on a separate node to ensure high availability and fault tolerance.

This can be caused by insufficient nodes in the cluster or misconfigured scheduling rules, such as pod affinity/anti-affinity rules or tolerations.

## Impact

This configuration reduces high availability, as a node failure hosting multiple database pods will cause all of them to go down simultaneously.

## Diagnosis

To investigate node placement of database pods:

- List all database pods and their node assignments:

```bash
kubectl get pods -A -l "cnpg.io/podRole=instance" -o json | jq -r '["Namespace", "Pod", "Node"], ( .items[] | [.metadata.namespace, .metadata.name, .spec.nodeName]) | @tsv' | column -t
```

- Describe the cluster and check the affinity and tolerations configuration:

```bash
kubectl describe --namespace <namespace> clusters.postgresql.cnpg.io/paradedb
```

- Describe the pods:

```bash
kubectl describe pods -A -l "cnpg.io/podRole=instance"
```

## Mitigation

- Verify that you have more than a single node with no taint preventing pods from being scheduled on these nodes.

- Verify your [affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/), taints, and tolerations configuration.

- Increase the instance CPU and Memory resources so that no node can host more than one instance.

For more information, please refer to the ["Scheduling"](https://cloudnative-pg.io/documentation/current/scheduling/) section of the documentation.
