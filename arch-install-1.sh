#!/bin/bash
# Pacstrap the needed packages
pacstrap /mnt base base-devel linux-zen linux-firmware
# Generate an /etc/fstab and append it to /mnt/etc/fstab
genfstab -U /mnt > /mnt/etc/fstab

echo "Now run bash arch-install-chroot.sh"
