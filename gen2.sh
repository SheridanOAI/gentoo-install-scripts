 #!/bin/bash

path1=/
path2=/usr/src/linux

#    echo '(П.36 стр.61) Подставляем необходимые утилиты'
TOOLS="app-admin/sysklogd sys-process/cronie net-misc/dhcpcd net-dialup/ppp sys-apps/mlocate app-portage/eix sys-fs/genfstab"

#    echo '(П.46 стр.93) Подставляем необходимые базовые пакеты'
PACKAGES="sys-fs/ntfs3g app-admin/sudo www-client/firefox-bin sys-apps/inxi sys-apps/lm-sensors x11-apps/xdpyinfo"

    echo '19. Обновляем окружение'
source /etc/profile
export PS1="(chroot) $PS1"
    echo '20. Устанавливаем снимок portage'
emerge-webrsync
    echo '21. Обновляем базу portage'
emerge --sync
    echo '22. Выставляем профиль'
    echo '1-KDE PLASMA, 2-GNOME, 3-DESKTOP'
    read choice
    if [[ "$choice" == "1" ]]; then
eselect profile set 8
    elif [[ "$choice" == "2" ]]; then
eselect profile set 6
    elif [[ "$choice" == "3" ]]; then
eselect profile set 5
    fi
    echo '23. Выставляем регион'
    read -p 'TIMEZONE_' TIMEZONE_
echo "TIMEZONE_" >> /etc/timezone
emerge --config sys-libs/timezone-data
    echo '24. Добавляем русскую локаль системы'
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
    echo '25. Генерируем локаль системы'
locale-gen
    echo '26. Выставляем язык системы'
eselect locale set ru_RU.utf8
    echo '27. Обновляем мир'
echo "dev-lang/python -bluetooth" >> /etc/portage/package.use/python
echo "dev-util/cmake -qt5" >> /etc/portage/package.use/cmake

emerge world -uDNav
    echo '28. Перезагружаем окружение'
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
    echo '29. Устанавливаем ядро'
emerge sys-kernel/gentoo-sources
    echo '30. Устанавливаем символьную ссылку ядра'
eselect kernel set 1
    echo '31. Устанавливаем genkernel'
emerge sys-kernel/genkernel
    echo '32. Путь к /usr/src/linux'
cd $path2
    echo '1 - Ryzen-2700, 2 - GENKERNEL ALL'
    read choice
    if [[ "$choice" == "1" ]]; then
cp /gentoo-install-scripts-main/config_ryzen /usr/src/linux/.config && make -j16 && make modules_install && make install && genkernel --install initramfs
    elif [[ "$choice" == "2" ]]; then
genkernel all
      fi
    echo '33. Устанавливаем имя компьютера'
    read -p 'HOSTNAME_' HOSTNAME_
  sed -i "s/localhost/$HOSTNAME_/g" /etc/conf.d/hostname
    echo '34 Устанавливаем среду управления сетевыми интерфесами'
emerge --noreplace netifrc
    echo '35. Устанавливаем пароль root'
passwd
    echo '36. Установка системных программ'
emerge $TOOLS
rc-update add sysklogd default
rc-update add cronie default
rc-update add sshd default
eix-update
    echo '37. Генерируем fstab'
genfstab -U / >> /etc/fstab
    echo '38. Установка пакетов загрузчика'
emerge --ask sys-boot/os-prober
etc-update --automode -3
emerge sys-boot/os-prober
    echo '39. Выбор диска устанавки GRUB'
read -p 'DISK_' DISK_
grub-install $DISK_
#echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
    echo '40. Обновление GRUB'
grub-mkconfig -o /boot/grub/grub.cfg
    echo '41. Обновляем окружение'
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
    echo '1-KDE PLASMA, 2-GNOME, 3-CINNAMON'
    read choice
    if [[ "$choice" == "1" ]]; then
emerge --ask kde-plasma/plasma-meta && etc-update --automode -3 && emerge kde-plasma/plasma-meta && emerge kde-apps/konsole && emerge kde-apps/dolphin && env-update && source /etc/profile && sed -i '8cconsolefont="UniCyr_8x16"' /etc/conf.d/consolefont && rc-update add consolefont boot
    elif [[ "$choice" == "2" ]]; then
emerge x11-base/xorg-server && echo "media-libs/libsndfile minimal" >> /etc/portage/package.use/libsndfile && echo "media-sound/mpg123 -pulseaudio" >> /etc/portage/package.use/mpg123 && emerge --ask gnome-base/gnome && etc-update --automode -3 && emerge gnome-base/gnome && env-update && source /etc/profile && rc-update add elogind boot && emerge --noreplace gui-libs/display-manager-init && sed -i '8cconsolefont="UniCyr_8x16"' /etc/conf.d/consolefont && rc-update add consolefont boot
    elif [[ "$choice" == "3" ]]; then
emerge x11-base/xorg-server && echo "dev-libs/libdbusmenu gtk3" >> /etc/portage/package.use/libdbusmenu && echo "x11-libs/xapp introspection" >> /etc/portage/package.use/xapp && echo "sys-boot/grub mount" >> /etc/portage/package.use/grub && echo "media-libs/libsndfile minimal" >> /etc/portage/package.use/libsndfile && echo "media-sound/mpg123 -pulseaudio" >> /etc/portage/package.use/mpg123 && emerge --ask gnome-extra/cinnamon && etc-update --automode -3 && emerge gnome-extra/cinnamon && env-update && source /etc/profile && rc-update add dbus default && emerge --noreplace gui-libs/display-manager-init && sed -i '8cconsolefont="UniCyr_8x16"' /etc/conf.d/consolefont && rc-update add consolefont boot && emerge x11-terms/xfce4-terminal gnome-extra/gnome-calculator media-gfx/gnome-screenshot media-gfx/eog app-text/evince gnome-extra/gnome-system-monitor app-arch/file-roller app-editors/gedit lxde-base/lxdm net-misc/networkmanager
    fi

    echo '43. Создаём пользователя'
read -p 'USERNAME_' USERNAME_
useradd -m -G users,wheel,audio,video -s /bin/bash $USERNAME_
    echo '44. Вписываем такое же имя пользователя'
read -p 'USERNAME_' USERNAME_
passwd $USERNAME_
    echo '45. Включаем daemon NetworkManager'
rc-update add NetworkManager default
    echo '46. Установка необходимых пакетов'
emerge $PACKAGES
    echo '47. Раскоментируем %wheel ALL=(ALL) ALL в sudoers'
sed -i '82c%wheel ALL=(ALL) ALL' /etc/sudoers
    echo '48. Выбор экранного менеджера 1-SDDM 2-GDM'
    echo '1-SDDM-KDE, 2-GDM-GNOME, 3-LXDM-CINNAMON-MATE-XFCE'
    read choice
    if [[ "$choice" == "1" ]]; then
sed -i '13cDISPLAYMANAGER="sddm"' /etc/conf.d/display-manager
    elif [[ "$choice" == "2" ]]; then
sed -i '13cDISPLAYMANAGER="gdm"' /etc/conf.d/display-manager
    elif [[ "$choice" == "3" ]]; then
sed -i '13cDISPLAYMANAGER="lxdm"' /etc/conf.d/display-manager
    fi
    echo '49. Включаем daemon display-manager'
rc-update add display-manager default
