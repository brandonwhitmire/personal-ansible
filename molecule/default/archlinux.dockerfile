FROM archlinux/archlinux

RUN pacman -Syyu --noconfirm && pacman -S --noconfirm python sudo
