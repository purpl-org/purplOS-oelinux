#!/usr/bin/env bash

# Only to be used by froggitti for purplOS auto-updates

clear

read -p "Enter build increment: " inc
export INCREMENT="$inc"

read -p "Enter path to server root key (required, FrogServer2): " keypath
export KEY_PATH="$keypath"

eval `ssh-agent`

ssh-add "$KEY_PATH"

echo Touch auto update inhibitor
ssh  root@websetup.froggitti.net 'touch /servers/drive2/froggitti-net/ota-purpl.skittl.net/otas/dnar'
sleep 1s

echo Remove old latest file
ssh  root@websetup.froggitti.net 'rm /servers/drive2/froggitti-net/ota-purpl.skittl.net/otas/latest'
sleep 1s

echo Make new latest file
ssh  root@websetup.froggitti.net 'touch /servers/drive2/froggitti-net/ota-purpl.skittl.net/otas/latest'
sleep 1s

echo Echo new version number to new latest file
ssh  root@websetup.froggitti.net "echo 0.3.3.$INCREMENT > /servers/drive2/froggitti-net/ota-purpl.skittl.net/otas/latest"
sleep 1s

echo Copy Dev OTA
scp  _build/vicos-0.3.3."$INCREMENT"d.ota root@websetup.froggitti.net:/servers/drive2/froggitti-net/v.skittl.net/site/firmware/purplOS\ DEV/0.3.3."$INCREMENT".ota

echo Copy OSKR OTA
scp  _build/vicos-0.3.3."$INCREMENT"oskr.ota root@websetup.froggitti.net:/servers/drive2/froggitti-net/v.skittl.net/site/firmware/purplOS\ OSKR/0.3.3."$INCREMENT".ota

#echo Copy Dev OTA to a never-changing URL
#ssh  root@websetup.froggitti.net "cp /servers/drive2/froggitti-net/v.skittl.net/site/firmware/purplOS\ DEV//0.3.3."$INCREMENT".ota /servers/drive2/froggitti-net/ota-purpl.skittl.net/otas/full/latest/dev.ota"

#echo Copy OSKR OTA to a never-changing URL
#ssh  root@websetup.froggitti.net "cp /servers/drive2/froggitti-net/ota-purpl.skittl.net/otas/full/oskr/0.3.3."$INCREMENT".ota /servers/drive2/froggitti-net/ota-purpl.skittl.net/otas/full/latest/oskr.ota"

echo Remove auto update inhibitor
ssh  root@websetup.froggitti.net 'rm /servers/drive2/froggitti-net/ota-purpl.skittl.net/otas/dnar'
sleep 1s

echo Done.
