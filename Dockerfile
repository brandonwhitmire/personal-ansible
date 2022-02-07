# Reference: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-debian

FROM debian 

# --- root user ---

RUN apt update -y && apt install -y \
	python3 \
	python3-pip \
	sshpass \
	sudo \
	git \
	vim \
	zsh \
	shellcheck \
	wget \
	curl \
	lsb-release \
	software-properties-common \
	systemd

# Install vagrant for dynamic inventory usage
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
	apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
	apt update -y && \
	apt install -y vagrant \
		ruby-libvirt \
		qemu \
		qemu-kvm \
		libvirt-clients \
		libvirt-daemon-system \
		ebtables \
		dnsmasq-base \
		virtinst \
		bridge-utils \
		libxslt-dev \
		libxml2-dev \
		libvirt-dev \
		zlib1g-dev \
		ruby-dev \
		libguestfs-tools

# Reference: https://developers.redhat.com/blog/2014/05/05/running-systemd-within-docker-container
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
	rm -f /lib/systemd/system/multi-user.target.wants/*; \
	rm -f /etc/systemd/system/*.wants/*; \
	rm -f /lib/systemd/system/local-fs.target.wants/*; \
	rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
	rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
	rm -f /lib/systemd/system/basic.target.wants/*; \
	rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN vagrant plugin install vagrant-libvirt

# Added to mitigate CA certs issue, but ignored in git since it was still broke
RUN git config --global http.sslverify false

# Reference: https://github.com/mnussbaum/ansible-yay
# https://docs.ansible.com/ansible/latest/dev_guide/developing_locally.html#adding-standalone-local-modules-for-all-playbooks-and-roles
RUN git clone https://github.com/mnussbaum/ansible-yay.git /tmp/ansible-yay/ && mkdir -p /usr/share/ansible/plugins/modules/ && mv -v /tmp/ansible-yay/yay /usr/share/ansible/plugins/modules/

# Pass in user/group to preserve file ownerships
ARG UID
ARG GUID
# Save passed outside user/group
ENV NEW_UID=$UID
ENV NEW_GUID=$GUID

# Create /home/${UID} dir and set default shell
RUN useradd -ms $(which zsh) ${UID}
RUN echo "${UID} ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers && visudo -c

# --- unprivileged user ---

USER ${UID}
ENV PATH="/home/${UID}/.local/bin:$PATH"

# Install Ansible and plugins
COPY requirements_ansible.txt .
RUN pip3 install --upgrade --requirement requirements_ansible.txt

# Install vim plugin manager and plugins
RUN curl -kfLo ~/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN echo "\ncall plug#begin() \n\
		Plug 'pearofducks/ansible-vim' \n\
	call plug#end()\n" > ~/.vimrc
RUN vim -c "PlugInstall | sleep 1 | q! | q!"

# Change working directory
ARG WORKDIR
WORKDIR ${WORKDIR}

# Shell customizations
RUN cp /etc/zsh/newuser.zshrc.recommended ~/.zshrc
RUN echo '\n\
# Find bindkey control char via: `cat`+ENTER, Hit Key, & CTRL+C \n\
bindkey "^[[7~"   beginning-of-line \n\
bindkey "^[[8~"   end-of-line \n\
bindkey "^[[1;5C" forward-word \n\
bindkey "^[[1;5D" backward-word  \n\
eval "$(_MOLECULE_COMPLETE=SHELL_source molecule)" \n\
alias ll="ls -la --color=auto" \n\
alias ap="ansible-playbook" \n\
alias al="ansible-lint" \n\
alias ansible_debug="ansible all -m debug -a var=hostvars" \n\
alias lint_all_the_things="find . -type f -iname \"*.yml\" -execdir ansible-lint \{\} \;" \n\
look_for () { \n\
	grep --with-filename --recursive --ignore-case --line-number --exclude-dir=".git" --regexp="$1" * \n\
} \n\
clear \n\
python3 run_first_time_setup.py \n\
set -e \n\
ansible --version \n\
set +e \n\
' | tee -a ~/.zshrc

# ENTRYPOINT ["/usr/bin/zsh"]
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/sbin/init"]
