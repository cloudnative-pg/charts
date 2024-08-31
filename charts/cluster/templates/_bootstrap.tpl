{{- define "cluster.bootstrap" -}}
{{- if eq .Values.mode "standalone" }}
bootstrap:
  initdb:
    {{- with .Values.cluster.initdb }}
        {{- with (omit . "postInitApplicationSQL") }}
            {{- toYaml . | nindent 4 }}
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
          {{- end }}
      {{- end }}
{{- else if (eq (include "cluster.recovery.enabled" .) "true") }}
bootstrap:
  {{- if (eq (include "cluster.import.enabled" .) "true") }}
  initdb:
    {{- if and (eq (include "cluster.import.type.microservice.enabled" .) "true") }}
    {{- with .Values.import.typeSettings.microservice.owner }}
    owner: {{ . }}
    {{- end }}
    {{- end }}
    import:
      {{- if (eq (include "cluster.import.type.microservice.enabled" .) "true") }}
      type: microservice
      databases:
        - {{ .Values.import.typeSettings.microservice.database }}
      {{- with .Values.import.typeSettings.microservice.postImportApplicationSQL }}
      postImportApplicationSQL:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- else if (eq (include "cluster.import.type.monolith.enabled" .) "true") }}
      type: monolith
      {{- with .Values.import.typeSettings.monolith.databases }}
      databases:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.import.typeSettings.monolith.roles }}
      roles:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- end }}
      source:
        externalCluster: pgBasebackupRecoveryCluster
  {{- else if eq .Values.recovery.method "pgBasebackup" }}
  pg_basebackup:
    source: pgBasebackupRecoveryCluster
  {{- if and (eq .Values.mode "recovery") (not (empty .Values.recovery.methodSettings.pgBasebackup.database)) }}
    {{- with .Values.recovery.methodSettings.pgBasebackup.database }}
    database: {{ . }}
    {{- end }}
    {{- with .Values.recovery.methodSettings.pgBasebackup.owner }}
    owner: {{ . }}
    {{- end }}
    {{- with .Values.recovery.methodSettings.pgBasebackup.ownerSecret }}
    secret:
      name: {{ . }}
    {{- end }}
  {{- end }}
  {{- else }}
  recovery:
    {{- if and (eq .Values.mode "recovery") (has .Values.recovery.method (list "backup" "objectStorage" "volumeSnapshot")) }}
    {{- with .Values.recovery.pitrTarget.time }}
    recoveryTarget:
      targetTime: {{ . }}
    {{- end }}
    {{- end }}
    {{- if eq .Values.recovery.method "backup" }}
    backup:
      name: {{ required ".Values.recovery.methodSettings.backup.name is required, but not specified." .Values.recovery.methodSettings.backup.name }}
    {{- else if eq .Values.recovery.method "objectStorage" }}
    source: objectStoreRecoveryCluster
    {{- else if eq .Values.recovery.method "volumeSnapshot" }}
    source: volumeSnapshotRecoveryCluster
    volumeSnapshots:
      storage:
        apiGroup: snapshot.storage.k8s.io
        kind: VolumeSnapshot
        name: {{ required ".Values.recovery.methodSettings.volumeSnapshot.storageSnapshotName is required, but not specified." .Values.recovery.methodSettings.volumeSnapshot.storageSnapshotName }}
      {{- with .Values.recovery.methodSettings.volumeSnapshot.walSnapshotName }}
      walStorage:
        apiGroup: snapshot.storage.k8s.io
        kind: VolumeSnapshot
        name: {{ . }}
      {{- end }}
    {{- end }}
  {{- end }}
{{ if (eq (include "cluster.replica.enabled" .) "true") }}
replica:
  {{- if (eq (include "cluster.replica.topology.standalone.enabled" .) "true") }}
  enabled: true
  {{- if not (empty .Values.replica.topologySettings.minApplyDelay) }}
  minApplyDelay: {{ .Values.replica.topologySettings.minApplyDelay }}
  {{- end }}
  {{- else if (eq (include "cluster.replica.topology.distributed.enabled" .) "true") }}
  {{- if .Values.replica.topologySettings.distributed.primary }}
  primary: {{ include "cluster.fullname" . }}
  {{- else }}
  primary: {{ include "cluster.replica.source" . }}
  {{- end }}
  {{- end }}
  source: {{ include "cluster.replica.source" . }}
{{- end }}
{{ if eq .Values.recovery.method "objectStorage" }}
externalClusters:
{{- if eq .Values.replica.topology "distributed" }}
  - name: {{ include "cluster.fullname" . }}
    barmanObjectStore:
      serverName: {{ include "cluster.fullname" . }}
      {{- $d := dict "chartFullname" (include "cluster.fullname" .) "scope" .Values.backups.objectStorage "secretPrefix" "backup" "existingSecret" .Values.backups.existingSecret }}
      {{- include "cluster.barmanObjectStoreConfig" $d | nindent 4 }}
{{- end }}
  - name: objectStoreRecoveryCluster
    barmanObjectStore:
      serverName: {{ default (include "cluster.fullname" .) .Values.recovery.methodSettings.objectStorage.clusterName }}
      {{- $d := dict "chartFullname" (include "cluster.fullname" .) "scope" .Values.recovery.methodSettings.objectStorage "secretPrefix" "recovery" "existingSecret" .Values.recovery.existingSecret }}
      {{- include "cluster.barmanObjectStoreConfig" $d | nindent 4 }}
{{- else if eq .Values.recovery.method "pgBasebackup" }}
externalClusters:
  - name: pgBasebackupRecoveryCluster
    connectionParameters:
      host: {{ required ".Values.recovery.methodSettings.pgBasebackup.connectionParameters.host is required, but not specified." .Values.recovery.methodSettings.pgBasebackup.connectionParameters.host }}
      port: {{ required ".Values.recovery.methodSettings.pgBasebackup.connectionParameters.port is required, but not specified." (.Values.recovery.methodSettings.pgBasebackup.connectionParameters.port | quote) }}
      user: {{ required ".Values.recovery.methodSettings.pgBasebackup.connectionParameters.user is required, but not specified." .Values.recovery.methodSettings.pgBasebackup.connectionParameters.user }}
      {{- with .Values.recovery.methodSettings.pgBasebackup.connectionParameters.sslMode }}
      sslmode: {{ . }}
      {{- end }}
      {{- if and (eq .Values.mode "recovery") (not (empty .Values.recovery.methodSettings.pgBasebackup.database)) }}
      dbname: {{ default .Values.recovery.methodSettings.pgBasebackup.database .Values.recovery.methodSettings.pgBasebackup.connectionParameters.database }}
      {{- else if or (eq .Values.mode "replica") (eq .Values.mode "import") }}
      dbname: postgres
      {{- end }}
  {{- $secretName := coalesce .Values.recovery.existingSecret.name (printf "%s-recovery-pgbb-creds" (include "cluster.fullname" .)) }}
  {{- if eq .Values.recovery.methodSettings.auth "password" }}
  password:
    {{- if .Values.recovery.methodSettings.pgBasebackup.sourcePassword }}
    name: {{ printf $secretName }}
    {{- end }}
    key: password
  {{- else if eq .Values.recovery.methodSettings.auth "tls" }}
  sslKey:
    name: {{ printf $secretName }}
    key: tls.key
  sslCert:
    name: {{ printf $secretName }}
    key: tls.crt
  sslRootCert:
    name: {{ printf $secretName }}
    key: ca.crt
  {{- end }}
{{- end }}
{{- else }}
  {{- fail "Invalid cluster mode!" }}
{{- end }}
{{- end -}}
