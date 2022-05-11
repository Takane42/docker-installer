#!/bin/bash

#requirement
# ubuntu / debian = sudo apt install curl
# rhel / centos = sudo yum install curl


function package_manager() {
  case $1 in
    "debian"|"ubuntu")
      install_docker apt
      ;;
    "centos")
      install_docker yum
      ;;
  esac
}

function install_docker() {
  PACKAGE=$1
  case $PACKAGE in
    apt)
      apt remove docker docker-engine docker.io containerd runc -y
      apt update
      apt install ca-certificates gnupg lsb-release -y
      curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$DISTRO $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
      apt-get update
      apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
      ;;
    yum)
      yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine -y
      yum install -y yum-utils
      yum-config-manager --add-repo https://download.docker.com/linux/$DISTRO/docker-ce.repo
      yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
      ;;
  esac
}

function docker_compose() {
  echo "Docker compose installed"
}

#DISTRO=$(lsb_release -i | awk '{print tolower($3)}')
DISTRO=$1

if [ -z $DISTRO ] || [[ $DISTRO == *"-"* ]] ; then
    echo "Please Specify Linux Distribution";
    exit
fi

case "$2" in #$2 -> Flags
  -wdc|--docker-compose)
    package_manager "$DISTRO"
    docker_compose
    ;;
  *)
    package_manager "$DISTRO"
    ;;
esac
