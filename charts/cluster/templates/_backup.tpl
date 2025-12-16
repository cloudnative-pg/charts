{{- define "cluster.backup" -}}
{{- if .Values.backups.enabled }}
plugins:
- name: barman-cloud.cloudnative-pg.io
  isWALArchiver: true
  parameters:
    barmanObjectName: {{ include "cluster.fullname" . }}-objectstore
{{- end }}
{{- end }}
