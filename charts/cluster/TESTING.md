# Testing

This chart uses Kyverno Chainsaw and implements end-to-end (E2E) tests for common features. Not everything is tested because of inadequate tooling — for example, local simulation of Azure and Google Cloud Storage. We do test S3 via MinIO. Our aim is that every critical feature that is technically feasible to test is covered.

We use a local kind cluster (minikube also works) and provision prerequisites such as the CloudNativePG operator, Prometheus CRDs, and MinIO. Then we run the `chainsaw` utility, which executes the individual tests. It can run tests in parallel, which is essential because some tests take over five minutes to complete.

## Procedure

1. Create a kind cluster.

    ```bash
    kind delete cluster kind
    ```

2. Install the CloudNativePG operator

    ```bash
    helm dependency update charts/cloudnative-pg
    helm upgrade \
      --install \
      --namespace $NAMESPACE \
      --create-namespace \
      --set config.clusterWide=$CLUSTER_WIDE \
      --wait \
      cnpg charts/cloudnative-pg
    ```

3. Install the Prometheus CRDs (optional, but required for monitoring tests)

    ```bash
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm install prometheus-crds prometheus-community/prometheus-operator-crds
    ```

4. Install MinIO (optional, but required for backup/recovery tests).

    ```bash
    helm repo add minio-operator https://operator.min.io
    helm upgrade \
      --install \
      --namespace minio-system \
      --create-namespace \
      --wait \
      operator minio-operator/operator

    helm upgrade \
      --install \
      --namespace minio \
      --create-namespace \
      --wait \
      --values ./.github/minio.yaml \
      tenant minio-operator/tenant
    ```

5. Install Kyverno Chainsaw

    Refer to the [Kyverno Chainsaw Installation](https://kyverno.io/blog/2023/12/12/kyverno-chainsaw-the-ultimate-end-to-end-testing-tool/#install-chainsaw) documentation for platform specific instructions.

    You can also install Kyverno Chainsaw from source if you have _Go_ installed:

    ```bash
    go install github.com/kyverno/chainsaw@latest
    ```

6. Run the tests

    To run the whole test suite:

    ```bash
    chainsaw test charts/cluster
    ```

    To run a specific test, specify its directory path. Example:

    ```bash
    chainsaw test charts/cluster/test/postgresql-cluster-configuration
    ```

## Test structure

We are only going to outline the test structure here. Refer to the [Kyverno Chainsaw](https://kyverno.github.io/chainsaw/latest/quick-start/) documentation for full reference and capabilities.
The tests are located in the `test` directory. Each test has its own subdirectory. Because clusters take time to provision, where it makes sense tests should be combined and executed sequentially on the same cluster. One exception is critical functionality such as backup/restore, which should be tested independently.

Inside each test there is a `chainsaw-test.yaml` file that outlines the steps of that particular test. Here are some tips for writing tests for CloudNativePG:

* Whenever you're adding new features, make sure at the very least to update the `postgresql-cluster-configuration` test that verifies that all non-default configuration options are passed and applied correctly. We're unlikely to merge PRs that don't have their own test or update this one. 
* Always manually uninstall Helm chart resources to speed up cleanup.
* Where applicable, and for steps likely to fail, add `catch` statements. For example:

    ```yaml
    catch:
      - describe:
          apiVersion: batch/v1
          kind: Job
      - describe:
          apiVersion: postgresql.cnpg.io/v1
          kind: Cluster
      - podLogs:
          selector: batch.kubernetes.io/job-name=your-job-name
    ```

    This will substantially help with debugging later.
* Provide useful step descriptions to aid in understanding test failures.
* Use reasonable test timeouts so tests fail if something isn't finished after 5–10 minutes. Aim for tests to complete within 10 minutes.
