{{/*
Expand the name of the chart.
*/}}
{{- define "pgbench.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pgbench.fullname" -}}
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
{{- define "pgbench.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "pgbench.labels" -}}
helm.sh/chart: {{ include "pgbench.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Service that we should connect to
*/}}
{{- define "pgbench.service" -}}
{{- if .Values.cnpg.pooler.instances -}}
pooler-{{ include "pgbench.fullname" . }}
{{- else -}}
{{ include "pgbench.fullname" . }}-rw
{{- end -}}
{{- end}}

{{- define "pgbench.credentials" -}}
{{- if not .Values.cnpg.existingCluster }}
- name: PGHOST
  value: {{ include "pgbench.service" . }}
- name: PGUSER
  valueFrom:
    secretKeyRef:
      name: {{ include "pgbench.fullname" . }}-app
      key: username
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "pgbench.fullname" . }}-app
      key: password
{{- else -}}
- name: PGHOST
  value: {{ .Values.cnpg.existingHost }}
- name: PGDATABASE
  value: {{ .Values.cnpg.existingDatabase }}
- name: PGPORT
  value: {{ .Values.cnpg.existingPort }}
- name: PGUSER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.cnpg.existingCredentials }}
      key: username
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.cnpg.existingCredentials }}
      key: password
{{- end -}}
{{- end }}
