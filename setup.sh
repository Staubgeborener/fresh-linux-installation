#!/bin/bash

#update sources and upgrade
sudo apt update && apt upgrade

#install git
sudo apt install git

#install asciidoc
sudo apt install asciidoc asciidoctor
sudo gem install asciidoctor asciidoctor-pdf --pre
sudo gem install pygments.rb rouge coderay

#install AsciidocFX 1.7.3
wget https://github.com/asciidocfx/AsciidocFX/releases/download/v1.7.3/AsciidocFX_Linux.tar.gz
tar -xzf AsciidocFX_Linux.tar.gz

#install pycharm
sudo snap install pycharm-community --classic
sudo apt-get install python3-distutils

#if virtualization with VirtualBox detected -> install GuestAdditions
if grep -Fxq "VirtualBox" /sys/class/dmi/id/product_name; then sudo mkdir /media/cdrom && sudo mount /dev/cdrom /media/cdrom && sudo sh /media/cdrom/VBoxLinuxAdditions.run; fi
