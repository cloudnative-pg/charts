#!/usr/bin/env bash
#
# Copyright © contributors to CloudNativePG, established as
# CloudNativePG a Series of LF Projects, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
#

set -euo pipefail

CHART_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUBE_VERSION="${KUBE_VERSION:-1.29.0}"
NAMESPACE="${NAMESPACE:-single-install}"

helm_template() {
  helm template test "${CHART_DIR}" \
    --kube-version "${KUBE_VERSION}" \
    --namespace "${NAMESPACE}" \
    --set monitoring.grafanaDashboard.create=false \
    "$@"
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local message="$3"

  if ! printf '%s' "${haystack}" | grep -Fq -- "${needle}"; then
    echo "assertion failed: ${message}" >&2
    echo "expected to find: ${needle}" >&2
    exit 1
  fi
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  local message="$3"

  if printf '%s' "${haystack}" | grep -Fq -- "${needle}"; then
    echo "assertion failed: ${message}" >&2
    echo "expected to not find: ${needle}" >&2
    exit 1
  fi
}

deployment_ns="$(helm_template --set config.clusterWide=false --show-only templates/deployment.yaml)"
assert_contains "${deployment_ns}" 'name: WEBHOOK_PREFIX' "namespace-scoped deployment sets WEBHOOK_PREFIX"
assert_contains "${deployment_ns}" "value: \"${NAMESPACE}-\"" "namespace-scoped deployment prefixes WEBHOOK_PREFIX with namespace"
assert_contains "${deployment_ns}" 'name: WATCH_NAMESPACE' "namespace-scoped deployment sets WATCH_NAMESPACE"

deployment_cluster="$(helm_template --set config.clusterWide=true --show-only templates/deployment.yaml)"
assert_not_contains "${deployment_cluster}" 'name: WEBHOOK_PREFIX' "cluster-wide deployment does not set WEBHOOK_PREFIX"
assert_not_contains "${deployment_cluster}" 'name: WATCH_NAMESPACE' "cluster-wide deployment does not set WATCH_NAMESPACE"

mutating_ns="$(helm_template --set config.clusterWide=false --show-only templates/mutatingwebhookconfiguration.yaml)"
assert_contains "${mutating_ns}" "name: ${NAMESPACE}-cnpg-mutating-webhook-configuration" "namespace-scoped mutating webhook uses prefixed name"
assert_contains "${mutating_ns}" "kubernetes.io/metadata.name" "namespace-scoped mutating webhook sets namespaceSelector"
assert_contains "${mutating_ns}" "          - ${NAMESPACE}" "namespace-scoped mutating webhook targets release namespace"

mutating_cluster="$(helm_template --set config.clusterWide=true --show-only templates/mutatingwebhookconfiguration.yaml)"
assert_contains "${mutating_cluster}" "name: cnpg-mutating-webhook-configuration" "cluster-wide mutating webhook keeps default name"
assert_not_contains "${mutating_cluster}" "namespaceSelector:" "cluster-wide mutating webhook has no namespaceSelector"

validating_ns="$(helm_template --set config.clusterWide=false --show-only templates/validatingwebhookconfiguration.yaml)"
assert_contains "${validating_ns}" "name: ${NAMESPACE}-cnpg-validating-webhook-configuration" "namespace-scoped validating webhook uses prefixed name"
assert_contains "${validating_ns}" "kubernetes.io/metadata.name" "namespace-scoped validating webhook sets namespaceSelector"

validating_cluster="$(helm_template --set config.clusterWide=true --show-only templates/validatingwebhookconfiguration.yaml)"
assert_contains "${validating_cluster}" "name: cnpg-validating-webhook-configuration" "cluster-wide validating webhook keeps default name"
assert_not_contains "${validating_cluster}" "namespaceSelector:" "cluster-wide validating webhook has no namespaceSelector"

echo "webhook prefix chart tests passed"
