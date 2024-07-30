Release Process
===============

This repo contains two helm charts: [cloudnative-pg](./charts/cloudnative-pg)
and [cluster](./charts/cluster). Both the charts are available
through a single [repository](https://cloudnative-pg.github.io/charts), but
should be released separately as their versioning might be unlinked, and the
latter depends on the former.

**IMPORTANT** we should run the below procedures against the latest point
release of the CloudNativePG operator. I.e. even if we have several release
branches in CNPG, we will only target the most advanced point
release (e.g. 1.17.1)

## Charts

1. [Releasing the `cloudnative-pg` chart](#releasing-the-cloudnative-pg-chart)
2. [Releasing `cluster` chart](#releasing-the-cluster-chart)

## Releasing the `cloudnative-pg` chart

In order to create a new release of the `cloudnative-pg` chart, follow these steps:

1. Take note of the current value of the release: see `.version` in `charts/cloudnative-pg/Chart.yaml`
    ```bash
    yq -r '.version' charts/cloudnative-pg/Chart.yaml
    ```
2. Decide which version to create, depending on the kind of jump of the CloudNativePG release, following semver
    semantics. For this document, let's call it `X.Y.Z`
    ```bash
    NEW_VERSION="X.Y.Z"
    ```
3. Create a branch named `release/cloudnative-pg-vX.Y.Z` and switch to it:
    ```bash
    git switch --create release/cloudnative-pg-v$NEW_VERSION
    ```
4. Update the `.version` in the [Chart.yaml](./charts/cloudnative-pg/Chart.yaml) file to `"X.Y.Z"`
    ```bash
    sed -i -E "s/^version: \"([0-9]+.?)+\"/version: \"$NEW_VERSION\"/" charts/cloudnative-pg/Chart.yaml
    ```
5. Update everything else as required, e.g. if releasing due to a new `cloudnative-pg` version being released, you might
    want to update the following:
    1. `.appVersion` in the [Chart.yaml](./charts/cloudnative-pg/Chart.yaml) file
    2. [crds.yaml](./charts/cloudnative-pg/templates/crds/crds.yaml), which can be built using
        [kustomize](https://kustomize.io/) from the `cloudnative-pg` repo using kustomize
        [remoteBuild](https://github.com/kubernetes-sigs/kustomize/blob/master/examples/remoteBuild.md)
        running:
        ```bash
        VERSION=v1.16.0
        kustomize build https://github.com/cloudnative-pg/cloudnative-pg/tree/release-1.16/config/helm/\?ref=v1.16.0
        ```
        It might be easier to run `kustomize build config/helm` from the `cloudnative-pg` repo, with the desired release
        branch checked out, and copy the result to `./charts/cloudnative-pg/templates/crds/crds.yaml`.
    3. NOTE: please keep the guards for `.Values.crds.create`, i.e.
        `{{- if .Values.crds.create }}` and `{{- end }}` after you copy the CRD into `templates/crds/crds.yaml`.
    4. To update the files in the [templates](./charts/cloudnative-pg/templates) directory, you can diff the previous
        CNPG release yaml against the new one, to find what should be updated (e.g.
        ```bash
        OLD_VERSION=1.15.0
        NEW_VERSION=1.15.1
        vimdiff \
            "https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/main/releases/cnpg-${OLD_VERSION}.yaml" \
            "https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/main/releases/cnpg-${NEW_VERSION}.yaml"
       ```
       Or from the `cloudnative-pg` repo, with the desired release branch checked out:
       ```bash
       vimdiff releases/cnpg-1.15.0.yaml releases/cnpg-1.15.1.yaml
       ```
   5. Update [values.yaml](./charts/cloudnative-pg/values.yaml) if needed
   6. NOTE: updating `values.yaml` just for the CNPG  version may not be necessary, as the value should default to the
       `appVersion` in `Chart.yaml`
6. Run `make docs schema` to regenerate the docs and the values schema in case it is needed
    ```bash
    make docs schema
    ```
7. Commit and add the relevant information you wish in the commit message.
    ```bash
    git add .
    git commit -S -s -m "Release cloudnative-pg-v$NEW_VERSION" --edit
    ```
8. Push the new branch
    ```bash
    git push --set-upstream origin release/cloudnative-pg-v$NEW_VERSION
    ```
9. A PR named `Release cloudnative-pg-vX.Y.Z` should be automatically created
10. Wait for all the checks to pass
11. Two approvals are required in order to merge the PR, if you are a maintainer approve the PR yourself and ask for
    another approval, otherwise ask for two approvals directly.
12. Merge the PR squashing all commits and **taking care to keep the commit message to be 
    `Release cloudnative-pg-vX.Y.Z`**
13. A release `cloudnative-pg-vX.Y.Z` should be automatically created by an action, which will then trigger the release 
    action. Verify they both are successful.
14. Once done you should be able to run:
    ```bash
    helm repo add cnpg https://cloudnative-pg.github.io/charts
    helm repo update
    helm search repo cnpg
    ```
    and be able to see the new version `X.Y.Z` as `CHART VERSION` for `cloudnative-pg`

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
