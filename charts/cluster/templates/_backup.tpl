{{- define "cluster.backup" -}}
{{- if .Values.backups.enabled }}
backup:
  target: "prefer-standby"
  retentionPolicy: {{ .Values.backups.retentionPolicy }}
  {{- if has .Values.backups.provider (list "s3" "azure" "google") }}
  barmanObjectStore:
    wal:
      compression: {{ .Values.backups.wal.compression }}
      encryption: {{ .Values.backups.wal.encryption }}
      maxParallel: {{ .Values.backups.wal.maxParallel }}
    data:
      compression: {{ .Values.backups.data.compression }}
      encryption: {{ .Values.backups.data.encryption }}
      jobs: {{ .Values.backups.data.jobs }}

    {{- $d := dict "chartFullname" (include "cluster.fullname" .) "scope" .Values.backups "secretPrefix" "backup" }}
    {{- include "cluster.barmanObjectStoreConfig" $d | nindent 2 }}
  {{- else if eq .Values.backups.provider "volumeSnapshot" }}
  volumeSnapshot:
    online: true
    className: {{ .Values.backups.volumeSnapshot.className }}
    {{- end }}
{{- end }}
{{- end }}
