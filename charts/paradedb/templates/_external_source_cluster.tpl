{{- define "cluster.externalSourceCluster" -}}
{{- $name := first . -}}
{{- $config := last . -}}
- name: {{ first . }}
  connectionParameters:
    host: {{ $config.host | quote }}
    port: {{ $config.port | quote }}
    user: {{ $config.username | quote }}
    {{- with $config.database }}
    dbname: {{ . | quote }}
    {{- end }}
    sslmode: {{ $config.sslMode | quote }}
  {{- if $config.passwordSecret.name }}
  password:
    name: {{ $config.passwordSecret.name }}
    key: {{ $config.passwordSecret.key }}
  {{- end }}
  {{- if $config.sslKeySecret.name }}
  sslKey:
    name: {{ $config.sslKeySecret.name }}
    key: {{ $config.sslKeySecret.key }}
  {{- end }}
  {{- if $config.sslCertSecret.name }}
  sslCert:
    name: {{ $config.sslCertSecret.name }}
    key: {{ $config.sslCertSecret.key }}
  {{- end }}
  {{- if $config.sslRootCertSecret.name }}
  sslRootCert:
    name: {{ $config.sslRootCertSecret.name }}
    key: {{ $config.sslRootCertSecret.key }}
  {{- end }}
{{- end }}
