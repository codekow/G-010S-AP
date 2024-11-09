#!/bin/sh /etc/rc.common

START=99

start() {
  fw_printenv boot_fail | grep -q '0' || \
    fw_setenv boot_fail '0'
}
