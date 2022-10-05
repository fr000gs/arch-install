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

pacman -S --noconfirm feh vim neofetch htop xorg xorg-xinit git ttf-cascadia-code firefox picom git dmenu mpv zsh sxhkd maim xclip scrot alacritty pipewire pipewire-alsa pipewire-pulse pavucontrol

#part3

mkdir /home/gavin/.config

# dwm
git clone https://github.com/CalvinKev/dwm.git /home/gavin/.config/dwm
make -C /home/gavin/.config/dwm clean install
rm -rf /home/gavin/.config/dwm/.git*
rm -rf /home/gavin/.config/dwm/LICENSE
rm -rf /home/gavin/.config/dwm/README.md
rm -rf /home/gavin/.config/dwm/config.h

# st
git clone https://github.com/CalvinKev/st.git /home/gavin/.config/st
make -C /home/gavin/.config/st clean install
rm -rf /home/gavin/.config/st/.git*
rm -rf /home/gavin/.config/st/LICENSE
rm -rf /home/gavin/.config/st/README.md
rm -rf /home/gavin/.config/st/config.h

mkdir /home/gavin/Downloads
mkdir /home/gavin/Documents
mkdir /home/gavin/Videos
mkdir /home/gavin/Scripts

# wallpapers
git clone https://github.com/CalvinKev/wallpapers.git /home/gavin/Pictures/wallpapers
rm -rf /home/gavin/Pictures/wallpapers/.git
rm -rf /home/gavin/Pictures/wallpapers/LICENSE
rm -rf /home/gavin/Pictures/wallpapers/README.md

# dotfiles
git clone https://github.com/CalvinKev/dotfiles.git /home/gavin/dotfiles
# alacritty
mkdir -p /home/gavin/.config/alacritty
mv /home/gavin/dotfiles/alacritty/alacritty.yml /home/gavin/.config/alacritty
# sxhkd
mkdir -p /home/gavin/.config/sxhkd
mv /home/gavin/dotfiles/sxhkd/sxhkdrc-standalone /home/gavin/.config/sxhkd
mv /home/gavin/.config/sxhkd/sxhkdrc-standalone /home/gavin/.config/sxhkd/sxhkdrc
# zsh
mv /home/gavin/dotfiles/shells/.zshrc /home/gavin
# .xinitrc
mv /home/gavin/dotfiles/xorg/xinitrc /home/gavin
mv /home/gavin/xinitrc /home/gavin/.xinitrc
# date.sh
mv /home/gavin/dotfiles/scripts/date.sh /home/gavin/Scripts
chmod +x /home/gavin/Scripts/date.sh
# pacman.conf
rm -rf /etc/pacman.conf
mv /home/gavin/dotfiles/arch/pacman.conf /etc/
# GRUB
rm -rf /etc/default/grub
mv /home/gavin/dotfiles/arch/grub /etc/default/
# picom
mkdir -p /home/gavin/.config/picom
mv /home/gavin/dotfiles/picom/picom.conf /home/gavin/.config/picom
# nvidia
mkdir -p /etc/X11/xorg.conf.d
mv /home/gavin/dotfiles/nvidia/20-nvidia.conf /etc/X11/xorg.conf.d
# remove dotfiles directory
rm -rf /home/gavin/dotfiles

# A *LOT* of chown-ing
chown gavin /home/gavin/Downloads
chown gavin /home/gavin/Documents
chown gavin /home/gavin/Pictures
chown gavin /home/gavin/Pictures/wallpapers/*
chown gavin /home/gavin/Videos
chown gavin /home/gavin/.config/dwm
chown gavin /home/gavin/.config/dwm/*
chown gavin /home/gavin/.config/st
chown gavin /home/gavin/.config/st/*
chown gavin /home/gavin/.config/alacritty
chown gavin /home/gavin/.config/alacritty/*
chown gavin /home/gavin/.config/sxhkd
chown gavin /home/gavin/.config/sxhkd/*
chown gavin /home/gavin/.config/picom
chown gavin /home/gavin/.config/picom/*
chown gavin /home/gavin/.config
chown gavin /home/gavin/.config/*

# Update after enabling multilib and other pacman.conf options
pacman -Syu
# Install a few multilib programs
pacman -S --noconfirm lib32-pipewire discord steam ttf-liberation
# Install NVIDIA drivers
pacman -S --noconfirm --needed nvidia nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader
# Update grub after configuration
grub-mkconfig -o /boot/grub/grub.cfg
# Install Paru (AUR helper)
git clone https://aur.archlinux.org/paru.git /home/gavin/paru
cd /home/gavin/paru
makepkg -si
rm -rf /home/gavin/paru

printf '\033c'
echo "Installation Complete! Please reboot now.

sleep 2s
exit

# Thanks again to Bugswriter for a lot of the code in this script!
