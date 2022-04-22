{{/*
Expand the name of the chart.
*/}}
{{- define "cnp-sandbox.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cnp-sandbox.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cnp-sandbox.labels" -}}
helm.sh/chart: {{ include "cnp-sandbox.chart" . }}
{{ include "cnp-sandbox.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cnp-sandbox.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cnp-sandbox.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
