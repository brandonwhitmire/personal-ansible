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
	curl

# Added to mitigate CA certs issue lazily
RUN git config --global http.sslverify false

# Reference: https://github.com/mnussbaum/ansible-yay
# https://docs.ansible.com/ansible/latest/dev_guide/developing_locally.html#adding-standalone-local-modules-for-all-playbooks-and-roles
RUN git clone https://github.com/mnussbaum/ansible-yay.git /tmp/ansible-yay/ && mkdir -p /usr/share/ansible/plugins/modules/ && mv -v /tmp/ansible-yay/yay /usr/share/ansible/plugins/modules/

# Pass in user/group to preserve file ownerships
ARG UID
ARG GUID
# Save passed outside user/group
# NOTE: Used by some scripts as a "inside Docker" check
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
		grep --with-filename --recursive --ignore-case --line-number --exclude-dir="artifacts" --exclude-dir=".git" --regexp="$1" * \n\
	} \n\
	clear \n\
	echo "===" \n\
	ansible --version \n\
	echo "---" \n\
	python3 run_first_time_setup.py \n\
	echo "---" \n\
	echo Hosts that Ansible will run against by default: \n\
	grep -E -v -e "^\s*#" hosts \n\
	echo "===" \n\
	' | tee -a ~/.zshrc

ENTRYPOINT ["/usr/bin/zsh"]
