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

#part1
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
# Don't know what this really does, bugswriter does, though.
sed '1,/^#part2$/d' `basename $0` > /mnt/arch-install2.sh
#mv /home/arch-install2.sh /mnt
chmod +x /mnt/arch-install2.sh
arch-chroot /mnt ./arch-install2.sh
exit

#part2
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

pacman -S --noconfirm vim neofetch htop xorg xorg-xinit git ttf-cascadia-code firefox picom git dmenu mpv zsh sxhkd maim xclip scrot alacritty pipewire pipewire-alsa pipewire-pulse pavucontrol

#part3

mkdir /home/gavin/.config

# dwm
git clone https://github.com/CalvinKev/dwm.git /mnt/home/gavin/.config/dwm
make -C /mnt/home/gavin/.config/dwm clean install

# st
git clone https://github.com/CalvinKev/st.git /mnt/home/gavin/.config/st
make -C /mnt/home/gavin/.config/st clean install

mkdir /mnt/home/gavin/Downloads
mkdir /mnt/home/gavin/Documents
mkdir -p /mnt/home/gavin/Pictures/Wallpapers
mkdir /mnt/home/gavin/Videos
mkdir /mnt/home/gavin/Scripts

# wallpapers
git clone https://github.com/CalvinKev/wallpapers.git /mnt/home/gavin/Pictures/wallpapers
rm -rf /mnt/home/gavin/Pictures/wallpapers/.git
rm -rf /mnt/home/gavin/Pictures/wallpapers/LICENSE
rm -rf /mnt/home/gavin/Pictures/wallpapers/README.md

# dotfiles
git clone https://github.com/CalvinKev/dotfiles.git /mnt/home/gavin/dotfiles
mkdir -p /mnt/home/gavin/.config/alacritty
mv /mnt/home/gavin/dotfiles/alacritty/alacritty.yml /mnt/home/gavin/.config/alacritty
mkdir -p /mnt/home/gavin/.config/sxhkd
mv /mnt/home/gavin/dotfiles/sxhkd/sxhkdrc-standalone /mnt/home/gavin/.config/sxhkd
mv /mnt/home/gavin/.config/sxhkd/sxhkdrc-standalone /mnt/home/gavin/.config/sxhkd/sxhkdrc
mv /mnt/home/gavin/dotfiles/shells/.zshrc /mnt/home/gavin
mv /mnt/home/gavin/dotfiles/xorg/xinitrc /mnt/home/gavin
mv /mnt/home/gavin/xinitrc /mnt/home/gavin/.xinitrc
mv /mnt/home/gavin/dotfiles/scripts/date.sh /mnt/home/gavin/Scripts
chmod +x /mnt/home/gavin/Scripts/date.sh
rm -rf /mnt/home/gavin/dotfiles

echo "Installation Complete! Please reboot now.

sleep 2s
exit
