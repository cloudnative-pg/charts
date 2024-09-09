Release Process
===============

## Releasing the `cluster` chart

In order to create a new release of the `cluster` chart, follow these steps:

1. Take note of the current value of the release: see `.version` in `charts/cluster/Chart.yaml`
    ```bash
    yq -r '.version' charts/cluster/Chart.yaml
    ```
2. Decide which version to create, depending on the kind of changes and backwards compatibility, following semver
   semantics. For this document, let's call it `X.Y.Z`
    ```bash
    NEW_VERSION="X.Y.Z"
    ```
3. Create a branch: named `release/cluster-vX.Y.Z` and switch to it
    ```bash
    git switch --create release/cluster-v$NEW_VERSION
    ```
4. Update the `.version` in the [Chart.yaml](./charts/cluster/Chart.yaml) file to `"X.Y.Z"`
    ```bash
    sed -i -E "s/^version: ([0-9]+.?)+/version: $NEW_VERSION/" charts/cluster/Chart.yaml
    ```
5. Run `make docs schema` to regenerate the docs and the values schema in case it is needed
    ```bash
    make docs schema
    ```
6. Commit and add the relevant information you wish in the commit message.
    ```bash
    git add .
    git commit -S -s -m "Release cluster-v$NEW_VERSION" --edit
    ```
7. Push the new branch
    ```bash
    git push --set-upstream origin release/cluster-v$NEW_VERSION
    ```
8. A PR should be automatically created
9. Wait for all the checks to pass
10. Two approvals are required in order to merge the PR, if you are a
    maintainer approve the PR yourself and ask for another approval, otherwise
    ask for two approvals directly.
11. Merge the PR squashing all commits and **taking care to keep the commit
    message to be `Release cluster-vX.Y.Z`**
12. A release `cluster-vX.Y.Z` should be automatically created by an action, which will ten trigger the release action.
    Verify they both are successful.
13. Once done you should be able to run:
    ```bash
    helm repo add cnpg https://cloudnative-pg.github.io/charts
    helm repo update
    helm search repo cnpg
    ```
    and be able to see the new version `X.Y.Z` as `CHART VERSION` for `cluster`
