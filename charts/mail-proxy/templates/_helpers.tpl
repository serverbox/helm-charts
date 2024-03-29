{{/*
Expand the name of the chart.
*/}}
{{- define "mail-proxy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mail-proxy.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mail-proxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mail-proxy.labels" -}}
helm.sh/chart: {{ include "mail-proxy.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "mail-proxy.nginxLabels" -}}
helm.sh/chart: {{ include "mail-proxy.chart" . }}
{{ include "mail-proxy.nginxSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "mail-proxy.phpLabels" -}}
helm.sh/chart: {{ include "mail-proxy.chart" . }}
{{ include "mail-proxy.phpSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mail-proxy.nginxSelectorLabels" -}}
app.kubernetes.io/name: {{ include "mail-proxy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}-nginx
{{- end }}
{{- define "mail-proxy.phpSelectorLabels" -}}
app.kubernetes.io/name: {{ include "mail-proxy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}-php
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "mail-proxy.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mail-proxy.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
