#! /bin/bash

ln -sf /usr/share/zoneinfo/GB /etc/localtime
hwclock --systohc

echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
localectl set-locale LANG=en_GB.UTF-8
localectl --no-convert set-x11-keymap gb
locale-gen
setxkbmap gb

echo $1 >> /etc/hostname
echo "root:$2" | chpasswd

echo "What username would you like?"
read username
useradd -m -G wheel -s /bin/bash $username
echo " %wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

echo "Enabling things"
systemctl enable NetworkManager
systemctl enable sddm
echo "Done"

echo "Intalling grub"
grub-install /dev/nvme0n1
grub-mkconfig -o /boot/grub/grub.cfg
echo "Done"

cp ./yay.sh /mnt/home/$username/
chmod +x /mnt/home/$username/yay.sh

echo "Starting yay.sh"
su $username yes /home/$username/yay.sh
rm ./yay.sh
#sed -i "s/%users ALL=(ALL:ALL) NOPASSWD: ALL/ /" /etc/sudoers
