# ATT Notes

Patch - Disable Local 802.x Enforcement

```sh
[ "$(md5sum /opt/lantiq/bin/omcid | cut -d' ' -f 1)" = "525139425009c4138e92766645dad7d0" ] && printf '\x00' | dd of=/opt/lantiq/bin/omcid conv=notrunc seek=275337 bs=1 count=1 2>/dev/null && echo patched
```

Find current Image

```sh
cat /proc/mtd | grep image
```

```sh
# mtd5: 00800000 00010000 "image1"
fw_setenv image1_version 'FS v5'
fw_setenv image1_is_valid 1
fw_setenv target oem-generic
fw_setenv committed_image 1
```

```sh
# mtd2: 00740000 00010000 "image0"
fw_setenv image0_version 'FS v5'
fw_setenv image0_is_valid 1
fw_setenv target oem-generic
fw_setenv committed_image 0
```

Reboot and repeat patch above

```sh
flash set OMCC_VER 160

flash set GPON_PLOAM_FORMAT 1

flash set GPON_PLOAM_PASSWD 44454641554c54000000

flash set OMCI_OLT_MODE 21

flash set OMCI_FAKE_OK 1

flash set VLAN_CFG_TYPE 1

flash set VLAN_MANU_MODE 0

flash set PON_VENDOR_ID NOKA

flash set GPON_ONU_MODEL iONT320505G

flash set GPON_SN NOKAxxxxxxxx

flash set HW_HWVER BGW320-505_2.2

flash set OMCI_SW_VER1 BGW320_3.20.5

flash set OMCI_SW_VER2 BGW320_3.20.5
```