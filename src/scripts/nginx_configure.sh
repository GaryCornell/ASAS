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

while [ 1 ]
do
NGINXSETTINGS=$(
whiptail --title "Nginx Configuration" --menu "\nConfigure most common settings below\nEdit nginx.conf manually for extended options" 20 78 10 \
        "1)" "Nginx worker_processes (Default:4)"   \
        "2)" "Nginx worker_connections (Default:2500)" \
        "3)" "Nginx worker_rlimit_nofile (Default:20000)"  \
        "4)" "Nginx keepalive_timeout (Default:60)" \
        "5)" "Nginx fastcgi_read_timeout (Default:300)" \
        "6)" "Nginx client_header_timeout (Default:15m)" \
        "7)" "Nginx client_body_timeout (Default:15m)" \
        "8)" "Nginx client_max_body_size (Default:20M)" \
        "9)" "Enable/Disable sendfile (Default:Off)" \
        "10)" "Nginx send_timeout (Default:15m)" \
        "11)" "Enable/Disable gzip (Default:On)" \
        "12)" "Enable/Disable Server Tokens (Default:Off)" \
        "13)" "Nginx limit_rate_after (Default:4m)" \
        "14)" "Nginx limit_rate (Default:100k)" \
        "15)" "Return to Nginx Menu" \
        "16)" "Return to Main Menu" \
        "17)" "Exit"  3>&2 2>&1 1>&3
)

case $NGINXSETTINGS in
        "1)")
          nginxworkerproc
        ;;

        "2)")
          nginxworkerconn
        ;;

        "3)")
          nginxworkerrlimit
        ;;

        "4)")
          nginxkeepalive
        ;;

        "5)")
          nginxfastcgiread
        ;;

        "6)")
          nginxclientheader
        ;;

        "7)")
          nginxclientbody
        ;;

        "8)")
          nginxclientmaxbody
        ;;

        "9)")
          nginxsendfileswitch
        ;;

        "10)")
          nginxsendtimeout
        ;;

        "11)")
          nginxgzipswitch
        ;;

        "12)")
          nginxtokensswitch
        ;;

        "13)")
          nginxlimitratetime
        ;;

        "14)")
          nginxlimitratespeed
        ;;

        "15)")
          return
        ;;

        "16)")
          asasMainMenu
        ;;

        "17)")
          exit 1
        ;;
   esac

 done

exit


