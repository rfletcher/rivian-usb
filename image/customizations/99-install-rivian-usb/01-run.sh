#!/bin/bash -e

SOURCE_DIR=files/riv
TARGET_DIR=/opt/riv

# copy `riv` files into place
rsync -rlptP ${SOURCE_DIR}/ ${ROOTFS_DIR}/${TARGET_DIR}/

# configure the system
on_chroot << EOF
${TARGET_DIR}/bin/riv self-install
EOF
