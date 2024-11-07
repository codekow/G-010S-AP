# Backup / Restore Firmware

See [U-Boot Defaults](env-defaults.txt)
See [EEPROM Tech Sheet](https://cdn.hackaday.io/files/21599924091616/AN_2030_DDMI_for_SFP_Rev_E2.pdf)

## Capture Files From Device

`ONTUSER@SFP#`

```sh
ssh ONTUSER@192.168.1.10 # SUGAR2A041
```

```sh
# make backup dir
mkdir /tmp/dump
cd /tmp/dump

# capture state
cat /proc/mtd > mtd
cat /proc/cmdline > cmdline
uname -a > uname
cat /proc/cpuinfo > cpuinfo

# capture configs
fw_printenv > env.txt
grep goi_config env.txt > env.goi_config.txt

ritool dump > ritool.txt
sfp_i2c -r > eeprom.txt
sfp_ddm_tool dumpA0 > /tmp/dumpA0.txt
```

```sh
# save flash
for i in /dev/mtd*ro
do
  cp $i .
done

# hash flash files
md5sum mtd*ro > md5sum
```

Transfer files from device

```sh
mkdir -p dump/
scp -O ONTUSER@192.168.1.10:/tmp/dump/*  dump/ # SUGAR2A041
```

## Restore Firmware

Run TFTP server

```sh
sudo systemctl stop firewalld
sudo dnsmasq \
  -d \
  -i eth0 \
  -a 0.0.0.0 \
  --port=0 \
  --enable-tftp \
  --tftp-root=$(pwd) \
  --tftp-no-fail \
  --tftp-secure \
  --tftp-no-blocksize
```

Default File List

```list
3FE46542AAAA_ri.bin
3FE46542AAAA_a0.bin
3FE46542AAAA_a2.bin
configfs.image
g010sa-squashfs.image
logfs.image
u-boot.env
```

Default Restore Functions

```sh
setenv a0_image '3FE46542AAAA_a0.bin'
setenv a2_image '3FE46542AAAA_a2.bin'
setenv ri_image '3FE46542AAAA_ri.bin'
setenv image_name 'g010sa'

setenv kernel0_offs '0xC0000'
setenv kernel1_offs '0x6C0000'
setenv config_iaddr '0xCC0000'
setenv log_iaddr '0xDC0000'
setenv ri_hiaddr '0xFD0000'
setenv a2_iaddr '0xFE0000'
setenv ri_siaddr '0xFF0000'

setenv update_configfs 'tftpboot ${ram_addr} ${tftppath}configfs.image;sf probe 0;sf erase ${config_iaddr} +${filesize};sf write ${ram_addr} ${config_iaddr} ${filesize}'
setenv update_image0 'tftpboot ${ram_addr} ${tftppath}${image_name}-squashfs.image;sf probe 0;sf erase ${kernel0_offs} +${filesize};sf write ${ram_addr} ${kernel0_offs} ${filesize}'
setenv update_image1 'tftpboot ${ram_addr} ${tftppath}${image_name}-squashfs.image;sf probe 0;sf erase ${kernel1_offs} +${filesize};sf write ${ram_addr} ${kernel1_offs} ${filesize}'
setenv update_logfs 'tftpboot ${ram_addr} ${tftppath}logfs.image;sf probe 0;sf erase ${log_iaddr} +${filesize};sf write ${ram_addr} ${log_iaddr} ${filesize}'
setenv update_ri 'tftpboot ${ram_addr} ${tftppath}${ri_image};sf probe 0;sf erase ${ri_hiaddr} +${filesize};sf write ${ram_addr} ${ri_hiaddr} ${filesize};sf erase ${ri_siaddr} +${filesize};sf write ${ram_addr} ${ri_siaddr} ${filesize}'

setenv load_uboot_env 'tftpboot ${ram_addr} ${tftppath}u-boot.env'
setenv import_uboot_env 'env import -t ${ram_addr} ${filesize}'
setenv update_uboot_env 'run load_uboot_env && run import_uboot_env && saveenv'
```

## Restore From Captured Files

| Offset   | Length   | Description |
|----------|----------|-------------|
| 0x000000 | 0x040000 | uboot       |
| 0x040000 | 0x080000 | uboot_env   |
| 0x0C0000 | 0x600000 | image0      |
| 0x6C0000 | 0x600000 | image1      |
| 0xCC0000 | 0x100000 | configfs    |
| 0xDC0000 | 0x210000 | logfs       |
| 0xFD0000 | 0x010000 | ri          |
| 0xFE0000 | 0x010000 | sfp         |
| 0xFF0000 | 0x010000 | ribackup    |

Set TFTP Path

```sh
setenv tftppath 'dump-3FE46541AADA/'
```

```sh
setenv mtd1 0x040000
setenv mtd2 0x0C0000
setenv mtd3 0x6C0000
setenv mtd6 0xCC0000
setenv mtd7 0xDC0000
setenv mtd8 0xFD0000
setenv mtd9 0xFE0000
setenv mtd10 0xFF0000

setenv ram_addr 80F00000

setenv restore_mtd1 'tftpboot ${ram_addr} ${tftppath}/mtd1ro;sf probe 0;sf erase ${mtd1} +${filesize};sf write ${ram_addr} ${mtd1} ${filesize}'
setenv restore_mtd2 'tftpboot ${ram_addr} ${tftppath}/mtd2ro;sf probe 0;sf erase ${mtd2} +${filesize};sf write ${ram_addr} ${mtd2} ${filesize}'
setenv restore_mtd3 'tftpboot ${ram_addr} ${tftppath}/mtd3ro;sf probe 0;sf erase ${mtd3} +${filesize};sf write ${ram_addr} ${mtd3} ${filesize}'
setenv restore_mtd6 'tftpboot ${ram_addr} ${tftppath}/mtd6ro;sf probe 0;sf erase ${mtd6} +${filesize};sf write ${ram_addr} ${mtd6} ${filesize}'

setenv restore_mtd7 'tftpboot ${ram_addr} ${tftppath}/mtd7ro;sf probe 0;sf erase ${mtd7} +${filesize};sf write ${ram_addr} ${mtd7} ${filesize}'
setenv restore_mtd8 'tftpboot ${ram_addr} ${tftppath}/mtd8ro;sf probe 0;sf erase ${mtd8} +${filesize};sf write ${ram_addr} ${mtd8} ${filesize}'
setenv restore_mtd9 'tftpboot ${ram_addr} ${tftppath}/mtd9ro;sf probe 0;sf erase ${mtd9} +${filesize};sf write ${ram_addr} ${mtd9} ${filesize}'
setenv restore_mtd10 'tftpboot ${ram_addr} ${tftppath}/mtd8ro;sf probe 0;sf erase ${mtd10} +${filesize};sf write ${ram_addr} ${mtd10} ${filesize}'

setenv restore_firmware 'run restore_mtd1 restore_mtd2 restore_mtd3 restore_mtd6 restore_mtd7 restore_mtd8 restore_mtd9 restore_mtd10'

run restore_firmware

reset
```
