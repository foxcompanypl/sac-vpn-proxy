#!/bin/bash

get_object() {
    local token=$(p11tool --list-token-urls | grep eToken)
    local object=$(p11tool --list-all $token | grep ";type=public" | grep -E -o 'object\=([0-9]+)' | grep -E -o '[0-9]+')
    echo $object
}

ssh_agent() {
    eval $(ssh-agent)
    echo "Add ssh key to ssh-agent..."
    expect -c "
        spawn ssh-add -s /usr/lib/libeTPkcs11.so
        expect \"Enter passphrase for \"
        send -- \"$TOKEN_PIN\r\"
        interact
    "
    echo "export SSH_AGENT_PID=$SSH_AGENT_PID" >>.bashrc
    echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >>.bashrc
}

connect() {
    object_id=$(get_object)
    echo "$TOKEN_PIN" | openconnect \
        --no-proxy \
        --certificate "pkcs11:model=eToken;object=$object_id" \
        --passwd-on-stdin \
        "$VPN_URL"
}

echo "Init SSH Agent..."
ssh_agent
until (connect); do
    echo "Connection failed. Reconnecting in 5 seconds..."
    sleep 5
done
