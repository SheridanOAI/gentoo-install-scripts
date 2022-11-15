#!/bin/bash

echo '01. Установка дополнительных флагов для Nvidia Conky'
echo 'app-admin/conky imlib curl lua bundled-toluapp rss nvidia ABI_X86=(64) LUA_SINGLE_TARGET="lua5-3"' >> /etc/portage/package.use/conky

echo '02. Установка дополнительных флагов для Audacious'
echo "media-plugins/audacious-plugins cue ffmpeg wavpack lame soxr" >> /etc/portage/package.use/Audacious

echo '03. Установка дополнительных флагов для Inxi'
echo "sys-apps/inxi hddtemp" >> /etc/portage/package.use/inxi

export TOOLS="sys-fs/f2fs-tools sys-fs/dosfstools kde-apps/ark app-arch/p7zip \
app-arch/unrar app-dicts/aspell-ru sys-apps/inxi app-misc/neofetch sys-apps/nvme-cli"

export FONTS="dev-perl/Font-TTF media-fonts/font-bh-ttf media-fonts/font-misc-meltho \
media-fonts/font-misc-misc media-fonts/font-adobe-utopia-type1 \
media-fonts/font-adobe-utopia-100dpi media-fonts/font-adobe-utopia-75dpi \
media-fonts/ubuntu-font-family media-fonts/noto-emoji"

export PACKAGES="media-sound/audacious sys-apps/gnome-disk-utility media-sound/kid3 \
media-sound/soundconverter media-sound/flacon kde-apps/kcalc games-board/gnome-mahjongg \
app-admin/conky media-sound/pavucontrol-qt kde-apps/gwenview media-gfx/flameshot \
net-p2p/qbittorrent kde-apps/kdenlive"

echo "04. Установка утилит"
emerge --ask $TOOLS
echo "05. Установка шрифтов"
emerge --ask $FONTS
echo "06. Установка программ"
emerge --ask $PACKAGES
etc-update --automode -3
emerge --ask $PACKAGES
