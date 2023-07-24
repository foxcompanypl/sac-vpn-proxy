#!/bin/bash

timeout=10
object_id=""

connect_with_token() {
    echo "$TOKEN_PIN" | exec /usr/sbin/openconnect \
        --timestamp \
        --certificate "pkcs11:model=eToken;object=$object_id" \
        --passwd-on-stdin \
        $OPENCONNECT_OPTIONS \
        "$VPN_URL"
}

connect_with_sms() {
    expect -c "
        spawn openconnect --timestamp --user $VPN_USER $OPENCONNECT_OPTIONS $VPN_URL
        expect \"GROUP:\"
        send -- \"SMS\r\"
        expect \"Password:\"
        send -- \"$VPN_PASSWORD\r\"
        interact
    "
}

connect() {
    case "$AUTH_MODE" in
    token)
        connect_with_token
        ;;
    sms)
        connect_with_sms
        ;;
    *)
        echo "Unknown auth mode: $AUTH_MODE"
        exit 1
        ;;
    esac
}

check_token() {
    if [ -z $(/token.sh find) ]; then
        echo "Token not found!"
        exit 1
    fi
    if [ -z "$TOKEN_PIN" ]; then
        echo "TOKEN_PIN is empty!"
        exit 1
    fi
    object_id=$(/token.sh object)
    if [ -z "$object_id" ]; then
        echo "Object not found!"
        exit 1
    fi
    echo "Init SSH Agent..."
    /token.sh ssh-agent
}

check_sms() {
    if [ -z "$VPN_USER" ]; then
        echo "VPN_USER is empty!"
        exit 1
    fi
    if [ -z "$VPN_PASSWORD" ]; then
        echo "VPN_PASSWORD is empty!"
        exit 1
    fi
}

check() {
    if [ -z "$VPN_URL" ]; then
        echo "VPN_URL is empty!"
        exit 1
    fi
    if [ "$AUTH_MODE" == "token" ]; then
        check_token
    elif [ "$AUTH_MODE" == "sms" ]; then
        check_sms
    else
        echo "Unknown auth mode: $AUTH_MODE"
        exit 1
    fi
}

check
echo "Connect to VPN..."
connect
