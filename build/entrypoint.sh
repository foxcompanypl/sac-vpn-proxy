#!/bin/bash

service pcscd start
/usr/bin/microsocks -i 0.0.0.0 -p 8889 &

if [ -f /root/.ssh/config_template ]; then
    cp /root/.ssh/config_template ~/.ssh/config
fi
chown -R root:root /root/.ssh
chmod -R 600 /root/.ssh/

exec "$@"
