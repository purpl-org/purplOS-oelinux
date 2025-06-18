#!/bin/bash

clear

read -p "enter build increment: " inc
export INCREMENT="$inc"

./build/build.sh -bt dev -v "$INCREMENT" 
./build/build.sh -bt oskr -bp annul-burl-zq-flew-hack-owe-phil-triton-pk -v "$INCREMENT" 

#scp -P 23 -i ~/root_cozmoserver2 "_build/vicos-0.3.1.${INCREMENT}d.ota" root@froggitti.xyz:/wire/otas/full/dev/0.3.1."${INCREMENT}"d.ota
#scp -P 23 -i ~/root_cozmoserver2 "_build/vicos-0.3.1.${INCREMENT}oskr.ota" root@froggitti.xyz:/wire/otas/full/oskr/0.3.1."${INCREMENT}"oskr.ota
