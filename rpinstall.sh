#!/bin/bash
#---------------
# This install script installs Raspberry Pi specific capabilities
#
# TODO: setup watchdog timer support for raspberry pi device
#
SCRIPTSDIR="$HOME/csoc-installation-scripts-master/"
echo "SCRIPTSDIR = " $SCRIPTSDIR  >>$SCRIPTSDIR/SETUP-RUN.TXT

# TODO: need to remove watchdog from here and use naveens script in honeypot.sh instead

echo "-----@ INSTALL WATCHDOG FOR CANARY -----" >>~/SETUP-RUN.TXT
sudo modprobe bcm2708_wdog
echo "bcm2708_wdog" | sudo tee -a /etc/modules
sudo apt-get install watchdog
#
# - need to add configuration for watchdog sudo nano /etc/watchdog.conf
#
# Uncomment the line that starts with #watchdog-device by removing the hash (#) to enable the  watchdog daemon to use the watchdog device.
# Uncomment the line that says #max-load-1 = 24 by removing the hash symbol to reboot the device if the load goes over 24 over 1 minute. A load of 25 of one minute means that you would have needed 25 Raspberry Pis to complete that task in 1 minute. You may tweak this value to your liking.
#
echo "-----@ INSTALL WATCHDOG FOR CANARY -----" >>~/SETUP-RUN.TXT


#Application to enable changing of mac address
sudo apt-get install -y macchanger

#Application to enable saving of iptables
sudo apt-get install -y iptables-persistent

#Change MAC address - this is for rpi
#ifconfig enxb827eb9e5b73 down
#sudo macchanger -m 94:2e:17:9E:5B:73 enxb827eb9e5b73
#ifconfig enxb827eb9e5b73 up

#Disable bluetooth and wifi
echo '#GCR Disable bluetooth and wifi' | sudo tee --append /boot/config.txt
echo 'dtoverlay=pi3-disable-bt' | sudo tee --append /boot/config.txt
echo 'dtoverlay=pi3-disable-wifi' | sudo tee --append /boot/config.txt
sudo systemctl disable hciuart
echo '#GCR Disable bluetooth and wifi' | sudo tee --append /etc/modprobe.d/raspi-blacklist.conf
echo '#disable wifi' | sudo tee --append /etc/modprobe.d/raspi-blacklist.conf
echo 'blacklist brcmfmac' | sudo tee --append /etc/modprobe.d/raspi-blacklist.conf
echo 'blacklist brcmutil' | sudo tee --append /etc/modprobe.d/raspi-blacklist.conf
echo '#disable bluetooth' | sudo tee --append /etc/modprobe.d/raspi-blacklist.conf
echo 'blacklist btbcm' | sudo tee --append /etc/modprobe.d/raspi-blacklist.conf
echo 'blacklist hci_uart' | sudo tee --append /etc/modprobe.d/raspi-blacklist.conf


#enable ssh
sudo systemctl enable ssh
sudo service ssh restart


#setup firewall
#First delete all existing rules
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT



#Set the INPUT policy to DROP All:
sudo iptables -P INPUT DROP

# Allow packets from connections related to established ones, packets
# from established ones, and packets from localhost:
sudo iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -i lo -j ACCEPT

# Allow new connections to TCP ports:
sudo iptables -A INPUT -p TCP -m multiport --dports 2202,23,22,25,8080,80,443,5060,5061,1900,69,139,445 \
-m state --state NEW -j ACCEPT

# Allow new connections to TCP ports:
sudo iptables -A INPUT -p UDP -m multiport --dports 22,1434,443,5060,5061,1900,69,139,44 \
-m state --state NEW -j ACCEPT

sudo iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT

#Save rules and make them persistant
sudo netfilter-persistent save


#update crontab 
#write out current crontab
#sudo crontab -l > mycron
#echo new cron into cron file
#sudo echo "0 3 * * * service rsyslog restart" >> mycron

#install new cron file
#sudo crontab mycron
#sudo rm mycron

#device should be rebooted for changes to take effect

