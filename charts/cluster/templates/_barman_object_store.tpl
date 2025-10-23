{{- define "cluster.barmanObjectStoreConfig" -}}

{{- if .scope.endpointURL }}
  endpointURL: {{ include "tpl" (dict "value" .scope.endpointURL "context" .context) | quote }}
{{- end }}

{{- if or (.scope.endpointCA.create) (.scope.endpointCA.name) }}
  endpointCA:
    name: {{ include "tpl" (dict "value" .scope.endpointCA.name "context" .context) }}
    key: {{ .scope.endpointCA.key }}
{{- end }}

{{- if .scope.destinationPath }}
  destinationPath: {{ include "tpl" (dict "value" .scope.destinationPath "context" .context) | quote }}
{{- end }}

{{- if eq .scope.provider "s3" }}
  {{- if empty .scope.endpointURL }}
  {{- $region := include "tpl" (dict "value" (required "You need to specify S3 region if endpointURL is not specified." .scope.s3.region) "context" .context) }}
  endpointURL: {{ printf "https://s3.%s.amazonaws.com" $region | quote }}
  {{- end }}
  {{- if empty .scope.destinationPath }}
  {{- $bucket := include "tpl" (dict "value" (required "You need to specify S3 bucket if destinationPath is not specified." .scope.s3.bucket) "context" .context) }}
  {{- $path := include "tpl" (dict "value" .scope.s3.path "context" .context) }}
  destinationPath: {{ printf "s3://%s%s" $bucket $path | quote }}
  {{- end }}
  {{- $secretName := coalesce .scope.secret.name (printf "%s-%s-s3-creds" .chartFullname .secretPrefix) }}
  s3Credentials:
  {{- if .scope.s3.inheritFromIAMRole }}
    inheritFromIAMRole: true
  {{- else }}
    accessKeyId:
      name: {{ include "tpl" (dict "value" $secretName "context" .context) }}
      key: ACCESS_KEY_ID
    secretAccessKey:
      name: {{ include "tpl" (dict "value" $secretName "context" .context) }}
      key: ACCESS_SECRET_KEY
  {{- end }}
{{- else if eq .scope.provider "azure" }}
  
  {{- if empty .scope.destinationPath }}
  {{- $storageAccount := include "tpl" (dict "value" (required "You need to specify Azure storageAccount if destinationPath is not specified." .scope.azure.storageAccount) "context" .context) }}
  {{- $containerName := include "tpl" (dict "value" .scope.azure.containerName "context" .context) }}
  destinationPath: {{ printf "https://%s.%s.core.windows.net/%s%s" $storageAccount .scope.azure.serviceName $containerName .scope.azure.path | quote }}
  {{- end }}
  {{- $secretName := coalesce .scope.secret.name (printf "%s-%s-azure-creds" .chartFullname .secretPrefix) }}
  azureCredentials:
  {{- if .scope.azure.inheritFromAzureAD }}
    inheritFromAzureAD: true
  {{- else if .scope.azure.connectionString }}
    connectionString:
      name: {{ include "tpl" (dict "value" $secretName "context" .context) }}
      key: AZURE_CONNECTION_STRING
  {{- else }}
    storageAccount:
      name: {{ include "tpl" (dict "value" $secretName "context" .context) }}
      key: AZURE_STORAGE_ACCOUNT
    {{- if .scope.azure.storageKey }}
    storageKey:
      name: {{ include "tpl" (dict "value" $secretName "context" .context) }}
      key: AZURE_STORAGE_KEY
    {{- else }}
    storageSasToken:
      name: {{ include "tpl" (dict "value" $secretName "context" .context) }}
      key: AZURE_STORAGE_SAS_TOKEN
    {{- end }}
  {{- end }}
{{- else if eq .scope.provider "google" }}
  {{- if empty .scope.destinationPath }}
  {{- $bucket := include "tpl" (dict "value" (required "You need to specify Google storage bucket if destinationPath is not specified." .scope.google.bucket) "context" .context) }}
  destinationPath: {{ printf "gs://%s%s" $bucket .scope.google.path | quote }}
  {{- end }}
  {{- $secretName := coalesce .scope.secret.name (printf "%s-%s-google-creds" .chartFullname .secretPrefix) }}
  googleCredentials:
    gkeEnvironment: {{ .scope.google.gkeEnvironment }}
{{- if not .scope.google.gkeEnvironment }}
    applicationCredentials:
      name: {{ include "tpl" (dict "value" $secretName "context" .context) }}
      key: APPLICATION_CREDENTIALS
{{- end }}
{{- end -}}
{{- end -}}
