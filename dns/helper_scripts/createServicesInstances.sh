#!/bin/bash

function sendHeartBeat {
	ID=$1
	serviceName=$2
	while :
	do
		echo sending heartbeat for $serviceName service with id $ID
		ST=`curl -X PUT  -i http://172.17.0.02:8080/api/v1/instances/${ID}/heartbeat | head -n1 | cut -d" " -f2`
		if [[ $ST != 200 ]] ; then 

			echo -e  "\e[91m"Failed : $ST 
			echo -n -e "\e[39m"
			break
		else
			echo  -e "\e[32m" success. http status: ${ST[*]}
			echo -n -e "\e[39m"
			sleep 25
		fi
	done
}


# Register a few service instances and keep them alive with heardbeats :
echo Welcome:
#mapOfServiceNameAndID=$1
read -r -p "Enter Service Name : " serviceName
read -r -p "Enter endpoint type :" endPointType

case $endPointType in 
	tcp) read -r -p "Enter IP address and Port: " endPointValue;;
	http) read -r -p "Enter url address : " endPointValue;;
	*) echo -e  "\e[91m"endPoint type can be tcp or http, exiting..."\e[39m"; sleep 5 ; exit 1
esac

read -r -p "Enter ttl : " ttl

echo $serviceName  $endPointType $endPointValue $ttl

HTTP_STATUS=`curl -H "Content-Type: application/json" -X POST -d '{ "service_name": "'"${serviceName}"'", "endpoint": { "type": "'"$endPointType"'", "value": "'"$endPointValue"'" }, "ttl": '"$ttl"', "status": "UP", "tags": [ "string"],"metadata": {} }' --connect-timeout 5 -i http://172.17.0.02:8080/api/v1/instances | tee json.txt | head -n1 | cut -d" " -f2`  
JSAON_OUTPUT=`cat json.txt | tail -1`
if [[ $HTTP_STATUS != 201 ]] ; then 
	
	echo -e  "\e[91m"Error in creating new service instance . Error code : $HTTP_STATUS 
	echo -n -e "\e[39m"
	sleep 5 ; exit 1
else 
	echo Created succesfully
	echo Created : $JSAON_OUTPUT
	echo -e "\e[32mHTTP response : $HTTP_STATUS"
	echo -n -e "\e[39m"
	ID=`echo $JSAON_OUTPUT | cut -d":" -f2 | cut -d"," -f1 | cut -d"\"" -f2`
	
	mapOfServiceNameAndID[${#mapOfServiceNameAndID[*]}]="${serviceName} : ${ID}"
	
	echo ${mapOfServiceNameAndID[*]}
	sleep 5
	sendHeartBeat $ID $serviceName &
fi
