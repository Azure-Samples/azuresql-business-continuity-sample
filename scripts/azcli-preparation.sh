#!/bin/sh
## $1 location
pairedRegion=$(az account list-locations --query "[?name=='$1'].metadata.pairedRegion[0].name" | jq .[0])
# remove quote
pairedRegion="${pairedRegion%\"}"
pairedRegion="${pairedRegion#\"}"
echo $pairedRegion

export pairedRegion=$pairedRegion