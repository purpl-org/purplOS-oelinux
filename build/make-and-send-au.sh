#!/usr/bin/env bash

# Only to be used by froggitti for purplOS auto-updates

clear

read -p "Enter build increment: " inc
export INCREMENT="$inc"

read -p "Enter path to server root key (required, FrogServer2): " keypath
export KEY_PATH="$keypath"

read -p "Enter OSKR bootloader password: " oskrpass
export OSKR_PASSWORD="$oskrpass"

echo "Building Dev OTA with version 0.3.1.$INCREMENT"
AUTO_UPDATE=1 ./build/build.sh -bt dev -v "$INCREMENT" -au

echo "Building OSKR OTA with version 0.3.1.$INCREMENT"
AUTO_UPDATE=1 ./build/build.sh -bt oskr -bp "$OSKR_PASSWORD" -v "$INCREMENT" -au

echo Remove old latest file
ssh -p 23 -i "$KEY_PATH" root@froggitti.net 'rm /wire/otas/latest'

echo Make new latest file
ssh -p 23 -i "$KEY_PATH" root@froggitti.net 'touch /wire/otas/latest'

echo Echo new version number to new latest file
ssh -p 23 -i "$KEY_PATH" root@froggitti.net "echo 0.3.1.$INCREMENT /wire/otas/latest"

echo Copy Dev OTA
scp -P 23 -i "$KEY_PATH" _build/0.3.1."$INCREMENT"d.ota root@froggitti.net:/wire/otas/full/dev/0.3.1."$INCREMENT".ota

echo Copy OSKR OTA
scp -P 23 -i "$KEY_PATH" _build/0.3.1."$INCREMENT"oskr.ota root@froggitti.net:/wire/otas/full/oskr/0.3.1."$INCREMENT".ota

echo Copy Dev OTA to a never-changing URL
ssh -p 23 -i "$KEY_PATH" "cp /wire/otas/full/dev/0.3.1."$INCREMENT".ota /wire/otas/full/latest/dev.ota"

echo Copy OSKR OTA to a never-changing URL
ssh -p 23 -i "$KEY_PATH" "cp /wire/otas/full/oskr/0.3.1."$INCREMENT".ota /wire/otas/full/latest/oskr.ota"


