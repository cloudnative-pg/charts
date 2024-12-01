{{- define "cluster.bootstrap" -}}
{{- if eq .Values.mode "standalone" }}
bootstrap:
  initdb:
    {{- with .Values.cluster.initdb }}
        {{- with (omit . "postInitSQL" "postInitApplicationSQL" "postInitTemplateSQL" "owner" "import") }}
            {{- . | toYaml | nindent 4 }}
        {{- end }}
    {{- end }}
    {{- if .Values.cluster.initdb.owner }}
    owner: {{ tpl .Values.cluster.initdb.owner . }}
    {{- end }}
    postInitSQL:
      {{- if or (eq .Values.type "paradedb") (eq .Values.type "paradedb-enterprise") }}
      - CREATE EXTENSION IF NOT EXISTS pg_cron;
      {{- end }}
      {{- with .Values.cluster.initdb }}
        {{- range .postInitSQL }}
          {{- printf "- %s" . | nindent 6 }}
        {{- end -}}
      {{- end }}
    {{- if or (eq .Values.type "paradedb") (eq .Values.type "paradedb-enterprise") (not (empty .Values.cluster.initdb.postInitApplicationSQL)) }}
    postInitApplicationSQL:
      {{- if or (eq .Values.type "paradedb") (eq .Values.type "paradedb-enterprise") }}
      - CREATE EXTENSION IF NOT EXISTS pg_search;
      - CREATE EXTENSION IF NOT EXISTS pg_analytics;
      - CREATE EXTENSION IF NOT EXISTS pg_ivm;
      - CREATE EXTENSION IF NOT EXISTS vector;
      - CREATE EXTENSION IF NOT EXISTS postgis;
      - CREATE EXTENSION IF NOT EXISTS postgis_topology;
      - CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
      - CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
      - ALTER DATABASE "{{ default "paradedb" .Values.cluster.initdb.database }}" SET search_path TO public,paradedb;
      {{- end }}
      {{- with .Values.cluster.initdb }}
        {{- range .postInitApplicationSQL }}
          {{- printf "- %s" . | nindent 6 }}
        {{- end -}}
      {{- end -}}
    {{- end }}
    {{- if or (eq .Values.type "paradedb") (eq .Values.type "paradedb-enterprise") (not (empty .Values.cluster.initdb.postInitTemplateSQL)) }}
    postInitTemplateSQL:
      {{- if or (eq .Values.type "paradedb") (eq .Values.type "paradedb-enterprise") }}
      - CREATE EXTENSION IF NOT EXISTS pg_search;
      - CREATE EXTENSION IF NOT EXISTS pg_analytics;
      - CREATE EXTENSION IF NOT EXISTS pg_ivm;
      - CREATE EXTENSION IF NOT EXISTS vector;
      - CREATE EXTENSION IF NOT EXISTS postgis;
      - CREATE EXTENSION IF NOT EXISTS postgis_topology;
      - CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
      - CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
      - ALTER DATABASE template1 SET search_path TO public,paradedb;
      {{- end }}
      {{- with .Values.cluster.initdb }}
        {{- range .postInitTemplateSQL }}
          {{- printf "- %s" . | nindent 6 }}
        {{- end -}}
      {{- end -}}
    {{- end }}
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
  {{- include "cluster.externalSourceCluster" (list "pgBaseBackupSource" .Values.recovery.pgBaseBackup.source) | nindent 2 }}

{{- else if eq .Values.recovery.method "import" }}
  initdb:
    {{- with .Values.cluster.initdb }}
        {{- with (omit . "owner" "import") }}
            {{- . | toYaml | nindent 4 }}
        {{- end }}
    {{- end }}
    {{- if .Values.cluster.initdb.owner }}
    owner: {{ tpl .Values.cluster.initdb.owner . }}
    {{- end }}
    import:
      source:
        externalCluster: importSource
      type: {{ .Values.recovery.import.type }}
      databases: {{ .Values.recovery.import.databases | toJson }}
      {{ with .Values.recovery.import.roles }}
      roles: {{ . | toJson }}
      {{- end }}
      {{ with .Values.recovery.import.postImportApplicationSQL }}
      postImportApplicationSQL:
        {{- . | toYaml | nindent 6 }}
      {{- end }}
      schemaOnly: {{ .Values.recovery.import.schemaOnly }}
      {{ with .Values.recovery.import.pgDumpExtraOptions }}
      pgDumpExtraOptions:
        {{- . | toYaml | nindent 6 }}
      {{- end }}
      {{ with .Values.recovery.import.pgRestoreExtraOptions }}
      pgRestoreExtraOptions:
        {{- . | toYaml | nindent 6 }}
      {{- end }}

externalClusters:
  {{- include "cluster.externalSourceCluster" (list "importSource" .Values.recovery.import.source) | nindent 2 }}

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
