#!/usr/bin/env bash
set -o errexit
set -o nounset

# Logfile for the keycloak export instance
LOGFILE=/shared/standalone.sh.log
{{- if  .Values.keycloak.export.preExportCommand }}

# Pre-export command (might refer to another script)
{{ .Values.keycloak.export.preExportCommand }}
{{- end }}

# Start a new keycloak instance with exporting options enabled.
# Use prot offset to prevent port conflicts with the "real" keycloak instance.
{{- $highAvailability := gt (int .Values.keycloak.replicas) 1 -}}
timeout {{ add 30 .Values.keycloak.export.timeout }}s \
    /opt/jboss/tools/docker-entrypoint.sh \
      {{ .Values.keycloak.extraArgs }}{{- if $highAvailability }} -c standalone-ha.xml{{ else }} -c standalone.xml{{ end }} \
        -Djboss.as.management.blocking.timeout={{ .Values.keycloak.export.timeout }} \
        -Djboss.socket.binding.port-offset=100 \
        -Dkeycloak.migration.action=export \
        -Dkeycloak.migration.provider=dir \
        -Dkeycloak.migration.dir={{ .Values.keycloak.export.path }} \
    | tee ${LOGFILE} &

# Grab the keycloak export instance process id
PID="${!}"

# Wait for the export to finish
timeout {{ add 30 .Values.keycloak.export.timeout }}s \
    grep -m 1 "Export finished successfully" <(tail -f ${LOGFILE})

# Stop the keycloak export instance
kill ${PID}
