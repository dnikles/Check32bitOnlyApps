#!/bin/bash

#set username, password, and JSS location
jssAPIUsername=""
jssAPIPassword=""
jssAddress=""

mobileApps=$(curl -H "Accept: application/JSON" -su ${jssAPIUsername}:${jssAPIPassword} -X GET ${jssAddress}/JSSResource/mobiledeviceapplications)
length=$(echo "$mobileApps"|./jq '.[]|length')
loopcount=0
while [ $loopcount -lt "$length" ]; do
jssappID=$(echo "$mobileApps"|./jq ".mobile_device_applications[$loopcount].id")
myOutput=$(curl -H "Accept: application/JSON" -su ${jssAPIUsername}:${jssAPIPassword} -X GET ${jssAddress}/JSSResource/mobiledeviceapplications/id/${jssappID})
adamURL=$(echo "$myOutput"|./jq '.mobile_device_application.general.external_url')
adamID=$(echo "$adamURL"|sed -e 's/.*\/id\(.*\)?.*/\1/')
adamIDquoted=\"$adamID\"
appleOutput=$(curl -s -H "Accept: application/JSON" -X GET "https://uclient-api.itunes.apple.com/WebObjects/MZStorePlatform.woa/wa/lookup?version=2&id=${adamID}&p=mdm-lockup&caller=MDM&platform=itunes&cc=us&l=en")
is32bit=$(echo "$appleOutput"|./jq .results.$adamIDquoted.is32bitOnly)
appName=$(echo "$appleOutput"|./jq .results.$adamIDquoted.name)
[ "$is32bit" == "true" ] && echo "$appName is 32bit only"
((loopcount++))
done
