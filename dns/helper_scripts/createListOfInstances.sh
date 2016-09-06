#!/bin/bash

echo -e "shoppingCart\ntcp\n123.34.55.6:8007\n60" | source ./createServicesInstances.sh $mapOfServiceNameAndID

echo -e "Orders\ntcp\n120.30.50.2:812\n60" | source ./createServicesInstances.sh $mapOfServiceNameAndID

echo -e "Clients\ntcp\n111.3.551.63:123\n60" | source ./createServicesInstances.sh $mapOfServiceNameAndID

