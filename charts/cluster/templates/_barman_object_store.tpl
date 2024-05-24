{{- define "cluster.barmanObjectStoreConfig" -}}

{{- if .scope.endpointURL }}
  endpointURL: {{ .scope.endpointURL }}
{{- end }}

{{- if or (.scope.endpointCA.create) (.scope.endpointCA.name) }}
  endpointCA:
    name: {{ .chartFullname }}-ca-bundle
    key: ca-bundle.crt
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
  s3Credentials:
    accessKeyId:
      name: {{ default (printf "%s-backup-s3%s-creds" .chartFullname (default "" .secretSuffix)) .scope.existingSecret }}
      key: ACCESS_KEY_ID
    secretAccessKey:
      name: {{ default (printf "%s-backup-s3%s-creds" .chartFullname (default "" .secretSuffix)) .scope.existingSecret }}
      key: ACCESS_SECRET_KEY
{{- else if eq .scope.provider "azure" }}
  {{- if empty .scope.destinationPath }}
  destinationPath: "https://{{ required "You need to specify Azure storageAccount if destinationPath is not specified." .scope.azure.storageAccount }}.{{ .scope.azure.serviceName }}.core.windows.net/{{ .scope.azure.containerName }}{{ .scope.azure.path }}"
  {{- end }}
  azureCredentials:
  {{- if .scope.azure.inheritFromAzureAD }}
    inheritFromAzureAD: true
  {{- else if .scope.azure.connectionString }}
    connectionString:
      name: {{ default (printf "%s-backup-azure%s-creds" .chartFullname (default "" .secretSuffix)) .scope.existingSecret }}
      key: AZURE_CONNECTION_STRING
  {{- else }}
    storageAccount:
      name: {{ default (printf "%s-backup-azure%s-creds" .chartFullname (default "" .secretSuffix)) .scope.existingSecret }}
      key: AZURE_STORAGE_ACCOUNT
    {{- if .scope.azure.storageKey }}
    storageKey:
      name: {{ default (printf "%s-backup-azure%s-creds" .chartFullname (default "" .secretSuffix)) .scope.existingSecret }}
      key: AZURE_STORAGE_KEY
    {{- else }}
    storageSasToken:
      name: {{ default (printf "%s-backup-azure%s-creds" .chartFullname (default "" .secretSuffix)) .scope.existingSecret }}
      key: AZURE_STORAGE_SAS_TOKEN
    {{- end }}
  {{- end }}
{{- else if eq .scope.provider "google" }}
  {{- if empty .scope.destinationPath }}
  destinationPath: "gs://{{ required "You need to specify Google storage bucket if destinationPath is not specified." .scope.google.bucket }}{{ .scope.google.path }}"
  {{- end }}
  googleCredentials:
    gkeEnvironment: {{ .scope.google.gkeEnvironment }}
    applicationCredentials:
      name: {{ default (printf "%s-backup-google%s-creds" .chartFullname (default "" .secretSuffix)) .scope.existingSecret }}
      key: APPLICATION_CREDENTIALS
{{- end -}}
{{- end -}}
