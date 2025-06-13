SUMMARY = "wireutils: simple scripts for debugging"
DESCRIPTION = "installs a couple helpful scripts for dealing with vector"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = " \
    file://anki-debug.sh \
    file://ddn.sh \
    file://vmesg.sh \
"

S = "${WORKDIR}/sources"
UNPACKDIR = "${S}"

do_install() {
    install -d ${D}${sbindir}

    install -m 0755 ${S}/anki-debug.sh  ${D}${sbindir}/anki-debug
    install -m 0755 ${S}/ddn.sh         ${D}${sbindir}/ddn
    install -m 0755 ${S}/vmesg.sh	${D}${sbindir}/vmesg
}

FILES:${PN} = "${sbindir}/ddn \
               ${sbindir}/anki-debug \
               ${sbindir}/vmesg"

RDEPENDS:${PN} = "bash"
