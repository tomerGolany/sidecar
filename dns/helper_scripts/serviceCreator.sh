#!/bin/bash

#
export mapOfServiceNameAndID=()
docker run amalgam8/a8-registry:latest &
sleep 5
# capture CTRL+C, CTRL+Z and quit singles using the trap
# set an 
while :
do
	# show menu
	clear
	echo "---------------------------------"
	echo "	     M A I N - M E N U"
	echo "---------------------------------"
	echo "0. Create list of service instances"
	echo "1. Create new service instance:"
	echo "2. Delete service instance:"
	echo "3. Show all service instancs"
	echo "4. Show all service names"
	echo "5. Print service names and IDs"
	echo "6. Exit"
	echo "---------------------------------"
	read -r -p "Enter your choice [1-5] : " c
	# take action
	case $c in
		0) source ./createListOfInstances.sh;; 
		1) source ./createServicesInstances.sh $mapOfServiceNameAndID;;
		2) source ./deleteServiceInstances.sh;;
		3) source ./getInstances.sh;;
		4) source ./getNames.sh;;
		5) echo service names: ; echo ${mapOfServiceNameAndID[*]}; sleep 5;;
		6) break;;
	esac
done