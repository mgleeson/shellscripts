#!/bin/bash
#===============================================================================
#
#          FILE: install_oracle10g.sh 
#
#         USAGE:  ./install_oracle10g.sh
#
#   DESCRIPTION: Script to automate most of the steps involved in installing Oracle10g on Centos5, 
#                ostensibly in preparation for installation of Blackboard 8 Enterprise, but certainly
#                not restricted to that purpose. Based for the most part on the information learned
#                in a blog post by Kamran Agayev and some sections of his shell script installer
#                (http://kamranagayev.wordpress.com/2009/05/01/step-by-step-installing-oracle-database
#                 -10g-release-2-on-linux-centos-and-automate-the-installation-using-linux-shell-script/
#                 ...or http://bit.ly/V4um6+)
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Matthew M. Gleeson (), matt@mattgleeson.net
#       COMPANY:  M.M.Gleeson Freelance Web Programmer
#       VERSION:  1.0
#       CREATED:  06/07/2009 02:48:11 PM CEST
#      REVISION:  ---
#===============================================================================



########———— Installing Rpm files —–########

# must run as root
Check_if_root ()      
{                   
if [ "$(id -u)" != "0" ]; then
    echo "current UID = $(id -u) -- Root UID = 0"
     echo "Must be root to run this script."
     exit 1
  fi
} 


#Install all packages that are not installed during OS installation and that are required packages for Oracle Database 10gR2
mkr="##_#_#"

Check_if_root

echo "Installing rpm packages …"

what="compat-db-4.2.52-5.1.i386"
rpm -Uvh "$(find ./ -name compat-db*)"
echo "$?"
     if [ $? -eq 0 ]; then # if good
          echo "OK!               compat-db-4.2.52-5.1.i386 installed successfully!"
     else
          if [ $? != 127 ]; then
               echo "ERROR!          $what update FAIL!"
               exit 1         
          else
          echo "OK! Already installed"
          fi
     fi
     unset what
    

what="sysstat-7.0.2-1.el5.i386"    
rpm -Uvh "$(find ./ -name sysstat*)"
     if [ $? -eq 0 ]; then # if good
          echo "OK!               sysstat-7.0.2-1.el5.i386 installed successfully!"
     else
          if [ $? != 127 ]; then
               echo "ERROR!          $what update FAIL!"
               exit 1         
          else
          echo "OK! Already installed"
          fi
     fi
     unset what
    
    
what="libaio-devel-0.3.106-3.2.i386"
rpm -Uvh "$(find ./ -name libaio-devel*)"
     if [ $? -eq 0 ]; then # if good
          echo "OK!               libaio-devel-0.3.106-3.2.i386 installed successfully!"
     else
          if [ $? != 127 ]; then
               echo "ERROR!          $what update FAIL!"
               exit 1         
          else
          echo "OK! Already installed"
          fi
     fi
     unset what

    
what="libXp-1.0.0-8.1.el5.i386"    
rpm -Uvh "$(find ./ -name libXp-1*)"
     if [ $? -eq 0 ]; then # if good
          echo "OK!               libXp-1.0.0-8.1.el5.i386 installed successfully!"
     else
          if [ $? != 127 ]; then
               echo "ERROR!          $what update FAIL!"
               exit 1         
          else
          echo "OK! Already installed"
          fi
     fi
unset what


echo "Rpm packages installed!"
wait


#Add lines to limits.conf file
echo "Updating limits.conf file"
file="/etc/security/limits.conf"
     echo "               checking to see if $file exists..."
     if [ ! -e "$file" ]; then       #  if file not exist.
          echo "               $file doesn't exist - update FAIL!"
          exit 1    
     else
          echo "               $file does exist..."
     fi # if file exist endif
         
          echo "               first we'll check if it's been patched before"
          egrep "^$mkr" "$file" >/dev/null
          if [ $? -eq 0 ]; then # if mkr exist
               echo "               $file was already updated!"
               echo "Nothing more to do here, moving on...."
          else # if mkr not exist
               echo "               nope, not patched already, we can do it now"
               echo "               now updating $file"

## updater proper
cat >> /etc/security/limits.conf <<EOF
##_#_# Added by Oracle install script
oracle soft nproc 2047
oracle hard nproc 16384
oracle soft nofile 1024
oracle hard nofile 65536

EOF
     if [ $? -eq 0 ]; then # if good
          echo "OK!          "
          echo "limits.conf file changed successfully"
     else
          echo "ERROR!          limits.conf update FAIL!"
          exit 1
     fi

##              
fi #if mkr exist endif
unset $file


#Add lines to profile to give maximum limit for Oracle user
echo "Changing /etc/profile file …."
file="/etc/profile"
     echo "               checking to see if $file exists..."
     if [ ! -e "$file" ]; then       #  if file not exist.
          echo "               $file doesn't exist - update FAIL!"
          exit 1    
     else
          echo "               $file does exist..."
     fi # if file exist endif
         
          echo "               first we'll check if it's been patched before"
          egrep "^$mkr" "$file" >/dev/null
          if [ $? -eq 0 ]; then # if mkr exist
               echo "               $file was already updated!"
               echo "Nothing more to do here, moving on...."
          else # if mkr not exist
               echo "               nope, not patched already, we can do it now"
               echo "               now updating $file"

## updater proper
cat >> /etc/profile <<EOF
##_#_# Added by Oracle install script
if [ \$USER = "oracle" ]; then
                                                  if [ \$SHELL = "bin/ksh" ]; then
                                                                ulimit -p 16384
                                                                ulimit -n 65536
                                                  else
                                                                ulimit -u 16384 -n 65536
                                                  fi
                                                  umask 022
fi

EOF

     if [ $? -eq 0 ]; then # if good
          echo "OK!          "
          echo "$file file changed successfully"
     else
          echo "ERROR!          $file update FAIL!"
          exit 1
     fi
## end updater proper    
fi #if mkr exist endif
unset $file         


#Add line to /etc/pam.d/login file
echo "Changing /etc/pam.d/login file …"
file="/etc/pam.d/login"
     echo "               checking to see if $file exists..."
     if [ ! -e "$file" ]; then       #  if file not exist.
          echo "               $file doesn't exist - update FAIL!"
          exit 1    
     else
          echo "               $file does exist..."
     fi # if file exist endif
         
          echo "               first we'll check if it's been patched before"
          egrep "^$mkr" "$file" >/dev/null
          if [ $? -eq 0 ]; then # if mkr exist
               echo "               $file was already updated!"
               echo "Nothing more to do here, moving on...."
          else # if mkr not exist
               echo "               nope, not patched already, we can do it now"
               echo "               now updating $file"

## updater proper
cat >> /etc/pam.d/login <<EOF
##_#_# Added by Oracle install script
session required /lib/security/pam_limits.so

EOF

     if [ $? -eq 0 ]; then # if good
          echo "OK!          "
          echo "$file file changed successfuly"
     else
          echo "ERROR!          update FAIL!"
          exit 1
     fi

## end updater proper
fi #if mkr exist endif
unset $file


#Add some kernel parameters to /etc/sysctl.conf file
echo "Changing kernel parameters … "
file="/etc/sysctl.conf"
     echo "               checking to see if $file exists..."
     if [ ! -e "$file" ]; then       #  if file not exist.
          echo "               $file doesn't exist - update FAIL!"
          exit 1    
     else
          echo "               $file does exist..."
     fi # if file exist endif
         
          echo "               first we'll check if it's been patched before"
          egrep "^$mkr" "$file" >/dev/null
          if [ $? -eq 0 ]; then # if mkr exist
               echo "               $file was already updated!"
               echo "Nothing more to do here, moving on...."
          else # if mkr not exist
               echo "               nope, not patched already, we can do it now"
               echo "               now updating $file"

## updater goes here
cat >> /etc/sysctl.conf <<EOF
##_#_# Added by Oracle install script
kernel.shmmax = 2147483648
kernel.shmall = 2097152
kernel.shmmni=4096
kernel.sem=250 32000 100 128
fs.file-max=65536
net.ipv4.ip_local_port_range=1024 65000
net.core.rmem_default=1048576
net.core.rmem_max=1048576
net.core.wmem_default=262144
net.core.wmem_max=262144

EOF

     if [ $? -eq 0 ]; then # if good
          echo "OK!          "
          echo "Kernel parameters changed successfully"
     else
          echo "ERROR!          update FAIL!"
          exit 1
     fi
## end updater          
fi #if mkr exist endif
unset $file


#Save all new kernel parameters
/sbin/sysctl -p
     if [ $? -eq 0 ]; then # if good
          echo "OK!          "
          echo "all new kernel parameters saved successfuly"
     else
          echo "ERROR!          kernel parameters save FAIL!"
          exit 1
     fi


#Add "redhat-4? line to /etc/redhat-release file
echo "Changing /etc/redhat-release file …"
cp /etc/redhat-release /etc/redhat-release.original
echo "redhat-4? > /etc/redhat-release"

     if [ $? -eq 0 ]; then # if good
          echo "OK!          "
          echo "/etc/redhat-release file changed successfully"
     else
          echo "ERROR!          update FAIL!"
          exit 1
     fi




#Create new groups and "oracle" user and add this user to group

# echo "Creating new groups and ‘oracle’ user …"

# groupadd oinstall

# groupadd dba

# useradd -m -g oinstall -G dba -d /home/oracle -s /bin/bash -c "Oracle Software Owner" oracle

# passwd oracle

# echo "Groups and user created successfully"

#Adding Environment Variables

echo "Adding Environment Variables"
file="/usr/local/oracle/.bashrc"
     echo "               checking to see if $file exists..."
     if [ ! -e "$file" ]; then       #  if file not exist.
          echo "               $file doesn't exist - update FAIL!"
          exit 1    
     else
          echo "               $file does exist..."
     fi # if file exist endif
         
          echo "               first we'll check if it's been patched before"
          egrep "^$mkr" "$file" >/dev/null
          if [ $? -eq 0 ]; then # if mkr exist
               echo "               $file was already updated!"
               echo "Nothing more to do here, moving on...."
          else # if mkr not exist
               echo "               nope, not patched already, we can do it now"
               echo "               now updating $file"

## updater goes here
cat >> /usr/local/oracle/.bashrc <<EOF
##_#_# Added by Oracle install script
export ORACLE_HOME=/usr/local/oracle/oracle/product/10.2.0/db_1
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME/lib
export PATH=$ORACLE_HOME/bin:$PATH
alias bb=`export ORACLE_SID=bbsid;sqlplus "/ as sysdba"`
export ORACLE_SID=bbsid

EOF

     if [ $? -eq 0 ]; then # if good
          echo "OK!          "
          echo "environment variables updated successfuly"
     else
          echo "ERROR!          update FAIL!"
          exit 1
     fi

##              
fi #if mkr exist endif
unset $file


#Unzip setup of Oracle
what="Unzipping setup of Oracle 10g Release 2"
echo "Unzipping setup of Oracle 10g Release 2…. "
unzip 10201_database_linux32.zip
     if [ $? -eq 0 ]; then # if  good
          echo -en '\E[47;32m'"\033[1mOK\033[0m"   # Green
          tput sgr0
          echo "          $what successful!"
     else
          echo -en '\E[47;31m'"\033[1mERROR\033[0m"   # Red
          tput sgr0
          echo "          $what FAIL!"
          exit 1
     fi

#Enter to installation directory and run the installation …

echo "Installation begins …"

cd /tmp/install/database

chmod 755 runInstaller

chmod 755 install/.oui

chmod 755 install/unzip

xhost +

what="oracle installer"
sudo -u oracle /tmp/install/database/runInstaller
     if [ $? -eq 0 ]; then # if  good
          echo -en '\E[47;32m'"\033[1mOK\033[0m"   # Green
          tput sgr0
          echo "          $what successful!"
     else
          echo -en '\E[47;31m'"\033[1mERROR\033[0m"   # Red
          tput sgr0
          echo "          $what FAIL!"
          exit 1
     fi
unset what

what="chown /usr/local/oracle to oracle:dba"
chown -R oracle:dba /usr/local/oracle
     if [ $? -eq 0 ]; then # if  good
          echo "OK!          $what successful!"
     else
          echo "ERROR!          $what FAIL!"
          exit 1
     fi
unset what

what="dbstart"
sudo -u oracle dbstart
     if [ $? -eq 0 ]; then # if  good
          echo -en '\E[47;32m'"\033[1mOK\033[0m"   # Green
          tput sgr0
          echo "          $what successful!"
     else
          echo -en '\E[47;31m'"\033[1mERROR\033[0m"   # Red
          tput sgr0
          echo "          $what FAIL!"
          exit 1
     fi
unset what

what="run rstrconn.sql"
ORACLE_SID=bbsid; export ORACLE_SID
sudo -u oracle sqlplus /nolog <<EOF
connect /as sysdba
whenever sqlerror exit 42
@$ORACLE_HOME/rdbms/admin/rstrconn.sql
EOF
# sudo -u oracle sqlplus -s '/ as sysdba'<<<$(printf "whenever sqlerror exit 42\n@$ORACLE_HOME/rdbms/admin/rstrconn.sql\nexit 0")||echo "exit status $?"
     if [ $? -eq 0 ]; then # if  good
          echo -en '\E[47;32m'"\033[1mOK\033[0m"   # Green
          tput sgr0
          echo "          $what successful!"
     else
          echo -en '\E[47;31m'"\033[1mERROR\033[0m"   # Red
          tput sgr0
          echo "          $what FAIL!"
          exit 1
     fi
unset what

echo "all good!"
exit 0
