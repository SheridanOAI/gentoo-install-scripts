 #!/bin/bash

path1=/mnt/gentoo
path2=/
path3=/usr/src/linux
setfont UniCyr_8x16

    echo 'Подставьте свои места установки разделов (LOCATION)'
 ROOT_LOCATION=/mnt/gentoo
 BOOT_LOCATION=/mnt/gentoo/boot/efi
 DATA_LOCATION=/mnt/gentoo/data
DATA2_LOCATION=/mnt/gentoo/data2

    echo 'Выбор разделов'
 BOOT_PARTITION=/dev/xxx
 SWAP_PARTITION=/dev/xxx
 ROOT_PARTITION=/dev/xxx
 DATA_PARTITION=/dev/xxx
DATA2_PARTITION=/dev/xxx

    echo 'Подставьте свой путь к директории где находится архив stage3'
 STAGE3=/mnt/gentoo/data/stage3*

    echo 'Подставьте свой путь к вашему настроеному файлу make.conf'
 MAKE_CONF=/mnt/gentoo/data/make.conf

    echo '01. Форматирование корневого раздела'
mkfs.ext4 $ROOT_PARTITION -L Gentoo
    echo '02. Монтирование корневого раздела'
mount $ROOT_PARTITION $ROOT_LOCATION
    echo '03. Создание папок для разделов с данными'
mkdir /mnt/{data,data2}
    echo '04. Создание папок /boot/efi'
mkdir -p /mnt/boot/efi
    echo '05. Монтирование загрузочного UEFI раздела'
mount $BOOT_PARTITION $BOOT_LOCATION
    echo '06. Монтирование раздела с данными 1'
mount $DATA_PARTITION $DATA_LOCATION
    echo '07. Монтирование раздела с данными 2'
mount $DATA2_PARTITION $DATA2_LOCATION
    echo '08. Монтирование раздела SWAP'
swapon $SWAP_PARTITION

    echo '09. Переходим в корень устанавливаемой системы'
cd $path1
    echo '10. Копируем архив stage3'
cp $STAGE3 /mnt/gentoo/
    echo '11. Распаковываем архив stage3'
tar xpvf stage3*.tar.xz --xattrs-include='*.*' --numeric-owner
    echo '12. Копируем make.conf'
cp $MAKE_CONF /mnt/gentoo/etc/portage/make.conf
    echo '13. Создаём каталог repos.conf'
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
    echo '14. Копируем конфигурацию репозитория Gentoo в gentoo.conf'
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
    echo '15. Копирование информации о DNS'
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
    echo '16. Монтирование необходимых файловых систем'
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
    echo '17. Скрипт gen2.sh который должен быть скопированным в /mnt/gentoo'
cp /1/gen2.sh /mnt/gentoo/
    echo '18. Переход в новое окружение'
chroot /mnt/gentoo /bin/bash /gen2.sh
