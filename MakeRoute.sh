#!/bin/sh

printf "Enter root-password: "
read -s ROOTPASS
printf "\n"

# Reset sudo
sudo -k
# Check $ROOTPASS
[ ! $( echo $ROOTPASS |sudo -S whoami 2>/dev/null |grep root) ] && echo "root-passwd is wrong!" && exit 1

echo $ROOTPASS |sudo -S route delete -net 192.168.100 2>/dev/null ;sudo -k

echo $ROOTPASS |sudo -S route add -net 192.168.100 192.168.101.254 2>/dev/null ;sudo -k
echo $ROOTPASS |sudo -S route add -host 192.168.100.1 192.168.101.254 2>/dev/null ;sudo -k


