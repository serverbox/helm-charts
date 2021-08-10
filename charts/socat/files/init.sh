#!/bin/sh
echo "Installing SoCat for port forwarding"
apk add --no-cache socat
echo "Running SoCat"
exec socat TCP-LISTEN:{{ .Values.service.listenPort }},fork TCP:{{ .Values.service.targetHost }}:{{ .Values.service.targetPort }}
