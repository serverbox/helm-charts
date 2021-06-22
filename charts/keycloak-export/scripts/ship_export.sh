#!/usr/bin/env bash
set -o errexit
set -o nounset

# Logfile for the keycloak export instance
LOGFILE=/shared/standalone.sh.log
# Wait for the export to finish
timeout {{ add 30 .Values.keycloak.export.timeout }}s \
  grep -m 1 "Export finished successfully" <(tail -f ${LOGFILE})

# Run shipping command
{{ .Values.keycloak.shipping.command }}
