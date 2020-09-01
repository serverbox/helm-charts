# Keycloak Exporter
Note this is still a work in progress
The task should run via crons and is designed to be extensible

Start pod with 2 containers
- container 1:
  * Runs keycloak with export options. Logs to file
  * Runs monitor to kill keycloak after export or timeout
- container 2:
  * monitors export log
  * Once export is complete uploads dumps


