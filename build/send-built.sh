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
ssh -p 23 root@froggitti.net 'touch /wire/otas/dnar && wall Inhibitor added.'
sleep 1s

echo Remove old latest file
ssh -p 23 root@froggitti.net 'rm /wire/otas/latest && wall Latest file removed.'
sleep 1s

echo Make new latest file
ssh -p 23 root@froggitti.net 'touch /wire/otas/latest && wall Latest file created.'
sleep 1s

echo Echo new version number to new latest file
ssh -p 23 root@froggitti.net "echo 0.3.1.$INCREMENT >> /wire/otas/latest && wall Latest file updated."
sleep 1s

echo Copy Dev OTA
scp -P 23 ~/vector/purplOS-oelinux/_build/vicos-0.3.1."$INCREMENT"d.ota root@froggitti.net:/wire/otas/full/dev/0.3.1."$INCREMENT".ota

echo Copy OSKR OTA
scp -P 23 ~/vector/purplOS-oelinux/_build/vicos-0.3.1."$INCREMENT"oskr.ota root@froggitti.net:/wire/otas/full/oskr/0.3.1."$INCREMENT".ota

echo Copy Dev OTA to a never-changing URL
ssh -p 23 root@froggitti.net "cp /wire/otas/full/dev/0.3.1."$INCREMENT".ota /wire/otas/full/latest/dev.ota"
	
echo Copy OSKR OTA to a never-changing URL
ssh -p 23 root@froggitti.net "cp /wire/otas/full/oskr/0.3.1."$INCREMENT".ota /wire/otas/full/latest/oskr.ota"

echo Remove auto update inhibitor
ssh -p 23 root@froggitti.net 'rm /wire/otas/dnar'
sleep 1s

ssh -p 23 root@froggitti.net 'cat /wire/otas/latest'

echo Done.

