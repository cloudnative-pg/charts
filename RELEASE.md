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
2. [Releasing the `cluster` chart](#releasing-the-cluster-chart)
3. [Releasing the `plugin-barman-cloud` chart](#releasing-the-plugin-barman-cloud)

## Releasing the `cloudnative-pg` chart

In order to create a new release of the `cloudnative-pg` chart, follow these steps:

1. Take note of the current value of the release: see `.version` in `charts/cloudnative-pg/Chart.yaml`
    ```bash
    OLD_VERSION=$(yq -r '.version' charts/cloudnative-pg/Chart.yaml)
    OLD_CNPG_VERSION=$(yq -r '.appVersion' charts/cloudnative-pg/Chart.yaml)
    echo Old chart version: $OLD_VERSION
    echo Old CNPG version: $OLD_CNPG_VERSION
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
    want to:
    1. Find the latest `cloudnative-pg` version by running:
        ```bash
        NEW_CNPG_VERSION=$(curl -Ssl "https://api.github.com/repos/cloudnative-pg/cloudnative-pg/tags" | jq -r '.[0].name | ltrimstr("v")')
        echo New CNPG version: $NEW_CNPG_VERSION
        ```
    2. Update `.appVersion` in the [Chart.yaml](./charts/cloudnative-pg/Chart.yaml) file
        ```bash
        sed -i -E "s/^appVersion: \"([0-9]+.?)+\"/appVersion: \"$NEW_CNPG_VERSION\"/" charts/cloudnative-pg/Chart.yaml
        ```
    3. Update [crds.yaml](./charts/cloudnative-pg/templates/crds/crds.yaml), which can be built using
        [kustomize](https://kustomize.io/) from the `cloudnative-pg` repo using kustomize
        [remoteBuild](https://github.com/kubernetes-sigs/kustomize/blob/master/examples/remoteBuild.md)
        running:

        Verify the version is correct. Edit it if incorrect, then run:
        ```bash
        echo '{{- if .Values.crds.create }}' > ./charts/cloudnative-pg/templates/crds/crds.yaml
        kustomize build https://github.com/cloudnative-pg/cloudnative-pg/config/helm/\?ref\=v$NEW_CNPG_VERSION >> ./charts/cloudnative-pg/templates/crds/crds.yaml
        echo '{{- end }}' >> ./charts/cloudnative-pg/templates/crds/crds.yaml
        ```
    4. To update the files in the [templates](./charts/cloudnative-pg/templates) directory, you can diff the previous
        CNPG release yaml against the new one, to find what should be updated (e.g.
        ```bash
        vimdiff \
            "https://github.com/cloudnative-pg/cloudnative-pg/releases/download/v${OLD_CNPG_VERSION}/cnpg-${OLD_CNPG_VERSION}.yaml" \
            "https://github.com/cloudnative-pg/cloudnative-pg/releases/download/v${NEW_CNPG_VERSION}/cnpg-${NEW_CNPG_VERSION}.yaml"
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

## Releasing the `plugin-barman-cloud` chart

In order to create a new release of the `plugin-barman-cloud` chart, follow these steps:

1. Take note of the current value of the release: see `.version` in `charts/plugin-barman-cloud/Chart.yaml`
    ```bash
    OLD_VERSION=$(yq -r '.version' charts/plugin-barman-cloud/Chart.yaml)
    OLD_APP_VERSION=$(yq -r '.appVersion' charts/plugin-barman-cloud/Chart.yaml)
    echo Old chart version: $OLD_VERSION
    echo Old app version: $OLD_APP_VERSION
    ```
2. Decide which version to create, depending on the kind of jump of the CloudNativePG release, following semver
    semantics. For this document, let's call it `X.Y.Z`
    ```bash
    NEW_VERSION="X.Y.Z"
    ```
3. Create a branch named `release/plugin-barman-cloud-vX.Y.Z` and switch to it:
    ```bash
    git switch --create release/plugin-barman-cloud-v$NEW_VERSION
    ```
4. Update the `.version` in the [Chart.yaml](./charts/plugin-barman-cloud/Chart.yaml) file to `"X.Y.Z"`
    ```bash
    sed -i -E "s/^version: \"([0-9]+.?)+\"/version: \"$NEW_VERSION\"/" charts/plugin-barman-cloud/Chart.yaml
    ```
5. Update everything else as required, e.g. if releasing due to a new `plugin-barman-cloud` version being released, you might
    want to:
    1. Find the latest `plugin-barman-cloud` version by running:
        ```bash
        NEW_APP_VERSION=$(curl -Ssl "https://api.github.com/repos/cloudnative-pg/plugin-barman-cloud/tags" | jq -r '.[0].name')
        echo New app version: $NEW_APP_VERSION
        ```
    2. Update `.appVersion` in the [Chart.yaml](./charts/plugin-barman-cloud/Chart.yaml) file
        ```bash
        sed -i -E "s/^appVersion: \"v([0-9]+.?)+\"/appVersion: \"$NEW_APP_VERSION\"/" charts/plugin-barman-cloud/Chart.yaml
        ```
    3. Update [crds.yaml](./charts/plugin-barman-cloud/templates/crds/crds.yaml), which can be built using
        [kustomize](https://kustomize.io/) from the `plugin-barman-cloud` repo using kustomize
        [remoteBuild](https://github.com/kubernetes-sigs/kustomize/blob/master/examples/remoteBuild.md)
        running:

        Verify the version is correct. Edit it if incorrect, then run:
        ```bash
        echo '{{- if .Values.crds.create }}' > ./charts/plugin-barman-cloud/templates/crds/crds.yaml
        kustomize build https://github.com/cloudnative-pg/plugin-barman-cloud/config/crd/\?ref\=$NEW_APP_VERSION >> ./charts/plugin-barman-cloud/templates/crds/crds.yaml
        echo '{{- end }}' >> ./charts/plugin-barman-cloud/templates/crds/crds.yaml
        ```

        Check that the `helm.sh/resource-policy: keep` annotation is still present after regenerating the CRDs.
    4. To update the files in the [templates](./charts/plugin-barman-cloud/templates) directory, you can diff the previous
        CNPG release yaml against the new one, to find what should be updated (e.g.
        ```bash
        vimdiff \
            "https://github.com/cloudnative-pg/plugin-barman-cloud/releases/download/${OLD_APP_VERSION}/manifest.yaml" \
            "https://github.com/cloudnative-pg/plugin-barman-cloud/releases/download/${NEW_APP_VERSION}/manifest.yaml"
       ```

    5. Update [values.yaml](./charts/plugin-barman-cloud/values.yaml) if needed
    6. NOTE: updating `values.yaml` just for the appVersion may not be necessary, as the value should default to the
        `appVersion` in `Chart.yaml`
6. Run `make docs schema` to regenerate the docs and the values schema in case it is needed
    ```bash
    make docs schema
    ```
7. Commit and add the relevant information you wish in the commit message.
    ```bash
    git add .
    git commit -S -s -m "Release plugin-barman-cloud-v$NEW_VERSION" --edit
    ```
8. Push the new branch
    ```bash
    git push --set-upstream origin release/plugin-barman-cloud-v$NEW_VERSION
    ```
9. A PR named `Release plugin-barman-cloud-vX.Y.Z` should be automatically created
10. Wait for all the checks to pass
11. Two approvals are required in order to merge the PR, if you are a maintainer approve the PR yourself and ask for
    another approval, otherwise ask for two approvals directly.
12. Merge the PR squashing all commits and **taking care to keep the commit message to be
    `Release plugin-barman-cloud-vX.Y.Z`**
13. A release `plugin-barman-cloud-vX.Y.Z` should be automatically created by an action, which will then trigger the release
    action. Verify they both are successful.
14. Once done you should be able to run:
    ```bash
    helm repo add cnpg https://cloudnative-pg.github.io/charts
    helm repo update
    helm search repo cnpg
    ```
    and be able to see the new version `X.Y.Z` as `CHART VERSION` for `plugin-barman-cloud`
