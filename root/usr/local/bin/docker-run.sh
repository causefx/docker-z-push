#!/bin/sh
set -e

echo "Starting environment..."
confd -onetime -backend env

if [ ! -d /data/state ]; then
  mkdir /data/state
fi

chown -R zpush:zpush /data /opt/zpush

# run application
echo "Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisord.conf
