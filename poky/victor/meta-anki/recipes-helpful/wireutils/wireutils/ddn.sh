#!/bin/bash

# author: Wire/@kercre123

set -e

if [[ $1 == "off" ]]; then
	curl -X POST -d "func=Set active mode and boot mode to Normal&args=" http://localhost:8888/consolefunccall > /dev/null 2>/dev/null
	echo "Vector go beep boop."
elif [[ $1 == "on" ]]; then
	curl -X POST -d "func=Set active mode and boot mode to DevDoNothing&args=" http://localhost:8888/consolefunccall > /dev/null 2>/dev/null
	echo "Vector is now silenced."
else
	echo "usage: ddn <on/off>"
	echo "This enables/disables DevDoNothing."
fi
