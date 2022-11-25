#!/bin/bash

timeout=10
object_id=""

connect() {
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
    until (connect); do
        echo "Connection failed. Reconnecting in $timeout seconds..."
        sleep $timeout
    done
}

check
main
