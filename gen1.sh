#!/bin/bash

path1=/mnt/gentoo
path2=/
setfont UniCyr_8x16

#echo 'Выбор места установки разделов (LOCATION)'
export ROOT_LOCATION=/mnt/gentoo
export BOOT_LOCATION=/mnt/gentoo/boot/efi/
export DATA_LOCATION=/mnt/gentoo/home/data
export DATA2_LOCATION=/mnt/gentoo/home/data2
export GAMES_LOCATION=/mnt/gentoo/home/games

#echo 'Выбор файла make.conf для NVIDIA или AMD'
export MAKE_KDE_NV=/mnt/gentoo/gentoo-install-scripts-main/make_kde_nv.conf
export MAKE_GNOME_NV=/mnt/gentoo/gentoo-install-scripts-main/make_gnome_nv.conf
export MAKE_CINNAMON_NV=/mnt/gentoo/gentoo-install-scripts-main/make_cinnamon_nv.conf
export MAKE_NV=/mnt/gentoo/gentoo-install-scripts-main/make_nv.conf
export MAKE_AMD=/mnt/gentoo/gentoo-install-scripts-main/make_amd.conf



echo '01. Выбор раздела ROOT (/dev/xxx)'
read -p 'DEV_' DEV_

echo '02. Форматирование раздела ROOT'
echo '1 - BTRFS, 2 - EXT4'
read choice

if [[ "$choice" == "1" ]]; then
    mkfs.btrfs -L Gentoo -f $DEV_ && mount $DEV_ /mnt/gentoo && \
    cd /mnt/gentoo && btrfs sub cre @ && btrfs sub cre @home && \
    btrfs sub cre @cache && btrfs sub cre @log && cd / && umount /mnt/gentoo
elif [[ "$choice" == "2" ]]; then
    mkfs.ext4 -L Gentoo $DEV_ && mount $DEV_ /mnt/gentoo && \
    mkdir -p /mnt/gentoo/home/{data,data2,games} && mkdir -p /mnt/gentoo/boot/efi && \
    cd / && umount /mnt/gentoo
fi

echo '03. Монтирование раздела ROOT'
echo '1 - BTRFS, 2 - EXT4'
read choice

if [[ "$choice" == "1" ]]; then
    mount -o noatime,autodefrag,compress=zstd,subvol=@ $DEV_ /mnt/gentoo && \
    mkdir -p /mnt/gentoo/home/{data,data2/games} && mkdir -p /mnt/gentoo/boot/efi && \
    mkdir -p /mnt/gentoo/var/log && mkdir -p /mnt/gentoo/var/cache && \
    mount -o noatime,autodefrag,compress=zstd,subvol=@home $DEV_ /mnt/gentoo/home && \
    mount -o noatime,autodefrag,compress=zstd,subvol=@cache $DEV_ /mnt/gentoo/var/cache && \
    mount -o noatime,autodefrag,compress=zstd,subvol=@log $DEV_ /mnt/gentoo/var/log
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

echo '07. Монтирование раздела Games'
read -p 'GAMES_PARTITION_' GAMES_PARTITION_
mount $GAMES_PARTITION_ $GAMES_LOCATION

echo '08. Монтирование раздела SWAP'
read -p 'SWAP_PARTITION_' SWAP_PARTITION_
swapon $SWAP_PARTITION_

echo '09. Переходим в корень устанавливаемой системы'
cd $path1

echo '10. Скачиваем архив stage3 (парсинг stage3-amd64-openrc)'
a=$(curl https://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds/current-stage3-amd64-openrc/ | sed -e 's/<[^>]*>//g' |cut -f1 -d' '| grep -e "^stage3-amd64-openrc.*.tar.xz$")
path_to_stage3='https://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds/current-stage3-amd64-openrc/'$a
wget $path_to_stage3 -O stage3-amd64-openrc.tar.xz

echo '11. Копируем архив stage3'
cp stage3* /mnt/gentoo/

echo '12. Распаковываем архив stage3'
tar xpvf stage3*.tar.xz --xattrs-include='*.*' --numeric-owner

echo '13. Копируем make.conf для нужного оборудования и DE'
wget https://github.com/SheridanOAI/gentoo-install-scripts/archive/refs/heads/main.zip
unzip main.zip -d /mnt/gentoo
echo '1-MAKE.CONF-KDE-NV, 2-MAKE.CONF-GNOME-NV, 3-MAKE.CONF-CINNAMON-NV, 4-MAKE.CONF-NV, 5-MAKE.CONF-AMD'
read choice

if [[ "$choice" == "1" ]]; then
    MAKE_CONF=$MAKE_KDE_NV
elif [[ "$choice" == "2" ]]; then
    MAKE_CONF=$MAKE_GNOME_NV
elif [[ "$choice" == "3" ]]; then
    MAKE_CONF=$MAKE_CINNAMON_NV
elif [[ "$choice" == "4" ]]; then
    MAKE_CONF=$MAKE_NV
elif [[ "$choice" == "5" ]]; then
    MAKE_CONF=$MAKE_AMD
fi

cp $MAKE_CONF /mnt/gentoo/etc/portage/make.conf

echo '14. Создаём каталог repos.conf'
mkdir --parents /mnt/gentoo/etc/portage/repos.conf

echo '15. Копируем конфигурацию репозитория Gentoo в gentoo.conf'
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf

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
