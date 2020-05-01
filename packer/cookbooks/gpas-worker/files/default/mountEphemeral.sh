#!/bin/bash -x
root_drive=`df -h | grep nvme | sed -e 's/\/dev\///g' | awk 'NR==1{print $1}'`

echo "Detected root drive at $root_drive"

unmounted_eph=`sudo nvme list | pcregrep -M Instance | awk 'NR<=10{print $1}'`

if [ "$(echo -n "$unmounted_eph" | grep -c '^' )" == 0 ]
then
  echo "No other ephemeral drive found, exiting."
  exit 0

elif [ "$(echo -n "$unmounted_eph" | grep -c '^' )" == 1 ]
then
  echo "Found one unmounted drive at $unmounted_eph"
  mkfs.ext4 -FE nodiscard -m0 $unmounted_eph
  mount -o nofail,noatime,discard $unmounted_eph /mnt

else
  echo -e "Found $(echo "$unmounted_eph" | wc -l) drives at:\n$unmounted_eph"

  echo "$(echo $unmounted_eph)"
  sudo mdadm --create --verbose /dev/md0 --level=0 --name=EPHEMERAL_RAID --raid-devices="$(echo "$unmounted_eph" | wc -l)" $(echo $unmounted_eph)

  sudo mkfs.ext4 -L EPHEMERAL_RAID /dev/md0
  sudo mount LABEL=EPHEMERAL_RAID /mnt
fi

mkdir -p /mnt/SCRATCH/

systemctl disable mountEphemeral.service
