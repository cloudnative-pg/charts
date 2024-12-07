{{- define "cluster.bootstrap" -}}
{{- if eq .Values.mode "standalone" }}
bootstrap:
  initdb:
    {{- with .Values.cluster.initdb }}
        {{- with (omit . "postInitApplicationSQL" "owner") }}
            {{- . | toYaml | nindent 4 }}
        {{- end }}
    {{- end }}
    {{- if .Values.cluster.initdb.owner }}
    owner: {{ tpl .Values.cluster.initdb.owner . }}
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
    source: pgBaseBackupSource
    {{ with .Values.recovery.pgBaseBackup.database }}
    database: {{ . }}
    {{- end }}
    {{ with .Values.recovery.pgBaseBackup.owner }}
    owner: {{ . }}
    {{- end }}
    {{ with .Values.recovery.pgBaseBackup.secret }}
    secret:
      {{- toYaml . | nindent 6 }}
    {{- end }}

externalClusters:
- name: pgBaseBackupSource
  connectionParameters:
    host: {{ .Values.recovery.pgBaseBackup.source.host | quote }}
    port: {{ .Values.recovery.pgBaseBackup.source.port | quote }}
    user: {{ .Values.recovery.pgBaseBackup.source.username | quote }}
    dbname: {{ .Values.recovery.pgBaseBackup.source.database | quote }}
    sslmode: {{ .Values.recovery.pgBaseBackup.source.sslMode | quote }}
  {{- if .Values.recovery.pgBaseBackup.source.passwordSecret.name }}
  password:
    name: {{ default (printf "%s-pg-basebackup-password" (include "cluster.fullname" .)) .Values.recovery.pgBaseBackup.source.passwordSecret.name }}
    key: {{ .Values.recovery.pgBaseBackup.source.passwordSecret.key }}
  {{- end }}
  {{- if .Values.recovery.pgBaseBackup.source.sslKeySecret.name }}
  sslKey:
    name: {{ .Values.recovery.pgBaseBackup.source.sslKeySecret.name }}
    key: {{ .Values.recovery.pgBaseBackup.source.sslKeySecret.key }}
  {{- end }}
  {{- if .Values.recovery.pgBaseBackup.source.sslCertSecret.name }}
  sslCert:
    name: {{ .Values.recovery.pgBaseBackup.source.sslCertSecret.name }}
    key: {{ .Values.recovery.pgBaseBackup.source.sslCertSecret.key }}
  {{- end }}
  {{- if .Values.recovery.pgBaseBackup.source.sslRootCertSecret.name }}
  sslRootCert:
    name: {{ .Values.recovery.pgBaseBackup.source.sslRootCertSecret.name }}
    key: {{ .Values.recovery.pgBaseBackup.source.sslRootCertSecret.key }}
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
      {{- $d := dict "chartFullname" (include "cluster.fullname" .) "scope" .Values.recovery "secretPrefix" "recovery" -}}
      {{- include "cluster.barmanObjectStoreConfig" $d | nindent 4 }}
{{- end }}
{{-  else }}
  {{ fail "Invalid cluster mode!" }}
{{- end }}
{{- end }}
