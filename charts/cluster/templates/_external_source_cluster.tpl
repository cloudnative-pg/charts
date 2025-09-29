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
  {{- if dig "passwordSecret" "name" nil $config  }}
  password:
    name: {{ tpl $config.passwordSecret.name . }}
    key: {{ $config.passwordSecret.key }}
  {{- end }}
  {{- if dig "sslKeySecret" "name" nil $config }}
  sslKey:
    name: {{ $config.sslKeySecret.name }}
    key: {{ $config.sslKeySecret.key }}
  {{- end }}
  {{- if dig "sslCertSecret" "name" nil $config }}
  sslCert:
    name: {{ $config.sslCertSecret.name }}
    key: {{ $config.sslCertSecret.key }}
  {{- end }}
  {{- if dig "sslRootCertSecret" "name" nil $config }}
  sslRootCert:
    name: {{ $config.sslRootCertSecret.name }}
    key: {{ $config.sslRootCertSecret.key }}
  {{- end }}
{{- end }}
