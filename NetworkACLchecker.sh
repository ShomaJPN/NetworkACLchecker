#!/bin/bash
#
# test-drive version
#
#


######################## Set "Log" file and function ###########################

LogPath=$HOME/log
LogFile="$LogPath/NetworkACLcheckr.log"

if [ ! -d "$LogPath" ]; then
    echo "Log directory is not exit!"
    mkdir $LogPath
    echo "Log directory is created"
  else
    echo "Log directory is exit!"
fi

function SendToLog ()
{
echo $(date +"%Y-%m-%d %T") : $@ | tee -a "$LogFile"
}

##################### End of set "Log" file and function #######################





############################### Set Variables ##################################


ACLtestList="
tcp 192.168.100.1/24:9000 192.168.101.1/24:22
tcp 192.168.100.1/24:9000 192.168.101.2/24:80
tcp 192.168.100.2/24:9001 192.168.101.1/24:22
tcp 192.168.100.2/24:9001 192.168.101.2/24:80
udp 192.168.100.3/24:9002 192.168.101.3/24:3479
udp 192.168.100.3/24:9002 192.168.101.4/24:5090
udp 192.168.100.4/24:9003 192.168.101.3/24:3479
udp 192.168.100.4/24:9003 192.168.101.4/24:5090
"


############################  End of Set Variables #############################





################################# Processing ###################################


SendToLog "NetworkACLchecker started !"

printf "Enter root-password: "
read -s ROOTPASS
printf "\n"

# Check $ROOTPASS
sudo -k
[ ! $( echo $ROOTPASS |sudo -S whoami 2>/dev/null |grep root) ] &&
 SendToLog "root-passwd is wrong!"                              &&
 exit 1


# delete blank-line
ACLtestList=$(echo "$ACLtestList" |grep -v ^$)

while read LINE;do
    Protocol=$(echo $LINE  |cut -d' ' -f1)
    SrcIP=$(echo $LINE  |cut -d' ' -f2)
    DstIP=$(echo $LINE  |cut -d' ' -f3)

    SrcIPaddress=$(echo $SrcIP |cut -d'/' -f1)
    SrcIPnetmask=$(echo $SrcIP |cut -d'/' -f2 |cut -d':' -f1)
    SrcIPport=$(echo $SrcIP |cut -d':' -f2)
    DstIPaddress=$(echo $DstIP |cut -d'/' -f1)
    DstIPnetmask=$(echo $DstIP |cut -d'/' -f2 |cut -d':' -f1)
    DstIPport=$(echo $DstIP |cut -d':' -f2)


    #for debug
    echo -----
    echo '$Protocol: '$Protocol
    echo '$SrcIPaddress: '$SrcIPaddress
    echo '$SrcIPnetmask: '$SrcIPnetmask
    echo '$SrcIPport: '$SrcIPport
    echo '$DstIPaddress: '$DstIPaddress
    echo '$DstIPnetmask: '$DstIPnetmask
    echo '$DstIPport: '$DstIPport


if [ "$Protocol" = "tcp" ] ; then

    # Make Reciver
    # Use sudo for the case of setting well-known port
    sudo -k                                                       # to Avoid showing the $ROOTPASS
    echo $ROOTPASS | sudo -S nc -l $DstIPaddress $DstIPport 2>/dev/null >> "$LogFile" &

    # Wait for "nc -l" to be activate
    sleep 0.4
    while [ ! "$(netstat -anL |grep $DstIPaddress.$DstIPort)" ]; do
        sleep 0.01
    done

    # Send Data
    # Use nmap-version ncat to specify the source IP/Port address
    echo $LINE OK |
    ncat -s $SrcIPaddress -p $SrcIPport $DstIPaddress $DstIPport ||
    SendToLog "$LINE NG"

    # Kill Reciver
    sudo pkill sudo

elif [ "$Protocol" = "udp" ] ; then

    # Make Reciver
    # Use sudo for the case of setting well-known port
    sudo -k                                                       # to Avoid showing the $ROOTPASS
    echo $ROOTPASS | sudo -S nc -ul $DstIPaddress $DstIPport 2>/dev/null >> "$LogFile" &

    # Wait for "nc -ul" to be activate
    while [ ! "$(netstat -an |grep udp4 |grep $DstIPaddress.$DstIPort)" ]; do
        sleep 0.01
    done

    # Send Data
    echo $LINE OK |
    ncat -s $SrcIPaddress -p $SrcIPport -u $DstIPaddress $DstIPport ||
    SendToLog "$LINE NG"

    # Kill Reciver
    sudo pkill sudo

else
    echo "something wrong!"

fi

done<<EOD
$ACLtestList
EOD

