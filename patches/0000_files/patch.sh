#!/bin/sh
set -e

ROOTFS=$1

apply_patches(){
  ls *.patch 2>/dev/null || return 0
  for patch in *.patch
  do
    patch -p1 -d "$ROOTFS" < "${patch}"
  done
}

delete_files(){
  echo "Deleting unwanted files..."
  grep -v '^ *#' < delete.txt | while IFS= read -r file
  do
    [ -z "${file}" ] && continue
    [ ! -e "${ROOTFS}/${file}" ] && continue
    rm "${ROOTFS}/${file}"
  done
}

sync_files(){
  [ -d files ] || return 0
  echo "Syncing files..."
  rsync -avH --chown=root:root files/ "${ROOTFS}/"
}

patch_banner(){
  [ -e "${ROOTFS}/etc/banner" ] || return 0
  echo "Pathing /etc/banner..."
  REV=$(git rev-parse --short HEAD) || REV=unknown
  echo "patched: $(date)" >> "${ROOTFS}/etc/banner"
  echo "commit: ${REV}" >> "${ROOTFS}/etc/banner"
}

apply_patches
delete_files
sync_files
patch_banner
