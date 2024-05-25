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
      serverName: {{ default (include "cluster.fullname" .) .Values.recovery.clusterName }}
      {{- $d := dict "chartFullname" (include "cluster.fullname" .) "scope" .Values.recovery "secretPrefix" "recovery" -}}
      {{- include "cluster.barmanObjectStoreConfig" $d | nindent 4 }}
{{-  else }}
  {{ fail "Invalid cluster mode!" }}
{{- end }}
{{- end }}
