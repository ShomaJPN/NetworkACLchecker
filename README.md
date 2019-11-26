# NetworkACLchecker(macOS)

## Overview
This tiny ShellScript checks the ACL of a Network-device.  
It works with just one Mac, but requires TWO NICs (e.g. two USB-ethernet Adapters).  
The reason is that this script actually sends data from one NIC to another, and as a result, checks the ACL of a Network-device in between them.  
Protocol (TCP/UDP), IPaddress (SrcIP/DstIP), PortNo(SrcPort/DstPort) can be specified.  

![catch_fig](https://user-images.githubusercontent.com/49780970/69261960-f00d6180-0c05-11ea-8322-54f73bdaece7.gif)


## Description
The feature of this script is to actually send and receive data (Netcat is used for it).  
If you want to find out more easily, consider using Nmap (it is much faster)

## Requirements
- Bash (for ShellScript)
  - Nmap-version Netcat (not use OSX's Pre-install "nc" for easy timeout-handling and other things)
- User with admin privileges

- Tested under Mojave 10.14.6 (Confrim Dialog/Firewall appear at the first run)

***Remark!***  
**DO NOT run this script on the SERVER!, because it change/occupy IP address and/or Port.**

## Usage
- AddIPaddress.sh  <-- Helper / Add multiple IP addresses to IFs
- MakeRoute.sh    <-- Helper / Make route to IP addresses
- NetworkACLchecker.sh   <-- Main / Test Script

## Setup and Test
The network configuration diagram is as follows.  
By using two NICs, Send/Recieve/Test are performed on one Mac.  
If you want to test two or more Send/Recieve IP-addresses at the same time, it is nessesary to add multiple IP-addresses to one NIC.  
![nw_fig](https://user-images.githubusercontent.com/49780970/69229256-75722100-0bc8-11ea-9339-878b1dd21d01.jpg)

The general flow is as follows:
1. Set IP address to the IFs. 
2. Make route to the IP addresses.  
3. Add test-parameters.  
4. Test!

For the sake of clarity, we will test with the following configuration.  

![sample_config2](https://user-images.githubusercontent.com/49780970/69381951-44ddd480-0cf9-11ea-9cfe-bdd3e099dfc7.jpg)

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
|TCP|192.168.100.1/24: 9001|192.168.101.2/24: 80|
|TCP|192.168.100.2/24: 9002|192.168.101.1/24: 22|
|TCP|192.168.100.2/24: 9003|192.168.101.2/24: 80|
|UDP|192.168.100.3/24: 9004|192.168.101.3/24: 3479|
|UDP|192.168.100.3/24: 9005|192.168.101.4/24: 5090|
|UDP|192.168.100.4/24: 9006|192.168.101.3/24: 3479|
|UDP|192.168.100.4/24: 9007|192.168.101.4/24: 5090|



### 1.Set IP addresses to the IFs
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
    inet 192.168.101.2 netmask 0xffffff00 broadcast 192.168.100.255
    inet 192.168.101.3 netmask 0xffffff00 broadcast 192.168.100.255
    inet 192.168.101.4 netmask 0xffffff00 broadcast 192.168.100.255
```
When assigning more...it may be helpful to modify and use `AddIPadress.sh`


### 2.Make route to the IP addresses 
Set the route so that Src IP and Dst IP do not communicate via MAC-inside (but through the gateway)
```
$ sudo route add -host 192.168.100.1 192.168.101.254
$ sudo route add -host 192.168.100.2 192.168.101.254
$ sudo route add -host 192.168.100.3 192.168.101.254
$ sudo route add -host 192.168.100.4 192.168.101.254

$ sudo route add -host 192.168.101.1 192.168.100.254
$ sudo route add -host 192.168.101.2 192.168.100.254
$ sudo route add -host 192.168.101.3 192.168.100.254
$ sudo route add -host 192.168.101.4 192.168.100.254
```
and you can check...
```
$ route get 192.168.100.1

   route to: 192.168.100.1
destination: 192.168.100.1
    gateway: 192.168.101.254
```
May be helpful to modify and use `MakeRoute.sh`


### 3.Add test-parameters
Add test-parameteers to `NetworkACLchecker.sh` in the following format (ACLtestList-area)  

`Protocol<tcp|udp> Src-IPaddress:Src-PortNo Dst-IPaddress:Dst-PortNo`


like this...
```
ACLtestList="
tcp 192.168.100.1/24:9000 192.168.101.1/24:22
tcp 192.168.100.1/24:9001 192.168.101.2/24:80
tcp 192.168.100.2/24:9002 192.168.101.1/24:22
tcp 192.168.100.2/24:9003 192.168.101.2/24:80
udp 192.168.100.3/24:9004 192.168.101.3/24:3479
udp 192.168.100.3/24:9005 192.168.101.4/24:5090
udp 192.168.100.4/24:9006 192.168.101.3/24:3479
udp 192.168.100.4/24:9007 192.168.101.4/24:5090
"
```

### 4.Test!
Run `NetworckACLchecker.sh` ,will add the result to the `NetworkACLtest.log`  
Sudo is used for setting a well-known port as a standby port in `NetworkACLchecker.sh`  
```
$ bash /Path/To/NetworkACLchecker.sh
```

```
$ tail -f /Path/To/NetworkACLresult.log
tcp 192.168.100.1/24:9000 192.168.101.1/24:22 OK
tcp 192.168.100.1/24:9001 192.168.101.2/24:80 OK
tcp 192.168.100.2/24:9002 192.168.101.1/24:22 NG
tcp 192.168.100.2/24:9003 192.168.101.2/24:80 NG
udp 192.168.100.3/24:9004 192.168.101.3/24:3479 OK
udp 192.168.100.3/24:9005 192.168.101.4/24:5090 NG
udp 192.168.100.4/24:9006 192.168.101.3/24:3479 OK
udp 192.168.100.4/24:9007 192.168.101.4/24:5090 NG
```
At the first run, a confirmation Firewall-dialog (Do you want the application "nc" to accept incoming network connections? ..) is appeared.  
Please allow it (in the case of Mojave )   

![FWDiag](https://user-images.githubusercontent.com/49780970/69227548-54f49780-0bc5-11ea-874f-d934da881d76.jpg)

If it fails by mistake, Change it in System Preferences->Security & Privacy->Firewall->Firewall Options...

![fw](https://user-images.githubusercontent.com/49780970/69275768-615a0e00-0c20-11ea-9bd9-7155b216a934.jpg)


## Author
SHOMA Shimahara : <shoma@yk.rim.or.jp>
