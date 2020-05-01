#!/bin/sh -x
sudo yum clean all
sudo rm -rf /var/cache/yum

export HISTSIZE=0
sudo sh -c "export HISTSIZE=0"

sudo dd if=/dev/zero of=/ZERO bs=1M
sudo rm -f /ZERO
