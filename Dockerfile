# Reference: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-debian

FROM debian 

# --- root user ---

RUN apt update --yes && apt install --yes \
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
RUN git clone https://github.com/mnussbaum/ansible-yay.git /tmp/ansible-yay/ && \
    mkdir --parents /usr/share/ansible/plugins/modules/ && \
    mv --verbose /tmp/ansible-yay/yay /usr/share/ansible/plugins/modules/

# Pass in user/group to preserve file ownerships
ARG UID
ARG GUID
# Save passed outside user/group
# NOTE: Used by some scripts as a "inside Docker" check
ENV NEW_UID=$UID
ENV NEW_GUID=$GUID

# Create /home/${UID} dir and set default shell
RUN useradd --create-home --shell $(which zsh) ${UID}
RUN echo "${UID} ALL=(ALL) NOPASSWD: ALL" | tee --append /etc/sudoers && visudo --check --strict
RUN mkdir --parents /etc/ansible/

# --- unprivileged user ---

RUN chown --recursive ${UID}:${UID} /home/${UID} && \
    chmod --recursive 755 /home/${UID}
USER ${UID}
ENV PATH="/home/${UID}/.local/bin:$PATH"
WORKDIR /home/${UID}

# Install Ansible and plugins
COPY --chown=${UID}:${UID} requirements.txt .
RUN pip3 install --upgrade --requirement requirements.txt

# Install vim plugin manager and plugins
RUN curl -kfLo ~/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
COPY --chown=${UID}:${UID} playbooks/files/vim_rc .vimrc
RUN vim -c "PlugInstall | sleep 1 | q! | q!"

# Shell customizations
COPY --chown=${UID}:${UID} playbooks/files/zsh_rc .zshrc
RUN echo '\n\
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
	grep --extended-regexp --invert-match --regexp="^\s*#" hosts \n\
	echo "===" \n\
	' | tee --append ~/.zshrc

# Change working directory
ARG WORKDIR
WORKDIR ${WORKDIR}

ENTRYPOINT ["/usr/bin/zsh"]
