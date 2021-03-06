#!/bin/bash

#requirement
# ubuntu / debian = sudo apt install curl
# rhel / centos = sudo yum install curl
# How To Use => bash <(curl -sL "https://bit.ly/DockerNata") <ubuntu/debian/centos> <-wdc/--docker-compose/-dco/--compose-only> <1/2>"

install_docker() {
echo "================================"
echo "1. Installing Docker"
echo "================================"
  case $DISTRO in
    ubuntu | debian)
      PACKAGE="apt"
      sudo apt remove docker docker-engine docker.io containerd runc -y
      sudo apt update
      sudo apt install ca-certificates gnupg lsb-release -y
      sudo curl -fsSL https://download.docker.com/linux/"$DISTRO"/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$DISTRO $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update
      sudo apt-get install docker-ce docker-ce-cli containerd.io -y
      ;;
    centos | rhel)
      PACKAGE="yum"
      sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine -y
      sudo yum install -y yum-utils
      sudo yum-config-manager --add-repo https://download.docker.com/linux/"$DISTRO"/docker-ce.repo
      sudo yum install docker-ce docker-ce-cli containerd.io -y
      ;;
    fedora)
      PACKAGE="dnf"
      sudo dnf remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine docker-engine-selinux docker-selinux -y
      sudo dnf -y install dnf-plugins-core
      sudo dnf-config-manager --add-repo https://download.docker.com/linux/"$DISTRO"/docker-ce.repo
      sudo dnf install docker-ce docker-ce-cli containerd.io -y
  esac
}

docker_compose() {
  case "$1" in
    1)
      echo "================================"
      echo "2. Installing Docker-Compose"
      echo "================================"
      sudo $PACKAGE install docker-compose-plugin -y ;;
    2)
      echo "================================"
      echo "2. Installing Docker-Compose"
      echo "================================"
      sudo rm -f /usr/local/bin/docker-compose
      sudo curl -SL "$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -o -m 1 "https.*linux-$(uname -m)")" -o /usr/local/bin/docker-compose
      sudo chmod +x /usr/local/bin/docker-compose ;;
    0)
      exit 0;;
    *)
      echo "================================"
      echo "2. Docker-Compose"
      echo "================================"
      echo "Please Choose the correct option"
      echo " 1) via package-manager"
      echo " 2) standalone binary"
      echo " 0) exit"
      read -r -p "Option : " OPTION
      docker_compose "$OPTION"
  esac
}

#Entry Point

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

#DISTRO=$(lsb_release -i | awk '{print tolower($3)}')
DISTRO=$1

if [[ -z $DISTRO ||  $DISTRO == *"-"* ]] ; then
    echo "Please Specify Linux Distribution";
    exit
fi

# Need Review on this code

if [ "$(sudo systemctl is-active docker)" == "active" ] && [ ! "$2" == "-dco" ] && [ ! "$2" == "--compose-only" ]; then
    echo "Docker is Already Installed"
    read -r -p "Reinstall Docker? (Y/n) : " docker_option
    if [ "$docker_option" == n ] ; then
      echo -e "${RED}INSTALLATION CANCELED${NC}\n"
      exit 1
    fi
fi

case "$2" in #$2 -> Flags
  -wdc|--docker-compose)
    install_docker "$DISTRO"
    docker_compose "$3"
    echo -e "${GREEN}INSTALLATION COMPLETE${NC}\n"
    ;;
  -dco|--compose-only)
    docker_compose "$3"
    echo -e "${GREEN}INSTALLATION COMPLETE${NC}\n"
    ;;
  *)
    install_docker "$DISTRO"
    echo -e "${GREEN}INSTALLATION COMPLETE${NC}\n"
    ;;
esac
