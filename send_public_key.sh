#!/bin/bash

clear

##Vars
#Specify the user for SSH connection to the servers:
user="user"

while read line
do
	server=$line
	#Put in vars name, IP and gateway from servers_list file
	name=`echo $server | cut -d":" -f1`
	ip=`echo $server | cut -d":" -f2`
	gateway=`echo $server | cut -d":" -f3`
	
	#Ping the serveur
	ping_asw=$(ping -W15 -c1 ${ip} | grep -c "1 received")
	
	if [ $ping_asw != 0 ];then
	#Ping sucessfull
		ssh-copy-id -i ~/.ssh/id_rsa.pub $user@$ip
    if [ $? != 0 ];then
      echo $name: FAIL - unable to copy ssh id
    else
      echo $name: SUCCESS
    fi
  else
    echo $name: FAIL - no response to ping
	fi
done < servers_list
