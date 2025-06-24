#!/bin/bash

VICOS_SDK_VERSION="5.2.1-r06"

set -e

if [[ ! -d poky ]]; then
	if [[ -d ../poky ]]; then
		cd ..
	else
		echo "run this in the correct directory"
		exit 1
	fi
fi

OD="$(pwd)"

if [[ -f old-toolchain/arm/gcc-linaro-4.9-2016.02-manifest.txt ]]; then
	echo "old 4.9 toolchain detected, replacing with 7.5 (this is used for kernel + some specific programs)"
	echo "ankibluetoothd bt-property common btvendorhal configdb dsutils diag fluoride hci-qcomm-init libbt-vendor libhardware qmi qmi-client-helper qmuxd qmi-framework time-genoff xmllib system-core libbase libunwindandroid libutils linux-msm" > wire-cleaning
fi

# if hf compiler, we want to replace with armel
if [[ -d old-toolchain ]]; then
	echo "Old toolchain detected - we have to delete Yocto's ENTIRE build cache."
	echo "Deleting... this will take a while..."
	sudo rm -rf old-toolchain
	sudo rm -rf poky/build/tmp-glibc poky/build/cache poky/build/sstate-cache
fi

cd "$OD"

if [[ -d anki-deps/vicos-sdk/dist/4.0.0-r05/prebuilt ]]; then
	echo "deleting old vicos-sdk clang toolchain..."
	sudo rm -rf anki-deps/vicos-sdk/dist/4.0.0-r05
fi

if [[ ! -d anki-deps/vicos-sdk/dist/${VICOS_SDK_VERSION}/prebuilt ]]; then
	if [[ -d anki-deps ]]; then
		sudo rm -rf anki-deps
	fi
	mkdir -p anki-deps/vicos-sdk/dist/${VICOS_SDK_VERSION}
	cd anki-deps/vicos-sdk/dist/${VICOS_SDK_VERSION}
	wget -q --show-progress https://github.com/os-vector/wire-os-externals/releases/download/${VICOS_SDK_VERSION}/vicos-sdk_${VICOS_SDK_VERSION}_amd64-linux.tar.gz
	tar -zxvf vicos-sdk_${VICOS_SDK_VERSION}_amd64-linux.tar.gz
	rm -f vicos-sdk_${VICOS_SDK_VERSION}_amd64-linux.tar.gz
fi

cd "$OD"

if [[ ! -d anki-deps/wwise ]]; then
	mkdir -p anki-deps/wwise/versions/2017.2.7_a
	cd anki-deps/wwise/versions/2017.2.7_a
	wget -q --show-progress https://github.com/os-vector/wire-os-externals/releases/download/4.0.0-r05/wwise-2017.2.7_a.tar.gz
	tar -zxvf wwise-2017.2.7_a.tar.gz
	rm -f wwise-2017.2.7_a.tar.gz
fi

cd "$OD"
