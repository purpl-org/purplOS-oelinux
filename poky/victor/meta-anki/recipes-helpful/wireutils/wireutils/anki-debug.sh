#!/bin/bash

# author: Wire/@kercre123

set -e

echo "This script gives/takes away debuggerd the ability to backtrace tombstones from the Anki programs, making them appear in logs."
echo "This makes debugging much easier."
echo

function ynFromUser() {
	read -p "(y/n): " yn
        case $yn in
                [Yy]* ) echo "Continuing." ;;
                [Nn]* ) exit 0 ;;
                * ) echo "that is not a y or an n."; exit 1;;
        esac
}

mount -o rw,remount /
cd /lib/systemd/system
if [[ "$(cat vic-engine.service)" == *'#User='* ]]; then
	echo "The Anki programs are currently set to run as root. Would you like to toggle them to run as normal?"
	echo "This DISABLES backtraces."
	echo "(This might cause weird behavior. It is recommended to reinstall the OS if you want to do this.)"
	ynFromUser
        sed -i 's|#User=|User=|g' vic-*.service
	sed -i 's|#Group=|Group=|g' vic-*.service
	sed -i 's|#Umask=|Umask=|g' vic-*.service
else
        echo "The Anki programs are currently set to run as normal. Would you like to toggle them to run as root?"
        echo "This ENABLES backtraces."
        ynFromUser
        sed -i 's|User=|#User=|g' vic-*.service
        sed -i 's|Group=|#Group=|g' vic-*.service
        sed -i 's|Umask=|#Umask=|g' vic-*.service
fi

echo
echo "Stopping anki-robot.target..."
systemctl stop anki-robot.target
sleep 3
echo "Reloading daemons..."
systemctl daemon-reload
echo "Starting anki-robot.target..."
systemctl start anki-robot.target
echo "Done."
