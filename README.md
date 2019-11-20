# NetworkACLchecker(macOS)

## Overview
This tiny ShellScript checks the ACL of Network-device by a Single Mac /w multiple NICs (e.g. two USB-Ethernet adapters).  
This script actually send/receive data to check, so you can leave a evidence.  
You can speciried Protocol (TCP/UDP), IPaddress (Src/Dst), PortNo(Src/Dst).  

![nwtester_top](https://user-images.githubusercontent.com/49780970/69122782-0b338080-0ae3-11ea-8e81-06cd65b2e0af.gif)

## Description
The feature of this script is to actually send and receive data, and Netcat is used for it.  
If you want to find out more easily, consider using Nmap (it is much faster)

## Requirements
- Bash (for ShellScript)
  - Nmap-version Netcat (OSX's PreInstalled "nc" cannot specify source IPaddress:port with TCP-snd )
- User with admin privileges

- Tested under Mojave 10.14.6 (Confrim Dialog/Firewall appear at the first run)

***Remark!***  
**DO NOT run this script on the SERVER!, because it change/occupy IP address and/or Port.**

## Usage
- AddIPaddress.sh  <-- Helper / Add multiple IP addresses to single IF
- MakeRoute.sh    <-- Helper / Make route to Src/Dst IP address
- NetworkACLchecker.sh   <-- Main / Test Script

## Setup and Test
The network configuration diagram is as follows.  
By using two NICs, Send/Recieve (Src/Dst) are performed on the same single Mac.  
When Testing two or more Src/Dst IP-addresses at the same time, you have to add multiple IP-addresses to one NIC.  

![nwtester_nwconf](https://user-images.githubusercontent.com/49780970/69123190-15a24a00-0ae4-11ea-9284-ddf9599c8dd8.jpg)

The general flow is as follows:
1. Set IP address to NICs. 
2. Make route to IP addresses.  
3. Add test-parameter.  
4. Test!

For the sake of clarity, we will test with the following configuration.  

![nwtester_sample_env2](https://user-images.githubusercontent.com/49780970/69124411-26a08a80-0ae7-11ea-80b7-38a5cade2414.jpg)

|NW|||
|:--|:--|:--|
||SrcSide|192.168.100.0/24|
||DstSide|192.168.101.0/24|

|Mac     ||IP|GW|
|:--|:--|:--|:--|
||en7|192.168.100.1-4|192.168.100.254|
||en8|192.168.101.1-4|192.168.101.254|

|Target|||
|:--|:--|:--|
||SrcSide|192.168.100.254|
||DstSide|192.168.101.254|


|**Test Content**|||
|:--|:--|:--|
|**Protocol**|**Src**|**Dst**|
|TCP|192.168.100.1/24: 9000|192.168.101.1/24: 22|
|TCP|192.168.100.1/24: 9000|192.168.101.2/24: 80|
|TCP|192.168.100.2/24: 9001|192.168.101.1/24: 22|
|TCP|192.168.100.2/24: 9001|192.168.101.2/24: 80|
|UDP|192.168.100.3/24: 9002|192.168.101.3/24: 3479|
|UDP|192.168.100.3/24: 9002|192.168.101.4/24: 5090|
|UDP|192.168.100.4/24: 9003|192.168.101.3/24: 3479|
|UDP|192.168.100.4/24: 9003|192.168.101.4/24: 5090|



### 1.Set IP addresses to NICs
Set 192.168.100.1-4/24 to en7 and 192.168.101.1-4/24 to en8  
```
$ sudo ifconfig en7 192.168.100.1/24 add
$ sudo ifconfig en7 192.168.100.2/24 add
$ sudo ifconfig en7 192.168.100.3/24 add
$ sudo ifconfig en7 192.168.100.4/24 add

$ sudo ifconfig en8 192.168.101.1/24 add
$ sudo ifconfig en8 192.168.101.2/24 add
$ sudo ifconfig en8 192.168.101.3/24 add
$ sudo ifconfig en8 192.168.101.4/24 add
```
and you can check...
```
$ ifconfig en7 |grep 'inet '
    inet 192.168.100.1 netmask 0xffffff00 broadcast 192.168.100.255
    inet 192.168.100.2 netmask 0xffffff00 broadcast 192.168.100.255
    inet 192.168.100.3 netmask 0xffffff00 broadcast 192.168.100.255
    inet 192.168.100.4 netmask 0xffffff00 broadcast 192.168.100.255
$ ifconfig en8 |grep 'inet '
    inet 192.168.101.1 netmask 0xffffff00 broadcast 192.168.100.255
    inet 192.168.102.2 netmask 0xffffff00 broadcast 192.168.100.255
    inet 192.168.103.3 netmask 0xffffff00 broadcast 192.168.100.255
    inet 192.168.104.4 netmask 0xffffff00 broadcast 192.168.100.255
```
When assigning more...it may be helpful to modify and use `AddIPadress.sh`


### 2.Make route to Src/Dst IP addresses with each other 
Set the route so that Src IP and Dst IP do not communicate via MAC-inside (but through the gateway)
```
$ sudo route delete -net 192.168.100
$ sudo route add -net 192.168.100 192.168.101.254
$ sudo route add -host 192.168.100.1 192.168.101.254

$ sudo route delete -net 192.168.101
$ sudo route add -net 192.168.101 192.168.100.254
$ sudo route add -host 192.168.101.1 192.168.100.254
```
and you can check...
```
$ route get 192.168.100.1

   route to: 192.168.100.1
destination: 192.168.100.1
    gateway: 192.168.101.254
```
May be helpful to modify and use `MakeRoute.sh`


### 3.Add test-parameter
Add test-parameteers to `NetworkACLchecker.sh` in the following format (in ACLtestList-area)

`Protocol<tcp|udp> Src-IPaddress:Src-PortNo Dst-IPaddress:Dst-PortNo`


like this...
```
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
```

### 4.Test!
Run `NetworckACLchecker.sh` ,will add the result to the `NetworkACLtest.log`
```
$ bash /Path/To/NetworkACLchecker.sh
```

```
$ tail -f /Path/To/NetworkACLtest.log
tcp 192.168.100.1/24:9000 192.168.101.1/24:22 OK
tcp 192.168.100.1/24:9000 192.168.101.2/24:80 OK
tcp 192.168.100.2/24:9001 192.168.101.1/24:22 NG
tcp 192.168.100.2/24:9001 192.168.101.2/24:80 NG
udp 192.168.100.3/24:9002 192.168.101.3/24:3479 OK
udp 192.168.100.3/24:9002 192.168.101.4/24:5090 NG
udp 192.168.100.4/24:9003 192.168.101.3/24:3479 OK
udp 192.168.100.4/24:9003 192.168.101.4/24:5090 NG
```
At the first run, confirmation Firewall-dialog (Do you want the application "nc" to accept incoming network connections? ..) is appeared.  
Please allow it (in the case of Mojave )   

![nc-incomming1](https://user-images.githubusercontent.com/49780970/69123955-0c19e180-0ae6-11ea-8296-6df16e0a21bc.jpg)

If it fails by mistake, Change it in System Preferences->Security & Privacy->Firewall->Firewall Options...

## Author
SHOMA Shimahara : <shoma@yk.rim.or.jp>
