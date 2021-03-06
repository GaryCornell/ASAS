#!/bin/bash
#################################################################################
#                   *** ASAS 2.10 [Auto Server Admin Script] ***                #
#        @author: Gary Cornell for devCU Software Open Source Projects          #
#        @contact: gary@devcu.com                                               #
#        $OS: Debian Core (Tested on Ubuntu 18x -> 20x / Debian 9.x -> 10.x)     #
#        $MAIN: https://www.devcu.com                                           #
#        $SOURCE: https://github.com/GaalexxC/ASAS                              #
#        $REPO: https://www.devcu.net                                           #
#        +Created:   06/15/2016 Ported from nginxubuntu-php7                    #
#        &Updated:   12/25/2020 11:56 EDT                                       #
#                                                                               #
#    This program is free software: you can redistribute it and/or modify       #
#    it under the terms of the GNU General Public License as published by       #
#    the Free Software Foundation, either version 3 of the License, or          #
#    (at your option) any later version.                                        #
#                                                                               #
#    This program is distributed in the hope that it will be useful,            #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
#    GNU General Public License for more details.                               #
#                                                                               #
#    You should have received a copy of the GNU General Public License          #
#    along with this program.  If not, see http://www.gnu.org/licenses/         #
#                                                                               #
#################################################################################
clear

      if [ ! -f $CURDIR/$LOGS/vsftpd-error-$CURDAY.log ]
       then
       touch $CURDIR/$LOGS/vsftpd-error-$CURDAY.log
      fi
      if [ ! -f $CURDIR/$LOGS/vsftpd-$CURDAY.log ]
       then
       touch $CURDIR/$LOGS/vsftpd-$CURDAY.log
      fi

while [ 5 ]
do

SELECTFTP=$(
whiptail --title "vsFTPd Installer" --radiolist "\nUse up/down arrows and space to select\nUpon selection operation will begin without prompts" 20 78 10 \
        "1)" "Install vsFTPd" ON \
        "2)" "Configure vsFTPd Settings" OFF \
        "3)" "Backup Config (vsftpd.conf)" OFF \
        "4)" "View Debug Log" OFF \
        "5)" "View Error Log" OFF \
        "6)" "View vsFTPd server Log" OFF \
        "7)" "Remove vsFTPd (Config Saved)" OFF \
        "8)" "Purge vsFTPd (Wipe Clean)" OFF \
        "9)" "Return to Main Menu" OFF \
        "10)" "Exit" OFF 3>&1 1>&2 2>&3
)

case $SELECTFTP in
        "1)")
      if ! type vsftpd > /dev/null 2>&1; then
          package() {
           printf "apt --yes install vsftpd"
         }
          systemInstaller
          vsftpdConfFile
          vsftpdRestart
          ftpver=$(vsftpd -v 0>&1)
          whiptail --title "vsFTPd Installed" --msgbox "$ftpver installed\nvsFTPd has been configured on default port 23452\nYou can change this and other settings from menu" --ok-button "OK" 12 70
       else
          ftpver=$(vsftpd -v 0>&1)
          whiptail --title "vsFTPd Check-Install" --msgbox "vsFTPd Installed!\n\n$ftpver" --ok-button "OK" 10 70
      fi
        ;;

        "2)")

      if type vsftpd > /dev/null 2>&1; then
         source $CURDIR/scripts/vsftpd_configure.sh
       else
         whiptail --title "vsFTPd Check" --msgbox "vsFTPd is not installed" --ok-button "OK" 10 70
      fi
       ;;

        "3)")
      if type vsftpd > /dev/null 2>&1; then
         vsftpdbackupconf
       else
         whiptail --title "vsFTPd Check" --msgbox "vsFTPd is not installed" --ok-button "OK" 10 70
      fi
       ;;

        "4)")
         whiptail --textbox $CURDIR/$LOGS/vsftpd-$CURDAY.log 24 78 10
       ;;

        "5)")
         whiptail --textbox $CURDIR/$LOGS/vsftpd-error-$CURDAY.log 24 78 10
       ;;

        "6)")
         whiptail --textbox /var/log/vsftpd.log 24 78 10
       ;;

        "7)")
      if type vsftpd > /dev/null 2>&1; then
        package() {
          printf "apt --yes remove vsftpd"
        }
        systemInstaller
        sleep 1
        pkgcache() {
           printf "apt-get --yes autoremove"
        }
        updateSources
        sleep 1
       else
         whiptail --title "vsFTPd Check" --msgbox "vsFTPd is not installed" --ok-button "OK" 10 70
      fi
        ;;

        "8)")
      if type vsftpd > /dev/null 2>&1; then
        package() {
          printf "apt --yes purge vsftpd"
        }
        systemInstaller
        sleep 1
        pkgcache() {
           printf "apt-get --yes autoremove"
        }
        updateSources
        rm -rf /var/log/vsftpd.log
        sleep 1
       else
         whiptail --title "vsFTPd Check" --msgbox "vsFTPd is not installed" --ok-button "OK" 10 70
      fi
        ;;
        "9)")

       return
        ;;

        "10)")

       exit 1
        ;;
  esac

 done

exit
