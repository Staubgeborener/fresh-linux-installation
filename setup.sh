#!/bin/bash
#update sources
sudo apt update

#install git
sudo apt install git

#install asciidoc
sudo apt install asciidoc asciidoctor
sudo gem install asciidoctor asciidoctor-pdf --pre
sudo gem install pygments.rb
