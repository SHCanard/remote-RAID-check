#!/bin/bash

clear

##Vars

today=`date "+%y-%m-%d"`

#Specify the local path to input and output files:
path="/home/user/remote-RAID-check"

output="$path/mdstat_$today.txt"

#Specify the user for SSH connection to the servers:
user="user"

while read line
do
	rm $path/mdswap.txt
	server=$line
	#Put in vars name, IP and gateway from servers_list file
	name=`echo $server | cut -d":" -f1`
	ip=`echo $server | cut -d":" -f2`
	gateway=`echo $server | cut -d":" -f3`
	
	#Ping the server
	ping_asw=$(ping -W15 -c1 ${ip} | grep -c "1 received")
	
	if [ $ping_asw != 0 ];then
	#Ping sucessfull
		#Copy the result of command cat /proc/mdstat in a local file
		ssh -n $user@$ip "cat /proc/mdstat" >> $path/mdswap.txt
		if [ $? != 0 ];then
		#SSH failed
		#Populate output file
			echo `date` >> $output 2>&1
			echo -e "\n$name @ $ip" >> $output 2>&1
			echo -e "\nRAID system state is unknown! Server has been contacted, but SSH failed." >> $output 2>&1
			echo -e "\n***************************************************************\n" >> $output 2>&1
			exit 1
		fi
		#Count the number of "_"
		nb_raid=$(cat $path/mdswap.txt | grep -c _)
		if [ $nb_raid != 0 ];then
		#If different from no "_", there's a problem
			#Populate output file
			echo `date` >> $output 2>&1
			echo -e "\n$name @ $ip" >> $output 2>&1
			echo -e "\nFound a problem of the RAID system!:\n" >> $output 2>&1
			cat $path/mdswap.txt >> $output
			echo -e "\n***************************************************************\n" >> $output 2>&1
			rm $path/mdswap.txt
			#Else RAID is ok or unknown
		else
			{
			#Count the number of "U"
			nb_raid=$(cat $path/mdswap.txt | grep -c U)
			if [ $nb_raid != 0 ];then
			#If different from no "U", all if fine
				#Populate output file
				echo `date` >> $output 2>&1
				echo -e "\n$name @ $ip" >> $output 2>&1
				echo -e "\nRAID system is ok." >> $output 2>&1
				echo -e "\n***************************************************************\n" >> $output 2>&1
			else
			#Any other case
				#Populate output file
				echo `date` >> $output 2>&1
				echo -e "\n$name @ $ip" >> $output 2>&1
				echo -e "\nRAID system state is unknown!:\n" >> $output 2>&1
				cat $path/mdswap.txt >> $output
				echo -e "\n***************************************************************\n" >> $output 2>&1
			fi
			rm $path/mdswap.txt
			}
		fi
		
	else
		{
		#Test gateway if ping on server failed
		ping_asw=`ping -c1 ${gateway} | grep -c "1 received"`		
			if [ $ping_asw != 0 ];then
				#Gateway ok
				#Populate output file
				echo `date` >> $output 2>&1
				echo -e "\n$name @ $ip" >> $output 2>&1
				echo -e "\nImpossible to establish connection with the server! However the gateway is responding ($gateway)." >> $output 2>&1
				echo -e "\n***************************************************************\n" >> $output 2>&1
			else
				{
				#Gateway is not ok
				#Populate output file
				echo `date` >> $output 2>&1
				echo -e "\n$name @ $ip" >> $output 2>&1
				echo -e "\nImpossible to establish connection with the gateway ($gateway) !" >> $output 2>&1
				echo -e "\n***************************************************************\n" >> $output 2>&1
				}
			fi
		}
	fi

done < $path/servers_list
