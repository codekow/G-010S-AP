#!/bin/sh
set -e

ROOTFS=$1

update_image_version(){
  if [ -z "${IMAGEVERSION}" ]; then
    echo "
      ==========================================================
      IMAGEVERSION must be defined to set custom image version

      Example: 
        export IMAGEVERSION='3FE45655BOCK99'
          or
        IMAGEVERSION='3FE45655BOCK99' patch.sh firmware/file.bin
      ==========================================================
    "
    return 0
  fi
  echo "Changing to software version to ${IMAGEVERSION}..."
  ORIG_VER=$(cat "$ROOTFS/usr/etc/buildinfo" | grep IMAGEVERSION | awk -F "=" '{print $2}')
  sed -i.orig 's/IMAGEVERSION=.*/IMAGEVERSION='"${IMAGEVERSION}"'/g' "$ROOTFS/usr/etc/buildinfo"
}

create_image_override(){
  [ ! -e "$ROOTFS/etc/init.d/update_image_version.sh" ] && return 0

  cp update_image_version.sh "$ROOTFS/etc/init.d/update_image_version.sh"
  echo "
    ====================================================
    Create /configs/image_version.lock after SFP boot
      to force software versions
      via file: /configs/image_version
    
    Example:
      touch /configs/image_version.lock
    ====================================================
  "
}

update_image_version
create_image_override
