#!/bin/bash
# A Bash script to prepare Azure Instance for CDH installation
# v1.1
# Owner : Debabrata Roy Chowdhury
# Date: 18-04-2018

echo "****************************"
echo "Starting Prepare Host"
echo "****************************"

#set umask
echo -e "\nSetting Umask to 022 in .bashrc"
umask 022
echo "umask 022" >> ~/.bashrc

#Turn on NTPD
echo "Setting up NTPD and syncing time"
#Need to add a check to see if NTPD is installed.  If not install it
sudo yum -y install ntp
sudo chkconfig ntpd on
sudo ntpd -q
sudo service ntpd start
echo -e "\nInstallation of NTPD done and NTPD and syncing time"


#disable SELinux
echo -e "\nDisabling SELinux"
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sudo setenforce 0

# Turn off autostart of Firewalls and iptables
echo -e "\nTurning off autostart of Firewalls and iptable"
sudo systemctl stop firewalld.service
sudo systemctl disable firewalld.service
#sudo service ip6tables stop
#sudo chkconfig ip6tables off


#Set Swapiness
echo -e "\nSetting Swapiness to 0"
echo 0 | sudo tee /proc/sys/vm/swappiness
echo vm.swappiness = 0 | sudo tee -a /etc/sysctl.conf

#Disable the tuned service
sudo systemctl start tuned
sudo tuned-adm off
sudo systemctl stop tuned
sudo systemctl disable tuned

#Turn on NSCD
#echo -e "\nTurning on NSCD"
#chkconfig --level 345 ncsd on
#ncsd -g

#Install JAVA
sudo mkdir -p /usr/java
sudo wget "http://<host>/java/jdk-8u144-linux-x64.tar.gz"
sudo tar -zxvf jdk-8u144-linux-x64.tar.gz -C /usr/java
echo -e "\nJava unzipped and installed in /usr/java"
sudo ln -sf /usr/java/jdk1.8.0_144 /usr/java/default
sudo echo 'export PATH=/usr/java/jdk1.8.0_144/bin:$PATH' >> ~/.bash_profile
source ~/.bash_profile
echo -e "\nJava installed and sourced in bash profile"

echo "****************************"
echo "Starting to copy JCE"
echo "****************************"


#Copy JCE in /root
sudo wget "http://dnacloud-d-vm01.edis.tatasteel.com/java/jce_policy-8.zip" -P /root
echo -e "\nJCE Copied to /root"


#Unizip JCE in /root
sudo unzip  /root/jce_policy-8.zip -d /root/jce/
echo -e "\nJCE Unzipped and placed in /root/jce"


#Copy and overwrite the JCE files in default java security
cp /root/jce/UnlimitedJCEPolicyJDK8/* /usr/java/jdk1.8.0_144/jre/lib/security
echo -e "Copy JCE files to /usr/java/jdk1.8.0_144/jre/lib/security"


echo "****************************"
echo "Copying JCE complete"
echo "****************************"


#Set File Handle Limits
echo -e "\nSetting File Handle Limits"
sudo -- sh -c 'echo hdfs – nofile 32768 >> /etc/security/limits.conf'
sudo -- sh -c 'echo mapred – nofile 32768 >> /etc/security/limits.conf'
sudo -- sh -c 'echo hbase – nofile 32768 >> /etc/security/limits.conf'
sudo -- sh -c 'echo hdfs – nproc 32768 >> /etc/security/limits.conf'
sudo -- sh -c 'echo mapred – nproc 32768 >> /etc/security/limits.conf'
sudo -- sh -c 'echo hbase – nproc 32768 >> /etc/security/limits.conf'

echo -e "\n****************************"
echo "Prepare Nodes COMPLETE!"
echo "****************************"
