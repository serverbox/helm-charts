#!/bin/sh
apk add --no-cache bash python3 curl py3-urllib3 py3-yaml 2>&1 >/dev/null
echo "$(date '+%F %H:%M:%S') Starting Crashloop restarter"
/usr/local/bin/scraper.py
