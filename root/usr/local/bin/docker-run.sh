#!/bin/sh
set -e

echo "Starting environment..."
confd -onetime -backend env

mkdir -p /data/state /data/logs

chown -R zpush:zpush /data /opt/zpush

# run application
echo "Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisord.conf
