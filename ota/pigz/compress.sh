#!/bin/bash

if [[ "$(uname -a)" == *"aarch64"* ]]; then
	gzip $@
else
	./pigz/amd64/pigz $@
fi
