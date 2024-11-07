# ATT Notes

Patch - Disable Local 802.x Enforcement

```sh
[ "$(md5sum /opt/lantiq/bin/omcid | cut -d' ' -f 1)" = "525139425009c4138e92766645dad7d0" ] && printf '\x00' | dd of=/opt/lantiq/bin/omcid conv=notrunc seek=275337 bs=1 count=1 2>/dev/null && echo patched
```

Fix: `boot_fail`

```sh
cat > /etc/init.d/fix_boot_fail.sh <<FILE
#!/bin/sh /etc/rc.common

START=99

start() {
  fw_printenv boot_fail | grep -q '0' || \
    fw_setenv boot_fail '0'
}
FILE

chmod +x /etc/init.d/fix_boot_fail.sh
/etc/init.d/fix_boot_fail.sh enable
```

Fix: some security

```sh
/etc/init.d/telnet disable
```

Find current Image

```sh
grep image /proc/mtd
```

```sh
# mtd5: 00800000 00010000 "image1"
fw_setenv image1_version 'FS v5'
fw_setenv image1_is_valid 1
fw_setenv committed_image 1
```

```sh
# mtd2: 00740000 00010000 "image0"
fw_setenv image0_version 'FS v5'
fw_setenv image0_is_valid 1
fw_setenv committed_image 0
```

Sync SSH Host Keys

```sh
# pull host keys
scp -O root@192.168.1.10:/etc/dropbear/* ./
# restore host keys
scp -O dropbear* root@192.168.1.10:/etc/dropbear/
```

Reboot and repeat 802.x patch above

```sh
SW_VERSION=BGW320_3.20.5
HW_VER=BGW320-505_2.2

fw_setenv target oem-generic
fw_setenv onu_serial "NOKAXXXXXXXX"
fw_setenv omci_vendor_id "NOKA"
fw_setenv omci_equip_id "iONT320505G"
fw_setenv omci_hw_ver "${HW_VER}"
fw_setenv image0_version "${SW_VERSION}"
fw_setenv image1_version "${SW_VERSION}"
```

```sh
SW_VERSION=BGW320_3.20.5
HW_VER=BGW320-500_2.1

fw_setenv target oem-generic
fw_setenv onu_serial "HUMAXXXXXXXX"
fw_setenv omci_vendor_id "HUMA"
fw_setenv omci_equip_id "iONT320505G"
fw_setenv omci_hw_ver "${HW_VER}"
fw_setenv image0_version "${SW_VERSION}"
fw_setenv image1_version "${SW_VERSION}"
```
