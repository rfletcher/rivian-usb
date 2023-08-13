#!/bin/bash -e

rsync -rlptP files/riv/ ${ROOTFS_DIR}/opt/riv/
