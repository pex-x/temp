#!/bin/bash
#---------------------START OF BASICS------------------------#
if [[ $EUID -ne 0 ]]; then
  echo "You must be root to run this script."
  exit 1
fi
if [[ $EUID == 0 ]]; then
     echo "Run Mega Script"

    read -p "Execute Script (y/n)? "
    echo 
    if [[ $REPLY =~ y ]]; then
        echo "==== Running Update ===="
        sudo apt update -y && sudo apt upgrade
        echo
        echo "==== Enabling the Firewall ===="
        sudo ufw enable
        echo
        echo "==== Only allowing SSH ===="
        sudo ufw allow ssh
        echo
    fi
fi
#---------------------END OF BASICS------------------------#

#Give a prompt to continue the script, this is where things begin to be altered, so confimation would be nice

#--------------------START OF DISABLING ROOT-------------------------#
    read -p "Continue (y/n)? "
#If prompt is no >
if [[ $REPLY =~ n ]]; then
    exit 
fi
#If prompt is yes >
if [[ $REPLY =~ y ]]; then
    echo "Disabling SSH Root Login"
    #Setting Paths to Dirs
    SSHD_CONFIG="/etc/ssh/sshd_config"
    SSHD_CONFIG_BACKUP="/etc/ssh/sshd_config.backup"

    #If statement, if anwser y, then backup and run
    if [[ $REPLY =~ y ]]; then
	    echo "Running Script"
	    echo "Backing up $SSHD_CONFIG to $SSHD_CONFIG_BACKUP"
	
        #-f is file ! means doesnt exist
		if ! [[ -f "$SSHD_CONFIG_BACKUP" ]]; then
		    echo "Backing up $SSHD_CONFIG to $SSHD_CONFIG_BACKUP"
		    cp $SSHD_CONFIG $SSHD_CONFIG_BACKUP
		fi
		
	    echo "To restore: cp $SSHD_CONFIG_BACKUP $SSHD_CONFIG"
	
	    echo "Modifying $SSHD_CONFIG"
	fi
    #SED actually edits the file, the ^ means beginning of the line, the $ means where the line ends, the g means globally edit the entire file, -i modifies
		sed -i 's/^PermitRootLogin yes$/PermitRootLogin no/g' $SSHD_CONFIG
		
	echo "Edited $SSHD_CONFIG"
	echo "----Diff----"
	git diff --unified=0 --no-index $SSHD_CONFIG_BACKUP $SSHD_CONFIG
fi
#--------------------END OF THE ROOT DISABLING-------------------#

#------PW Requirements--------#
  echo "Password Requirements"
echo 
    read -p "Continue (y/n)? "
echo 
#If prompt is no >
if [[ $REPLY =~ n ]]; then
    exit 
fi


if [[ $REPLY =~ y ]]; then
	echo "running script"
	
    LOGIN_CONFIG="/etc/login.defs"
    LOGIN_CONFIG_BACKUP="$LOGIN_CONFIG.backup"

	if ! [[ -f "$LOGIN_CONFIG_BACKUP" ]]; then
		echo "backing up $LOGIN_CONFIG to $LOGIN_CONFIG_BACKUP"
		cp $LOGIN_CONFIG $LOGIN_CONFIG_BACKUP
	fi

	echo "To Restore: cp $LOGIN_CONFIG_BACKUP"
	
	sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 90/g' $LOGIN_CONFIG
	sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 10/g' $LOGIN_CONFIG
	sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE  7/g' $LOGIN_CONFIG

	echo "Edited $LOGIN_CONFIG"
	echo "----Diff----"
	git diff --unified=0 --no-index $LOGIN_CONFIG_BACKUP $LOGIN_CONFIG
fi
#-----END------#

#----LIBPAM REQUIREMENTS----#
  echo "LIBPAM "
echo 
    read -p "Continue (y/n)? "
echo 
#If prompt is no >
if [[ $REPLY =~ n ]]; then
    exit 
fi

if [[ $REPLY =~ y ]]; then
	echo "running script"
	sudo apt-get -y install libpam-cracklib

    PW_CONFIG="/etc/pam.d/common-password"
    PW_CONFIG_BACKUP="$PW_CONFIG.backup"

	if ! [[ -f "$PW_CONFIG_BACKUP" ]]; then
		echo "backing up $PW_CONFIG to $PW_CONFIG_BACKUP"
		cp $PW_CONFIG $PW_CONFIG_BACKUP
	fi

    sed -i '1 s/^/password requisite pam_cracklib.so retry=3 minlen=8 difok=3 reject_username minclass=3 maxrepeat=2 dcredit=1 ucredit=1 lcredit=1 ocredit=1\n/' $PW_CONFIG

	echo "Edited $PW_CONFIG"
	echo "----Diff----"
	git diff --unified=0 --no-index $PW_CONFIG_BACKUP $PW_CONFIG
fi
#---------END----------#


#--------------END---------------#

#-----LOOKING $ FILES-----#
for suffix in mp3 txt wav wma aac mp4 mov avi gif jpg png bmp img exe msi bat sh
do
  sudo find /home -name *.$suffix
done
#----END----#

#----SERVICES----#

# MySQL
echo -n "MySQL [Y/n] "
read option
if [[ $option =~ ^[Yy]$ ]]; then
  sudo apt-get -y install mysql-server
  # Disable remote access
  sudo sed -i '/bind-address/ c\bind-address = 127.0.0.1' /etc/mysql/my.cnf
  sudo service mysql restart
    else
  sudo apt-get -y purge mysql*
fi

# OpenSSH Server
echo -n "OpenSSH Server [Y/n] "
read option
if [[ $option =~ ^[Yy]$ ]]; then
  sudo apt-get -y install openssh-server
  # Disable root login
  sudo sed -i '/^PermitRootLogin/ c\PermitRootLogin no' /etc/ssh/sshd_config
  sudo service ssh restart
    else
  sudo apt-get -y purge openssh-server*
fi

# OpenSSH Server
echo -n "OpenSSH Server [Y/n] "
read option
if [[ $option =~ ^[Yy]$ ]]; then
  sudo apt-get -y install openssh-server
  # Disable root login
  sudo sed -i '/^PermitRootLogin/ c\PermitRootLogin no' /etc/ssh/sshd_config
  sudo service ssh restart
    else
  sudo apt-get -y purge openssh-server*
fi

# VSFTPD
echo -n "VSFTP [Y/n] "
read option
if [[ $option =~ ^[Yy]$ ]]; then
  sudo apt-get -y install vsftpd
  # Disable anonymous uploads
  sudo sed -i '/^anon_upload_enable/ c\anon_upload_enable no' /etc/vsftpd.conf
  sudo sed -i '/^anonymous_enable/ c\anonymous_enable=NO' /etc/vsftpd.conf
  # FTP user directories use chroot
  sudo sed -i '/^chroot_local_user/ c\chroot_local_user=YES' /etc/vsftpd.conf
  sudo service vsftpd restart
    else
  sudo apt-get -y purge vsftpd*
fi

#Maybe purge everything then just add whats supposed to come back?
#Firefox?
#Livepatch?
