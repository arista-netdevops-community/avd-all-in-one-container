#!/bin/bash

DOCKER_SOCKET=/var/run/docker.sock
DOCKER_GROUP=docker
USER=avd
HOME_AVD=/home/avd

GITCFGFILE=${HOME_AVD}/.gitconfig

# if container is called as devcontainer from VScode, .gitconfig must be present
if [ -f ${GITCFGFILE} ]; then
  rm -f ${HOME_AVD}/gitconfig-avd-base-template
# if no .gitconfig created by VScode, copy AVD base template and edit
else
  mv ${HOME_AVD}/gitconfig-avd-base-template ${HOME_AVD}/.gitconfig
  # Update gitconfig with username and email
  if [ -n "${AVD_GIT_USER}" ]; then
    echo "Update gitconfig with ${AVD_GIT_USER}"
    sed -i "s/USERNAME/${AVD_GIT_USER}/g" ${HOME_AVD}/.gitconfig
  else
    echo "Update gitconfig with default username"
    sed -i "s/USERNAME/AVD Base USER/g" ${HOME_AVD}/.gitconfig
  fi
  if [ -n "${AVD_GIT_EMAIL}" ]; then
    echo "Update gitconfig with ${AVD_GIT_EMAIL}"
    sed -i "s/USER_EMAIL/${AVD_GIT_EMAIL}/g" ${HOME_AVD}/.gitconfig
  else
    echo "Update gitconfig with default email"
    sed -i "s/USER_EMAIL/avd-base@arista.com/g" ${HOME_AVD}/.gitconfig
  fi
fi

if [ -S ${DOCKER_SOCKET} ]; then
    sudo chmod 666 /var/run/docker.sock &>/dev/null
fi

# execute command from docker cli if any
if [ ${@+True} ]; then
  exec "$@"
# otherwise just enter zsh
else
  exec zsh
fi
