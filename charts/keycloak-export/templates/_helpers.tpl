{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "keycloak-export.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "keycloak-export.fullname" -}}
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
{{- define "keycloak-export.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "keycloak-export.labels" -}}
helm.sh/chart: {{ include "keycloak-export.chart" . }}
{{ include "keycloak-export.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "keycloak-export.selectorLabels" -}}
app.kubernetes.io/name: {{ include "keycloak-export.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "keycloak-export.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "keycloak-export.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Create the name for the database secret.
*/}}
{{- define "keycloak-export.dbSecretName" -}}
{{- if .Values.keycloak.persistence.existingSecret -}}
  {{- tpl .Values.keycloak.persistence.existingSecret $ -}}
{{- else -}}
  {{- include "keycloak-export.fullname" . -}}-db
{{- end -}}
{{- end -}}

{{/*
Create the name for the database password secret key - if it is defined.
*/}}
{{- define "keycloak-export.dbUserKey" -}}
{{- if and .Values.keycloak.persistence.existingSecret .Values.keycloak.persistence.existingSecretUsernameKey -}}
  {{- .Values.keycloak.persistence.existingSecretUsernameKey -}}
{{- else -}}
  username
{{- end -}}
{{- end -}}

{{/*
Create the name for the database password secret key.
*/}}
{{- define "keycloak-export.dbPasswordKey" -}}
{{- if and .Values.keycloak.persistence.existingSecret .Values.keycloak.persistence.existingSecretPasswordKey -}}
  {{- .Values.keycloak.persistence.existingSecretPasswordKey -}}
{{- else -}}
  password
{{- end -}}
{{- end -}}


{{/*
Create environment variables for database configuration.
*/}}
{{- define "keycloak-export.dbEnvVars" -}}
{{- if .Values.keycloak.persistence.deployPostgres }}
{{- if not (eq "postgres" .Values.keycloak.persistence.dbVendor) }}
{{ fail (printf "ERROR: 'Setting keycloak.persistence.deployPostgres' to 'true' requires setting 'keycloak.persistence.dbVendor' to 'postgres' (is: '%s')!" .Values.keycloak.persistence.dbVendor) }}
{{- end }}
- name: DB_VENDOR
  value: postgres
- name: DB_ADDR
  value: {{ include "keycloak-export.postgresql.fullname" . }}
- name: DB_PORT
  value: "5432"
- name: DB_DATABASE
  value: {{ .Values.postgresql.postgresqlDatabase | quote }}
- name: DB_USER
  value: {{ .Values.postgresql.postgresqlUsername | quote }}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      key: postgresql-password
{{- else }}
- name: DB_VENDOR
  value: {{ .Values.keycloak.persistence.dbVendor | quote }}
{{- if not (eq "h2" .Values.keycloak.persistence.dbVendor) }}
- name: DB_ADDR
  value: {{ .Values.keycloak.persistence.dbHost | quote }}
- name: DB_PORT
  value: {{ .Values.keycloak.persistence.dbPort | quote }}
- name: DB_DATABASE
  value: {{ .Values.keycloak.persistence.dbName | quote }}
- name: DB_USER
  valueFrom:
    secretKeyRef:
      name: {{ include "keycloak-export.dbSecretName" . }}
      key: {{ include "keycloak-export.dbUserKey" . | quote }}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "keycloak-export.dbSecretName" . }}
      key: {{ include "keycloak-export.dbPasswordKey" . | quote }}
{{- end }}
{{- end }}
{{- end -}}


{{/*
Create a default fully qualified app name for the postgres requirement.
*/}}
{{- define "keycloak-export.postgresql.fullname" -}}
{{- $postgresContext := dict "Values" .Values.postgresql "Release" .Release "Chart" (dict "Name" "postgresql") -}}
{{ include "postgresql.fullname" $postgresContext }}
{{- end -}}
