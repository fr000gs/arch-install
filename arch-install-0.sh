printf '\033c'

echo "Welcome to fr000gs Arch installer."

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

echo "Partition your drive and mount the partitions in /mnt, then run bash arch-install-1.sh"
