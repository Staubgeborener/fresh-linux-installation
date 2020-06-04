#!/bin/bash

#ANSI escape codes for color
RED='\033[0;31m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
   printf "${RED}Script requires root privileges !!!${NC}\n"
   exit 1
fi

get_machine_style() {
    read -p "Is this a forensic machine? That would mean that Sleuthkit, EWF, Xmount, LiME, Volatility, ... (and many more) will also be installed [y/n] " yn
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

get_forensic_style() {
    read -p "Is this "Sleuthkit, EWF, Xmount, LiME, Volatility, ... (and many more)" or "Plaso"? [x/p] " xp
    case $xp in
        [Xx]* )
		return 0
		;;
        [Pp]* )
		return 0
		;;
        * ) 	printf "Please answer x (Sleuthkit, ...) or p (Plaso).\n"
		return 1
		;;
    esac
}

until get_machine_style; do : ; done

if [ "$yn" != "${yn#[Yy]}" ]; then until get_forensic_style; do : ; done

#APT
if [ ! -z $(which apt-get) ]; then
    #update sources and upgrade
    sudo apt -y update && apt -y upgrade

    #install git
    sudo apt -y install git

    #install asciidoc
    sudo apt -y install asciidoc asciidoctor
    sudo gem install asciidoctor asciidoctor-pdf --pre
    sudo gem install pygments.rb rouge coderay

    #install AsciidocFX 1.7.3
    wget https://github.com/asciidocfx/AsciidocFX/releases/download/v1.7.3/AsciidocFX_Linux.tar.gz
    tar -xzf AsciidocFX_Linux.tar.gz
    sudo rm AsciidocFX_Linux.tar.gz

    #install python, pip and pycharm
    #python2 is required for volatility / forensic machine, so...
    if [ "$yn" != "${yn#[Yy]}" ]; then sudo apt -y install python2.7 python-pip python-dev python-distorm3 && sudo -H pip install pycrypto openpyxl; fi
    #python3 and pip3
    sudo apt -y install python3-pip
    sudo apt -y install python3.6
    sudo apt -y install python3-pip
    sudo apt -y install python3-distutils
    sudo snap install pycharm-community --classic
    
#PACMAN
elif [ ! -z $(which pacman) ]; then
    #update sources and upgrade
    sudo pacman -Syu --noconfirm
    
    #install kernel-headers
    #uname -r
    #sudo pacman -Ss linux | grep core/linux
    #sudo pacman -S linux56-headers

    #sudo pacman -S base-devel --noconfirm
    #sudo pacman -S make gcc --noconfirm
    #sudo pacman -S libdwarf --noconfirm
    
    #install git
    sudo pacman -S git base-devel --noconfirm
    
    #install asciidoc
    #git clone https://aur.archlinux.org/asciidoctor-pdf.git
    #cd ./asciidoctor-pdf
    #makepkg -si --noconfirm
    #cd ..
    #sudo gem install asciidoctor asciidoctor-pdf --pre
    #sudo gem install pygments.rb rouge coderay

    #install AsciidocFX 1.7.2
    #git clone https://aur.archlinux.org/asciidocfx.git
    #cd asciidocfx
    #makepkg -sii --noconfirm
    #cd ..
    
else
    printf "${RED}Abort: Cannot determine package manager (neither apt nor pacman)${NC}\n"
    exit 1
fi

#forensic machine
if [ "$yn" != "${yn#[Yy]}" ]; then

    #install lime
    git clone https://github.com/504ensicsLabs/LiME/
    #jump through directories because otherwise 'make' fails
    cd ./LiME/src
    make
    cd ../..

    #install volatility (v2.6.1 - Released: December 2018)
    sudo apt -y install dwarfdump
    git clone https://github.com/volatilityfoundation/volatility
    #jump through directories because otherwise 'make' fails
    cd ./volatility/tools/linux
    make
    cd ../../..

    #forensic machine and apt
    if [ ! -z $(which apt-get) ]; then
        #install Zeitgeist and Sqilitebrowser
        sudo apt -y install zeitgeist-explorer
        sudo apt -y install sqlitebrowser

        #install Sleuthkit, mdadm, EWF, Xmount, Kpartx, cryptsetup and some R00tkit-Hunter
        sudo apt -y install sleuthkit
        sudo apt -y install mdadm
        sudo apt -y install ewf-tools
        sudo apt -y install xmount
        sudo apt -y install kpartx
        sudo apt -y install whois
        sudo apt -y install cryptsetup-bin
        sudo apt -y install chkrootkit
        sudo apt -y install rkhunter
	
        #install plaso (support only for Ubuntu 18.04 LTS (bionic) and 20.04 LTS (focal)!)
        #sudo apt-get -y install plaso-tools
    
    #forensic machine and pacman
    elif [ ! -z $(which pacman) ]; then
        #install Zeitgeist and Sqilitebrowser
        sudo pacman -S zeitgeist-explorer --noconfirm
        sudo pacman -S sqlitebrowser --noconfirm

        #install Sleuthkit, mdadm, EWF, Xmount, Kpartx, cryptsetup and some R00tkit-Hunter
        sudo pacman -S sleuthkit --noconfirm
	sudo pacman -S mdadm --noconfirm
	sudo pacman -S ewf-tools --noconfirm
	
	#afflib is a dependency on xmount
	git clone https://aur.archlinux.org/afflib.git
	(cd afflib && makepkg -si --noconfirm)
	sudo pacman -S xmount --noconfirm
	
	sudo pacman -S kpartx --noconfirm
	sudo pacman -S whois --noconfirm
	sudo pacman -S cryptsetup-bin --noconfirm
	sudo pacman -S chkrootkit --noconfirm
	sudo pacman -S rkhunter --noconfirm
    fi
fi

#if virtualization with VirtualBox detected -> install GuestAdditions (add GuestAddition.iso in VirtualBox!)
GAs_device=$(lsblk | grep VBox_GA | awk '{ printf $1 }')
if grep -Fxq "VirtualBox" /sys/class/dmi/id/product_name; then sudo mkdir /media/cdrom && sudo mount /dev/$GAs_device /media/cdrom && sudo sh /media/cdrom/VBoxLinuxAdditions.run; fi

#edit favorites in gnome
gsettings set org.gnome.shell favorite-apps "['firefox.desktop', 'org.gnome.Terminal.desktop']"

reboot
