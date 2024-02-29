{{- define "cluster.backup" -}}
backup:
{{- if .Values.backups.enabled }}
  target: "prefer-standby"
  retentionPolicy: {{ .Values.backups.retentionPolicy }}
  barmanObjectStore:
    wal:
      compression: gzip
      encryption: AES256
    data:
      compression: gzip
      encryption: AES256
      jobs: 2

    {{- $d := dict "chartFullname" (include "cluster.fullname" .) "scope" .Values.backups "secretSuffix" "" }}
    {{- include "cluster.barmanObjectStoreConfig" $d | nindent 2 }}
{{- end }}
{{- end }}
