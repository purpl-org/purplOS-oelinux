DESCRIPTION = "A lightweight package manager for Vector written in Bash"
LICENSE = "CLOSED"

DEPENDS = "bash"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://external/purplpkg"

S = "${UNPACKDIR}/external/purplpkg"

do_compile() {
}

do_install() {
   mkdir -p ${D}/usr/sbin
   cp ${S}/bash/purplpkg.sh ${D}/usr/sbin/purplpkg
   chmod 0755 ${D}/usr/sbin/purplpkg
}

FILES:${PN} += "usr/sbin"
