#!/bin/bash


FILE='/tmp/setup.log'
LOG='/tmp/setup.log 2>&1'

echo ""
echo "INICIANDO CONFIGURAÇÃO DO SETUP LINUX."
echo "REPOSITORIOS ADICIONAIS"
echo " -VIRTUAL BOX"

#Repositório virtual box
sudo echo deb http://download.virtualbox.org/virtualbox/debian xenial contrib | sudo tee /etc/apt/sources.list.d/virtual.list
wget -Sq https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -Sq https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -

echo " -SPOTIFY"
#Add the Spotify repository signing key to be able to verify downloaded packages
nohup sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886 >> $LOG
#Add the Spotify repository
nohup sudo echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list >> $LOG

echo "INCIANDO UPDATE REPOSITÓRIOS"

sudo apt-get update -q=2 && sudo apt-get upgrade -q=2 -y >> $LOG

echo "UPDATE REPOSITÓRIOS FINALIZADO"
echo "INCIANDO INSTALAÇÃO GIT."

sudo apt-get install -q=2 git

echo "INSTALAÇÃO GIT FINALIZADA."
echo "INICIANDO INSTALAÇÃO i3WM."

sudo apt-get install -q=2 i3 i3blocks i3lock i3status >> $LOG
echo " -INSTALAÇÃO PACOTES DE CUSTOMIZAÇÃO"

sudo  apt-get install -y feh gnome-icon-theme-full rofi compton
echo "  -INSTALAÇÃO FEG GNOME ICON ROFI COMPTON FINALIZADA!"
sudo wget -Sq https://github.com/acrisci/playerctl/releases/download/v0.4.2/playerctl-0.4.2_amd64.deb
sudo dpkg -i playerctl-0.4.2_amd64.deb
sudo rm -rf playerctl-0.4.2_amd64.deb

echo "  -INSTALAÇÃO FONTS"
git clone https://github.com/supermarin/YosemiteSanFranciscoFont.git
sudo cp -v YosemiteSanFranciscoFont/*.ttf /usr/share/fonts
rm -rf YosemiteSanFranciscoFont

git clone https://github.com/FortAwesome/Font-Awesome.git
sudo cp -v Font-Awesome/fonts/*.ttf /usr/share/fonts
rm -rf Font-Awesome

echo "  -INSTALAÇÃO ARC FIREFOX"
git clone https://github.com/horst3180/arc-firefox-theme
sudo apt-get install -q=2 autoconf
sudo bash arc-firefox-theme/autogen.sh --prefix=/usr
sudo make install
rm -rf arc-firefox-theme
	
echo " -CUSTOMIZAÇÃO FINALIZADA"
echo "-INSTALAÇÃO i3WM FINALIZADA."
echo "-COPIANDO CONFIGURAÇÕES GIT"

cd ./setup/
cp -v ./i3/config ~/.config/i3/ >> $LOG
cp -rv ./i3/i3blocks ~/.config/ >> $LOG

echo "CONFIGURAÇÃO DATASTORE"
sudo mkdir /media/$USER/1TB_DATASTORE01
sudo mkdir /media/$USER/1TB_DATASTORE02

sudo mount -a

echo "CONFIGURAÇÃO DATASTORE FINALIZADA"

echo "CONFIGURAÇÃO MULTIMIDIA"
echo " -INSTALAÇÃO TRANSMISSION INICIADA."

# Removendo instalações anteriores
sudo apt-get purge -q=2 $(dpkg -l | grep -i transmission | awk '{print $2}';) -y >> $LOG

<<COMMENT1
PASSO REMOVIDO, transmission migrado para container Docker.

# Instalando Daemon e cli
sudo apt-get install -q=2 transmission-daemon transmission-common transmission-cli transmission-remote-cli >> $LOG
sudo service transmission-daemon stop

# Arquivos de configuração do transmission
sudo cp ./transmission/settings.json /var/lib/transmission-daemon/.config/transmission-daemon/ >> $LOG
sudo cp ./transmission/transmission-daemon /etc/init.d/ >> $LOG
sudo cp -pr ./transmission/transmission-arquivos/* $HOME/.config/transmission-daemon/ >> $LOG

sudo chmod -R 2775 /var/lib/transmission-daemon/
sudo chmod -R 2775 /var/lib/transmission-daemon/info/
COMMENT1

echo "  -Endereço Host do Container Transmission. "
read ip_transmission
echo "  -SENHA Transmission: "
read pass_transmission

echo "alias t-list='transmission-remote $ip_transmission:9091  -n 'dionitas:$pass_transmission' -l'" >> /home/$USER/.bash_aliases
echo "alias t-basicstats='transmission-remote $ip_transmission:9091 -n 'dionitas:$pass_transmission' -st'" >> /home/$USER/.bash_aliases
echo "alias t-fullstats='transmission-remote $ip_transmission:9091 -n 'dionitas:$pass_transmission' -si'" >> /home/$USER/.bash_aliases
echo "alias t-as='transmission-remote $ip_transmission:9091 -n 'dionitas:$pass_transmission' -as'" >> /home/$USER/.bash_aliases

source /home/$USER/.bash_aliases
echo " -INSTALAÇÃO DO VLC INICIADA."

sudo apt-get install -q=2 vlc
sudo cp ./vlc/vlsub.lua /usr/lib/vlc/lua/extensions

echo " -INSTALAÇÃO DO VLC FINALIZADA."
echo " -INSTALAÇÃO DO SPOTIFY INICIADA."

#Install Spotify
nohup sudo apt-get install -q=2 spotify-client >> $LOG

echo " -INSTALAÇÃO DO SPOTIFY FINALIZADA."
echo "AMBIENTE E FERRAMENTAS."
echo " -INSTALAÇÃO DO VIRTUALBOX INICIADA."

#Install Virtualbox
sudo apt-get install -q=2 $(sudo apt-cache search virtualbox | grep ^virtual | tail -n 1 | awk '{print $1}')

#Instalação do pacote extension
sudo wget -Sq https://www.virtualbox.org/wiki/Downloads -O page.txti >> $LOG
LINK=$(cat page.txt | grep -i ".vbox-extpack" | grep -iv 'if' | awk -v FS="(href=\"|\">)" '{print $2}')
FILE=$(echo $LINK | awk -v FS="(/O|$)" '{print $2}' | sed 's/^/O/g')
sudo wget -Sq $LINK -O $FILE >> $LOG
yes | sudo vboxmanage extpack install $FILE >> $LOG
rm -rf page.txt $FILE

#Registrando as VM Docker(Apache, Transmission, Sickrage, Couchpotato) e CentOS-Plex.
vboxmanage registervm /media/dionitas/1TB_DATASTORE02/Virtualbox/DataCenter/Prod/CentOS-DockerM/CentOS-DockerM.vdi
vboxmanage registervm /media/dionitas/1TB_DATASTORE02/Virtualbox/DataCenter/Prod/CentOS-Plex/CentOS-Base.vdi

#Ligando as VM's
vboxmanage startvm f09d0c8e-998a-4dca-b1c9-3333271a78a4 --type headless
vboxmanage startvm 43c7d51f-4818-4842-9d39-34f7dc3ed4fa --type headless

echo " -INSTALAÇÃO DO VIRTUALBOX FINALIZADA."
echo " -INSTALAÇÃO DO NOIP INICIADA."

#Install noIP

sudo wget -Sq https://www.noip.com/client/linux/noip-duc-linux.tar.gz -O noip.tar.gz >> $LOG
tar -xf noip.tar.gz >> $LOG
NOIP=$(ls | grep noip | grep -v .tar)
sudo mv $NOIP /opt/
sudo ln -s /opt/$NOIP/ /opt/noip
sudo ln -s /opt/$NOIP/binaries/noip2-x86_64 /bin/noip
rm -rf ./noip.tar.gz $NOIP

echo " -INSTALAÇÃO DO NOIP FINALIZADA."

echo " -INSTALAÇÃO DO OPENSSH INICIADA."
#Instalação ssh-server
sudo apt-get install -q=2 openssh-server >> $LOG
echo " -INSTALAÇÃO DO OPENSSH FINALIZADA."

echo " -INSTALAÇÃO DO CODE INICIADA."
#Instalação Atom
wget -Sq https://go.microsoft.com/fwlink/?LinkID=760868  >> $LOG
mv index* code.deb
sudo dpkg -i code.deb
rm -rf code*
echo " -INSTALAÇÃO DO CODE FINALIZADA."