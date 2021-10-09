FROM debian

# --- root ---

RUN apt update -y
RUN apt install -y python3 python3-pip sshpass git vim zsh ca-certificates

COPY requirements.txt .
RUN pip3 install --no-cache-dir --upgrade --requirement requirements.txt

RUN ansible-galaxy collection install community.general

RUN mkdir -p /etc/ansible/

# --- user ---

ARG UID
ARG GUID
ENV NEW_UID=$UID
ENV NEW_GUID=$GUID

RUN cp /etc/zsh/newuser.zshrc.recommended ~/.zshrc

RUN echo ' \n\
bindkey "^[[1;5C" forward-word \n\
bindkey "^[[1;5D" backward-word \n\
alias ll="ls --color=auto -la" \n\
clear \n\
ansible --version \n\
' >> ~/.zshrc

ENTRYPOINT ["/usr/bin/zsh"]
