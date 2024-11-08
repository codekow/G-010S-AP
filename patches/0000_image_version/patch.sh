#!/bin/sh
set -e

ROOTFS=$1

update_image_version(){
  if [ -z "${IMAGEVERSION}" ]; then
    echo "
      IMAGEVERSION must be defined to set custom image version
      example: 
        export IMAGEVERSION='3FE45655BOCK99'
    "
    return 0
  fi
  echo "Changing to software version to ${IMAGEVERSION}..."
  ORIG_VER=$(cat "$ROOTFS/usr/etc/buildinfo" | grep IMAGEVERSION | awk -F "=" '{print $2}')
  sed -i.orig 's/IMAGEVERSION=.*/IMAGEVERSION='"${IMAGEVERSION}"'/g' "$ROOTFS/usr/etc/buildinfo"
}

update_image_version
