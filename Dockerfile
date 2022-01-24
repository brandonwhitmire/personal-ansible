# Reference: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-debian

FROM debian 

# Pass in user/group to preserve file ownerships
ARG UID
ARG GUID
# Flask API IP:PORT
ARG API_HOST="0.0.0.0"
ARG API_PORT=5000

RUN apt update -y
RUN apt install -y python3 python3-pip git vim zsh ca-certificates sudo sshpass

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
# RUN pip3 install --upgrade pip setuptools
RUN pip3 install --upgrade --requirement requirements_ansible.txt
RUN ansible-galaxy collection install -fvvvv community.vmware

# Shell customizations
RUN cp /etc/zsh/newuser.zshrc.recommended ~/.zshrc
RUN echo ' \n\
bindkey "^[[1;5C" forward-word \n\
bindkey "^[[1;5D" backward-word  \n\
eval "$(_MOLECULE_COMPLETE=SHELL_source molecule)" \n\
alias ll="ls -la --color=auto" \n\
cd ansible \n\
set -e \n\
./run_first_time_setup.sh \n\
clear \n\
ansible --version \n\
set +e \n\
' | tee -a ~/.zshrc

# Change working directory
# NOTE: currently breaks the server
ARG WORKDIR
WORKDIR ${WORKDIR}

# Expose Flask API port
EXPOSE ${API_PORT}

# Flask env variables
ENV FLASK_ENV=development
ENV FLASK_DEBUG=1
ENV FLASK_TEST=True
ENV FLASK_APP=${WORKDIR}/ansible/api.py
ENV FLASK_RUN_HOST=${API_HOST}
ENV FLASK_RUN_PORT=${API_PORT}

# ENTRYPOINT ["python3", "-m", "flask", "run"]
ENTRYPOINT ["/usr/bin/zsh"]
