{{- define "cluster.externalSourceCluster" -}}
connectionParameters:
  host: {{ .host | quote }}
  port: {{ .port | quote }}
  user: {{ .username | quote }}
  {{- with .database }}
  dbname: {{ . | quote }}
  {{- end }}
  sslmode: {{ .sslMode | quote }}
{{- if .passwordSecret.name }}
password:
  name: {{ .passwordSecret.name }}
  key: {{ .passwordSecret.key }}
{{- end }}
{{- if .sslKeySecret.name }}
sslKey:
  name: {{ .sslKeySecret.name }}
  key: {{ .sslKeySecret.key }}
{{- end }}
{{- if .sslCertSecret.name }}
sslCert:
  name: {{ .sslCertSecret.name }}
  key: {{ .sslCertSecret.key }}
{{- end }}
{{- if .sslRootCertSecret.name }}
sslRootCert:
  name: {{ .sslRootCertSecret.name }}
  key: {{ .sslRootCertSecret.key }}
{{- end }}
{{- end }}
