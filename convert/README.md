# Convert G-010S-A to G-010S-P

## Links

- https://hack-gpon.org/ont-huawei-ma5671a/#list-of-firmwares-and-files

## Download firmware

FS Modded Firmware for Huawei MA5671A and FS.com GPON-ONU-34-20BI

- https://hack-gpon.org/ont-huawei-ma5671a-fs-mod/

```sh
md5sum convert-G-010S-P/6BA1896SPLQA42_MODDED_ver5-1.img
# md5hash: c4f1bbe1695803d3d449f911f43d78ea

crc32 convert-G-010S-P/6BA1896SPLQA42_MODDED_ver5-1.img
# output: 58736C78
```

Carlito

- https://hack-gpon.org/ont-huawei-ma5671a-carlito/
- https://hack-gpon.org/ont-huawei-ma5671a/#list-of-firmwares-and-files

```sh
md5sum convert-G-010S-P/mtd2
# md5hash: d3cb6f7efec201b37931139feb4bb23b

crc32 convert-G-010S-P/mtd2
# output: 03071158
```

## Load firmware into uboot

### Load carlito via XMODEM (serial)

```sh
# load mtd2 into memory
loadx 0x82F00000
# start XMODEM transfer

# check memory
crc32 0x82F00000 0x00740000
# CRC32 for 82f00000 ... 8363ffff ==> 03071158
# If this doesn't match, DO NOT continue!
```

### Load ver FS Modded v5.1 via tftp

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

Start netconsole

```sh
killall nc
./netconsole 192.168.1.10
```

```sh
# load mtd2 into memory
tftpboot 0x82F00000 convert-G-010S-P/6BA1896SPLQA42_MODDED_ver5-1.img

# check memory
crc32 0x82F00000 0x344E66
# CRC32 for 82f00000 ... 83244e65 ==> 58736c78
# If this doesn't match, DO NOT continue!
```

### Convert Flash to G-0105-P

```sh
# The following are destructive commands
# erase flash for mtd2
sf probe 0

# erase / write memory to flash (mtd2)
sf erase 0x0C0000 0x740000
sf write 0x82F00000 0x0C0000 0x740000

# erase / write memory to flash (mtd5)
sf erase 0x800000 0x800000
sf write 0x82F00000 0x800000 0x800000
```

```sh
# read flash (mtd2) to memory, verify crc
sf read 0x82F00000 0x0C0000 0x740000
crc32 0x82F00000 0x00740000
# CRC32 for 82f00000 ... 8363ffff ==> 2ebe0a35

# read flash (mtd5) to memory, verify crc
sf read 0x82F00000 0x800000 0x800000
crc32 0x82F00000 0x800000
# CRC32 for 82f00000 ... 836fffff ==> cdc9fd4b
```

Convert uBoot Env

```sh
setenv a0_image
setenv a2_image
setenv a2_iaddr
setenv addmisc 'setenv bootargs ${bootargs} ethaddr=${ethaddr} machtype=${machtype} ignore_loglevel vpe1_load_addr=0x83f00000 vpe1_mem=1M mem=63M ${mtdparts}'
setenv addmtdparts0 'setenv mtdparts mtdparts=sflash:256k(uboot)ro,512k(uboot_env),7424k(linux),8192k(image1)'
setenv addmtdparts1 'setenv mtdparts mtdparts=sflash:256k(uboot)ro,512k(uboot_env),7424k(image0),8192k(linux)'
setenv bertEnable 0
setenv bootargs
setenv bootretry
setenv boot_fail

setenv c_img 0
setenv commit 0
setenv committed_image 0
setenv config_iaddr
setenv fileaddr 80F00000
setenv filesize 400092
setenv gphy0_phyaddr 0
setenv gphy1_phyaddr 1
setenv image0_is_valid 1
setenv image0_version 'FS v5'
setenv image1_is_valid 0
setenv image_name openwrt-lantiq-falcon-SFP
setenv kernel1_offs '0x800000'
setenv load_kernel
setenv load_uboot
setenv mtdparts
setenv nSerial 'HWTC1CFA349A'

setenv next_active
setenv omci_loid loid
setenv omci_lpwd loidpass
setenv ri_hiaddr
setenv ri_image
setenv ri_siaddr

setenv select_image 'setenv activate_image -1;if itest *${magic_addr} == ${magic_val} ; then if itest *${act_img_addr} == 0 ; then setenv activate_image 0;fi;if itest *${act_img_addr} == 1 ; then setenv activate_image 1;fi;mw ${magic_addr} 0x0;mw ${act_img_addr} 0x0;fi;if test $activate_image = -1 ; then setenv c_img $committed_image;else setenv c_img $activate_image;setenv activate_image -1;fi;if test $c_img = 0 && test $image0_is_valid = 0 ; then setenv c_img 1;fi;if test $c_img = 1 && test $image1_is_valid = 0 ; then setenv c_img 0;fi;if test $image0_is_valid = 0 && test $image1_is_valid = 0 ; then setenv c_img _err;fi;exit 0'

setenv update_A0
setenv update_A2
setenv update_configfs
setenv update_image0
setenv update_image1
setenv update_logfs
setenv update_openwrt
setenv update_ri     
setenv update_system

setenv bootdelay '5'
setenv if_netconsole 'sleep 5; echo check for netconsole; ping $serverip'
setenv start_netconsole 'echo netconsole enabled; run netconsole'
setenv netconsole 'setenv ncip $serverip; set stderr nc,serial; set stdin nc,serial; set stdout nc,serial; version;'
setenv preboot 'run if_netconsole start_netconsole'
```

Set SN

```sh
# find info from ritool dump
setenv nSerial <MfrID><YPSerialNum>
```

Save U-Boot Env

```sh
saveenv
```

```sh
run select_image boot_image0
```

Update uBoot (optional, DANGEROUS)

```sh
md5sum 1224ABORT.bin
# md5hash: 10e94a4b4acdc82dec20c7904b69e5c0
```

```sh
# load mtd0 into memory
tftpboot 0x82F00000 convert-G-010S-P/1.3.6.1-2018.bin
crc32 0x82F00000 0x262144
# CRC32 for 82f00000 ... 83162143 ==> c68feb79
# If CRC32 doesn't match, DO NOT continue!
```

```sh
# The following are destructive commands
sf probe 0

# erase / write memory to flash (mtd0)
sf erase 0x00000 0x40000
sf write 0x82F00000 0x00000 0x40000
```

Debug Dump

```sh
setenv select_image 'setenv activate_image -1;if itest *${magic_addr} == ${magic_val} ; then if itest *${act_img_addr} == 0 ; then setenv activate_image 0;fi;if itest *${act_img_addr} == 1 ; then setenv activate_image 1;fi;echo mw ${magic_addr} 0x0;echo mw ${act_img_addr} 0x0;fi;if test $activate_image = -1 ; then setenv c_img $committed_image;else setenv c_img $activate_image;setenv activate_image -1;fi;if test $c_img = 0 && test $image0_is_valid = 0 ; then setenv c_img 1;fi;if test $c_img = 1 

&& test $image1_is_valid = 0 ; then setenv c_img 0;fi;if test $image0_is_valid = 0 && test $image1_is_valid = 0 ; then setenv c_img _err;fi;exit 0'
```
