#!/bin/bash

path1=/
path2=/usr/src/linux

#echo '(П.36 стр.61) Подставляем необходимые утилиты'
export TOOLS="app-admin/sysklogd sys-process/cronie net-misc/dhcpcd net-dialup/ppp \
sys-apps/mlocate app-portage/eix sys-fs/genfstab"

#echo '(П.46 стр.93) Подставляем необходимые базовые пакеты'
echo "sys-apps/inxi hddtemp" >> /etc/portage/package.use/inxi
export PACKAGES="app-admin/sudo www-client/firefox-bin sys-apps/inxi \
sys-apps/lm-sensors x11-apps/xdpyinfo"

echo '19. Обновляем окружение'
source /etc/profile && export PS1="(chroot) $PS1"

echo '20. Устанавливаем снимок portage'
emerge-webrsync

echo '21. Выставляем профиль'
echo '1-KDE PLASMA, 2-GNOME, 3-DESKTOP'
read choice

if [[ "$choice" == "1" ]]; then
    eselect profile set 9
elif [[ "$choice" == "2" ]]; then
    eselect profile set 6
elif [[ "$choice" == "3" ]]; then
    eselect profile set 5
fi

echo '22. Выставляем регион'
read -p 'TIMEZONE_' TIMEZONE_
echo "$TIMEZONE_" >> /etc/timezone
emerge --config sys-libs/timezone-data

echo '23. Обновляем базу portage'
emerge --sync

echo '24. Добавляем русскую локаль системы'
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen

echo '25. Генерируем локаль системы'
locale-gen

echo '26. Выставляем язык системы'
eselect locale set ru_RU.utf8

echo '27. Обновляем мир'
emerge  --quiet-build=y world -uDNav
etc-update --automode -3
emerge  --quiet-build=y world -uDNav
echo '28. Перезагружаем окружение'
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

echo '29. Путь к /usr/src/linux'
cd $path2

echo '30. Устанавливаем ядро'
echo '1 - GENTOO-SOURCES, 2 - GENTOO-KERNEL'
read choice

if [[ "$choice" == "1" ]]; then
    emerge sys-kernel/gentoo-sources sys-kernel/genkernel && eselect kernel set 1 && \
    genkernel all
elif [[ "$choice" == "2" ]]; then
    echo 'sys-kernel/gentoo-kernel' > /etc/portage/package.accept_keywords/gentoo-kernel
    emerge sys-kernel/gentoo-kernel sys-kernel/linux-firmware && eselect kernel set 1
fi

echo '31. Устанавливаем имя компьютера'
read -p 'HOSTNAME_' HOSTNAME_
sed -i "s/localhost/$HOSTNAME_/g" /etc/conf.d/hostname
sed -i "s|^127.0.0.1.*localhost|127.0.0.1 localhost $(hostname)|" /etc/hosts

echo '32 Устанавливаем среду управления сетевыми интерфесами'
emerge --noreplace netifrc

echo '33. Устанавливаем пароль root'
passwd

echo '34. Установка системных программ'
emerge $TOOLS
rc-update add sysklogd default
rc-update add cronie default
rc-update add sshd default
eix-update

echo '35. Генерируем fstab'
genfstab -U / >> /etc/fstab

echo '36. Установка пакетов загрузчика'
emerge --ask sys-boot/os-prober
etc-update --automode -3
emerge sys-boot/os-prober

echo '37. Выбор диска устанавки GRUB'
read -p 'DISK_' DISK_
grub-install $DISK_
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub

echo '38. Обновление GRUB'
grub-mkconfig -o /boot/grub/grub.cfg

echo '39. Обновляем окружение'
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

echo '40. Устанавливаем DE (рабочий стол)'
echo '1-KDE PLASMA, 2-GNOME, 3-CINNAMON'
read choice

if [[ "$choice" == "1" ]]; then
    echo "media-libs/libsndfile minimal" >> /etc/portage/package.use/libsndfile
    echo "media-sound/mpg123 -pulseaudio" >> /etc/portage/package.use/mpg123
    echo "sys-boot/grub mount" >> /etc/portage/package.use/grub
    echo 'app-admin/conky imlib' >> /etc/portage/package.use/conky
    echo 'app-text/cherrytree' >> /etc/portage/package.accept_keywords/cherrytree
    echo 'kde-misc/latte-dock' >> /etc/portage/package.accept_keywords/latte-dock
    echo 'media-video/obs-studio' >> /etc/portage/package.accept_keywords/obs
    echo 'app-misc/radeontop' >> /etc/portage/package.accept_keywords/radeontop
    echo 'net-misc/anydesk' >> /etc/portage/package.accept_keywords/anydesk
    echo 'x11-libs/gtkglext' >> /etc/portage/package.accept_keywords/anydesk
    echo "media-plugins/audacious-plugins cue ffmpeg wavpack lame soxr" >> /etc/portage/package.use/Audacious
    echo "sys-apps/inxi hddtemp" >> /etc/portage/package.use/inxi
    emerge x11-base/xorg-server &&
    emerge --ask kde-plasma/plasma-meta && etc-update --automode -3
    emerge kde-plasma/plasma-meta && emerge kde-apps/konsole 
    emerge kde-apps/dolphin && env-update && source /etc/profile
    emerge --noreplace gui-libs/display-manager-init
    sed -i '8cconsolefont="UniCyr_8x16"' /etc/conf.d/consolefont
    rc-update add consolefont boot
elif [[ "$choice" == "2" ]]; then
    emerge x11-base/xorg-server &&
    echo "media-libs/libsndfile minimal" >> /etc/portage/package.use/libsndfile
    echo "media-sound/mpg123 -pulseaudio" >> /etc/portage/package.use/mpg123
    echo "sys-boot/grub mount" >> /etc/portage/package.use/grub
    emerge --ask gnome-base/gnome && etc-update --automode -3 &&
    emerge gnome-base/gnome && env-update && source /etc/profile
    rc-update add elogind boot && emerge --noreplace gui-libs/display-manager-init &&
    sed -i '8cconsolefont="UniCyr_8x16"' /etc/conf.d/consolefont &&
    rc-update add consolefont boot
elif [[ "$choice" == "3" ]]; then
    emerge x11-base/xorg-server && \
    echo "dev-libs/libdbusmenu gtk3" >> /etc/portage/package.use/libdbusmenu && \
    echo "x11-libs/xapp introspection" >> /etc/portage/package.use/xapp && \
    echo "sys-boot/grub mount" >> /etc/portage/package.use/grub && \
    echo "media-libs/libsndfile minimal" >> /etc/portage/package.use/libsndfile && \
    echo "media-sound/mpg123 -pulseaudio" >> /etc/portage/package.use/mpg123 && \
    emerge --ask gnome-extra/cinnamon && etc-update --automode -3 && \
    emerge gnome-extra/cinnamon && env-update && source /etc/profile && \
    rc-update add dbus default && emerge --noreplace gui-libs/display-manager-init && \
    sed -i '8cconsolefont="UniCyr_8x16"' /etc/conf.d/consolefont && \
    rc-update add consolefont boot && emerge x11-terms/xfce4-terminal \
    gnome-extra/gnome-calculator media-gfx/gnome-screenshot media-gfx/eog \
    app-text/evince gnome-extra/gnome-system-monitor app-arch/file-roller \
    app-editors/gedit x11-misc/lightdm x11-misc/lightdm-gtk-greeter \
    net-misc/networkmanager
fi

echo '41. Создаём пользователя'
read -p 'USERNAME_' USERNAME_
useradd -m -G users,wheel,audio,video -s /bin/bash $USERNAME_

echo '42. Вписываем такое же имя пользователя'
read -p 'USERNAME_' USERNAME_
passwd $USERNAME_

echo '43. Включаем daemon NetworkManager'
rc-update add NetworkManager default

echo '44. Установка необходимых пакетов'
emerge $PACKAGES

echo '45. Раскоментируем %wheel ALL=(ALL) ALL в sudoers'
sed -i '82c%wheel ALL=(ALL) ALL' /etc/sudoers

echo '46. Выбор экранного менеджера 1-SDDM 2-GDM'
echo '1-SDDM-KDE, 2-GDM-GNOME, 3-LIGHTDM-CINNAMON-MATE-XFCE'
read choice

if [[ "$choice" == "1" ]]; then
    sed -i '13cDISPLAYMANAGER="sddm"' /etc/conf.d/display-manager
elif [[ "$choice" == "2" ]]; then
    sed -i '13cDISPLAYMANAGER="gdm"' /etc/conf.d/display-manager
elif [[ "$choice" == "3" ]]; then
    sed -i '13cDISPLAYMANAGER="lightdm"' /etc/conf.d/display-manager
fi

echo '47. Включаем daemon display-manager'
rc-update add display-manager default

echo '48. Установка дополнительного ПО'
mkdir /etc/portage/sets
cp /gentoo-install-scripts-main/mysets /etc/portage/sets/
emerge @mysets
