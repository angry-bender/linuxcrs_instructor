#!/bin/bash


#function to install apps with a clean display
function retryinstall
{
echo -e "[\033[33m-\e[0m] Retrying..."
DEBIAN_FRONTEND=noninteractive apt-get --fix-broken install -yq -o  Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" >/dev/null 2>/dev/nul
DEBIAN_FRONTEND=noninteractive apt-get install --fix-missing -yq -o  Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" >/dev/null 2>/dev/nul
DEBIAN_FRONTEND=noninteractive apt-get install -yq -o  Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" $1 >/dev/null 2>/dev/null && echo -e "[\033[32m*\e[0m]OK" || echo -e "[\033[31m-\e[0m] FAILED"
}
function install
{
echo -n "installing:$1 "
DEBIAN_FRONTEND=noninteractive apt-get install -yq -o  Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" $1 >/dev/null 2>/dev/null && echo -e "[\033[32m*\e[0m]OK" || retryinstall $1
}



##### Main #####
USERN=drop

#Check Sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo" 
   exit 1
fi

#Check working directory
FILE=.zshrc
if test -f "$FILE"; then
    echo "working directory validated"
    else
        "Please change to the downloaded direectory with file and run directly from there"
        exit
fi

#Get the Standard Users username
inuser=$SUDO_USER


#Install Instructor Applications
install vim
install powerline
install rssh
install git
install zsh
install curl
install cowsay
install fortune

#install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
ensure shell changed
sudo -u ${inuser} chsh -s /usr/bin/zsh

#Create the drop user
useradd -m -d /home/drop -s /usr/bin/rssh drop
echo "user drop added successfully!"
echo drop:"Drop1" | chpasswd
echo "Password for user drop changed successfully to Drop1"

git clone https://github.com/samfree91/linuxtraining.git 
cp -r linuxtraining /home/$inuser/

#remove my username with set username
sed -i -e "s/setupuser/"${inuser}"/g" .zshrc

#Enable ssh
systemctl enable ssh
systemctl start ssh

#copy files to correct directories
cp rssh.conf /etc/rssh.conf
cp .vimrc /home/${inuser}/
cp .zshrc /home/${inuser}/



echo "Setup Complete, Please log out and back in"
echo "Note: Your terminal is now zsh, & the scripts required for course are stored in ~/linuxtraining"
echo "SCP Username:drop, Password Drop1"