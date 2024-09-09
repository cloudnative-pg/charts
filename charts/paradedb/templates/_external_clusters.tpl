{{- define "cluster.externalClusters" -}}
externalClusters:
{{- if eq .Values.mode "standalone" }}
{{- else if eq .Values.mode "recovery" }}
  {{- if eq .Values.recovery.method "pg_basebackup" }}
  - name: pgBaseBackupSource
     {{- include "cluster.externalSourceCluster" .Values.recovery.pgBaseBackup.source | nindent 4 }}
  {{- else if eq .Values.recovery.method "import" }}
  - name: importSource
     {{- include "cluster.externalSourceCluster" .Values.recovery.import.source | nindent 4 }}
  {{- else if eq .Values.recovery.method "object_store" }}
  - name: objectStoreRecoveryCluster
    barmanObjectStore:
      serverName: {{ .Values.recovery.clusterName }}
      {{- $d := dict "chartFullname" (include "cluster.fullname" .) "scope" .Values.recovery "secretPrefix" "recovery" -}}
      {{- include "cluster.barmanObjectStoreConfig" $d | nindent 4 }}
  {{- end }}
{{- else if eq .Values.mode "replica" }}
  - name: originCluster
  {{- if not (empty .Values.replica.origin.objectStore.provider) }}
    barmanObjectStore:
      serverName: {{ .Values.replica.origin.objectStore.clusterName }}
      {{- $d := dict "chartFullname" (include "cluster.fullname" .) "scope" .Values.replica.origin.objectStore "secretPrefix" "origin" -}}
      {{- include "cluster.barmanObjectStoreConfig" $d | nindent 4 -}}
  {{- end }}
  {{- if not (empty .Values.replica.origin.pg_basebackup.host) }}
    {{- include "cluster.externalSourceCluster" .Values.replica.origin.pg_basebackup | nindent 4 }}
  {{- end }}
{{- else }}
  {{ fail "Invalid cluster mode!" }}
{{- end }}
{{ end }}
