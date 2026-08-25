{{/*
Helper templates - reusable snippets included elsewhere with `include`.
Keeping names/labels here avoids repeating the same logic in every template file.
*/}}

{{/*
Name of the chart.
*/}}
{{- define "simple-app.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{/*
Standard Kubernetes recommended labels.
*/}}
{{- define "simple-app.labels" -}}
app.kubernetes.io/name: {{ include "simple-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
