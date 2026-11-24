SUMMARY = "Host Console Pattern Monitoring Service"
LICENSE = "CLOSED"

SRC_URI = "file://host-console-monitor.sh \
           file://host-console-monitor.service \
          "

S = "${UNPACKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "host-console-monitor.service"
SYSTEMD_AUTO_ENABLE = "enable"

RDEPENDS:${PN} += "bash systemd"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${UNPACKDIR}/host-console-monitor.sh ${D}${bindir}/host-console-monitor.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${UNPACKDIR}/host-console-monitor.service ${D}${systemd_system_unitdir}/host-console-monitor.service
}

FILES:${PN} += "${bindir}/host-console-monitor.sh \
                ${systemd_system_unitdir}/host-console-monitor.service \
               "
