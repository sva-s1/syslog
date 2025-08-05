#!/bin/sh
set -eu

# Template and output paths
TEMPLATE=/etc/syslog-ng/syslog-ng.conf.tmpl
RENDERED=/etc/syslog-ng/syslog-ng.conf

# Substitute only specific environment variables in the template
envsubst '$S1_HEC_URL $S1_HEC_WRITE_TOKEN' < "$TEMPLATE" > "$RENDERED"

# Validate the configuration
/usr/sbin/syslog-ng -s -f "$RENDERED"

# Execute syslog-ng with the rendered config
exec "$@" -f "$RENDERED"
