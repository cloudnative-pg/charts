{{- define "cluster.externalClusters" -}}
{{- if eq .Values.mode "standalone" }}
{{- else }}
{{- if not (and (eq .Values.mode "recovery") (eq .Values.recovery.method "backup")) }}
externalClusters:
{{- end }}
{{- if eq .Values.mode "recovery" }}
  {{- if eq .Values.recovery.method "pg_basebackup" }}
  - name: pgBaseBackupSource
     {{- include "cluster.externalSourceCluster" .Values.recovery.pgBaseBackup.source | nindent 4 }}
  {{- else if eq .Values.recovery.method "import" }}
  - name: importSource
     {{- include "cluster.externalSourceCluster" .Values.recovery.import.source | nindent 4 }}
  {{- else if eq .Values.recovery.method "object_store" }}
  - name: objectStoreRecoveryCluster
    barmanObjectStore:
      serverName: {{ .Values.recovery.clusterName | quote }}
      {{- $d := dict "chartFullname" (include "cluster.fullname" .) "scope" .Values.recovery "secretPrefix" "recovery" -}}
      {{- include "cluster.barmanObjectStoreConfig" $d | trimPrefix "\n" | nindent 4 }}
  {{- else if and (eq .Values.recovery.method "plugin") (eq .Values.recovery.pluginConfiguration.name "barman-cloud.cloudnative-pg.io") }}
  - name: pluginRecoveryCluster
    plugin:
      {{- omit .Values.recovery.pluginConfiguration "parameters" | toYaml | nindent 6 }}
      parameters:
        {{- $pluginConfigurationParameters := omit (coalesce .Values.recovery.pluginConfiguration.parameters dict) "barmanObjectName" "serverName" -}}
        {{- with $pluginConfigurationParameters }}
        {{- toYaml . | nindent 8 -}}
        {{- end }}
        barmanObjectName: {{ include "cluster.fullname" . }}-recovery
        serverName: {{ .Values.recovery.clusterName | quote }}
  {{- end }}
{{- else if eq .Values.mode "replica" }}
  - name: originCluster
  {{- if not (empty .Values.replica.origin.objectStore.provider) }}
    barmanObjectStore:
      serverName: {{ .Values.replica.origin.objectStore.clusterName | quote }}
      {{- $d := dict "chartFullname" (include "cluster.fullname" .) "scope" .Values.replica.origin.objectStore "secretPrefix" "origin" -}}
      {{- include "cluster.barmanObjectStoreConfig" $d | trimPrefix "\n" | nindent 4 -}}
  {{- end }}
  {{- if not (empty .Values.replica.origin.pg_basebackup.host) }}
    {{- include "cluster.externalSourceCluster" .Values.replica.origin.pg_basebackup | nindent 4 }}
  {{- end }}
{{- else }}
  {{ fail "Invalid cluster mode!" }}
{{- end }}
{{- end }}
{{- end }}
