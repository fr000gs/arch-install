# arch-install

This Arch installation script will install kde, firefox and libreoffice(fresh) and optionally nvidia drivers.

## Using arch-install

First run 
    bash arch-install-0.sh
Now partition your drive and mount the partitions in /mnt. The boot, efi and root partitions must be present, recommended sizes:

1.Boot >500MB
2.EFI >200MB
3.Root >5GB

Now run
    bash arch-install-1.sh
    arch-chroot /mnt
    bash arch-install-chroot.sh
Now installation is complete.
    reboot
