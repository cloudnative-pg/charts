{{- define "cluster.externalSourceCluster" -}}
{{- $name := first . -}}
{{- $config := last . -}}
- name: {{ first . }}
  connectionParameters:
    host: {{ include "tpl" (dict "value" $config.host "context" $) | quote }}
    port: {{ include "tpl" (dict "value" $config.port "context" $) | quote }}
    user: {{ include "tpl" (dict "value" $config.username "context" $) | quote }}
    {{- with $config.database }}
    dbname: {{ include "tpl" (dict "value" . "context" $) | quote }}
    {{- end }}
    sslmode: {{ include "tpl" (dict "value" $config.sslMode "context" $) | quote }}
  {{- if $config.passwordSecret.name }}
  password:
    name: {{ include "tpl" (dict "value" $config.passwordSecret.name "context" $) }}
    key: {{ $config.passwordSecret.key }}
  {{- end }}
  {{- if $config.sslKeySecret.name }}
  sslKey:
    name: {{ include "tpl" (dict "value" $config.sslKeySecret.name "context" $) }}
    key: {{ $config.sslKeySecret.key }}
  {{- end }}
  {{- if $config.sslCertSecret.name }}
  sslCert:
    name: {{ include "tpl" (dict "value" $config.sslCertSecret.name "context" $) }}
    key: {{ $config.sslCertSecret.key }}
  {{- end }}
  {{- if $config.sslRootCertSecret.name }}
  sslRootCert:
    name: {{ include "tpl" (dict "value" $config.sslRootCertSecret.name "context" $) }}
    key: {{ $config.sslRootCertSecret.key }}
  {{- end }}
{{- end }}
