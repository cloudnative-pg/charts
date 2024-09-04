{{- define "cluster.backup" -}}
{{- if (eq (include "cluster.backups.enabled" .) "true") }}
backup:
  target: {{ .Values.backups.target }}
  retentionPolicy: {{ .Values.backups.retentionPolicy }}
  {{- if (eq (include "cluster.backups.objectStorage.enabled" .) "true") }}
  barmanObjectStore:
    wal:
      compression: {{ .Values.backups.objectStorage.wal.compression }}
      encryption: {{ .Values.backups.objectStorage.wal.encryption }}
      maxParallel: {{ .Values.backups.objectStorage.wal.maxParallel }}
    data:
      compression: {{ .Values.backups.objectStorage.data.compression }}
      encryption: {{ .Values.backups.objectStorage.data.encryption }}
      jobs: {{ .Values.backups.objectStorage.data.jobs }}

    {{- $d := dict "chartFullname" (include "cluster.fullname" .) "scope" .Values.backups.objectStorage "secretPrefix" "backup" "existingSecret" .Values.backups.existingSecret }}
    {{- include "cluster.barmanObjectStoreConfig" $d | nindent 2 }}
  {{- end }}
  {{- if (not (empty .Values.backups.volumeSnapshot.className )) }}
  {{- with .Values.backups.volumeSnapshot }}
  volumeSnapshot:
    className: {{ .className }}
    {{- if (not (empty .walClassName)) }}
    walClassName: {{ .walClassName }}
    {{- end }}
    online: {{ .online }}
    onlineConfiguration:
      immediateCheckpoint: {{ .onlineConfiguration.immediateCheckpoint }}
      waitForArchive: {{ .onlineConfiguration.waitForArchive }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}
