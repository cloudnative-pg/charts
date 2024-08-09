{{- define "cluster.bootstrap" -}}
{{- if eq .Values.mode "standalone" }}
bootstrap:
  initdb:
    {{- with .Values.cluster.initdb }}
        {{- with (omit . "postInitApplicationSQL") }}
            {{- . | toYaml | nindent 4 }}
        {{- end }}
    {{- end }}
    postInitApplicationSQL:
      {{- if eq .Values.type "postgis" }}
      - CREATE EXTENSION IF NOT EXISTS postgis;
      - CREATE EXTENSION IF NOT EXISTS postgis_topology;
      - CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
      - CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
      {{- else if eq .Values.type "timescaledb" }}
      - CREATE EXTENSION IF NOT EXISTS timescaledb;
      {{- end }}
      {{- with .Values.cluster.initdb }}
          {{- range .postInitApplicationSQL }}
            {{- printf "- %s" . | nindent 6 }}
          {{- end -}}
      {{- end -}}
{{- else if eq .Values.mode "recovery" -}}
bootstrap:
{{- if eq .Values.recovery.method "pg_basebackup" }}
  pg_basebackup:
    source: {{ .Values.recovery.pgBaseBackup.sourceName }}

externalClusters:
- name: {{ .Values.recovery.pgBaseBackup.sourceName }}
  connectionParameters:
    host: {{ .Values.recovery.pgBaseBackup.sourceHost }}
    user: {{ .Values.recovery.pgBaseBackup.sourceUsername }}
    {{- if .Values.recovery.pgBaseBackup.TLS.enabled }}
    sslmode: verify-full
    {{- end }}
  {{- if or .Values.recovery.pgBaseBackup.sourcePassword .Values.recovery.pgBaseBackup.existingPasswordSecret }}
  password:
    {{- if .Values.recovery.pgBaseBackup.sourcePassword }}
    name: {{ include "cluster.fullname" . }}-source-db-password
    {{- else }}
    name: {{ .Values.recovery.pgBaseBackup.existingPasswordSecret }}
    {{- end }}
    key: password
  {{- else if .Values.recovery.pgBaseBackup.TLS.enabled }}
  sslKey:
    name: {{ .Values.recovery.pgBaseBackup.TLS.sslKey.secretName }}
    key: {{ .Values.recovery.pgBaseBackup.TLS.sslKey.key }}
  sslCert:
    name: {{ .Values.recovery.pgBaseBackup.TLS.sslCert.secretName }}
    key: {{ .Values.recovery.pgBaseBackup.TLS.sslCert.key }}
  sslRootCert:
    name: {{ .Values.recovery.pgBaseBackup.TLS.sslRootCert.secretName }}
    key: {{ .Values.recovery.pgBaseBackup.TLS.sslRootCert.key }}
  {{- else }}
  {{ fail "No password or TLS secret defined for pg_basebackup" }}
  {{- end }}

{{- else }}
  recovery:
    {{- with .Values.recovery.pitrTarget.time }}
    recoveryTarget:
      targetTime: {{ . }}
    {{- end }}
    {{- if eq .Values.recovery.method "backup" }}
    backup:
      name: {{ .Values.recovery.backupName }}
    {{- else if eq .Values.recovery.method "object_store" }}
    source: objectStoreRecoveryCluster
    {{- end }}

externalClusters:
  - name: objectStoreRecoveryCluster
    barmanObjectStore:
      serverName: {{ .Values.recovery.clusterName }}
      {{- $d := dict "chartFullname" (include "cluster.fullname" .) "scope" .Values.recovery "secretSuffix" "-recovery" -}}
      {{- include "cluster.barmanObjectStoreConfig" $d | nindent 4 }}
{{- end }}
{{-  else }}
  {{ fail "Invalid cluster mode!" }}
{{- end }}
{{- end }}
