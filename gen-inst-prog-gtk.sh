#!/bin/bash

    echo 'app-admin/conky imlib curl lua bundled-toluapp rss nvidia ABI_X86=(64) LUA_SINGLE_TARGET="lua5-3"' >> /etc/portage/package.use/conky
    echo "media-plugins/audacious-plugins cue ffmpeg wavpack lame soxr" >> /etc/portage/package.use/Audacious
    echo "sys-apps/inxi hddtemp" >> /etc/portage/package.use/inxi

    TOOLS="sys-fs/f2fs-tools sys-fs/dosfstools app-arch/p7zip app-arch/unrar app-dicts/aspell-ru"
    FONTS="dev-perl/Font-TTF media-fonts/font-bh-ttf media-fonts/font-misc-meltho media-fonts/font-misc-misc media-fonts/font-adobe-utopia-type1 media-fonts/font-adobe-utopia-100dpi media-fonts/font-adobe-utopia-75dpi media-fonts/ubuntu-font-family media-fonts/noto-emoji gnome-extra/gucharmap"
    PACKAGES="media-sound/audacious sys-apps/gnome-disk-utility media-sound/kid3 media-sound/soundconverter media-sound/flacon games-board/gnome-mahjongg media-gfx/nomacs app-admin/conky media-sound/pavucontrol media-gfx/flameshot net-p2p/qbittorrent"

    echo 'app-admin/conky imlib curl lua bundled-toluapp rss nvidia ABI_X86=(64) LUA_SINGLE_TARGET="lua5-3"' >> /etc/portage/package.use/conky
    echo "media-plugins/audacious-plugins cue ffmpeg wavpack lame soxr" >> /etc/portage/package.use/audacious

    echo "Установка утилит"
emerge --ask $TOOLS
    echo "Установка шрифтов"
emerge --ask $FONTS
    echo "Установка программ"
emerge --ask $PACKAGES
etc-update --automode -3
emerge --ask $PACKAGES
