#!/bin/bash

readonly lib=/usr/lib/libeTPkcs11.so

find() {
    echo $(p11tool --list-token-urls --provider $lib | grep eToken)
}

get_object() {
    local token=$(find)
    if [ ! -z "$token" ]; then
        local object=$(p11tool --list-all $token | grep ";type=public" | grep -E -o 'object\=([0-9]+)' | grep -E -o '[0-9]+')
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

    eval $(ssh-agent)
    echo "Add ssh key to ssh-agent..."
    expect -c "
        spawn ssh-add -s $lib
        expect \"Enter passphrase for \"
        send -- \"$TOKEN_PIN\r\"
        interact
    "
    echo "export SSH_AGENT_PID=$SSH_AGENT_PID" >>.bashrc
    echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >>.bashrc
}

main() {
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
}

main $@
