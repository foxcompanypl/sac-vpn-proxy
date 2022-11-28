#!/bin/bash

readonly VENDOR_ID=0x0529
readonly PRODUCT_ID=0x0620

search() {

    local device=$(lsusb -d "$VENDOR_ID:$PRODUCT_ID")
    if [ -z "$device" ]; then
        # If device not found try finding it by vendor id only
        device=$(lsusb -d "$VENDOR_ID:")
    fi
    local bus_path=$(echo "$device" | awk -F'[ :]' '{printf "/dev/bus/usb/%s/%s\n", $2, $4}')
    echo $bus_path
}

main() {
    if [ "$1" = "save" ]; then
        bus_path=$(search)
        sed -i "/^TOKEN_USB_DEVICE=/s/=.*/=$(echo $bus_path | sed 's/\//\\\//g')/" .env
        echo "Saved to .env"
    else
        search
    fi
}

main $@
