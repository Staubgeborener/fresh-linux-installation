#!/bin/bash

# ANSI escape codes for color
RED='\033[0;31m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
   printf "${RED}Script requires root privileges !!!${NC}\n"
   exit 1
fi

get_machine_style() {
    read -p "Is this a forensic machine? That would mean that Sleuthkit, EWF, Xmount, LiME, Volatility, ... (and many more) will also be installed " yn
    case $yn in
        [Yy]* )
		return 0
		;;
        [Nn]* )
		return 0
		;;
        * ) 	printf "Please answer yes or no.\n"
		return 1
		;;
    esac
}

until get_machine_style; do : ; done

#update sources and upgrade
sudo apt update && apt upgrade

#if virtualization with VirtualBox detected -> install GuestAdditions (add GuestAddition.iso in VirtualBox!)
if grep -Fxq "VirtualBox" /sys/class/dmi/id/product_name; then sudo mkdir /media/cdrom && sudo mount /dev/cdrom /media/cdrom && sudo sh /media/cdrom/VBoxLinuxAdditions.run; fi

#install git
sudo apt -y install git

#install asciidoc
sudo apt -y install asciidoc asciidoctor
sudo gem install asciidoctor asciidoctor-pdf --pre
sudo gem install pygments.rb rouge coderay

#install AsciidocFX 1.7.3
wget https://github.com/asciidocfx/AsciidocFX/releases/download/v1.7.3/AsciidocFX_Linux.tar.gz
tar -xzf AsciidocFX_Linux.tar.gz

#install pycharm
sudo snap install pycharm-community --classic
sudo apt -y install python3-distutils

#install python, pip and pycharm
sudo apt -y install python3.6
sudo apt -y install python3-pip
sudo apt -y install python-pip
pip install --upgrade setuptools
pip install distorm3
sudo apt -y install python3-distutils
sudo snap install pycharm-community --classic


if [[ $yn == "Y" ]] || [[ $vm == "y" ]]; then
        #install Zeitgeist and Sqilitebrowser
        sudo apt -y install zeitgeist-explorer
        sudo apt -y install sqlitebrowser

        #install Xmount and EWF
        sudo apt -y install sleuthkit
        sudo apt -y install mdadm
        sudo apt -y install ewf-tools
        sudo apt -y install xmount
        sudo apt -y install kpartx
        sudo apt -y install whois
        sudo apt -y install cryptsetup-bin
        sudo apt -y install chkrootkit
        sudo apt -y install rkhunter

        #install lime
        git clone https://github.com/504ensicsLabs/LiME/
        cd ./LiME/src
        make
        cd ../..

        #install volatility (v2.6 - Released: December 2016)
        wget http://downloads.volatilityfoundation.org/releases/2.6/volatility-2.6.zip
        unzip volatility-2.6.zip
        sudo rm volatility-2.6.zip
        #jump through directories because otherwise 'make' fails
        cd ./volatility-master
        sudo apt-get install dwarfdump
        cd ./tools/linux
        make
        cd ../../..
fi
