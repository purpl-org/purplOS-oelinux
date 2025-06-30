#!/bin/bash

clear

read -p "enter build increment: " inc
export INCREMENT="$inc"

I_AM_THE_CREATOR_AND_WANT_TO_MAKE_THE_BUILD_AUTO_UPDATE=1 ./build/build.sh -bt dev -v "$INCREMENT" -au
I_AM_THE_CREATOR_AND_WANT_TO_MAKE_THE_BUILD_AUTO_UPDATE=1 ./build/build.sh -bt oskr -bp annul-burl-zq-flew-hack-owe-phil-triton-pk -v "$INCREMENT" -au

scp -P 23 -i ~/root_cozmoserver2 "_build/vicos-0.3.1.${INCREMENT}d.ota" root@froggitti.xyz:/wire/otas/full/dev/0.3.1."${INCREMENT}".ota
scp -P 23 -i ~/root_cozmoserver2 "_build/vicos-0.3.1.${INCREMENT}oskr.ota" root@froggitti.xyz:/wire/otas/full/oskr/0.3.1."${INCREMENT}".ota

scp -P 23 -i ~/root_cozmoserver2 "_build/vicos-0.3.1.${INCREMENT}d.ota" root@froggitti.xyz:/wire/otas/full/latest/dev.ota
scp -P 23 -i ~/root_cozmoserver2 "_build/vicos-0.3.1.${INCREMENT}oskr.ota" root@froggitti.xyz:/wire/otas/full/latest/oskr.ota
