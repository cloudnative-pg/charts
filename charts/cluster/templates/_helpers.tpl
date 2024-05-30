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
        {{ fail "You need to provide your own cluster.imageName as an official timescaledb image doesn't exist yet." }}
    {{- else -}}
        {{ fail "Invalid cluster type!" }}
    {{- end }}
{{- end -}}

{{/*
Cluster Image
If imageCatalogRef defined, use it, otherwice calculate ordinary imageName.
*/}}
{{- define "cluster.image" }}
{{- if .Values.cluster.imageCatalogRef.name }}
imageCatalogRef:
  apiGroup: postgresql.cnpg.io
  {{- toYaml .Values.cluster.imageCatalogRef | nindent 2 }}
  major: {{ .Values.version.major }}
{{- else if and .Values.imageCatalog.create (not (empty .Values.imageCatalog.images )) }}
imageCatalogRef:
  apiGroup: postgresql.cnpg.io
  kind: ImageCatalog
  name: {{ include "cluster.fullname" . }}
  major: {{ .Values.version.major }}
{{- else }}
  {{- if empty .Values.cluster.imageName -}}
    {{- if and .Values.imageCatalog.create (eq .Values.type "timescaledb") -}}
imageCatalogRef:
  apiGroup: postgresql.cnpg.io
  kind: ImageCatalog
  name: {{ include "cluster.fullname" . }}-timescaledb-ha
  major: {{ .Values.version.major }}
    {{- end }}
  {{- else }}
imageName: {{ include "cluster.imageName" . }}
  {{- end }}
{{- end }}
{{- end }}