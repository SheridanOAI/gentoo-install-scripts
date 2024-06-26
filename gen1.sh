#!/bin/bash

path1=/mnt/gentoo
path2=/
setfont UniCyr_8x16

#echo 'Выбор места установки разделов (LOCATION)'
export  ROOT_LOCATION=/mnt/gentoo
export  BOOT_LOCATION=/mnt/gentoo/boot/efi
export  DATA_LOCATION=/mnt/gentoo/home/data
export DATA2_LOCATION=/mnt/gentoo/home/data2
export DATA3_LOCATION=/mnt/gentoo/home/data3

#echo 'Выбор файла make.conf для NVIDIA или AMD'
export MAKE_AMD=/mnt/gentoo/gentoo-install-scripts-main/make_amd.conf
export MAKE_NV=/mnt/gentoo/gentoo-install-scripts-main/make_nv.conf
export MAKE_INTEL=/mnt/gentoo/gentoo-install-scripts-main/make_intel.conf

echo '01. Выбор раздела ROOT (/dev/xxx)'
read -p 'DEV_' DEV_

echo '02. Форматирование раздела ROOT'
echo '1 - BTRFS, 2 - EXT4'
read choice

if [[ "$choice" == "1" ]]; then
    mkfs.btrfs -L Gentoo -f $DEV_ && mkdir /mnt/gentoo && mount $DEV_ /mnt/gentoo && \
    cd /mnt/gentoo && btrfs sub cre @ && cd / && umount /mnt/gentoo
elif [[ "$choice" == "2" ]]; then
    mkfs.ext4 -L Gentoo $DEV_ && mkdir /mnt/gentoo && mount $DEV_ /mnt/gentoo && \
    mkdir -p /mnt/gentoo/home/{data,data2,games} && mkdir -p /mnt/gentoo/boot/efi && \
    cd / && umount /mnt/gentoo
fi

echo '03. Монтирование раздела ROOT'
echo '1 - BTRFS, 2 - EXT4'
read choice

if [[ "$choice" == "1" ]]; then
    mount -o rw,noatime,ssd,discard=async,space_cashe=v2,compress=zstd,subvol=@ $DEV_ /mnt/gentoo && \
    mkdir -p /mnt/gentoo/home/{data,data2/games} && mkdir -p /mnt/gentoo/boot/efi && \
    elif [[ "$choice" == "2" ]]; then
    mount $DEV_ /mnt/gentoo
fi

echo '04. Монтирование раздела UEFI'
read -p 'BOOT_PARTITION_' BOOT_PARTITION_
mount $BOOT_PARTITION_ $BOOT_LOCATION

echo '05. Монтирование раздела DATA'
read -p 'DATA_PARTITION_' DATA_PARTITION_
mount $DATA_PARTITION_ $DATA_LOCATION

echo '06. Монтирование раздела DATA2'
read -p 'DATA2_PARTITION_' DATA2_PARTITION_
mount $DATA2_PARTITION_ $DATA2_LOCATION

echo '07. Монтирование раздела DATA3'
read -p 'DATA3_PARTITION_' DATA3_PARTITION_
mount $DATA3_PARTITION_ $DATA3_LOCATION

echo '08. Монтирование раздела SWAP'
read -p 'SWAP_PARTITION_' SWAP_PARTITION_
swapon $SWAP_PARTITION_

echo '09. Переходим в корень устанавливаемой системы'
cd $path1

echo '10. Скачиваем архив stage3 (парсинг stage3-amd64-openrc)'
a=$(curl https://mirrors.mit.edu/gentoo-distfiles/releases/amd64/autobuilds/current-stage3-amd64-openrc/ | sed -e 's/<[^>]*>//g' |cut -f1 -d' '| grep -e "^stage3-amd64-openrc.*.tar.xz$")
path_to_stage3='https://mirrors.mit.edu/gentoo-distfiles/releases/amd64/autobuilds/current-stage3-amd64-openrc/'$a
wget $path_to_stage3 -O stage3-amd64-openrc.tar.xz

echo '11. Копируем архив stage3'
cp stage3* /mnt/gentoo/

echo '12. Распаковываем архив stage3'
tar xpvf stage3*.tar.xz --xattrs-include='*.*' --numeric-owner

echo '13. Копируем make.conf для нужного оборудования и DE'
wget https://github.com/SheridanOAI/gentoo-install-scripts/archive/refs/heads/main.zip
unzip main.zip -d /mnt/gentoo
echo '1-MAKE-AMD, 2-MAKE-NVIDIA, 3-MAKE-INTEL'
read choice

if [[ "$choice" == "1" ]]; then
    MAKE_CONF=$MAKE_AMD
elif [[ "$choice" == "2" ]]; then
    MAKE_CONF=$MAKE_NV
elif [[ "$choice" == "3" ]]; then
    MAKE_CONF=$MAKE_INTEL
fi

cp $MAKE_CONF /mnt/gentoo/etc/portage/make.conf

echo '14. Создаём каталог repos.conf'
mkdir --parents /mnt/gentoo/etc/portage/repos.conf

echo '15. Копируем конфигурацию репозитория Gentoo в gentoo.conf'
cp /usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf

echo '16. Копирование информации о DNS'
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

echo '17. Монтирование необходимых файловых систем'
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

echo '18. Переход в новое окружение'
chroot /mnt/gentoo /bin/bash /gentoo-install-scripts-main/gen2.sh
