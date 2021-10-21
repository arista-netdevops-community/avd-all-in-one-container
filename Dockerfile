FROM python:3.9.5-slim

# install tools permanently
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    make \
    wget \
    curl \
    less \
    git \
    zsh \
    vim \
    sudo \
    sshpass \
    git-extras \
    openssh-client \
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean

# install docker in docker and docker-compose
RUN curl -fsSL https://get.docker.com | sh \
    && curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# add AVD user
RUN useradd -md /home/avd -s /bin/zsh -u 1000 avd \
    && echo 'avd ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    # add docker and sudo to avd group
    && usermod -aG docker avd \
    && usermod -aG sudo avd
USER avd
ENV HOME=/home/avd
ENV PATH=$PATH:/home/avd/.local/bin

WORKDIR /home/avd

# install zsh
RUN wget --quiet https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true \
    && echo 'PROMPT="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"' >> ${HOME}/.zshrc \
    && echo 'PROMPT+=" %{$fg[blue]%}(%{$fg[red]%}A%{$fg[green]%}V%{$fg[blue]%}D 🐳%{$fg[blue]%})%{$reset_color%}"' >> ${HOME}/.zshrc \
    && echo 'PROMPT+=" %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)"' >> ${HOME}/.zshrc \
    && echo 'plugins=(ansible common-aliases safe-paste git jsontools history git-extras)' >> ${HOME}/.zshrc \
    # redirect to &>/dev/null is required to silence `agent pid XXXX` message from ssh-agent 
    && echo 'eval `ssh-agent -s` &>/dev/null' >> ${HOME}/.zshrc \
    && echo 'export TERM=xterm-256color' >>  $HOME/.zshrc \
    && echo "export LC_ALL=C.UTF-8" >> $HOME/.zshrc \
    && echo "export LANG=C.UTF-8" >> $HOME/.zshrc \
    && echo 'export PATH=$PATH:/home/avd/.local/bin' >> $HOME/.zshrc

# ^ ^ ^
# | | |     The section above usually remains unchanged between releases

# | | |     The section below will be updated for every release
# V V V

# add entrypoint script
COPY ./entrypoint.sh /bin/entrypoint.sh
RUN sudo chmod +x /bin/entrypoint.sh
# use ENTRYPOINT instead of CMD to ensure that entryscript is always executed
ENTRYPOINT [ "/bin/entrypoint.sh" ]

# add AVD gitconfig to be used if container is not called as VScode devcontainer
COPY ./gitconfig /home/avd/gitconfig-avd-base-template
COPY ./avd-all-in-one-requirements.txt /home/avd/avd-all-in-one-requirements.txt

# change this for every release
ENV _AVD_VERSION="v3.0.0rc2"
ENV _CVP_VERSION="v3.2.0"

# labels to be changed for every release
LABEL maintainer="Arista Ansible Team <ansible@arista.com>"
LABEL com.example.version="avd3.0.0rc2_cvp3.2.0_debian"
LABEL vendor1="Arista"
LABEL com.example.release-date="2021-10-04"
LABEL com.example.version.is-production="False"

# clone AVD and CVP collections
RUN _CURL=$(which curl) \
    && _GIT=$(which git) \
    && _REPO_AVD="https://github.com/aristanetworks/ansible-avd.git" \
    && _REPO_CVP="https://github.com/aristanetworks/ansible-cvp.git" \
    && ${_GIT} clone --depth 1 --branch ${_AVD_VERSION} --single-branch ${_REPO_AVD} /home/avd/ansible-avd \
    && ${_GIT} clone --depth 1 --branch ${_CVP_VERSION} --single-branch ${_REPO_CVP} /home/avd/ansible-cvp \
    && pip3 install --user --no-cache-dir -r /home/avd/ansible-avd/ansible_collections/arista/avd/requirements.txt \
    && pip3 install --user --no-cache-dir -r /home/avd/ansible-avd/ansible_collections/arista/avd/requirements-dev.txt \
    && pip3 install --user --no-cache-dir -r /home/avd/ansible-cvp/ansible_collections/arista/cvp/requirements.txt \
    && pip3 install --user --no-cache-dir -r /home/avd/ansible-cvp/ansible_collections/arista/cvp/requirements-dev.txt \
    && ansible-galaxy install -r /home/avd/ansible-avd/ansible_collections/arista/avd/collections.yml \
    && pip3 install --user --no-cache-dir -r /home/avd/avd-all-in-one-requirements.txt

# if not running as VScode devcontainer, start in projects
WORKDIR /home/avd/projects
