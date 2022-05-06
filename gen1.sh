 #!/bin/bash

          path1=/mnt/gentoo
          path2=/
          setfont UniCyr_8x16

    echo 'Выбор места установки разделов (LOCATION)'
 ROOT_LOCATION=/mnt/gentoo
 BOOT_LOCATION=/mnt/gentoo/boot/efi/
 DATA_LOCATION=/mnt/gentoo/data
DATA2_LOCATION=/mnt/gentoo/data2

    echo 'Выбор FS ROOT раздела'
       FS_TYPE=ext4

    echo 'Выбор файла make.conf для NVIDIA или AMD'
       MAKE_NV=/mnt/gentoo/gentoo-install-scripts-main/make_nv.conf
      MAKE_AMD=/mnt/gentoo/gentoo-install-scripts-main/make_amd.conf
 MAKE_GNOME_NV=/mnt/gentoo/gentoo-install-scripts-main/make_gnome_nv.conf

    echo '01. Форматирование корневого раздела'
read -p 'ROOT_PARTITION_' ROOT_PARTITION_
mkfs.$FS_TYPE $ROOT_PARTITION_ -L Gentoo
    echo '02. Монтирование корневого раздела'
read -p 'ROOT_PARTITION_' ROOT_PARTITION_
mount $ROOT_PARTITION_ $ROOT_LOCATION
    echo '03. Создание папок для разделов с данными'
mkdir /mnt/gentoo/{data,data2}
    echo '04. Создание папок /boot/efi'
mkdir -p /mnt/gentoo/boot/efi
    echo '05. Монтирование загрузочного UEFI раздела'
read -p 'BOOT_PARTITION_' BOOT_PARTITION_
mount $BOOT_PARTITION_ $BOOT_LOCATION
    echo '06. Монтирование раздела с данными 1'
read -p 'DATA_PARTITION_' DATA_PARTITION_
mount $DATA_PARTITION_ $DATA_LOCATION
    echo '07. Монтирование раздела с данными 2'
read -p 'DATA2_PARTITION_' DATA2_PARTITION_
mount $DATA2_PARTITION_ $DATA2_LOCATION
    echo '08. Монтирование раздела SWAP'
read -p 'SWAP_PARTITION_' SWAP_PARTITION_
swapon $SWAP_PARTITION_
    echo '09. Переходим в корень устанавливаемой системы'
cd $path1
    echo '10. Скачиваем архив stage3'
a=$(curl https://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds/current-stage3-amd64-openrc/ | sed -e 's/<[^>]*>//g' |cut -f1 -d' '| grep -e "^stage3-amd64-openrc.*.tar.xz$")
path_to_stage3='https://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds/current-stage3-amd64-openrc/'$a
wget $path_to_stage3 -O stage3-amd64-openrc.tar.xz
    echo '11. Копируем архив stage3'
cp stage3* /mnt/gentoo/
    echo '12. Распаковываем архив stage3'
tar xpvf stage3*.tar.xz --xattrs-include='*.*' --numeric-owner
    echo '13. Копируем make.conf'
wget https://github.com/SheridanOAI/gentoo-install-scripts/archive/refs/heads/main.zip
unzip main.zip -d /mnt/gentoo
    echo '1-MAKE.CONF-NVIDIA, 2-MAKE.CONF-AMD, 3-MAKE_GNOME_NV'
    read choice
      if [[ "$choice" == "1" ]]; then
MAKE_CONF=$MAKE_NV
    elif [[ "$choice" == "2" ]]; then
MAKE_CONF=$MAKE_AMD
    elif [[ "$choice" == "3" ]]; then
MAKE_CONF=$MAKE_GNOME_NV
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
