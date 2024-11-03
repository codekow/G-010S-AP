# Backup Firmware

See [U-Boot Defaults](env-defaults.txt)

## Capture files from device

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

# capture configs
fw_printenv > env.txt
grep goi_config env.txt > env.goi_config.txt

ritool dump > ritool.txt
```

```sh
# save flash
for i in /dev/mtd?
do
  cp $i .
done

# hash flash files
md5sum mtd? > md5sum
```

Transfer files from device

```sh
mkdir -p dump/
scp ONTUSER@192.168.1.10:/tmp/dump/*  dump/
```
