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

printf '\033c'

# Install Intel Microcode
pacman -S --noconfirm intel-ucode dhcpcd
# Change ParallelDownloads from 5 to 15
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
# Set timezone
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
# Sync hardware clock with Arch Linux
hwclock --systohc
# Set locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
# Generate locale
locale-gen
# Set locale.conf
echo "LANG=en_US.UTF-8" > /etc/locale.conf
# Set hostname
echo "Hostname: "
read hostname
echo $hostname > /etc/hostname

# Configure /etc/hosts
echo "127.0.0.1		localhost" >> /etc/hosts
echo "::1		localhost" >> /etc/hosts
echo "127.0.1.1		$hostname.localdomain	$hostname >> /etc/hosts"

# Change root password
passwd
# Create user account
useradd -mG wheel,audio,video gavin
# Set user password
passwd gavin
# Configure sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# GRUB
pacman --noconfirm -S grub efibootmgr

lsblk
echo "Enter EFI partition: "
read efipartition
mkdir /boot/efi
mount $efipartition /boot/efi
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Enable dhcpcd.service
systemctl enable dhcpcd.service

echo '\n'
echo "Base installation complete. Please reboot now."
