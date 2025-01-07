{{- define "cluster.barmanObjectStoreConfig" -}}

{{- if .scope.endpointURL }}
  endpointURL: {{ .scope.endpointURL | quote }}
{{- end }}

{{- if or (.scope.endpointCA.create) (.scope.endpointCA.name) }}
  endpointCA:
    name: {{.scope.endpointCA.name }}
    key: {{ .scope.endpointCA.key }}
{{- end }}

{{- if .scope.destinationPath }}
  destinationPath: {{ .scope.destinationPath }}
{{- end }}

{{- if eq .scope.provider "s3" }}
  {{- if empty .scope.endpointURL }}
  endpointURL: "https://s3.{{ required "You need to specify S3 region if endpointURL is not specified." .scope.s3.region }}.amazonaws.com"
  {{- end }}
  {{- if empty .scope.destinationPath }}
  destinationPath: "s3://{{ required "You need to specify S3 bucket if destinationPath is not specified." .scope.s3.bucket }}{{ .scope.s3.path }}"
  {{- end }}
  {{- $secretName := coalesce .scope.secret.name (printf "%s-%s-s3-creds" .chartFullname .secretPrefix) }}
  s3Credentials:
    accessKeyId:
      name: {{ $secretName }}
      key: {{ required ".Values.backups.secret.keyNames.accessKey is required, but not specified" .scope.secret.keyNames.accessKey }}
    secretAccessKey:
      name: {{ $secretName }}
      key: {{ required ".Values.backups.secret.keyNames.secretKey is required, but not specified" .scope.secret.keyNames.secretKey }}
{{- else if eq .scope.provider "azure" }}
  {{- if empty .scope.destinationPath }}
  destinationPath: "https://{{ required "You need to specify Azure storageAccount if destinationPath is not specified." .scope.azure.storageAccount }}.{{ .scope.azure.serviceName }}.core.windows.net/{{ .scope.azure.containerName }}{{ .scope.azure.path }}"
  {{- end }}
  {{- $secretName := coalesce .scope.secret.name (printf "%s-%s-azure-creds" .chartFullname .secretPrefix) }}
  azureCredentials:
  {{- if .scope.azure.inheritFromAzureAD }}
    inheritFromAzureAD: true
  {{- else if .scope.azure.connectionString }}
    connectionString:
      name: {{ $secretName }}
      key: {{ required ".Values.backups.secret.keyNames.connectionString is required, but not specified" .scope.secret.keyNames.connectionString }}
  {{- else }}
    storageAccount:
      name: {{ $secretName }}
      key: {{ required ".Values.backups.secret.keyNames.storageAccount is required, but not specified" .scope.secret.keyNames.storageAccount }}
    {{- if .scope.azure.storageKey }}
    storageKey:
      name: {{ $secretName }}
      key: {{ required ".Values.backups.secret.keyNames.storageKey is required, but not specified" .scope.secret.keyNames.storageKey }}
    {{- else }}
    storageSasToken:
      name: {{ $secretName }}
      key: {{ required ".Values.backups.secret.keyNames.storageSasToken is required, but not specified" .scope.secret.keyNames.storageSasToken }}
    {{- end }}
  {{- end }}
{{- else if eq .scope.provider "google" }}
  {{- if empty .scope.destinationPath }}
  destinationPath: "gs://{{ required "You need to specify Google storage bucket if destinationPath is not specified." .scope.google.bucket }}{{ .scope.google.path }}"
  {{- end }}
  {{- $secretName := coalesce .scope.secret.name (printf "%s-%s-google-creds" .chartFullname .secretPrefix) }}
  googleCredentials:
    gkeEnvironment: {{ .scope.google.gkeEnvironment }}
{{- if not .scope.google.gkeEnvironment }}
    applicationCredentials:
      name: {{ $secretName }}
      key: {{ required ".Values.backups.secret.keyNames.applicationCredentials is required, but not specified" .scope.secret.keyNames.applicationCredentials }}
{{- end }}
{{- end -}}
{{- end -}}
