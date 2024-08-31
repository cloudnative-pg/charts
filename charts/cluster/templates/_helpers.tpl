{{/*
Expand the name of the chart.
*/}}
{{- define "cluster.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cluster.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cluster.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cluster.labels" -}}
helm.sh/chart: {{ include "cluster.chart" . }}
{{ include "cluster.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cluster.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cluster.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: cloudnative-pg
{{- end }}

{{/*
Cluster Image Name
If a custom imageName is available, use it, otherwise use the defaults based on the .Values.type
*/}}
{{- define "cluster.imageName" -}}
    {{- if .Values.cluster.imageName -}}
        {{- .Values.cluster.imageName -}}
    {{- else if eq .Values.type "postgresql" -}}
        {{- "ghcr.io/cloudnative-pg/postgresql:15.2" -}}
    {{- else if eq .Values.type "postgis" -}}
        {{- "ghcr.io/cloudnative-pg/postgis:14" -}}
    {{- else if eq .Values.type "timescaledb" -}}
        {{- fail "You need to provide your own cluster.imageName as an official timescaledb image doesn't exist yet." }}
    {{- else -}}
        {{- fail "Invalid cluster type!" }}
    {{- end }}
{{- end -}}

{{/*
Recovery enabled
Verify that recovery method is set to one of supported methods in methodSettings
Definition assume we have recovery enabled also in import and replication modes, if need to know
for sure that mode is set to recovery: use (eq .Values.mode "recovery")
*/}}
{{- define "cluster.recovery.enabled" -}}
  {{- if and (or (eq .Values.mode "recovery") (eq .Values.mode "replica") (eq .Values.mode "import")) }}
    {{- if empty .Values.recovery.method }}
      {{- fail (printf ".Values.recovery.method is required, but not specified.") }}
    {{- else if not (hasKey .Values.recovery.methodSettings .Values.recovery.method) }}
      {{- fail (printf "The specified method '%s' does not match any of the supported in .Values.recovery.methodSettings" .Values.recovery.method) }}
    {{- end }}
    {{- hasKey .Values.recovery.methodSettings .Values.recovery.method }}
  {{- end }}
{{- end }}

{{/*
Recovery objectStorage enabled
Verify that provider is set to one of supported providers in providerSettings
*/}}
{{- define "cluster.recovery.method.objectStorage.enabled" -}}
  {{- if and (eq (include "cluster.recovery.enabled" .) "true") (eq .Values.recovery.method "objectStorage") }}
    {{- if empty .Values.recovery.methodSettings.objectStorage.provider }}
      {{- fail (printf ".Values.recovery.methodSettings.objectStorage.provider is required, but not specified.") }}
    {{- else if not (hasKey .Values.recovery.methodSettings.objectStorage.providerSettings .Values.recovery.methodSettings.objectStorage.provider) }}
      {{- fail (printf "The specified provider '%s' does not match any of the supported in .Values.recovery.methodSettings.objectStorage.providerSettings" .Values.recovery.methodSettings.objectStorage.provider) }}
    {{- end }}
    {{- hasKey .Values.recovery.methodSettings.objectStorage.providerSettings .Values.recovery.methodSettings.objectStorage.provider }}
  {{- end }}
{{- end }}

{{/*
Recovery pgBasebackup enabled
*/}}
{{- define "cluster.recovery.method.pgBasebackup.enabled" -}}
  {{- if (eq (include "cluster.recovery.method.pgBasebackup.auth.enabled" .) "true") }}
    {{- and (eq (include "cluster.recovery.enabled" .) "true") (eq .Values.recovery.method "pgBasebackup") }}
  {{- end }}
{{- end }}

{{/*
Recovery pgBasebackup auth enabled
Verify that pgBasebackup auth is set to one of supported options in authDetails
*/}}
{{- define "cluster.recovery.method.pgBasebackup.auth.enabled" -}}
  {{- if empty .Values.recovery.methodSettings.pgBasebackup.auth }}
    {{- fail (printf ".Values.recovery.methodSettings.pgBasebackup.auth is required, but not specified.") }}
  {{- else if not (hasKey .Values.recovery.methodSettings.pgBasebackup.authDetails .Values.recovery.methodSettings.pgBasebackup.auth) }}
    {{- fail (printf "The specified auth '%s' does not match any of the supported in .Values.recovery.methodSettings.pgBasebackup.authDetails" .Values.recovery.methodSettings.pgBasebackup.auth) }}
  {{- end }}
  {{- hasKey .Values.recovery.methodSettings.pgBasebackup.authDetails .Values.recovery.methodSettings.pgBasebackup.auth }}
{{- end }}

{{/*
Import enabled
Verify that import type is set to one of supported in typeSettings
*/}}
{{- define "cluster.import.enabled" -}}
  {{- if eq .Values.mode "import" }}
    {{- if empty .Values.import.type }}
      {{- fail (printf ".Values.import.type is required, but not specified.") }}
    {{- else if not (hasKey .Values.import.typeSettings .Values.import.type) }}
      {{- fail (printf "The specified type '%s' does not match any of the supported in .Values.import.typeSettings" .Values.import.type) }}
    {{- end }}
    {{- hasKey .Values.import.typeSettings .Values.import.type }}
  {{- end }}
{{- end }}

{{/*
Import type microservice enabled
Verify that recovery method is set to pgBasebackup
*/}}
{{- define "cluster.import.type.microservice.enabled" -}}
{{- if and (eq (include "cluster.import.enabled" .) "true") (eq .Values.import.type "microservice") }}
  {{- if (eq (include "cluster.recovery.method.pgBasebackup.enabled" .) "true") }}
    {{- if (empty .Values.import.typeSettings.microservice.database) }}
      {{- fail (printf ".Values.import.typeSettings.microservice.database is required, but not specified.") }}
    {{- else }}
      {{- true }}
    {{- end }}
  {{- else }}
    {{- fail (printf "Import mode requires recovery mode to be set to 'pgBasebackup'") }}
  {{- end }}
{{- else }}
  {{- false }}
{{- end }}
{{- end }}

{{/*
Import type monolith enabled
Verify that recovery method is set to pgBasebackup
*/}}
{{- define "cluster.import.type.monolith.enabled" -}}
{{- if and (eq (include "cluster.import.enabled" .) "true") (eq .Values.import.type "monolith") }}
  {{- if (eq (include "cluster.recovery.method.pgBasebackup.enabled" .) "true") }}
    {{- if (eq (len .Values.import.typeSettings.monolith.databases) 0) }}
      {{- fail (printf ".Values.import.typeSettings.monolith.databases is required, but not specified.") }}
    {{- else }}
      {{- true }}
    {{- end }}
  {{- else }}
    {{- fail (printf "Import mode requires recovery mode to be set to 'pgBasebackup'") }}
  {{- end }}
{{- else }}
  {{- false }}
{{- end }}
{{- end }}

{{/*
Replica enabled
Verify that replica topology is set to one of supported in topologySettings
*/}}
{{- define "cluster.replica.enabled" -}}
  {{- if eq .Values.mode "replica" }}
    {{- if empty .Values.replica.topology }}
      {{- fail (printf ".Values.replica.topology is required, but not specified.") }}
    {{- else if not (hasKey .Values.replica.topologySettings .Values.replica.topology) }}
      {{- fail (printf "The specified topology '%s' does not match any of the supported in .Values.replica.topologySettings" .Values.replica.topology) }}
    {{- end }}
    {{- hasKey .Values.replica.topologySettings .Values.replica.topology }}
  {{- end }}
{{- end }}

{{/*
Replica topology standalone enabled
Verify that at both recovery and backups method is set to objectStorage or pgBasebackup
*/}}
{{- define "cluster.replica.topology.standalone.enabled" -}}
{{- if and (eq (include "cluster.replica.enabled" .) "true") (eq .Values.replica.topology "standalone") }}
  {{- if and (or (eq (include "cluster.recovery.method.pgBasebackup.enabled" .) "true") (eq (include "cluster.recovery.method.objectStorage.enabled" .) "true")) }}
    {{- true }}
  {{- else }}
    {{- fail (printf "Replica in standalone topology mode requires recovery mode to be set to 'pgBasebackup' or 'objectStorage'") }}
  {{- end }}
{{- else }}
  {{- false }}
{{- end }}
{{- end }}

{{/*
Replica topology distributed enabled
Validate that both recovery and backups method is set to objectStorage in distributed topology
*/}}
{{- define "cluster.replica.topology.distributed.enabled" -}}
{{- if and (eq (include "cluster.replica.enabled" .) "true") (eq .Values.replica.topology "distributed") }}
  {{- if and (eq (include "cluster.recovery.method.objectStorage.enabled" .) "true") (eq (include "cluster.backups.objectStorage.enabled" .) "true") }}
    {{- if (empty .Values.recovery.methodSettings.objectStorage.clusterName) }}
      {{- fail (printf ".Values.recovery.methodSettings.objectStorage.clusterName is required, but not specified. Replica in distributed topology mode requires setting it up to the name of second cluster.") }}
    {{- else if (eq .Values.recovery.methodSettings.objectStorage.clusterName (include "cluster.fullname" .)) }}
      {{- fail (printf ".Values.recovery.methodSettings.objectStorage.clusterName is set to current cluster name, while replica in distributed topology mode requires setting it up to the name of second cluster.") }}
    {{- end }}
    {{- true }}
  {{- else }}
    {{- fail (printf "Replica in distributed topology mode requires setting up both recovery and backups to objectStorage") }}
  {{- end }}
{{- else }}
  {{- false }}
{{- end }}
{{- end }}

{{/*
Replica source
Defines which source to use
*/}}
{{- define "cluster.replica.source" -}}
{{- if or (eq (include "cluster.replica.topology.standalone.enabled" .) "true") (eq (include "cluster.replica.topology.distributed.enabled" .) "true") }}
  {{- if (eq (include "cluster.recovery.method.objectStorage.enabled" .) "true") }}
    {{- print "objectStoreRecoveryCluster" }}
  {{- else if (eq (include "cluster.recovery.method.pgBasebackup.enabled" .) "true") }}
    {{- print "pgBasebackupRecoveryCluster" }}
  {{- else }}
    {{- fail (printf "The specified topology '%s' does not match any of the supported in .Values.replica.topologySettings" .Values.replica.topology) }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Replica readonly
Defines if we can't change anything in cluster
*/}}
{{- define "cluster.replica.readonly" -}}
{{- or (and (not .Values.replica.topologySettings.distributed.primary) (eq (include "cluster.replica.topology.distributed.enabled" .) "true")) (eq (include "cluster.replica.topology.standalone.enabled" .) "true") }}
{{- end }}

{{/*
Backups objectStorage enabled
Validate that provider is set to one of supported providers in providerSettings
*/}}
{{- define "cluster.backups.objectStorage.enabled" -}}
{{- if and (not (empty .Values.backups.objectStorage.provider)) (not (hasKey .Values.backups.objectStorage.providerSettings .Values.backups.objectStorage.provider)) }}
  {{- fail (printf "The specified provider '%s' does not match any of the supported in .Values.backups.objectStorage.providerSettings" .Values.backups.objectStorage.provider) }}
{{- end }}
{{- hasKey .Values.backups.objectStorage.providerSettings .Values.backups.objectStorage.provider }}
{{- end }}

{{/*
Backups enabled
*/}}
{{- define "cluster.backups.enabled" -}}
{{- or (eq (include "cluster.backups.objectStorage.enabled" .) "true") (not (empty .Values.backups.volumeSnapshot.className )) -}}
{{- end }}
