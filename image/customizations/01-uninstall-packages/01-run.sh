#!/bin/bash -e

# remove packages we don't need, especially those which include unused
# background services

PACKAGES_TO_REMOVE=(
  triggerhappy
)

on_chroot << EOF
  apt-get remove -y --force-yes --purge ${PACKAGES_TO_REMOVE[*]}
EOF
