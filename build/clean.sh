#!/bin/bash

if [[ ! -d poky ]]; then
	if [[ -d ../poky ]]; then
		cd ..
	else
		echo "run this in the correct directory..........."
		exit 1
	fi
fi

DIRPATH="$(pwd)"

#docker build --build-arg DIR_PATH="${DIRPATH}" --build-arg USER_NAME=$(whoami) --build-arg UID=$(id -u $USER) --build-arg GID=$(id -g $USER) -t vic-yocto-builder-2 build/

VARI="perf"

if [[ ${PROD} == "1" ]]; then
	VARI="user"
fi

NO_DOCKER=0

if [[ "$1" == "-nd" ]]; then
	echo "Not running in Docker"
	NO_DOCKER=1
	shift
fi


function run_in_docker() {
	docker run -it --rm \
		-v $(pwd)/anki-deps:${HOME}/.anki \
		-v $(pwd):$(pwd) \
		-v $(pwd)/build/cache:${HOME}/.ccache \
		vic-yocto-builder-7 bash -c "$@"
}

CMDTORUN="cd $(pwd)/poky && source build/conf/set_bb_env.sh && MACHINE=apq8009-robot VARIANT=perf DISTRO=msm-${VARI} PRODUCT=robot bitbake -c cleanall $@"

if [[ "${NO_DOCKER}" == "1" ]]; then
	bash -c "${CMDTORUN}"
else
	run_in_docker "${CMDTORUN}"
fi
