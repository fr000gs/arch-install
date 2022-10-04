#!/bin/bash

# ARCH INSTALL
#   ____ _  __
#  / ___| |/ /
# | |   | ' /
# | |___| . \
#  \____|_|\_\
#
# https://github.com/CalvinKev/arch-install
#
# DISCLAIMER: This script is not meant to work for everyone. This script is meant only meant for myself.
#
# Credit to bugswriter for many of this stolen code.
#
# Make sure to run as root.

printf '\033c'

  echo "Welcome to CalvinKev's Arch installer."

# Change ParallelDownloads from "5" to "10"
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
# Update archlinux-keyring to avoid unnecessary errors
pacman --noconfirm -Sy archlinux-keyring
# Load US keyboard layout
loadkeys us
# Fix date and time
timedatectl set-ntp true

# Select drive to partition
lsblk
echo "Enter the drive you wish to partition: "
read drive
cfdisk $drive

# Select partitions to format

# Root/Linux partition
echo "Enter the root partiton/Linux filesystem: "
read partition
mkfs.ext4 $partition

# Boot partition
echo "Enter boot partition (EFI): "
read efipartition
mkfs.fat -F32 $efipartition

# Mount root partition to /mnt
mount $partition /mnt
# Pacstrap the needed packages
pacstrap /mnt base base-devel linux linux-firmware
# Generate an /etc/fstab and append it to /mnt/etc/fstab
genfstab -U /mnt >> /mnt/etc/fstab
mv /home/arch-install2.sh /mnt
chmod +x /mnt/arch-install2.sh
arch-chroot /mnt ./arch-install2.sh
exit

# Second part (after chroot) in arch-install2.sh
