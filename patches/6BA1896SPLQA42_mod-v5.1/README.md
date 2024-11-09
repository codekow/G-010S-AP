# Notes for firmware

This is my best attempt to reverse engineer and trace the steps to
rebuild the `6BA1896SPLQA42_MODDED_ver5-1.img` that is floating around.

The file system permissions on the image above are incorrect.

Running this patch on G-010-P firmware `6BA1896SPLQA42.bin` should reproduce
the same outcome.

I have cherry picked the binaries from the modded firmware.
TODO: document how to rebuild them.

- `busybox`
- `dropbear`

```sh
md5sum 6BA1896SPLQA42_MODDED_ver5-1.img
```

```
c4f1bbe1695803d3d449f911f43d78ea  6BA1896SPLQA42_MODDED_ver5-1.img
```

- https://hack-gpon.org/ont-fs-com-gpon-onu-stick-with-mac

## Original 

```sh
3daca225bf1f0f254c02451da94bee76  bin/busybox
7c718c3410c4120fe98fa7a9a5c6c407  lib/modules/3.10.49/mod_optic.ko
7e97163e24c9cb39439589c65b438168  opt/lantiq/bin/omcid
ed03f65a25e48591ceebe1b2a4504a56  usr/sbin/dropbear
```

## Modified v5.1

```sh
8855ec74aeeea16a744f3373896bbd58  bin/busybox
7c718c3410c4120fe98fa7a9a5c6c407  lib/modules/3.10.49/mod_optic.ko
525139425009c4138e92766645dad7d0  opt/lantiq/bin/omcid
dded114001dda79c427d932c41a81cf7  usr/sbin/dropbear
```

## Setting OMCI software version (ME 7)

The image version normally can’t be changed because it is hard-coded
into the `/opt/lantiq/bin/omcid` binary, so the binary has to be
modified with the following hex patch which removes the hardcoded version.

```
# create patch
printf 'QlNESUZGNDA1AAAAAAAAAD4AAAAAAAAA2C8JAAAAAABCWmg5MUFZJlNZYqnvBwAACFBSQWAAAMAA
AAgAQCAAMQwIIwjImgDOdMvi7kinChIMVT3g4EJaaDkxQVkmU1lrJSbUAACFTAjAACAAAAiCAAAI
IABQYAFKQ01INxUgd6Soj2JURm8pUR8XckU4UJBrJSbUQlpoORdyRThQkAAAAAA=' | base64 -d > omcid.bspatch

# apply patch
cp opt/lantiq/bin/omcid opt/lantiq/bin/omcid.orig
bspatch opt/lantiq/bin/omcid.orig opt/lantiq/bin/omcid omcid.bspatch

# verify hashes
md5sum opt/lantiq/bin/omcid*
```

```
525139425009c4138e92766645dad7d0  opt/lantiq/bin/omcid
7e97163e24c9cb39439589c65b438168  opt/lantiq/bin/omcid.orig
```

## Disable RX_LOS status

Some switches/routers (e.g. Mikrotik) do not allow access to the management
interface without the fiber being connected because the SFP reports RX_LOS status.
It is possible to fix this by modifying the `mod_optic.ko` driver to spoof
non RX_LOS status by setting PIN 8 (RX_LOS) to be always low.

```sh
# create patch
printf 'QlNESUZGNDA2AAAAAAAAADYAAAAAAAAAXEEFAAAAAABCWmg5MUFZJlNZ5TTrjgAAB+ZARjAEACAA
AARAACAAMQZMQRppiFkgKGTeXi7kinChIcpp1xxCWmg5MUFZJlNZcaVLvQABOOCAwAAAAQAIAAig
ACClRgZoMhUf9JKbgIk3hdyRThQkHGlS70BCWmg5F3JFOFCQAAAAAA==' | base64 -d > mod_optic.bspatch

# apply patch
cp lib/modules/3.10.49/mod_optic.ko lib/modules/3.10.49/mod_optic.ko.orig
bspatch lib/modules/3.10.49/mod_optic.ko.orig lib/modules/3.10.49/mod_optic.ko mod_optic.bspatch

# verify hashes
md5sum lib/modules/3.10.49/mod_optic.ko*
```

```
e14a5a70b023873853afe920870f076e  lib/modules/3.10.49/mod_optic.ko
7c718c3410c4120fe98fa7a9a5c6c407  lib/modules/3.10.49/mod_optic.ko.orig
```

## Additional Notes

```sh
find -type f -exec md5sum '{}' \; > md5sum.txt
```
