{{- define "cluster.externalClusters" -}}
externalClusters:
{{- if eq .Values.mode "standalone" }}
{{- else if eq .Values.mode "recovery" }}
  {{- if eq .Values.recovery.method "pg_basebackup" }}
    {{- include "cluster.externalSourceCluster" (list "pgBaseBackupSource" .Values.recovery.pgBaseBackup.source) | nindent 2 }}
  {{- else if eq .Values.recovery.method "import" }}
    {{- include "cluster.externalSourceCluster" (list "importSource" .Values.recovery.import.source) | nindent 2 }}
  {{- else }}
  - name: objectStoreRecoveryCluster
    barmanObjectStore:
      serverName: {{ .Values.recovery.clusterName }}
      {{- $d := dict "chartFullname" (include "cluster.fullname" .) "scope" .Values.recovery "secretPrefix" "recovery" -}}
      {{- include "cluster.barmanObjectStoreConfig" $d | nindent 4 }}
  {{- end }}
{{- else if eq .Values.mode "replica" }}
  - name: originCluster
    {{- if eq .Values.replica.origin.type "object_store" }}
    barmanObjectStore:
      {{- $d := dict "chartFullname" (include "cluster.fullname" .) "scope" .Values.replica.origin.objectStore "secretPrefix" "origin" -}}
      {{- include "cluster.barmanObjectStoreConfig" $d | nindent 4 -}}
    {{- else if eq .Values.replica.origin.type "pg_basebackup" }}
      {{- toYaml .Values.replica.origin.pg_basebackup | nindent 4 }}
    {{- else if eq .Values.replica.origin.type "" }}
      {{ fail "Origin type unspecified!" }}
    {{- else -}}
      {{ fail (printf "Invalid origin type: \"%s\"!" .Values.replica.origin.type) }}
    {{- end }}
{{- else }}
  {{ fail "Invalid cluster mode!" }}
{{- end }}
{{ end }}
