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
    [ "${ROOTFS}/${file}" "/" ] && continue
    [ ! -e "${ROOTFS}/${file}" ] && continue
    [ -d "${ROOTFS}/${file}" ] && rm -rf "${ROOTFS}/${file}"
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
  echo "revision: ${REV}" >> "${ROOTFS}/etc/banner"
}

fix_perms(){
  find "${ROOTFS}" \! -user root -print
  echo "Setting chmod root:root on all files..."
  chown root:root -R "${ROOTFS}"
}

apply_patches
delete_files
sync_files
# patch_banner
fix_perms
