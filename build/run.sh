#!/bin/bash

timeout=10
object_id=""

connect() {
    if [ ! -z "$1" ] && [ "$1" -eq 1 ]; then
        OPENCONNECT_OPTIONS+=" --background"
    fi
    echo "$TOKEN_PIN" | exec /usr/sbin/openconnect \
        --no-proxy \
        --certificate "pkcs11:model=eToken;object=$object_id" \
        --passwd-on-stdin \
        $OPENCONNECT_OPTIONS \
        "$VPN_URL"
}

check() {
    if [ -z $(/token.sh find) ]; then
        echo "Token not found!"
        exit 1
    fi
    if [ -z "$TOKEN_PIN" ]; then
        echo "TOKEN_PIN is empty!"
        exit 1
    fi
    if [ -z "$VPN_URL" ]; then
        echo "VPN_URL is empty!"
        exit 1
    fi
    object_id=$(/token.sh object)
    if [ -z "$object_id" ]; then
        echo "Object not found!"
        exit 1
    fi
}

main() {
    echo "Init SSH Agent..."
    /token.sh ssh-agent
    echo "Connect to VPN..."
    if [ -z "$1" ]; then
        until connect; do
            echo "Reconnect in $timeout seconds..."
            sleep $timeout
        done
    else
        connect 1
    fi
}

check
if [ "$1" == "-b" ]; then
    echo "[Background mode]"
    main 1
else
    main
fi
