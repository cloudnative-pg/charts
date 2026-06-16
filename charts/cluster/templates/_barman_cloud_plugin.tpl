{{/*
Name of the Barman Cloud Plugin ObjectStore resource.
*/}}
{{- define "cluster.barmanCloudPlugin.objectStoreName" -}}
{{- default (printf "%s-barman-store" (include "cluster.fullname" .)) .Values.barmanCloudPlugin.objectStore.name -}}
{{- end -}}

{{/*
Name of the Secret containing Barman Cloud Plugin object store credentials.
*/}}
{{- define "cluster.barmanCloudPlugin.secretName" -}}
{{- default (printf "%s-barman-s3-creds" (include "cluster.fullname" .)) .Values.barmanCloudPlugin.s3.secret.name -}}
{{- end -}}
