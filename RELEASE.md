# How To Release

This repo contains two helm charts: [cloudnative-pg](./charts/cloudnative-pg)
and [cnpg-sandbox](./charts/cnpg-sandbox). Both the charts are available
through a single [repository](https://cloudnative-pg.github.io/charts), but
should be released separately as their versioning might be unlinked and the
latter depend on the former.

## How to release cloudnative-pg

In order to release `vX.Y.Z` of the `cloudnative-pg` chart, follow these steps:

1. create a branch named `release/cloudnative-pg-vX.Y.Z` and switch to it
1. bump the `.version` in the [Chart.yaml](./charts/cloudnative-pg/Chart.yaml) file to `vX.Y.Z`
1. update everything else as required, e.g. if releasing due to a new
   cloudnative-pg version being released, you might want to update the
   following:
    1. `.appVersion` in the [Chart.yaml](./charts/cloudnative-pg/Chart.yaml) file
    1. [crds.yaml](./charts/cloudnative-pg/templates/crds/crds.yaml), whose
       content can be built using [kustomize](https://kustomize.io/) from the
       cloudnative-pg repo using kustomize
       [remoteBuild](https://github.com/kubernetes-sigs/kustomize/blob/master/examples/remoteBuild.md)
       running: `kustomize build
       https://github.com/cloudnative-pg/cloudnative-pg//config/helm/\?ref=v1.15.1`,
       take care to set the correct version as ref (v1.15.1 in the example command).
    1. all the needed files in the
       [templates](./charts/cloudnative-pg/templates) directory, you can diff
       the previous release yaml w.r.t. the new one to know what should be
       updated (e.g. `vimdiff
       https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/main/releases/cnpg-1.15.0.yaml
       https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/main/releases/cnpg-1.15.1.yaml`)
    1. update [values.yaml](./charts/cloudnative-pg/values.yaml) if needed
  1. run `make docs schema` to regenerate the docs and the values schema in case it is needed
  1. `git commit -S -s -m "Release cloudnative-pg-vX.Y.Z" --edit` and add all
     the informations you wish below the commit message.
  1. `git push --set-upstream origin release/coudnative-pg-vX.Y.Z`
  1. a PR named `Release cloudnative-pg-vX.Y.Z` will be automatically created
  1. wait for all the checks to pass
  1. two approvals are required in order to merge the PR, if you are a
     maintainer approve the PR yourself and ask for another approval, otherwise
     ask for two approvals directly.
  1. merge the pr squashing all commits and **taking care to keep the commit
     message to be `Release cloudnative-pg-vX.Y.Z`**
  1. a tag `cloudnative-pg-vX.Y.Z` will be automatically created by an action,
     which will ten trigger the release action, check they both are successful.
  1. once done you should be able to run helm repo `helm repo add cnpg https://cloudnative-pg.github.io/charts; helm repo update; helm search repo cnpg` and be ableto see the new version `vX.Y.Z` as `CHART VERSION` for `cloudnative-pg`

## How to release cnpg-sandbox

cnpg-sandbox is an umbrella chart which depends on the cloudnative-pg chart, therefore in case the only change required is bumping cloudnative-pg version, its release should be done only once its dependency has been successfully released.

In order to release `vX.Y.Z` of the `cnpg-sandbox` chart, follow these steps:

1. create a branch `release/cnpg-sandbox-vX.Y.Z` and switch to it
1. bump the `.version` in the [Chart.yaml](./charts/cnpg-sanbox/Chart.yaml) file to `vX.Y.Z`
1. update everything else as required, e.g. if releasing due to a new cloudnative-pg chart being released:
  1. bump `.dependecies[0].version` for the `cloudnative-pg` chart in the aforementioned `Chart.yaml` file
  1. update the [values.yaml](./charts/cnpg-sandbox/Chart.yaml) file if needed
  1. run `helm dependency update charts/cnpg-sandbox` to sync the [Chart.lock](./charts/cnpg-sandbox/Chart.lock) to the new dependencies
1. run `make docs schema` to regenerate the docs and the values schema in case it is needed
1. `git commit -S -s -m "Release cnpg-sandbox-vX.Y.Z" --edit` and add all
   the informations you wish below the commit message.
1. `git push --set-upstream origin release/cnpg-sandbox-vX.Y.Z`
1. a PR named `Release cnpg-sandbox-vX.Y.Z` will be automatically created
1. wait for all the checks to pass
1. two approvals are required in order to merge the PR, if you are a
   maintainer approve the PR yourself and ask for another approval, otherwise
   ask for two approvals directly.
1. merge the pr squashing all commits and **taking care to keep the commit
   message to be `Release cnpg-sandbox-vX.Y.Z`**
1. a tag `cnpg-sandbox-vX.Y.Z` will be automatically created by an action,
   which will ten trigger the release action, check they both are successful.
1. once done you should be able to run helm repo `helm repo add cnpg https://cloudnative-pg.github.io/charts; helm repo update; helm search repo cnpg` and be ableto see the new version `vX.Y.Z` as `CHART VERSION` for `cnpg-sanbox`
