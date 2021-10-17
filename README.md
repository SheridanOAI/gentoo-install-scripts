#     Скрипт по установке Gentoo Linux с установленным DE KDE Plasma.
    Данный скрипт по умолчанию предназначен для процессора AMD Ryzen 7 2700, видеокарты Nvidia и DE KDE Plasma, если же у вас другой процессор вам необходимо выставить параметр (COMMON_FLAGS=) в make.conf согласно таблице своего процессора
    https://wiki.gentoo.org/wiki/Safe_CFLAGS
ниже я приложу два примера make.conf, один для Nvidia другой для Radeon
    Кофигурационный файл (make.conf https://wiki.gentoo.org/wiki//etc/portage/make.conf) предназначан для глобальной установки параметров компиляции всех устанавливаемых пакетов Gentoo, от него зависит с какими параметрами вы настроите компилятор, а это быстродействие и стабильность системы. В параметре MAKEOPTS="-j16" укажите количество ядер вашего процессора, если у вас по два потока на ядро (количество ядер умножаете на 2).

    ВНИМАНИЕ!
        Не запускайте скрипты сразу так как там указаны мои разделы, внимательно изучите куда подставлять данные. Автор не несёт ответственность за использования этого скрипта.

    После того как запустили скрипт вам необходимо подставлять значение(Y) а также внимательно вводит пароль для ROOT и для USERNAME, дело в том что в Gentoo простые пароли не проходят, поэтому выбирайте сложные пароли (буквенно цыфровые с регистрами)

    Для тех у кого стоит на флешке программа VENTOY, рекомендую записывать скрипты во второй раздел установочной флешки ventoy.
Для этого необходимо смонтировать второй раздел  установочной флешки ventoy в ваш систему.
    Сначала вставьте флешку с программой ventoy, затем в консоли введите команду #fdisl -l и посмотрите под каким буквенно цифровым номером ваша флешка
    (в моём случае sdb2)
пример:
монтируемся в #mount /sdb2 /mnt , затем копируем в /mnt два скрипта (gen1.sh, gen2.sh),
набрав команду в консоли #cp /путь где лежат скрипты/{gen1.sh,gen2.sh} /mnt
1. Скачиваем архив stage3, заходим https://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds/ , затем выбираете папку с последней датой, и с этой папки скачиваете архив stage3-amd64-openrc-2021*.tar.xz, так же скачайте установочный образ
install-amd64-minimal-2021*.iso
1. Загружаемся с установочного диска Gentoo
2. В консоли создаём папку для монтирования второго раздела Ventoy #mkdir /1
3. Монтируем второй раздел Ventoy (в моём случае #mount /dev/sdb2 /1)
4. Заупускаем скрипт gen1.sh  #/1/gen1.sh
Если у кого установочный образ Gentoo установлен на флешку, необходимо вставить дополнительную флешку с записанными на ней скриптами,
1. Создаём папку #mkdir /1
2. Монтируем флешку #mount /dev/sdX2 /1
3. Запускаем скрипт #/1/gen1.sh

    В этих локациях я указываю куда подключать ваши разделы.(скрипт gen1.sh)
ROOT_LOCATION=/mnt
BOOT_LOCATION=/mnt/boot/efi
DATA_LOCATION=/mnt/data
DATA2_LOCATION=/mnt/data2

    В этих партициях я указываю разделы которые небходимо подключить. (скрипт gen1.sh)
 BOOT_PARTITION=/dev/sda1
 SWAP_PARTITION=/dev/nvme0n1p6
 ROOT_PARTITION=/dev/sda2
 DATA_PARTITION=/dev/sda5
DATA2_PARTITION=/dev/nvme0n1p5

    В СКРИПТЕ gent-inst-prog.sh находятся программы, шрифты и утилиты необходимые для установки после перезагрузки

    В параметре MAKE_CONF (строка 25 gen1.sh) укажите путь к make.conf
    В параметре STAGE3 (строка 22 gen1.sh) после = укажите свой путь к архиву stage3
    В параметре TIMEZONE (строка 8 gen2.sh) после = подставляем свой регион
    В параметре HOSTNAME (строка 11 gen2.sh) после = вводим имя компьютера
    В параметре TOOLS (строка 14 gen2.sh) после = список необходимых утилит
    В параметре PACKAGES (строка 17 gen2.sh) после = список необходимых базовых пакетов
    В параметре GRUB_INSTALL (строка 20 gen2.sh) после = указываем свой диск на который будет установлен GRUB
    Ядро устанавливается автоматически sys-kernel/gentoo-kernel
    Список литературы для видеокарт Nvidia AMD
Для видеокарт Radeon https://wiki.gentoo.org/wiki/Radeon
Для видеокарт AMDGPU https://wiki.gentoo.org/wiki/AMDGPU
Для видеокарт Nvidia https://wiki.gentoo.org/wiki/NVIDIA/nvidia-drivers/ru ,https://wiki.gentoo.org/wiki/Nouveau , https://wiki.gentoo.org/wiki/NVIDIA/Bumblebee
Для установки WIFI https://wiki.gentoo.org/wiki/Wifi/ru
    Настройку зеркал я не делаю так как по умолчанию лучшие зеркала
    Литература по установке Gentoo https://wiki.gentoo.org/wiki/Handbook:AMD64/ru

    От автора: Удачной установки!
