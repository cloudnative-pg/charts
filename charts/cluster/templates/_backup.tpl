{{- define "cluster.backup" -}}
{{- if .Values.backups.enabled }}
backup:
  target: {{ .Values.backups.target }}
  retentionPolicy: {{ .Values.backups.retentionPolicy }}
  {{- if eq .Values.backups.method "plugin" }}
  pluginConfiguration:
    name: {{ .Values.backups.pluginConfiguration.name }}
    parameters: 
      {{ .Values.backups.pluginConfiguration.parameters | toYaml | nindent 6 }}
  {{- end }}
  {{- if eq .Values.backups.method "volumeSnapshot" }}
  volumeSnapshot:
    labels:
      {{ .Values.backups.volumeSnapshot.labels | toYaml | nindent 6 }}
    annotations: 
      {{ .Values.backups.volumeSnapshot.annotations | toYaml | nindent 6 }}
    className: {{ .Values.backups.volumeSnapshot.className }}
    walClassName: {{ .Values.backups.volumeSnapshot.walClassName }}
    tablespaceClassName: 
      {{ .Values.backups.volumeSnapshot.tablespaceClassName | toYaml | nindent 6 }}
    snapshotOwnerReference: {{ .Values.backups.volumeSnapshot.snapshotOwnerReference }}
    online: {{ .Values.backups.volumeSnapshot.online }}
    onlineConfiguration:
      waitForArchive: {{ .Values.backups.volumeSnapshot.onlineConfiguration.waitForArchive }}
      immediateCheckpoint: {{ .Values.backups.volumeSnapshot.onlineConfiguration.immediateCheckpoint }}
  {{- end }}  
  {{- if eq .Values.backups.method "barmanObjectStore" }}
  barmanObjectStore:
    wal:
      compression: {{ .Values.backups.barmanObjectStore.wal.compression }}
      encryption: {{ .Values.backups.barmanObjectStore.wal.encryption }}
      maxParallel: {{ .Values.backups.barmanObjectStore.wal.maxParallel }}
    data:
      compression: {{ .Values.backups.barmanObjectStore.data.compression }}
      encryption: {{ .Values.backups.barmanObjectStore.data.encryption }}
      jobs: {{ .Values.backups.barmanObjectStore.data.jobs }}
    {{- $d := dict "chartFullname" (include "cluster.fullname" .) "scope" .Values.backups.barmanObjectStore "secretPrefix" "backup" }}
    {{- include "cluster.barmanObjectStoreConfig" $d | nindent 2 }}
  {{- end }}  
{{- end }}
{{- end }}
