#!/bin/bash
# ASAS 2.10
# @author: GCornell for devCU Software
# @contact: gacornell@devcu.com
# Compatibility: Debian Core Systems (Tested on Ubuntu 14x-16x-17x & Debian 8/9)
# MAIN: https://www.devcu.com
# CODE: https://github.com/GaalexxC/ASAS
# REPO: https://www.devcu.net
# License: GNU General Public License v3.0
# Created:   06/15/2016
# Updated:   09/27/2017

clear

#Nginx Install Menu

while [ 3 ]
do

SELECTNGINX=$(
whiptail --title "Nginx Web Server Installer" --radiolist "\nUse up/down arrows and tab to select an Nginx version\nUpon selection operation will begin without prompts" 20 78 7 \
        "1)" "Nginx Latest Mainline (Recommended)" ON \
        "2)" "Nginx Latest Stable" OFF \
        "3)" "Build Nginx source with Openssl (Advanced)" OFF \
        "4)" "Remove Nginx (Preserves Configurations)" OFF \
        "5)" "Purge Nginx (WARNING! Removes Everything!)" OFF \
        "6)" "Generate 2048bit Diffie-Hellman (Required for Nginx SSL/TLS)" OFF \
        "7)" "Return to Main Menu"  OFF 3>&1 1>&2 2>&3
)

case $SELECTNGINX in
        "1)")

      return
        ;;

        "2)")
# Install and/or upgrade Nginx to stable
      echo -e  "\nDo you want to install Nginx Stable(y/n)"
      read INSTALLNGINX
   if [ $INSTALLNGINX == "y" ]; then
      echo -e  "\nChecking if Nginx stable repo exists"
   if grep -q $NGINX_STABLE $APT_SOURCES; then
      echo "Great! we found '$NGINX_STABLE' lets install:"
      echo -e  "\nLooking for latest nginx, this may take a few seconds..."
      apt -qq update
      apt install nginx fcgiwrap -y
      nginx -v
      echo -e "\nNginx Installed"
   else
      echo "We couldnt find '$NGINX_STABLE' adding it now and updating:"
      echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" >> $APT_SOURCES
      echo "deb-src http://nginx.org/packages/ubuntu/ xenial nginx" >> $APT_SOURCES
      apt clean
      echo "Grabbing signing key"
      curl -O https://nginx.org/keys/nginx_signing.key && apt-key add ./nginx_signing.key
      echo -e  "\nLooking for nginx, this may take a few seconds..."
      apt -qq update
      apt-get install nginx fcgiwrap -y
      nginx -v
      echo -e "\nNginx installed successfully\n"
   fi
   else
      echo -e "\nSkipping Nginx stable install\n"
   fi

# -------
# NGINX CONFIG:
# -------
      if [ $INSTALLNGINX == "y" ]; then
        echo -e "\nMaking backup of original nginx.conf"
        sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
        echo -e "\nUpdating nginx.conf with cache optimization and secure rules\n"
        CONFIGCONF='/etc/nginx/'
        cp config/nginx/nginx.conf $CONFIGCONF 2>/dev/null
        sleep 1
        echo -e "\nCreate nginx $NGINX_SITES_AVAILABLE if doesnt exist"
      if [ -d "$NGINX_SITES_AVAILABLE" ]
      then
        echo -e "\nDirectory $NGINX_SITES_AVAILABLE exists."
      else
        mkdir -p $NGINX_SITES_AVAILABLE
        echo -e "\nFinished directory creation"
      fi
        sleep 1
        echo -e "\nCreate nginx $NGINX_SITES_ENABLED if doesnt exist"
      if [ -d "$NGINX_SITES_ENABLED" ]
      then
        echo -e "\nDirectory $NGINX_SITES_ENABLED exists."
      else
        mkdir -p $NGINX_SITES_ENABLED
        echo -e "\nFinished directory creation"
      fi
        sleep 1
        echo -e "\nCreate nginx $NGINX_CONFD if doesnt exist"
      if [ -d "$NGINX_CONFD" ]
      then
        echo -e "\nDirectory $NGINX_CONFD exists."
      else
        mkdir -p $NGINX_CONFD
        echo -e "\nFinished directory creation"
      fi
        sleep 1
# -------
# NGINX VHOST:
# -------
        echo -e "\nCreate nginx vhosts.conf if doesnt exist"
      if [ -f /etc/nginx/conf.d/vhosts.conf ]
      then
        echo -e "\nGreat! the file exists"
      else
        echo -e "\nThe file doesnt exist, creating..."
        touch /etc/nginx/conf.d/vhosts.conf
        echo "include /etc/nginx/sites-enabled/*.vhost;" >>/etc/nginx/conf.d/vhosts.conf
      fi
        echo -e "\nFinished vhosts.conf creation"
        sleep 1
# Create, chown and optimize nginx cache/gzip directories!
        echo -e "\nCreate, chown and optimize nginx cache/gzip directories"
        mkdir -p /var/cache/nginx
        mkdir -p /var/cache/nginx/fcgi
        mkdir -p /var/cache/nginx/tmp
        chown -R www-data:root /var/cache/nginx
        echo -e "\nOperation Complete"
        echo -e "\nRestart Services\n"
         $NGINX_INIT
      else
        echo -e "\nSkipping Nginx directory setup"
      fi
        echo
        echo
         read -p "Hit [ENTER] to return to Nginx menu..."
        ;;

        "3)")

      return
        ;;

        "4)")

         sudo apt remove `dpkg -l | grep nginx| awk '{print $2}' |tr "\n" " "`
         sudo apt autoremove
         read -p "Nginx has been removed, configurations preserved\n\nPress [Enter] to return to main menu"
      return
        ;;

        "5)")

         sudo apt purge `dpkg -l | grep nginx| awk '{print $2}' |tr "\n" " "`
         sudo apt autoremove
         rm -rf /etc/nginx
         read -p "Nginx has been removed from the system\n\nPress [Enter] to return to main menu"
      return
        ;;

        "6)")
      if [ -f /etc/ssl/certs/dhparam.pem ]
      then
        whiptail --title "Security Check-Modify" --msgbox "Diffie-Hellman cert already exists!\nPATH is configured in nginx vhost templates\n\nPress [Enter] to return to Nginx menu" --ok-button "OK" 10 70
      else
      secureCommand() {
         output='openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048'
         printf "$output"
       }
      secureApp() {
         printf "openssl"
       }
        secureCheckModify
        whiptail --title "Security Check-Modify" --msgbox "Diffie-Hellman cert @ /etc/ssl/certs/dhparam.pem\nPATH is configured in nginx vhost templates\n\nPress [Enter] to return to Nginx menu" --ok-button "OK" 10 70
      fi
        ;;

        "7)")

      return
        ;;

    esac

  done

exit

