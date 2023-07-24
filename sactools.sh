#/bin/bash

if [ -z "$DISPLAY" ]; then
    echo "DISPLAY is empty!"
    exit 1
fi

docker run \
    --rm \
    --interactive \
    --tty \
    --net host \
    --env DISPLAY=$DISPLAY \
    --device /dev/bus/usb \
    --volume $HOME/.Xauthority:/root/.Xauthority \
    liskeee/sac-vpn-proxy:latest \
    SACTools
