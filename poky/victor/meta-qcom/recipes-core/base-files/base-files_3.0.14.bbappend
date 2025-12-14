FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}-${PV}:"
DEPENDS = "base-passwd"

SRC_URI:append = "file://fstab \
                  file://profile"

#dirs755:append = " /media/cf /media/net /media/ram \
#            /media/union /media/realroot /media/hdd /media/mmc1"

# userdata mount point is present by default in all machines.
# TODO: Add this path to MACHINE_MNT_POINTS in machine conf.
dirs755:append = " ${userfsdatadir}"

dirs755:append = " ${MACHINE_MNT_POINTS}"

# /systemrw partition is needed only when system is RO.
# Otherwise files can be directly written to / itself.
#dirs755:append = " ${@bb.utils.contains('DISTRO_FEATURES','ro-rootfs','/systemrw','',d)}"
dirs755:append_apq8009 = "/firmware /persist /factory"

# Explicitly remove sepolicy entries from fstab when selinux is not present.
fix_sepolicies () {
    #For /run
    sed -i "s#,rootcontext=system_u:object_r:var_run_t:s0##g" ${WORKDIR}/sources/fstab
    # For /var/volatile
    sed -i "s#,rootcontext=system_u:object_r:var_t:s0##g" ${WORKDIR}/sources/fstab
}
do_install[prefuncs] += " ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '', 'fix_sepolicies', d)}"

# Don't install fstab for systemd targets
do_install:append() {
    # kercre123 - install custom profile
    install -m 0755 ${WORKDIR}/sources/profile ${D}${sysconfdir}/profile

    # Switch-modder - We can't save configs such as neofetch and btop's configs to / because it's set to ro.
    # To get around that we'll symlink the .config folder so that it saves to by default to /data/.config
    mkdir -p ${D}/root/
    ln -s /data/.config ${D}/root/.config

    # kercre123 - we use connman
    #install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
    #ln -s /lib/systemd/system/systemd-resolved.service ${D}${sysconfdir}/systemd/system/dbus-org.freedesktop.resolve1.service
    #ln -s /lib/systemd/system/systemd-resolved.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/systemd-resolved.service
}

do_install:append_sdm845 () {
    install -m 755 -o diag -g diag -d ${D}/mnt/usbstorage0
    install -m 755 -o diag -g diag -d ${D}/mnt/usbstorage1
    install -m 755 -o diag -g diag -d ${D}/mnt/usbstorage2
}

FILES:${PN} += " /etc/systemd/system/dbus-org.freedesktop.resolve1.service /etc/systemd/system/multi-user.target.wants/systemd-resolved.service /root/"
