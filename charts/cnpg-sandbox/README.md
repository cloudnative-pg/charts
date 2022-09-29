# cnpg-sandbox

![Version: 0.6.0](https://img.shields.io/badge/Version-0.6.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.17.0](https://img.shields.io/badge/AppVersion-1.17.0-informational?style=flat-square)

A sandbox for CloudNativePG

**Homepage:** <https://cloudnative-pg.io>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| phisco | <p.scorsolini@gmail.com> |  |

## Source Code

* <https://github.com/cloudnative-pg/cnpg-sandbox>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://cloudnative-pg.github.io/charts | cloudnative-pg | 0.15.0 |
| https://prometheus-community.github.io/helm-charts | kube-prometheus-stack | 32.2.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cloudnative-pg | object | `{"config":{"create":true,"data":{"MONITORING_QUERIES_CONFIGMAP":"default-monitoring-queries"}},"enabled":true}` | here you can pass the whole values directly to the cloudnative-pg chart |
| defaultAlerts | bool | `true` |  |
| defaultDashboard | bool | `true` |  |
| kube-prometheus-stack | object | `{"alertmanager":{"enabled":true},"defaultRules":{"create":true,"rules":{"alertmanager":false,"configReloaders":false,"etcd":false,"general":false,"k8s":true,"kubeApiserver":false,"kubeApiserverAvailability":false,"kubeApiserverSlos":false,"kubePrometheusGeneral":false,"kubePrometheusNodeRecording":false,"kubeProxy":false,"kubeScheduler":false,"kubeStateMetrics":false,"kubelet":true,"kubernetesApps":false,"kubernetesResources":false,"kubernetesStorage":false,"kubernetesSystem":false,"network":false,"node":true,"nodeExporterAlerting":false,"nodeExporterRecording":true,"prometheus":false,"prometheusOperator":false}},"enabled":true,"grafana":{"adminPassword":"prom-operator","defaultDashboardsEnabled":false,"enabled":true},"kubeControllerManager":{"enabled":false},"nodeExporter":{"enabled":false},"prometheus":{"prometheusSpec":{"podMonitorSelectorNilUsesHelmValues":false,"probeSelectorNilUsesHelmValues":false,"ruleSelectorNilUsesHelmValues":false,"serviceMonitorSelectorNilUsesHelmValues":false}}}` | here you can pass the whole values directly to the kube-prometheus-stack chart |
| kube-prometheus-stack.grafana.adminPassword | string | `"prom-operator"` | the grafana admin password |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)