# Backup Firmware

Capture files from device

```sh
# make backup dir
mkdir /tmp/dump
cd /tmp/dump

# capture config
cat /proc/mtd > mtd
cat /proc/cmdline > cmdline
fw_printenv > env.txt
ritool dump > ritool.txt

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
