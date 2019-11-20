#!/bin/sh

printf "Add or Delete [a/d]: "
read ANS

printf "Enter root-password: "
read -s ROOTPASS
printf "\n"

# Reset sudo
sudo -k
# Check $ROOTPASS
[ ! $( echo $ROOTPASS |sudo -S whoami 2>/dev/null |grep root) ] && echo "root-passwd is wrong!" && exit 1

case $ANS in
  a )
    echo $ROOTPASS | sudo -S ifconfig en7 inet 192.168.100.1/24 alias 2>/dev/null ;sudo -k
    echo $ROOTPASS | sudo -S ifconfig en7 inet 192.168.100.2/24 alias 2>/dev/null ;sudo -k
    echo $ROOTPASS | sudo -S ifconfig en7 inet 192.168.100.3/24 alias 2>/dev/null ;sudo -k
    echo $ROOTPASS | sudo -S ifconfig en7 inet 192.168.100.4/24 alias 2>/dev/null ;sudo -k
   ;;
  d )
    echo $ROOTPASS | sudo -S ifconfig en7 inet 192.168.100.1/24 -alias 2>/dev/null ;sudo -k
    echo $ROOTPASS | sudo -S ifconfig en7 inet 192.168.100.2/24 -alias 2>/dev/null ;sudo -k
    echo $ROOTPASS | sudo -S ifconfig en7 inet 192.168.100.3/24 -alias 2>/dev/null ;sudo -k
    echo $ROOTPASS | sudo -S ifconfig en7 inet 192.168.100.4/24 -alias 2>/dev/null ;sudo -k
    ;;
  *)
    echo "something wrong!"
    ;;
esac

echo '$ ifconfig en7'
ifconfig en7
read ANS

