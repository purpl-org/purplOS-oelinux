# wire-os

The main repo for WireOS.

WireOS serves as a nice, stable, and maintained base for Vector CFW.

This builds the OS, the /anki programs (`victor`), and creates a final OTA. This repo can be thought of as `wire-os-oelinux`.

## Submodules

- /poky/poky -> [yoctoproject/poky](https://github.com/yoctoproject/poky) (walnascar)
- /poky/meta-openembedded -> [openembedded/meta-openembedded](https://github.com/openembedded/meta-openembedded) (walnascar)
- /anki/victor -> [wire-os-victor](https://github.com/os-vector/wire-os-victor) (main)
- /anki/wired -> [wired](https://github.com/os-vector/wired) (main)

## Update notes:

For those using wire-os as a base for their CFW, I change up recipes from time to time and sometimes you have to clean a couple yourself.

- **06-23-25**: Full rebuild required, sorry. The build script will automatically do this.
- **06-28-25**: `./build/clean.sh "linux-msm"`

## Build

- Note: you will need a somewhat beefy **x86_64 Linux** machine with at least 16GB of RAM and 100GB of free space.

1. [Install Docker](https://docs.docker.com/engine/install/), git, and wget.

2. Configure Docker so a regular user can use it:

```
sudo groupadd docker
sudo gpasswd -a $USER docker
newgrp docker
sudo chown root:docker /var/run/docker.sock
sudo chmod 660 /var/run/docker.sock
```

3. Clone and build:

```
git clone https://github.com/os-vector/wire-os --recurse-submodules
cd wire-os
./build/build.sh -bt <dev/oskr> -bp <boot-passwd> -v <build-increment>
# boot password not required for dev
# example: ./build/build.sh -bt dev -v 1
# <build-increment> is what the last number of the version string will be - if it's 1, it will be 3.0.1.1.ota
```

### Where is my OTA?

`./_build/3.0.1.1.ota`

## Development path

- **Most work should be done in `wire-os-victor`. Generally, that's all you need to have cloned. That can be worked on on a less beefy Linux laptop or M-series MacBook. If you have a modern base WireOS OTA installed; you can clone `wire-os-victor`, make changes, build that standalone, and deploy that to your robot. This repo is more meant to be cloned to a build server, and built less often.**

##  Donate

If you want to :P

[![Buy Me A Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://buymeacoffee.com/kercre123)

## Differences compared to normal Vector FW

-   New OS base
    -   Yocto Walnascar rather than Jethro
        -   glibc 2.41 (latest as of 06-2025)
-   `victor` software compiled with Clang 18.1.8 rather than 5.0.1
-   Rainbow eye color
    -   Can be activated in :8888/demo.html
-   Some Anki-era PRs have been merged
    -   Performances
        -   He will somewhat randomly do loosepixel and binaryeyes
    -   Better camera gamma correction
        -   He handles too-bright situations much better now
-   Picovoice Porcupine (1.5) wakeword engine
    -   Custom wake words in :8080 webserver!
-   `htop` and `rsync` are embedded
-   Python 3.13 rather than Python 2
-   General bug fixes - for instance, now he won't read the EMR partition upon every single screen draw (DDL bug)
-   :8080 webserver for configuring things I don't want to integrate into a normal app
-   Cat and dog detection (basic, similar to Cozmo)
-   Smaller OTA size - a dev OTA is 166M somehow
-   New Anki boot animation, new pre-boot-anim splash screen, rainbow backpack light animations
-   TensorFlow Lite has been updated to v2.19.0 (latest as of 06-2025)
	-  This means we can maybe leverage the GPU delegate at some point
	-  XNNPACK - the CPU delegate - is faster than what was there before
-   OpenCV has been recompiled under Clang 18 - this seems to have made it quite a bit smaller
-   Global SSH key: ([ssh_root_key](https://raw.githubusercontent.com/kercre123/unlocking-vector/refs/heads/main/ssh_root_key))

## Helpful scripts

-	`anki-debug`
	-	If you are debugging `victor` and want to see backtraces in /var/log/messages, run this to enable those.
-	`ddn [on/off]`
	-	Turns on/off DevDoNothing, which makes the bot stand still until shaken.
-	`vmesg [-c|-t] <grep args>`
	-	A wrapper for cat/tail /var/log/messages:

```
usage: vmesg [-t|-c] <grep args>
this is a helper tool for viewing Vector's /var/log/messages
if no grep args are provided, the tailed/whole log will be given
-t = tail (-f), -c = cat
example for searching: vmesg -t -i "tflite\|gpu"
example for whole log: vmesg -c
```

## Proprietary software notes

-	This repo contains lots of proprietary Qualcomm code and prebuilt software.
-	After a stupid amount of work, I have most HAL programs compiling with Yocto's GCC 14. It wasn't terribly difficult since it's generally all autotools, but some jank is still involved, and it was still time-consuming.
-	The camera programs and *some* of the BLE programs are being copied in rather than compiled.
	-	Why not compile camera programs? Because I would have to add 2GB to the repo and figure out how to use the weird Qualcomm-specific toolchain.
	-	Why not compile those BLE programs? `ankibluetoothd` and `hci_qcomm_init` are able to compile under GCC 14, but there is some weird low-level issue which makes them unable to properly communicate with a BLE library. So, for now, I am just copying pre-compiled ones in. I will probably try to fix this at some point.

## How this upgrade was done

-	Much work upgrading Yocto recipes.
-	All of the software is compiling with Yocto's GCC 14 or the Clang 18.1.8 vicos-sdk toolchain, with a couple of tiny exceptions.
-	Some recipes are still somewhat old - these include wpa_supplicant and connman (I had issues with SAE - he's able to recognize SAE networks, but his WLAN driver and kernel don't know how to actually connect to it, and I was unable to disable it in modern wpa_supplicant and connman)
