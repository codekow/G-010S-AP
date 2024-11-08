#!/bin/sh
if [ -e /configs/image_version.lock ]; then
  echo "touch /configs/image_version.lock to lock image_versions"
  return 0
fi
/etc/init.d/image_version.sh
