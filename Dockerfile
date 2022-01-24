# Reference: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-debian

FROM debian 

# Pass in user/group to preserve file ownerships
ARG UID
ARG GUID

RUN apt update -y && apt install -y \
	python3 \
	python3-pip \
	sshpass \
	sudo \
	git \
	vim \
	zsh \
	curl \
	ca-certificates

RUN mkdir -p /etc/ansible
# Create /home/${UID} dir and set default shell
RUN useradd -ms $(which zsh) ${UID}
RUN echo "${UID} ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers && visudo -c

# Save passed outside user/group
ARG UID
ARG GUID
ENV NEW_UID=$UID
ENV NEW_GUID=$GUID

# Change to unprivileged user
USER ${UID}
ENV PATH="/home/${UID}/.local/bin:$PATH"

# Install Ansible and plugins
RUN git config --global http.sslVerify false
COPY requirements_ansible.txt .
RUN pip3 install --upgrade --requirement requirements_ansible.txt

# Shell customizations
RUN cp /etc/zsh/newuser.zshrc.recommended ~/.zshrc
RUN echo ' \n\
bindkey "^[[1;5C" forward-word \n\
bindkey "^[[1;5D" backward-word  \n\
eval "$(_MOLECULE_COMPLETE=SHELL_source molecule)" \n\
alias ll="ls -la --color=auto" \n\
set -e \n\
ansible --version \n\
set +e \n\
' | tee -a ~/.zshrc

# Install vim plugin manager and plugins
RUN curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN echo " \n\
call plug#begin() \n\
Plug 'pearofducks/ansible-vim' \n\
call plug#end() \n\
" > ~/.vimrc
RUN vim -c "PlugInstall | sleep 1 | q! | q!"

# Change working directory
# NOTE: currently breaks the server
ARG WORKDIR
WORKDIR ${WORKDIR}

ENTRYPOINT ["/usr/bin/zsh"]
