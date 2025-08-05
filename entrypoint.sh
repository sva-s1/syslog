#!/bin/bash
set -euo pipefail

# Log function for consistent output
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Default user/group IDs
USER_ID=${USER_ID:-1000}
GROUP_ID=${GROUP_ID:-1000}

# Validate user/group IDs
[[ "$USER_ID" =~ ^[0-9]+$ ]] || { log "ERROR: USER_ID must be a number"; exit 1; }
[[ "$GROUP_ID" =~ ^[0-9]+$ ]] || { log "ERROR: GROUP_ID must be a number"; exit 1; }

log "Starting syslog-ng container (UID: $USER_ID, GID: $GROUP_ID)"

# Create required directories with correct ownership
for dir in /var/lib/syslog-ng /var/log/syslog-ng /run/syslog-ng /tmp /var/cache/syslog-ng; do
    mkdir -p "$dir"
    chown "$USER_ID:$GROUP_ID" "$dir"
    chmod 750 "$dir"
done
chmod 1777 /tmp  # Sticky bit for /tmp
chmod 640 /etc/syslog-ng/syslog-ng.conf
chown "$USER_ID:$GROUP_ID" /etc/syslog-ng/syslog-ng.conf

# Create group if it doesn't exist
if ! getent group "$GROUP_ID" >/dev/null; then
    groupadd -g "$GROUP_ID" syslogng || { log "ERROR: Failed to create group"; exit 1; }
fi

# Create user if it doesn't exist
if ! getent passwd "$USER_ID" >/dev/null; then
    useradd -u "$USER_ID" -g "$GROUP_ID" -s /bin/false -d /var/lib/syslog-ng syslogng || 
    { log "ERROR: Failed to create user"; exit 1; }
fi

# Verify syslog-ng configuration
log "Verifying configuration..."
if ! gosu "$USER_ID:$GROUP_ID" /usr/sbin/syslog-ng -s -f /etc/syslog-ng/syslog-ng.conf; then
    log "ERROR: Configuration check failed"; exit 1
fi

# Start syslog-ng
log "Starting syslog-ng..."
exec gosu "$USER_ID:$GROUP_ID" /usr/sbin/syslog-ng -F --no-caps -f /etc/syslog-ng/syslog-ng.conf "$@"
