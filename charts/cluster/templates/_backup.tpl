{{- define "cluster.backup" -}}
{{- if .Values.backups.enabled }}
backup:
  target: "prefer-standby"
  retentionPolicy: {{ .Values.backups.retentionPolicy }}
  barmanObjectStore:
    wal:
      compression: {{ .Values.backups.wal.compression }}
      {{- if .Values.backups.wal.encryption }}
      encryption: {{ .Values.backups.wal.encryption }}
      {{- end }}
      maxParallel: {{ .Values.backups.wal.maxParallel }}
      {{- if .Values.backups.wal.additionalCommandArgs }}
      additionalCommandArgs:
        {{- toYaml .Values.backups.wal.additionalCommandArgs | nindent 8 }}
      {{- end }}
    data:
      compression: {{ .Values.backups.data.compression }}
      {{- if .Values.backups.data.encryption }}
      encryption: {{ .Values.backups.data.encryption }}
      {{- end }}
      jobs: {{ .Values.backups.data.jobs }}
      {{- if .Values.backups.data.additionalCommandArgs }}
      additionalCommandArgs:
        {{- toYaml .Values.backups.data.additionalCommandArgs | nindent 8 }}
      {{- end }}

    {{- $d := dict "chartFullname" (include "cluster.fullname" .) "scope" .Values.backups "secretPrefix" "backup" }}
    {{- include "cluster.barmanObjectStoreConfig" $d | nindent 2 }}
{{- end }}
{{- end }}
