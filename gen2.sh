 #!/bin/bash

path1=/mnt/gentoo
path2=/
path3=/usr/src/linux

    echo '(П.23 стр.33) Подставляем свой регион'
TIMEZONE=Europe/Moscow

    echo '(П.33 стр.56) Подставляем имя компьютера'
HOSTNAME="Gentoo"

    echo '(П.36 стр.62) Подставляем необходимые утилиты'
TOOLS="app-admin/sysklogd sys-process/cronie net-misc/dhcpcd net-dialup/ppp sys-apps/mlocate app-portage/eix sys-fs/genfstab"

    echo '(П.46 стр.91) Подставляем необходимые базовые пакеты'
PACKAGES="sys-fs/ntfs3g kde-apps/yakuake app-admin/sudo kde-apps/dolphin kde-apps/kate sys-apps/inxi sys-apps/lm-sensors x11-apps/xdpyinfo"

    echo '(П.38 стр.74) Подставляем своё место установки GRUB (sda или nvme0n1)'
GRUB_INSTALL=/dev/sdX

    echo '19. Обновляем окружение'
env-update
source /etc/profile
export PS1="(chroot) $PS1"
    echo '20. Устанавливаем снимок portage'
emerge-webrsync
    echo '21. Обновляем базу portage'
emerge --sync
    echo '22. Выставляем профиль KDE Plasma'
eselect profile set 8
    echo '23. Выставляем регион'
echo "$TIMEZONE" > /etc/timezone
emerge --config sys-libs/timezone-data
    echo '24. Добавляем русскую локаль системы'
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
    echo '25. Генерируем локаль системы'
locale-gen
    echo '26. Выставляем язык системы'
eselect locale set ru_RU.utf8
echo "dev-util/cmake -qt5" >> /etc/portage/package.use/zz-autounmask
    echo '27. Обновляем мир'
emerge world -uDNav
    echo '28. Перезагружаем окружение'
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
    echo '29. Устанавливаем ядро'
emerge sys-kernel/gentoo-kernel
    echo '30. Устанавливаем символьную ссылку ядра'
eselect kernel set 1
    echo '31. Путь к /usr/src/linux'
cd $path3
    echo '32. Устанавливаем genkernel, firmware'
emerge sys-kernel/genkernel
    echo '33. Устанавливаем имя компьютера'
  sed -i "s/localhost/$HOSTNAME/g" /etc/conf.d/hostname
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
    echo '39. Устанавливаем GRUB'
grub-install $GRUB_INSTALL
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
    echo '40. Обновление GRUB'
grub-mkconfig -o /boot/grub/grub.cfg
    echo '41. Обновляем окружение'
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
    echo '42. Устанавливаем DE KDE Plasma'
emerge --ask kde-plasma/plasma-meta
etc-update --automode -3
emerge kde-plasma/plasma-meta
    echo '43. Создаём профиль пользователя'
useradd -m -G users,wheel,audio,video -s /bin/bash username
    echo '44. Создаём пароль пользователя'
passwd username
    echo '45. Включаем daemon NetworkManager'
rc-update add NetworkManager default
    echo '46. Установка необходимых пакетов'
emerge $PACKAGES
    echo '47. Раскоментируем %wheel ALL=(ALL) ALL в sudoers'
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
    echo '48. Замена xdm на sddm в display-manager'
sed -i 's/DISPLAYMANAGER="xdm"/DISPLAYMANAGER="sddm"/' /etc/conf.d/display-manager
    echo '49. Включаем daemon display-manager'
rc-update add display-manager default
exit
