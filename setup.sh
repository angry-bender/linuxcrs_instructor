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
    echo -e "Working Directory Check [\033[32m*\e[0m]OK"
    else
        echo -e "[\033[31m-\e[0m] Working Directory Check FAILED"
        echo "Please change to the downloaded direectory with file and run directly from there"
        echo "This script will now exit"
        exit
fi

#Get the Standard Users username
inuser=$SUDO_USER

#install oh my zsh
install curl
install zsh
echo -e "Installiing Oh my ZSH [-]"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" 0<&- >/dev/null 2>&1
echo -e "Oh my ZSH installation [\033[33m-\e[0m] Check after logon"

#ensure shell changed
usermod -s /usr/bin/zsh ${inuser}
echo -e "${inuser} shell changed to zsh [\033[32m*\e[0m]OK"

#Install Instructor Applications
install vim
install git
install cowsay
install fortune
install powerline
install rssh

#Create the drop user
useradd -m -d /home/drop -s /usr/bin/rssh drop
echo -e "Useradd: Drop [\033[32m*\e[0m]OK"
echo drop:"Drop1" | chpasswd
echo -e "Password Set to Drop1 for user: drop [\033[32m*\e[0m]OK"

git clone https://github.com/samfree91/linuxtraining.git >/dev/null 2>&1 && echo -e "Training Scripts Clone: [\033[32m*\e[0m]OK" || echo -e "Training Scripts Clone: [\033[31m-\e[0m]  FAILED"
cp -r linuxtraining /home/$inuser/

#remove my username with set username
sed -i -e "s/setupuser/"${inuser}"/g" .zshrc

#Enable ssh
systemctl enable ssh >/dev/null 2>&1 echo -e "SSH Service: [\033[32m*\e[0m]OK" || echo -e "SSH Service: [\033[31m-\e[0m]  FAILED"
systemctl start ssh >/dev/null 2>&1 echo -e "Start SSH: [\033[32m*\e[0m]OK" || echo -e "Start SSH: [\033[31m-\e[0m]  FAILED"

#copy files to correct directories
cp rssh.conf /etc/rssh.conf
cp .vimrc /home/${inuser}/
cp .zshrc /home/${inuser}/
echo -e "Copy Config Files: [\033[32m*\e[0m]OK"


echo -e "[\033[32m*\e[0m]Setup Complete, Please log out and back in"
echo "Note: Your terminal is now zsh, & the scripts required for course are stored in ~/linuxtraining"
echo "SCP Username:drop, Password Drop1"
