#!/bin/bash

# This script is used to check and update your GoDaddy DNS server to the IP address of your current internet connection.
# Special thanks to mfox for his ps script
# https://github.com/markafox/GoDaddy_Powershell_DDNS
#
# First go to GoDaddy developer site to create a developer account and get your key and secret
#
# https://developer.godaddy.com/getstarted
# Be aware that there are 2 types of key and secret - one for the test server and one for the production server
# Get a key and secret for the production server
#
#Update the first 5 variables with your information

domain="domain.com" # domain name
name="name"     # name of A record to update
key="key"      # key for godaddy developer API(Production)
secret="secret"   # secret for godaddy developer API(Production)
record="A"
headers="Authorization: sso-key $key:$secret"

result=$(curl -s -X GET \
  -H "$headers" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  "https://api.godaddy.com/v1/domains/$domain/records/$record/$name")
#echo $result

dnsIp=$(echo $result | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
#echo "dnsIp:" $dnsIp

# Get public ip address there are several websites that can do this.
ret=$(curl -s GET "http://inet-ip.info/ip")
currentIp=$(echo $ret | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
#echo "currentIp:" $currentIp

if [ "$dnsIp" != "$currentIp" ];
  then
    echo "Ips are not equal"
    request="[{\"data\":\"$currentIp\",\"ttl\":"3600"}]"
#    echo $request
    nresult=$(curl -i -s -X PUT \
      -H "accept: application/json" \
      -H "Content-Type: application/json" \
      -H "$headers" \
      -d $request "https://api.godaddy.com/v1/domains/$domain/records/$record/$name")
#    echo $nresult
    echo "Updated IP"
  else
    echo "Nothing to do"
fi
