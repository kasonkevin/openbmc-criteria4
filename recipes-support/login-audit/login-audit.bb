SUMMARY = "SSH Login Audit Monitor Service"
LICENSE = "CLOSED"

SRC_URI = "file://sshd-log-monitor.sh \
           file://sshd-audit.service \
          "

S = "${UNPACKDIR}"

inherit systemd

# 告訴 Yocto 這個套件包含哪些 systemd 服務
SYSTEMD_SERVICE:${PN} = "sshd-audit.service"
# 設定開機自動啟動
SYSTEMD_AUTO_ENABLE = "enable"

# 依賴 bash 和 systemd
RDEPENDS:${PN} += "bash systemd"

do_install() {
    # 安裝腳本到 /usr/bin/
    install -d ${D}${bindir}
    install -m 0755 ${UNPACKDIR}/sshd-log-monitor.sh ${D}${bindir}/sshd-log-monitor.sh

    # 安裝 service 檔案到 /lib/systemd/system/
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${UNPACKDIR}/sshd-audit.service ${D}${systemd_system_unitdir}/sshd-audit.service
}

FILES:${PN} += "${bindir}/sshd-log-monitor.sh \
                ${systemd_system_unitdir}/sshd-audit.service \
               "
