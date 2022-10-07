#!/bin/bash
echo "If you are sure you are connected to the internet; have partitioned your drive, pacstrapped linux, linux-firmware, base (and bade-devel), AND ARE RUNNING IN CHROOT, press RETURN else Control-C"
read aaa

# Change ParallelDownloads from 5 to 15
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf

# Install Intel Microcode
pacman -S --noconfirm intel-ucode dhcpcd iwd

# Set timezone
echo "Enter timezone (format Continent/City): "
read $timezone
timedatectl set-timezone $timezone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
# Sync hardware clock with Arch Linux
hwclock -lw

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
echo "Enter name of sudo user: "
read $user
useradd -mG sudo,wheel,audio,video $user
# Set user password
passwd $user
# Configure sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
echo "%sudo ALL=(ALL) ALL" >> /etc/sudoers

# GRUB
pacman --noconfirm -S grub efibootmgr dhcpcd iwd

lsblk
echo "Enter EFI partition: "
read efipartition
grub-install --target=x86_64-efi --efi-dir=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Enable dhcpcd.service
systemctl enable dhcpcd.service
systemctl enable iwd.service

pacman -S --noconfirm vim neofetch htop xorg xorg-xinit firefox xclip libreoffice-fresh pipewire pipewire-alsa pipewire-pulse pavucontrol plasma plasma-wayland-session

#kde services
systemctl enable sddm.service
systemctl enable NetworkManager.service

# Update after enabling multilib and other pacman.conf options
pacman -Syu

read -p "Install Nvidia drivers? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Install NVIDIA drivers
    pacman -S --noconfirm --needed nvidia nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader
fi

#Install pikaur
git clone https://aur.archlinux.org/pikaur.git
cd pikaur
makepkg -fsri

printf '\033c'
echo "Installation Complete! Exiting: (Press return): "
read aaa

exit
