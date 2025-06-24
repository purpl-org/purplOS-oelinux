# purplOS-oelinux

This builds the OS, the /anki programs (`purplOS`), and creates a final OTA. 

## Submodules

- /poky/poky -> [yoctoproject/poky](https://github.com/yoctoproject/poky) (walnascar)
- /poky/meta-openembedded -> [openembedded/meta-openembedded](https://github.com/openembedded/meta-openembedded) (walnascar)
- /anki/victor -> [purplOS](https://github.com/purpl-org/purplOS) (main)
- /anki/wired -> [wired](https://github.com/os-vector/wired) (main)

## Update notes:

- **06-23-25**: Full rebuild required, sorry. The build script will automatically do this.

## Build

- Note: you will need a somewhat beefy **x86_64 Linux** machine with at least 16GB of RAM and 100GB of free space.

1. [Install Docker](https://docs.docker.com/engine/install/), git, and wget.

2. Configure it so a regular user can use it:

```
sudo groupadd docker
sudo gpasswd -a $USER docker
newgrp docker
sudo chown root:docker /var/run/docker.sock
sudo chmod 660 /var/run/docker.sock
```

3. Clone and build:

```
git clone https://github.com/purpl-org/purplOS-oelinux --recurse-submodules
cd purplOS-oelinux
./build/build.sh -bt <dev/oskr> -bp <boot-passwd> -v <build-increment>
# boot password not required for dev
# example: ./build/build.sh -bt dev -v 1
```

### Where is my OTA?

`./_build/0.3.1.1.ota`


## Differences compared to normal Vector FW

-   New OS base
    -   Yocto Walnascar rather than Jethro
        -   glibc 2.41 (latest as of 04-2025)
-   `victor` software compiled with Clang 18.1.8 rather than 5.0.1
-   Rainbow eye color
    -   Can be activated in :8888/demo.html
-   Some Anki-era PRs have been merged
    -   Performances
        -   He will somewhat randomly do loosepixel and binaryeyes
    -   Better camera gamma correction
        -   He handles too-bright situations much better now
-   Picovoice wakeword engine
    -   Custom wake words in :8080 webserver!
-   `htop` and `rsync` are embedded
-   Python 3.13 rather than Python 2
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
-	After a stupid amount of work, I have most HAL programs compiling with Yocto's GCC.
-	This is only for audio and BLE. For camera, I decided to just copy in those binaries (mm-camera recipe).
-	If you want to change the code in mm-anki-camera or mm-qcamera-daemon for whatever reason, you'll have to clone vicos-oelinux-nosign, change the code there, compile it in there, then pack the built binaries into a --bzip2 tar and put it into prebuilt_HY11/mm-camera.
	-	Why am I not having Yocto build them? This is because I would have to add ~2GB of code to the repo, I would have to figure out how to get Qualcomm's ancient "SDLLVM" compiler working, and because the binaries are stable enough.
	-	UPDATE: some BLE binaries are being copied in now, too. explained later

## How this upgrade was done

-	Much work upgrading Yocto recipes.
-	All of the software is compiling with Yocto's GCC 14 or the Clang 18.1.8 vicos-sdk toolchain, with a couple of tiny exceptions.
-	These exceptions include mm-anki-camera, mm-qcamera-daemon, ankibluetoothd, and hci_qcomm_init. They are able to compile under GCC 14, but there's a very low level issue which I haven't been able to figure out as of yet. I am copying prebuilt ones in for now.
-	Some recipes are still somewhat old - these include wpa_supplicant and connman (I had issues with SAE)
