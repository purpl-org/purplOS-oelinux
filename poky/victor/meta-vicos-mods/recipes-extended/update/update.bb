SUMMARY = "update"
DESCRIPTION = "command that updates vector to the latest purplOS version"
LICENSE = "CLOSED"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI = "file://update.sh"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${UNPACKDIR}/update.sh ${D}${bindir}/update
}

FILES:${PN} = "${bindir}/update"
RDEPENDS:${PN} = "bash"