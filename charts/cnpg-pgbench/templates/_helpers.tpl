{{/*
Expand the name of the chart.
*/}}
{{- define "cnpg-pgbench.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cnpg-pgbench.fullname" -}}
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
{{- define "cnpg-pgbench.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cnpg-pgbench.labels" -}}
helm.sh/chart: {{ include "cnpg-pgbench.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Service that we should connect to
*/}}
{{- define "cnpg-pgbench.service" -}}
{{- if .Values.cnp.pooler.instances -}}
pooler-{{ include "cnpg-pgbench.fullname" . }}
{{- else -}}
{{ include "cnpg-pgbench.fullname" . }}-rw
{{- end -}}
{{- end}}

{{- define "cnpg-pgbench.credentials" -}}
{{- if not .Values.cnp.existingCluster }}
- name: PGHOST
  value: {{ include "cnpg-pgbench.service" . }}
- name: PGUSER
  valueFrom:
    secretKeyRef:
      name: {{ include "cnpg-pgbench.fullname" . }}-app
      key: username
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "cnpg-pgbench.fullname" . }}-app
      key: password
{{- else -}}
- name: PGHOST
  value: {{ .Values.cnp.existingHost }}
- name: PGDATABASE
  value: {{ .Values.cnp.existingDatabase }}
- name: PGPORT
  value: {{ .Values.cnp.existingPort }}
- name: PGUSER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.cnp.existingCredentials }}
      key: username
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.cnp.existingCredentials }}
      key: password
{{- end -}}
{{- end }}
