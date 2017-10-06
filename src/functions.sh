#!/bin/bash
#################################################################################
#                   *** ASAS 2.10 [Auto Server Admin Script] ***                #
#        @author: GCornell for devCU Software Open Source Projects              #
#        @contact: gacornell@devcu.com                                          #
#        $OS: Debian Core (Tested on Ubuntu 14x -> 17x / Debian 8.x -> 9.x)     #
#        $MAIN: https://www.devcu.com                                           #
#        $SOURCE: https://github.com/GaalexxC/ASAS                              #
#        $REPO: https://www.devcu.net                                           #
#        +Created:   06/15/2016 Ported from nginxubuntu-php7                    #
#        &Updated:   10/05/2017 02:08 EDT                                       #
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
#*****************************
#
# Global Functions
#
#*****************************
## NEWT Color palette for ASAS whiptail GUI ##
readarray -t newtcolor < bin/palette
NEWT_COLORS="${newtcolor[@]}"

validateRoot() {
    if [ "$(id -u)" != "0" ]; then
       whiptail --title "System Check" --msgbox "\nYou need to be root to run this script.\nPress [Enter] to exit\nBye Bye" --ok-button "Exit" 10 70
       exit 1
    else
       whiptail --title "System Check" --msgbox "Root User Confirmed\nPress [Enter] to continue" --ok-button "Continue" 10 70
    fi
}

completeOperation() {
whiptail --title "Operation Complete" --msgbox "Operation Complete\nPress [Enter] to return to menu" --ok-button "OK" 10 70
}

cancelOperation() {
whiptail --title "Operation Cancelled" --msgbox "Operation Cancelled\nPress [Enter] to return to menu" --ok-button "OK" 10 70
}

rebootRequired() {
  if [ -f /var/run/reboot-required ]; then
    whiptail --title "Reboot Required" --msgbox "Your Kernel was modified a reboot is required\nPress [Enter] to reboot" --ok-button "Reboot" 10 70
    reboot
  fi
}

# Work In Progress for bug patch
phpDependencies() {
apt install -y language-pack-en-base &&
export LC_ALL=en_US.UTF-8 &&
export LANG=en_US.UTF-8 &&
apt install -y software-properties-common &&
add-apt-repository ppa:ondrej/php &&
apt update
}

#LicenseView() {
#}

lowercase() {
        echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

clean_string() {
        clean=$1
        clean=${clean//\"/}
        echo $clean
}

#*****************************
#
# System Detect Functions
#
#*****************************
systemDetect()
{
	OS=`lowercase \`uname\``
        KERNEL=`uname -r`
        ARCH=`uname -m`
        declare -a osdist=( Debian Ubuntu )
        declare -a osrev=( 8 9 14.04 15.10 16.04 16.10 17.04 17.10 )

        if [ "${OS}" = "linux" ] ; then
                if [ -f /etc/debian_version ]; then
                        DistroBaseCore='Debian'
                        DISTRO=`cat /etc/*-release | grep '^NAME' | awk -F=  '{ print $2 }'`
                        VERSION=`cat /etc/*-release | grep '^VERSION_ID' | awk -F=  '{ print $2 }'`
                        CODENAME=`lsb_release -c --short`
                        RELEASE=`cat /etc/*-release | grep '^PRETTY_NAME' | awk -F=  '{ print $2 }'`
                        DISTRIB_CODENAME=`cat /etc/*-release | grep '^DISTRIB_CODENAME' | awk -F=  '{ print $2 }'`
                        fi
                fi

        OS=`lowercase $OS`
        DISTRO=`clean_string $DISTRO`
        DistroBaseCore=`clean_string "$DistroBaseCore"`
        CODENAME=`clean_string "$CODENAME"`
        RELEASE=`clean_string "$RELEASE"`
        VERSION=`clean_string $VERSION`
        KERNEL=`clean_string "$KERNEL"`
        ARCH=`clean_string "$ARCH"`

        readonly OS
        readonly DISTRO
        readonly DistroBaseCore
        readonly CODENAME
        readonly VERSION
        readonly RELEASE
        readonly KERNEL
        readonly ARCH
        if [[ "${osdist[*]}" =~ "$DISTRO"  && "${osrev[*]}" =~ "$VERSION" ]] ; then
                whiptail --title "System Detect" --msgbox "OS: $OS\nDistribution: $DISTRO\nVersion: $VERSION\nCodename: $CODENAME\nCommonName: $RELEASE\nDistroBaseCore: $DistroBaseCore\nKernel: $KERNEL\nArchetecture: $ARCH\n\nGreat $DISTRO - $VERSION is supported" --ok-button "Continue" 16 70 6
        else
                whiptail --title "System Detect" --msgbox "OS: $OS\nDistribution: $DISTRO\nVersion: $VERSION\nCodename: $CODENAME\nCommonName: $RELEASE\nDistroBaseCore: $DistroBaseCore\nKernel: $KERNEL\nArchetecture: $ARCH\n\nSorry $DISTRO - $VERSION is not supported" --ok-button "Exit" 16 70 6
        exit 1
        fi
}

#*****************************
#
# System Functions
#
#*****************************
systemInstaller() {
pkg=0
$(package) 2> /dev/null | \
    tr '[:upper:]' '[:lower:]' | \
while read x; do
    case $x in
        *upgraded*newly*)
            u=${x%% *}
            n=${x%% newly installed*}
            n=${n##*upgraded, }
            r=${x%% to remove*}
            r=${r##*installed, }
            pkgs=$((u*2+n*2+r))
            pkg=0
        ;;
        unpacking*|setting\ up*|updating*|installing*|found*|removing*\ ...)
            if [ $pkgs -gt 0 ]; then
                pkg=$((pkg+1))
                x=${x%% (*}
                x=${x%% ...}
                x=$(echo ${x:0:1} | tr '[:lower:]' '[:upper:]')${x:1}
                sleep .25
                printf "XXX\n$((pkg*100/pkgs))\n\n${x} ...\nXXX\n$((pkg*100/pkgs))\n"
            fi
        ;;
    esac
done | whiptail --title "ASAS System Installer"  --gauge "\nChecking Packages..." 10 70 0
}

# TODO
# ** Debian 8x/9x no longer support update-notifier Damn Them! This is a bit messy IMO **
# ** Maybe code something more efficient and elegant if possible in future. Looks like **
# ** a bird sanctuary with all the nesting going on. elif may be more friendly??? **
systemUpgrades() {
    UPGRADECHECK=$(apt-get -s upgrade | grep -Po "^\d+ (?=upgraded)" 2>&1)
  if [ "$UPGRADECHECK" -gt 0 ]; then
   if [ "$DISTRO" = "Ubuntu" ]; then
    UPGRADES=$(/usr/lib/update-notifier/apt-check 2>&1)
    upsecurity=$(echo "${UPGRADES}" | cut -d ";" -f 2)
    upnonsecurity=$(echo "${UPGRADES}" | cut -d ";" -f 1)
    totalupgrade=$((upsecurity + upnonsecurity))
    if (whiptail --title "System Check" --yesno "$totalupgrade Updates are available\n$upsecurity are security updates\nWould you like to update now (Recommended)" --yes-button "Update" --no-button "Skip" 10 70) then
      package() {
         echo "apt --yes --force-yes upgrade"
       }
      systemInstaller
      rebootRequired
      completeOperation
   else
      return
    fi
   fi
   if [ "$DISTRO" = "Debian" ]; then
    if (whiptail --title "System Check" --yesno "$UPGRADECHECK Updates are available\n\nWould you like to update now (Recommended)" --yes-button "Update" --no-button "Skip" 10 70) then
      package() {
         printf "apt --yes --force-yes upgrade"
       }
     systemInstaller
     rebootRequired
     completeOperation
   else
      return
    fi
   fi
   else
     whiptail --title "System Check" --msgbox "System is up to date\n\nPress [Enter] for main menu..." --ok-button "OK" 10 70
     return
  fi
}

#*****************************
#
# Check Install
#
#*****************************
whiptailInstallCheck() {
   if ! type whiptail > /dev/null 2>&1; then
      echo -e "\n\nDependency Check...${RED}Whiptail not installed${NOCOL}"
      sleep 1.5
      echo -e "\nInstalling Whiptail - required by this script"
      apt install whiptail -y
      echo -e "\n${GREEN}Whiptail successfully installed${NOCOL}\n\n"
      sleep 2
   else
       whipver=$(whiptail -v 2>&1)
       echo -e "\n\nDependency Check..."
       sleep 1
       echo -e "\n${GREEN}Great! $whipver is installed${NOCOL}\n\n"
       sleep 1.5
   fi
}

emailCheckInstall() {
   if ! type postfix > /dev/null 2>&1; then
     if (whiptail --title "Postfix Check" --yesno "Postfix not installed\nDo you want to install?" --yes-button "Install" --no-button "Cancel" 10 70) then
        source scripts/mail_server.sh
    else
         return
     fi
   else
        postver=$(postfix -v)
        whiptail --title "Postfix Check" --msgbox "$postver is already installed\n\nPress [Enter] to return to main menu" --ok-button "OK" 10 70
        return
   fi
}

bindCheckInstall() {
   if ! type named > /dev/null 2>&1; then
     if (whiptail --title "Bind9 Check" --yesno "Bind9 not installed\nDo you want to install?" --yes-button "Install" --no-button "Cancel" 10 70) then
        source scripts/bind9_install.sh
    else
         return
     fi
   else
        bindver=$(named -v)
        whiptail --title "Bind9 Check" --msgbox "$bindver is already installed\nPress [Enter] to return to main menu" --ok-button "OK" 10 70
        return
   fi
}

mysqlCheckInstall() {
   if ! type mysql > /dev/null 2>&1; then
     if (whiptail --title "MySQL Check" --yesno "MySQL not installed\nDo you want to install?" --yes-button "Install" --no-button "Cancel" 10 70) then
        source scripts/mysql_install.sh
    else
	 return
     fi
    else
        dbver=$(mysql -V 2>&1)
        whiptail --title "MySQL Check" --msgbox "$dbver is currently installed\n\nPress [Enter] to return to main menu" --ok-button "OK" 10 70
        return
   fi
}

nginxCheckInstall() {
   if ! type nginx > /dev/null 2>&1; then
        whiptail --title "Nginx Check-Install" --msgbox "Nginx not installed\nPress [Enter] to continue" --ok-button "OK" 10 70
        source scripts/nginx_install.sh
   else
        ngxver=$(nginx -v 2>&1)
        whiptail --title "Nginx Check" --msgbox "$ngxver is currently installed\nPress [Enter] to continue" --ok-button "OK" 10 70
        source scripts/nginx_install.sh
   fi
}

nginxCheckCompile() {
   if ! type nginx > /dev/null 2>&1; then
     if (whiptail --title "Nginx Check" --yesno "Nginx not installed\nDo you want to install?" --yes-button "Install" --no-button "Cancel" 10 70) then
        source scripts/nginx_compile.sh &&
        source scripts/nginx_configure.sh | grep -v 'omitting directory'
    else
         return
     fi
   else
        ngxver=$(nginx -v 2>&1)
        whiptail --title "Nginx Check" --msgbox "$ngxver is currently installed\nPress [Enter] to return to main menu" --ok-button "OK" 10 70
        return
   fi
}

phpCheckInstall() {
   if ! type php > /dev/null 2>&1; then
        whiptail --title "PHP Check-Install" --msgbox "PHP not installed\nPress [Enter] to continue" --ok-button "OK" 10 70
        source scripts/php_install.sh
   else
        phpver=$(php -r \@phpinfo\(\)\; | grep 'PHP Version' -m 1)
        whiptail --title "PHP Check-Install" --msgbox "$phpver is currently installed\nPress [Enter] to continue" --ok-button "OK" 10 70
        source scripts/php_install.sh
   fi
}

vsftpdCheckInstall() {
   if ! type vsftpd > /dev/null 2>&1; then
     if (whiptail --title "vsFTPd Check" --yesno "vsFTPd not installed\nDo you want to install?" --yes-button "Install" --no-button "Cancel" 10 70) then
         source scripts/ftp_install.sh
    else
         return
     fi
   else
        ftpver=$(vsftpd -v 0>&1)
        whiptail --title "vsFTPd Check" --msgbox "$ftpver is currently installed\n\nPress [Enter] to return to main menu" --ok-button "OK" 10 70
        return
   fi
}

#systemCheckInstall() {
#}

#securityCheckInstall() {
#}

#clientCheckInstall() {
#}

#*****************************
#
# Check Compile
#
#*****************************

#*****************************
#
# Security Functions
#
#*****************************
secureCheckModify() {
{
        i="0"
            $(secureCommand) 2> /dev/null &
            sleep 2
            while (true)
            do
            proc=$(ps aux | grep -v grep | grep -e "$(secureApp)")
            if [[ "$proc" == "" ]] && [[ "$i" -eq "0" ]];
            then
                break;
            elif [[ "$proc" == "" ]] && [[ "$i" -gt "0" ]];
            then
                sleep .5
                echo 95
                sleep 1.5
                echo 99
                sleep 1.5
                echo 100
                sleep 2
                break;
            elif [[ "60" -eq "$i" ]]
            then
                i="40"
            fi
            sleep 1
            i=$(expr $i + 1)
            z=$(echo "$output")
            printf "XXX\n$i\n\nGenerating dhparam.pem file... ${z}\nXXX\n$i\n"
        done
  } | whiptail --title "Security Check-Modify"  --gauge "\nGenerating DH parameters, 2048 bit long safe prime, generator 2\nThis is going to take a long time" 10 70 0
}

#*****************************
#
# Update Source List Functions
#
#*****************************
updateSources() {
         i=0
         $(pkgcache) 2> /dev/null | \
         tr '[:upper:]' '[:lower:]' | \
            while read x; do
            case $x in
        *inrelease*)
            count=4
            i=0
        ;;
            fetched*|building*|reading*|all*\ ...)
            if [[ "$count" -gt 0 ]]; then
                i=$((i+1))
                x=${x%% (*}
                x=${x%% ...}
                x=$(echo ${x:0:1} | tr '[:lower:]' '[:upper:]')${x:1}
                sleep .50
                printf "XXX\n$((i*100/count))\n\n${x}\nXXX\n$((i*100/count))\n"
           fi
        ;;
    esac
done | whiptail --title "Package Check"  --gauge "\nRefreshing package cache" 10 70 0
}

#*****************************
#
# Nginx Functions
#
#*****************************
nginxRepoAdd() {
{
    sleep 1
    echo -e "XXX\n25\n\nAdding Nginx repos... \nXXX"
    sleep 1
    echo -e "XXX\n50\n\nAdding Nginx repos... Done.\nXXX"
    sleep 1
    echo -e "XXX\n75\n\nFetch Nginx signing key... \nXXX"
    curl -O https://nginx.org/keys/nginx_signing.key 2> /dev/null &&
    apt-key add ./nginx_signing.key 2> /dev/null &
    sleep 1
    echo -e "XXX\n100\n\nFetch Nginx signing key... Done.\nXXX"
    sleep 1
  } | whiptail --title "Nginx Setup" --gauge "\nAdd Nginx repos" 10 70 0
}

nginxRemove() {
{
    sleep .75
    echo -e "XXX\n25\n\nRemoving Nginx logs... Done.\nXXX"
    rm -rf /var/log/nginx
    sleep .75
    echo -e "XXX\n50\n\nRemoving Nginx cache... Done.\nXXX"
    rm -rf /var/cache/nginx
    sleep .75
    echo -e "XXX\n75\n\nRemoving Nginx repos... \nXXX"
    rm -rf /var/lib/apt/lists/nginx*
    sed -i.bak '/nginx/d' $APT_SOURCES
    sleep .75
    echo -e "XXX\n100\n\nConfiguration preserved @ /etc/nginx... Done.\nXXX"
    sleep 1
  } | whiptail --title "Nginx Remove" --gauge "\nWiping traces of Nginx" 10 70 0
}

nginxPurge() {
{
    sleep .75
    echo -e "XXX\n20\n\nRemoving Nginx configurations... \nXXX"
    rm -rf /etc/nginx
    sleep .75
    echo -e "XXX\n40\n\nRemoving Nginx logs... Done.\nXXX"
    rm -rf /var/log/nginx
    sleep .75
    echo -e "XXX\n60\n\nRemoving Nginx cache... Done.\nXXX"
    rm -rf /var/cache/nginx
    sleep .75
    echo -e "XXX\n80\n\nRemoving Nginx repos... \nXXX"
    rm -rf /var/lib/apt/lists/nginx*
    rm -rf/usr/local/lib/x86_64-linux-gnu/perl/5.20.2/nginx.pm
    rm -rf/usr/local/lib/x86_64-linux-gnu/perl/5.20.2/auto/nginx
    sed -i.bak '/nginx/d' $APT_SOURCES
    sleep .75
    echo -e "XXX\n100\n\nAll traces cleaned... Done.\nXXX"
    sleep 1
  } | whiptail --title "Nginx Purge" --gauge "\nWiping traces of Nginx" 10 70 0
}

cleanBuild() {
{
    sleep .75
    echo -e "XXX\n10\n\nBacking up Nginx configurations... \nXXX"
    tar cvpfz /nginxconf_backup.tar.gz /etc/nginx/ 2> /dev/null
    if [ ! -d  $CURDIR/backups ]; then
    mkdir $CURDIR/backups
    fi
    mv /nginxconf_backup.tar.gz $CURDIR/backups
    rm -rf /etc/nginx
    sleep .75
    echo -e "XXX\n25\n\nStopping Nginx webserver... Done.\nXXX"
    /etc/init.d/nginx stop 2> /dev/null
    sleep .75
    echo -e "XXX\n37\n\nRemoving Nginx cache... Done.\nXXX"
    rm -rf /var/cache/nginx
    sleep .75
    echo -e "XXX\n51\n\nRemoving Nginx services... \nXXX"
    update-rc.d -f /etc/init.d/nginx remove
    rm -rf /etc/init.d/nginx
    rm -rf /etc/rc0.d/K01nginx
    rm -rf /etc/rc1.d/K01nginx
    rm -rf /etc/rc2.d/S01nginx
    rm -rf /etc/rc3.d/S01nginx
    rm -rf /etc/rc4.d/S01nginx
    rm -rf /etc/rc5.d/S01nginx
    rm -rf /etc/rc6.d/K01nginx
    rm -rf /etc/systemd/system/multi-user.target.wants/nginx.service
    rm -rf /lib/systemd/system/nginx.service
    sleep .75
    echo -e "XXX\n65\n\nRemoving Nginx logs... \nXXX"
    rm -rf /var/log/nginx
    sleep .75
    echo -e "XXX\n78\n\nRemoving Nginx modules... \nXXX"
    rm -rf /usr/lib/nginx
    rm -rf /usr/local/lib/x86_64-linux-gnu/perl/5.24.1/nginx.pm
    rm -rf /usr/local/lib/x86_64-linux-gnu/perl/5.24.1/auto/nginx
    rm -rf /usr/local/lib/x86_64-linux-gnu/perl/5.24.1/auto/nginx/.packlist
    rm -rf /usr/local/lib/x86_64-linux-gnu/perl/5.24.1/auto/nginx/nginx.so
    rm -rf /usr/local/share/man/man3/nginx.3pm
    rm -rf /usr/sbin/nginx
    rm -rf /usr/sbin/nginx.old
    rm -rf /usr/share/doc/fcgiwrap/examples/nginx.conf
    rm -rf /var/lib/lxcfs/cgroup/blkio/system.slice/nginx.service
    rm -rf /var/lib/lxcfs/cgroup/cpu,cpuacct/system.slice/nginx.service
    rm -rf /var/lib/lxcfs/cgroup/devices/system.slice/nginx.service
    rm -rf /var/lib/lxcfs/cgroup/memory/system.slice/nginx.service
    rm -rf /var/lib/lxcfs/cgroup/name=systemd/system.slice/nginx.service
    rm -rf /var/lib/lxcfs/cgroup/pids/system.slice/nginx.service
    sleep .75
    echo -e "XXX\n90\n\nRemoving temporary files... \nXXX"
    rm -rf /var/tmp/systemd-private-*-nginx.service-*
    rm -rf/usr/local/lib/x86_64-linux-gnu/perl/5.20.2/nginx.pm
    rm -rf/usr/local/lib/x86_64-linux-gnu/perl/5.20.2/auto/nginx
    sleep .75
    echo -e "XXX\n100\n\nAll traces cleaned... Done.\nXXX"
    sleep 1
  } | whiptail --title "Nginx Clean Build" --gauge "\nWiping traces of Nginx" 10 70 0
}

nginxService() {
{
    sleep 1
    echo -e "XXX\n5\n\nChecking for Nginx service file...\nXXX"
    if [ -f /lib/systemd/system/nginx.service ]
    then
    echo -e "XXX\n50\n\nNginx.service already exists, skipping...\nXXX"
    sleep .75
    else
    echo -e "XXX\n25\n\nCreate Nginx systemd service... \nXXX"
    CONFIGSERVICE='/lib/systemd/system/'
    cp $CURDIR/config/nginx/nginx.service $CONFIGSERVICE 2> /dev/null
    chmod 0644 /lib/systemd/system/nginx.service
    sleep .75
    systemctl enable nginx.service 2> /dev/null
    echo -e "XXX\n50\n\nNginx service file enabled... Done.\nXXX"
    fi
    sleep .75
    echo -e "XXX\n55\n\nChecking for Nginx init.d file...\nXXX"
    if [ -f /etc/init.d/nginx ]
    then
    echo -e "XXX\n75\n\nNginx init.d already exists, skipping...\nXXX"
    sleep .75
    else
    echo -e "XXX\n80\n\nCreate Nginx init.d service... \nXXX"
    CONFIGINITD='/etc/init.d/'
    cp $CURDIR/config/nginx/nginx $CONFIGINITD 2> /dev/null
    chmod 755 /etc/init.d/nginx
    echo -e "XXX\n90\n\nNginx init.d file installed... Done.\nXXX"
    sleep .75
    update-rc.d nginx defaults 2> /dev/null
    echo -e "XXX\n100\n\nNginx init.d file enabled... Done.\nXXX"
    fi
    sleep .75
  } | whiptail --title "Nginx Services" --gauge "\nCreating service files for Nginx" 10 70 0
}

nginxConfigure() {
{
    echo -e "XXX\n7\n\nMaking backup of default nginx.conf...\nXXX"
    sleep .75
    if [ -f /etc/nginx/nginx.conf.bak ]
    then
    echo -e "XXX\n7\n\nBackup already exists, skipping nginx.conf...\nXXX"
    sleep .75
    else
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
    echo -e "XXX\n13\n\nInstalling optimized nginx.conf...\nXXX"
    sleep .75
    CONFIGCONF='/etc/nginx/'
    cp $CURDIR/config/nginx/nginx.conf $CONFIGCONF 2>/dev/null
    echo -e "XXX\n15\n\nInstalled optimized nginx.conf...\nXXX"
    sleep .75
    fi
    echo -e "XXX\n20\n\nCreate $NGINX_SITES_AVAILABLE if doesnt exist...\nXXX"
    sleep .25
    if [ -d "$NGINX_SITES_AVAILABLE" ]
    then
    echo -e "XXX\n26\n\nDirectory $NGINX_SITES_AVAILABLE exists...\nXXX"
    sleep .75
    else
    mkdir -p $NGINX_SITES_AVAILABLE
    echo -e "XXX\n26\n\nDirectory $NGINX_SITES_AVAILABLE created...\nXXX"
    sleep .75
    fi
    echo -e "XXX\n35\n\nCreate nginx $NGINX_SITES_ENABLED if doesnt exist...\nXXX"
    sleep .75
    if [ -d "$NGINX_SITES_ENABLED" ]
    then
    echo -e "XXX\n43\n\nDirectory $NGINX_SITES_ENABLED exists...\nXXX"
    sleep .75
    else
    mkdir -p $NGINX_SITES_ENABLED
    echo -e "XXX\n43\n\nDirectory $NGINX_SITES_ENABLED created...\nXXX"
    sleep .75
    fi
    echo -e "XXX\n56\n\nCreate nginx $NGINX_CONFD if doesnt exist...\nXXX"
    sleep .75
    if [ -d "$NGINX_CONFD" ]
    then
    echo -e "XXX\n65\n\nDirectory $NGINX_CONFD exists...\nXXX"
    sleep .75
    else
    mkdir -p $NGINX_CONFD
    echo -e "XXX\n65\n\nDirectory $NGINX_CONFD created...\nXXX"
    sleep .75
    fi
    echo -e "XXX\n73\n\nCreate nginx vhosts.conf if doesnt exist...\nXXX"
    sleep .75
    if [ -f /etc/nginx/conf.d/vhosts.conf ]
    then
    echo -e "XXX\n82\n\nGreat! vhosts.conf file exists...\nXXX"
    sleep .75
    else
    touch /etc/nginx/conf.d/vhosts.conf
    echo "include /etc/nginx/sites-enabled/*.vhost;" >>/etc/nginx/conf.d/vhosts.conf
    echo -e "XXX\n82\n\nFile vhosts.conf created...\nXXX"
    sleep .75
    fi
    echo -e "XXX\n91\n\nCreate nginx cache/gzip directories if doesnt exist...\nXXX"
    sleep .75
    if [ -d /var/cache/nginx/fcgi ] || [ -d /var/cache/nginx/tmp ];
    then
    echo -e "XXX\n93\n\nGreat! Cache directories exist...\nXXX"
    sleep .75
    else
    mkdir -p /var/cache/nginx
    mkdir -p /var/cache/nginx/fcgi
    mkdir -p /var/cache/nginx/tmp
    chown -R www-data:root /var/cache/nginx
    echo -e "XXX\n93\n\nNginx cache directories created...\nXXX"
    sleep .75
    fi
    echo -e "XXX\n95\n\nCleanup - Remove Nginx signing key...\nXXX"
    sleep .75
    rm -rf $CURDIR/nginx_signing.key
    echo -e "XXX\n98\n\nRestarting Nginx service... Done.\nXXX"
    sleep 1
    $NGINX_INIT 2> /dev/null
    if [ $? -eq 0 ]; then
    echo -e "XXX\n100\n\nSuccessfully restarted Nginx... Done.\nXXX"
    sleep 1
    else
    echo -e "XXX\n100\n\nNginx failed, check nginx_binary.log...\nXXX"
    sleep 3
    exit 1
    fi
    sleep 1
  } | whiptail --title "Nginx Setup" --gauge "\nNginx directory and configuration" 10 70 0
}

wgetFiles() {
{
  wget $(wgetURL) 2>&1 | \
  stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }'
  } | whiptail --title "ASAS Downloader" --gauge "\nFetching build sources" 10 70 0
}

#*****************************
#
# Testing Ground
#
#*****************************
secureCheckModify2() {
            i=0
            $(secureCommand) 2> /dev/null | \
            while read x; do
            case $x in
        *+*)
            count=20
            i=0
        ;;
           +*\ ...)
            proc=$(ps aux | grep -v grep | grep -e "$(secureApp)")
            if [[ "$proc" == "" ]] && [[ $count -gt 0 ]]; then
                i=$((i+1))
                x=${x% (*}
                x=${x% ...}
                x=$(echo ${x:1})
                sleep .50
                printf "XXX\n$((i*100/count))\n\n${x}\nXXX\n$((i*100/count))\n"
           fi
        ;;
    esac
done | whiptail --title "Security Check-Modify"  --gauge "\nGenerating DH parameters, 2048 bit long safe prime, generator 2\nThis is going to take a long time" 10 70 0
}

############
# File End #
############

