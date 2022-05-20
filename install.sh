#!/bin/bash

loadkeys uk
timedatectl set-ntp true
echo "Welcome to the rapid install script!"
echo "If you need to use Wifi to 'ctrl+c' and then 'iwctl', 'station wlan0 get-networks', 'station wlan0 connect <network name>' then after connecting restart this script"
echo "What hostname would you like?"
read hostchosenname
echo "What root password would you like?"
read hostpasswd
echo "Auto setup drive partions? [y/n]"
read auto_partition
if [ $auto_partition == 'y' ]; then
    echo "Is your drive is an NVME drive? [y/n]"
    read drive
    if [ $drive == 'y' ]; then
        echo "NVME drive selected"
        echo "Setting partion table"
        parted -s /dev/nvme0n1 mklabel gpt
        parted -s /dev/nvme0n1 mkpart primary 0 4000MB
        parted -s /dev/nvme0n1 mkpart primary 4000MB 4100MB
        parted -s /dev/nvme0n1 mkpart primary 4100MB 100%
        echo "Done partions"

        echo "Formmating partions"
        mkswap /dev/nvme0n1p1
        mkfs.fat -F 32 /dev/nvme0n1p2
        mkfs.ext4 -F /dev/nvme0n1p3
        echo "Formmated partions"

        echo "Mounting drives"
        mount /dev/nvme0n1p3 /mnt
        mkdir -p /mnt/boot/efi
        mount /dev/nvme0n1p2 /mnt/boot/efi
        echo "Done"

        echo "Enabling swap"
        swapon /dev/nvme0n1p1
        echo "Done"
    else
        echo "Setting partion table"
        parted -s /dev/sda mklabel gpt
        parted -s /dev/sda mkpart primary 0 4000MB
        parted -s /dev/sda mkpart primary 4000MB 4100MB
        parted -s /dev/sda mkpart primary 4100MB 100%
        echo "Done partions"

        echo "Formmating partions"
        mkswap /dev/sda1
        mkfs.fat -F 32 /dev/sda2
        mkfs.ext4 -F /dev/sda3
        echo "Formmated partions"

        echo "Mounting drives"
        mount /dev/sda3 /mnt
        mkdir -p /mnt/boot/efi
        mount /dev/sda2 /mnt/boot/efi
        echo "Done"

        echo "Enabling swap"
        swapon /dev/sda1
        echo "Done"
    fi
fi

echo "Intalling base system and software packages"
pacstrap /mnt base linux linux-firmware sof-firmware nano firefox networkmanager sddm plasma git base-devel grub efibootmgr mousepad fuse2 ntfs-3g spectacle dolphin konsole unzip zip vlc
genfstab -U /mnt >> /mnt/etc/fstab

cp ./chrooted.sh /mnt/root/
cp ./yay.sh /mnt/root/

chmod +x /mnt/root/chrooted.sh
echo "Starting chrooted.sh"
arch-chroot /mnt /root/chrooted.sh $hostchosenname $hostpasswd
rm /mnt/root/chrooted.sh

echo "To set user password type 'arch-chroot /mnt' then 'passwd <user>' then set and password and then 'exit'"
echo "To unmount and reboot into new system type 'umount -a' then 'reboot'"
