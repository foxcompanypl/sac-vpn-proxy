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
    if [ ! -z "$SSH_AUTH_SOCK" ]; then
        if [ ! -S "$SSH_AUTH_SOCK" ]; then
            echo "Starting ssh agent..."
            eval $(ssh-agent -s -a $SSH_AUTH_SOCK)
            chmod 777 "$SSH_AUTH_SOCK"
        else
            echo "Using mounted ssh agent..."
        fi
    fi
}

services
ssh_config

exec "$@"
