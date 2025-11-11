{{- define "cluster.bootstrap" -}}
{{- if eq .Values.mode "standalone" }}
bootstrap:
  initdb:
    {{- with .Values.cluster.initdb }}
        {{- with (omit . "postInitApplicationSQL" "owner" "import") }}
            {{- . | toYaml | nindent 4 }}
        {{- end }}
    {{- end }}
    {{- if .Values.cluster.initdb.owner }}
    owner: {{ tpl .Values.cluster.initdb.owner . }}
    {{- end }}
    {{- if eq .Values.type "documentdb" }}
    # pg_cron extension must be created in postgres database
    # See: https://github.com/citusdata/pg_cron#installing-pg_cron
    postInitSQL:
      - CREATE EXTENSION IF NOT EXISTS pg_cron CASCADE;
    {{- end }}
    {{- if or (eq .Values.type "postgis") (eq .Values.type "timescaledb") (eq .Values.type "documentdb") (not (empty .Values.cluster.initdb.postInitApplicationSQL)) }}
    postInitApplicationSQL:
      {{- if eq .Values.type "postgis" }}
      - CREATE EXTENSION IF NOT EXISTS postgis;
      - CREATE EXTENSION IF NOT EXISTS postgis_topology;
      - CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
      - CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
      {{- else if eq .Values.type "timescaledb" }}
      - CREATE EXTENSION IF NOT EXISTS timescaledb;
      {{- else if eq .Values.type "documentdb" }}
      {{- $owner := .Values.cluster.initdb.owner | default .Values.cluster.initdb.database | default "app" }}
      - CREATE EXTENSION IF NOT EXISTS documentdb CASCADE;
      - GRANT documentdb_admin_role TO {{ $owner }};
      - GRANT USAGE ON SCHEMA documentdb_api TO {{ $owner }};
      - GRANT USAGE ON SCHEMA documentdb_core TO {{ $owner }};
      - GRANT USAGE ON SCHEMA documentdb_api_catalog TO {{ $owner }};
      - GRANT USAGE ON SCHEMA documentdb_api_internal TO {{ $owner }};
      - GRANT USAGE ON SCHEMA documentdb_data TO {{ $owner }};
      - GRANT ALL ON ALL TABLES IN SCHEMA documentdb_api TO {{ $owner }};
      - GRANT ALL ON ALL SEQUENCES IN SCHEMA documentdb_api TO {{ $owner }};
      - GRANT ALL ON ALL TABLES IN SCHEMA documentdb_core TO {{ $owner }};
      - GRANT ALL ON ALL SEQUENCES IN SCHEMA documentdb_core TO {{ $owner }};
      - GRANT ALL ON ALL TABLES IN SCHEMA documentdb_api_catalog TO {{ $owner }};
      - GRANT ALL ON ALL SEQUENCES IN SCHEMA documentdb_api_catalog TO {{ $owner }};
      - GRANT ALL ON ALL TABLES IN SCHEMA documentdb_api_internal TO {{ $owner }};
      - GRANT ALL ON ALL SEQUENCES IN SCHEMA documentdb_api_internal TO {{ $owner }};
      - GRANT ALL ON ALL TABLES IN SCHEMA documentdb_data TO {{ $owner }};
      - GRANT ALL ON ALL SEQUENCES IN SCHEMA documentdb_data TO {{ $owner }};
      - GRANT CREATE ON SCHEMA documentdb_data TO {{ $owner }};
      - ALTER DEFAULT PRIVILEGES IN SCHEMA documentdb_api GRANT ALL ON TABLES TO {{ $owner }};
      - ALTER DEFAULT PRIVILEGES IN SCHEMA documentdb_api GRANT ALL ON SEQUENCES TO {{ $owner }};
      - ALTER DEFAULT PRIVILEGES IN SCHEMA documentdb_core GRANT ALL ON TABLES TO {{ $owner }};
      - ALTER DEFAULT PRIVILEGES IN SCHEMA documentdb_core GRANT ALL ON SEQUENCES TO {{ $owner }};
      - ALTER DEFAULT PRIVILEGES IN SCHEMA documentdb_api_catalog GRANT ALL ON TABLES TO {{ $owner }};
      - ALTER DEFAULT PRIVILEGES IN SCHEMA documentdb_api_catalog GRANT ALL ON SEQUENCES TO {{ $owner }};
      - ALTER DEFAULT PRIVILEGES IN SCHEMA documentdb_api_internal GRANT ALL ON TABLES TO {{ $owner }};
      - ALTER DEFAULT PRIVILEGES IN SCHEMA documentdb_api_internal GRANT ALL ON SEQUENCES TO {{ $owner }};
      - ALTER DEFAULT PRIVILEGES IN SCHEMA documentdb_data GRANT ALL ON TABLES TO {{ $owner }};
      - ALTER DEFAULT PRIVILEGES IN SCHEMA documentdb_data GRANT ALL ON SEQUENCES TO {{ $owner }};
      {{- end }}
      {{- with .Values.cluster.initdb }}
          {{- range .postInitApplicationSQL }}
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
    {{ with .Values.recovery.database }}
    database: {{ . }}
    {{- end }}
    {{ with .Values.recovery.owner }}
    owner: {{ . }}
    {{- end }}
    {{- if eq .Values.recovery.method "backup" }}
    backup:
      name: {{ .Values.recovery.backupName }}
    {{- else if eq .Values.recovery.method "object_store" }}
    source: objectStoreRecoveryCluster

externalClusters:
  - name: objectStoreRecoveryCluster
    barmanObjectStore:
      serverName: {{ .Values.recovery.clusterName }}
      {{- $d := dict "chartFullname" (include "cluster.fullname" .) "scope" .Values.recovery "secretPrefix" "recovery" -}}
      {{- include "cluster.barmanObjectStoreConfig" $d | nindent 4 }}
    {{- end }}
{{- end }}
{{-  else }}
  {{ fail "Invalid cluster mode!" }}
{{- end }}
{{- end }}
