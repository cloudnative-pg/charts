{{- define "cluster.bootstrap" -}}
bootstrap:
{{- if eq .Values.mode "standalone" }}
  initdb:
    {{- with .Values.cluster.initdb }}
        {{- with (omit . "postInitApplicationSQL" "owner" "import") }}
            {{- . | toYaml | nindent 4 }}
        {{- end }}
    {{- end }}
    {{- if .Values.cluster.initdb.owner }}
    owner: {{ tpl .Values.cluster.initdb.owner . }}
    {{- end }}
    {{- if or (eq .Values.type "postgis") (eq .Values.type "timescaledb") (not (empty .Values.cluster.initdb.postInitApplicationSQL)) }}
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
    {{- end }}
{{- else if eq .Values.mode "recovery" -}}
  {{- if eq .Values.recovery.method "pg_basebackup" }}
  pg_basebackup:
    source: pgBaseBackupSource
    {{ with .Values.recovery.pgBaseBackup.database }}
    database: {{ . }}
    {{- end }}
    {{ with .Values.recovery.pgBaseBackup.owner }}
    owner: {{ . }}
    {{- end }}
    {{ with .Values.recovery.pgBaseBackup.secretName }}
    secret:
      name: {{ . }}
    {{- end }}
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
    {{- end }}
  {{- end }}
{{- else if eq .Values.mode "replica" }}
  {{- if eq .Values.replica.bootstrap.source "pg_basebackup" }}
  pg_basebackup:
    source: originCluster
    {{ with .Values.replica.bootstrap.database }}
    database: {{ . }}
    {{- end }}
    {{ with .Values.replica.bootstrap.owner }}
    owner: {{ . }}
    {{- end }}
    {{ with .Values.replica.bootstrap.secret }}
    secret:
      {{- toYaml . | nindent 6 }}
    {{- end }}
  {{- else if eq .Values.replica.bootstrap.source "object_store" }}
  recovery:
    source: originCluster
    {{ with .Values.replica.bootstrap.database }}
    database: {{ . }}
    {{- end }}
    {{ with .Values.replica.bootstrap.owner }}
    owner: {{ . }}
    {{- end }}
    {{ with .Values.replica.bootstrap.secret }}
    secret:
      {{- toYaml . | nindent 6 }}
    {{- end }}
  {{- else }}
    {{ fail "Invalid replica bootstrap mode!" }}
  {{- end }}
{{- else }}
  {{ fail "Invalid cluster mode!" }}
{{- end }}
{{- if eq .Values.mode "replica" }}
replica:
  enabled: true
  source: originCluster
  {{ with .Values.replica.self }}
  self: {{ . }}
  {{- end }}
  {{ with .Values.replica.primary }}
  primary: {{ . }}
  {{- end }}
  {{ with .Values.replica.promotionToken }}
  promotionToken: {{ . }}
  {{- end }}
  {{ with .Values.replica.minApplyDelay }}
  minApplyDelay: {{ . }}
  {{- end }}
{{- end }}
{{- end }}
