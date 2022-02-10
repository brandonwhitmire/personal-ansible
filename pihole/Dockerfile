# Reference:
# https://wiki.archlinux.org/title/Pi-hole#Installation

FROM archlinux

# --- root user ---

RUN yes | pacman -S --refresh --refresh --sysupgrade
RUN pacman -S --noconfirm --needed git \
		base-devel \
		zsh \
		cargo \
		sudo \
		lighttpd \
		php-cgi

# Pass in user/group to preserve file ownerships
ARG UID
ARG GUID
# Save passed outside user/group
# NOTE: Used by some scripts as a "inside Docker" check
ENV NEW_UID=$UID
ENV NEW_GUID=$GUID

# Create /home/${UID} dir and set default shell
RUN useradd --badname --create-home --shell "$(which zsh)" "${UID}"
RUN echo "${UID} ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers && visudo -c

# --- unprivileged user ---

USER ${UID}

# Change working directory
WORKDIR "/home/${UID}"

# Install paru (AUR)
# Reference: https://github.com/morganamilo/paru
RUN git clone https://aur.archlinux.org/paru.git && \
	cd paru && \
	yes | makepkg -si

# Install Pi-hole
# Reference: https://wiki.archlinux.org/title/Pi-hole#Installation
RUN yes | paru -S --noconfirm pi-hole-server
RUN sudo cp -v /usr/share/pihole/configs/lighttpd.example.conf /etc/lighttpd/lighttpd.conf

# Entrypoint script to start pihole-FTL and lighttpd
COPY entrypoint.sh .

# Update blocklists
RUN sudo pihole -g -r recreate && \
	pihole --regex '(.*\.)?facebook.com'

# Bulk list tool
# Reference: https://github.com/jessedp/pihole5-list-tool
# TODO: fix this tool since it isn't compatible with more recent python3 versions
RUN yes | paru -S --noconfirm python39
RUN sudo pacman -S --noconfirm python-pip
RUN sudo pip3 install --python-version '3.9' --upgrade pihole5-list-tool

# pihole options
# Reference: https://github.com/pi-hole/docker-pi-hole
ENV TZ='America/Chicago'
ENV PIHOLE_DNS_='1.1.1.1'
ENV WEBTHEME='default-darker'
ENV TEMPERATUREUNIT='f'

CMD ["bash", "entrypoint.sh"]
