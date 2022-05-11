#!/bin/bash

#requirement
# ubuntu / debian = sudo apt install curl
# rhel / centos = sudo yum install curl

function install_docker() {
  case $DISTRO in
    ubuntu | debian)
      PACKAGE="apt"
      apt remove docker docker-engine docker.io containerd runc -y
      apt update
      apt install ca-certificates gnupg lsb-release -y
      curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$DISTRO $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
      apt-get update
      apt-get install docker-ce docker-ce-cli containerd.io -y
      ;;
    centos | rhel)
      PACKAGE="yum"
      yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine -y
      yum install -y yum-utils
      yum-config-manager --add-repo https://download.docker.com/linux/$DISTRO/docker-ce.repo
      yum install docker-ce docker-ce-cli containerd.io -y
      ;;
  esac
}

function docker_compose() {
  case "$1" in
    1)
      $PACKAGE install docker-compose-plugin -y ;;
    2)
      curl -SL $(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -o -m 1 "https.*linux-x86_64") -o /usr/local/bin/docker-compose
      chmod +x /usr/local/bin/docker-compose ;;
    0)
      exit 0;;
    *)
      echo "Please Choose the correct option"
      echo " 1) via package-manager"
      echo " 2) standalone binary"
      echo " 0) exit"
      read -p "Option : " OPTION
      docker_compose $OPTION
  esac
}

#DISTRO=$(lsb_release -i | awk '{print tolower($3)}')
DISTRO=$1

if [ -z $DISTRO ] || [[ $DISTRO == *"-"* ]] ; then
    echo "Please Specify Linux Distribution";
    exit
fi

case "$2" in #$2 -> Flags
  -wdc|--docker-compose)
    install_docker "$DISTRO"
    docker_compose $3
    ;;
  -dco|--compose-only)
    docker_compose $3
    ;;
  *)
    install_docker "$DISTRO"
    ;;
esac
