{{/* Expand the name of the chart */}}
{{- define "cnpgdb.name" -}}
{{- default .Chart.Name .Values.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Expand the fullname of the chart */}}
{{- define "cnpgdb.fullname" -}}
{{- if .Values.fullname }}
{{- .Values.fullname | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.name }}
{{- if contains $name .Release.Name }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/* Expand the namespace of the chart */}}
{{- define "cnpgdb.namespace" -}}
{{- .Values.namespace | default "cnpgdb-system" | quote }}
{{- end }}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cnpgdb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Image Name
If a custom imageName is available, use it, otherwise use the defaults based on the .Values.type
*/}}
{{- define "cnpgdb.imageName" -}}
    {{- if .Values.imageName -}}
        {{- .Values.imageName -}}
    {{- else if eq .Values.type "postgresql" -}}
        {{- "ghcr.io/cloudnative-pg/postgresql:15.2" -}}
    {{- else -}}
        {{ fail "Invalid cluster type!" }}
    {{- end }}
{{- end -}}
