{{- with .Values.mail.sql }}
<?php
// 'host' for the PostgreSQL server
$sqlConf->host      = {{ .host | quote }};

// default port for PostgreSQL is "5432"
$sqlConf->port      = {{ .port | quote }};

// set the database name for the connection
$sqlConf->dbname    = {{ .db | quote }};

// set the username for PostgreSQL database
$sqlConf->user      = {{ .user | quote }};

// password for the PostgreSQL database
$sqlConf->password  = {{ .pass | quote }};

$mail_server_ip     = {{ $.Values.mail.mailhost | quote }};
?>
{{- end }}
