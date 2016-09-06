#!/bin/bash
unset serviceID
unset currentserviceName
read -r -p "Enter Service Name : " serviceName
for service in "${mapOfServiceNameAndID[*]}" ; do
	currentserviceName=`echo "$service" | cut -d":" -f1 | cut -d" " -f1`
	if [[ $currentserviceName == $serviceName ]] ; then
		echo HIIII
		serviceID=`echo "$service" | cut -d":" -f2 | cut -d" " -f2` 
		echo FOUND ! $serviceID
		break
	fi
done

if [[ $serviceID == "" ]] ; then 
	echo -e  "\e[91m" "Service Name NOT FOUND"
	echo -n -e "\e[39m"
	sleep 10
else 
	HTTP_STATUS=`curl -X "DELETE" -i http://172.17.0.02:8080/api/v1/instances/"${serviceID}"  | tee json.txt | head -n1 | cut -d" " -f2`  
	JSAON_OUTPUT=`cat json.txt | tail -1`
	if [[ $HTTP_STATUS != 200 ]] ; then 
	
		echo -e  "\e[91m"Error in deleting service instance . Error code : $HTTP_STATUS
		echo -e $JSAON_OUTPUT
		rm -rf json.txt 
		echo -n -e "\e[39m"
		sleep 5
	else 
		echo deleted succesfully
		echo -e "\e[32mHTTP response : $HTTP_STATUS"
		echo -n -e "\e[39m"
		delete=("${currentserviceName} : ${serviceID}")
		mapOfServiceNameAndID=( "${mapOfServiceNameAndID[@]/$delete}" )
		sleep 10
	fi
	
fi
