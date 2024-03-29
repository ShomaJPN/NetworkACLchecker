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
    echo $ROOTPASS |sudo -S route add -host 192.168.100.1 192.168.101.254 2>/dev/null ;sudo -k
    echo $ROOTPASS |sudo -S route add -host 192.168.100.2 192.168.101.254 2>/dev/null ;sudo -k
    echo $ROOTPASS |sudo -S route add -host 192.168.100.3 192.168.101.254 2>/dev/null ;sudo -k
    echo $ROOTPASS |sudo -S route add -host 192.168.100.4 192.168.101.254 2>/dev/null ;sudo -k
    echo $ROOTPASS |sudo -S route add -host 192.168.101.1 192.168.100.254 2>/dev/null ;sudo -k
    echo $ROOTPASS |sudo -S route add -host 192.168.101.2 192.168.100.254 2>/dev/null ;sudo -k
    echo $ROOTPASS |sudo -S route add -host 192.168.101.3 192.168.100.254 2>/dev/null ;sudo -k
    echo $ROOTPASS |sudo -S route add -host 192.168.101.4 192.168.100.254 2>/dev/null ;sudo -k
    ;;
  d )
    echo $ROOTPASS |sudo -S route delete -host 192.168.100.1 192.168.101.254 2>/dev/null ;sudo -k
    echo $ROOTPASS |sudo -S route delete -host 192.168.100.2 192.168.101.254 2>/dev/null ;sudo -k
    echo $ROOTPASS |sudo -S route delete -host 192.168.100.3 192.168.101.254 2>/dev/null ;sudo -k
    echo $ROOTPASS |sudo -S route delete -host 192.168.100.4 192.168.101.254 2>/dev/null ;sudo -k
    echo $ROOTPASS |sudo -S route delete -host 192.168.101.1 192.168.100.254 2>/dev/null ;sudo -k
    echo $ROOTPASS |sudo -S route delete -host 192.168.101.2 192.168.100.254 2>/dev/null ;sudo -k
    echo $ROOTPASS |sudo -S route delete -host 192.168.101.3 192.168.100.254 2>/dev/null ;sudo -k
    echo $ROOTPASS |sudo -S route delete -host 192.168.101.4 192.168.100.254 2>/dev/null ;sudo -k
    ;;
  * )
    echo "something wrong!"
    ;;
esac

# sudo route add -net 0.0.0.0 xxx.xxx.xxx.xxx <- set defaults gateway

