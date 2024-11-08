#!/bin/sh
set -e

ROOTFS=$1

delete_files(){
  grep -v '^ *#' < delete.txt | while IFS= read -r file
  do
    [ -z "${file}" ] && continue
    [ ! -e "${ROOTFS}/${file}" ] && continue
    rm "${ROOTFS}/${file}"
  done
}

sync_files(){
  [ -d files ] || return 1
  echo "Syncing files..."
  rsync -avH files/ "${ROOTFS}/"
}

patch_motd(){
  [ -e "${ROOTFS}/motd" ] || return 1
  echo "patched: $(date)" >> "${ROOTFS}/motd"
}

delete_files
sync_files
patch_motd
