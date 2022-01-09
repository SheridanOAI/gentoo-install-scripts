 #!/bin/bash

path1=/
path2=/usr/src/linux

    echo '(П.36 стр.62) Подставляем необходимые утилиты'
TOOLS="app-admin/sysklogd sys-process/cronie net-misc/dhcpcd net-dialup/ppp sys-apps/mlocate app-portage/eix sys-fs/genfstab"

    echo '(П.46 стр.91) Подставляем необходимые базовые пакеты'
PACKAGES="sys-fs/ntfs3g kde-apps/konsole app-admin/sudo kde-apps/dolphin www-client/google-chrome kde-apps/kate sys-apps/inxi sys-apps/lm-sensors x11-apps/xdpyinfo"

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
echo "Europe/Moscow" >> /etc/timezone
emerge --config sys-libs/timezone-data
    echo '24. Добавляем русскую локаль системы'
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
    echo '25. Генерируем локаль системы'
locale-gen
    echo '26. Выставляем язык системы'
eselect locale set en_US.utf8
echo "dev-util/cmake -qt5" >> /etc/portage/package.use/zz-autounmask
    echo '27. Обновляем мир'
emerge world -uDNav
    echo '28. Перезагружаем окружение'
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
    echo '29. Устанавливаем ядро'
emerge sys-kernel/gentoo-sources
    echo '30. Устанавливаем символьную ссылку ядра'
eselect kernel set 1
    echo '31. Путь к /usr/src/linux'
cd $path2
    echo '32. Копируем конфиг ядра'
cp /gentoo-install-scripts-main/config_ryzen /usr/src/linux-5.15.11-gentoo/.config
    echo '33. Компилируем ядро'
make -j16 && make modules_install
    echo '34. Копируем ядро в /boot'
make install
    echo '35. Устанавливаем genkernel и обновляем initramfs'
emerge sys-kernel/genkernel
genkernel --install initramfs
    echo '36. Устанавливаем имя компьютера'
    read -p 'HOSTNAME_' HOSTNAME_
  sed -i "s/localhost/$HOSTNAME_/g" /etc/conf.d/hostname
    echo '37 Устанавливаем среду управления сетевыми интерфесами'
emerge --noreplace netifrc
    echo '38. Устанавливаем пароль root'
passwd
    echo '39. Установка системных программ'
emerge $TOOLS
rc-update add sysklogd default
rc-update add cronie default
rc-update add sshd default
eix-update
    echo '40. Генерируем fstab'
genfstab -U / >> /etc/fstab
    echo '41. Установка пакетов загрузчика'
emerge --ask sys-boot/os-prober
etc-update --automode -3
emerge sys-boot/os-prober
    echo '42. Выбор диска устанавки GRUB'
read -p 'DISK_' DISK_
grub-install $DISK_
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
    echo '43. Обновление GRUB'
grub-mkconfig -o /boot/grub/grub.cfg
    echo '44. Обновляем окружение'
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
    echo '45. Устанавливаем DE KDE Plasma'
emerge --ask kde-plasma/plasma-meta
etc-update --automode -3
emerge kde-plasma/plasma-meta
    echo '46. Создаём пользователя'
read -p 'USERNAME_' USERNAME_
useradd -m -G users,wheel,audio,video -s /bin/bash $USERNAME_
    echo '47. Вписываем такое же имя пользователя'
read -p 'USERNAME_' USERNAME_
passwd $USERNAME_
    echo '48. Включаем daemon NetworkManager'
rc-update add NetworkManager default
    echo '49. Установка необходимых пакетов'
emerge $PACKAGES
    echo '50. Раскоментируем %wheel ALL=(ALL) ALL в sudoers'
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
    echo '51. Замена xdm на sddm в display-manager'
sed -i 's/DISPLAYMANAGER="xdm"/DISPLAYMANAGER="sddm"/' /etc/conf.d/display-manager
    echo '52. Включаем daemon display-manager'
rc-update add display-manager default
exit
