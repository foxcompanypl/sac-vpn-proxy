#!/bin/bash

find() {
    echo $(p11tool --list-token-urls --provider $PKCS11_MODULE_LIB | grep eToken)
}

get_object() {
    local token=$(find)
    if [ ! -z "$token" ]; then
        local object=$(p11tool --list-all $token --provider $PKCS11_MODULE_LIB | grep ";type=public" | grep -E -o 'object\=([0-9]+)' | grep -E -o '[0-9]+')
        echo $object
    else
        echo ""
    fi
}

init_ssh_agent() {
    if [ -z $(find) ]; then
        echo "Token not found!"
        exit 1
    fi
    if [ -z "$SSH_AUTH_SOCK" ]; then
        eval $(ssh-agent)
        echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >>.bashrc
    fi
    echo "Add ssh key to ssh-agent..."
    expect -c "
        spawn ssh-add -s $PKCS11_MODULE_LIB
        expect \"Enter passphrase for \"
        send -- \"$TOKEN_PIN\r\"
        interact
    "
}

case "$1" in
find)
    find
    ;;
object)
    get_object
    ;;
ssh-agent)
    init_ssh_agent
    ;;
*)
    echo "Usage: $0 {find|object|ssh-agent}"
    exit 1
    ;;
esac
