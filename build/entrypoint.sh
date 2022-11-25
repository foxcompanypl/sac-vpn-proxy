#!/bin/bash

services() {
    echo "Starting services..."
    service pcscd start
    /usr/bin/microsocks -i 0.0.0.0 -p 8889 &
}

ssh_config() {
    echo "Configuring SSH..."
    if [ -f /root/.ssh/config_template ]; then
        envsubst </root/.ssh/config_template >/root/.ssh/config
    fi
    chown -R root:root /root/.ssh
    chmod -R 600 /root/.ssh/
}

services
ssh_config

exec "$@"
