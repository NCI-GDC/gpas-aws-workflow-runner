#!/bin/sh

# Clean up
purge-old-kernels
/usr/bin/apt-get -y remove dkms 
/usr/bin/apt-get -y autoremove --purge
/usr/bin/apt-get -y clean

# Remove temporary files
rm -rf /tmp/*

# Zero out free space
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
