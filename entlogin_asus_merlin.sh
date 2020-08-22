#!/bin/sh
###
 # @Author: your name
 # @Date: 2020-08-21 19:26:14
 # @LastEditTime: 2020-08-22 20:07:55
 # @LastEditors: Please set LastEditors
 # @Description: In User Settings Edit
 # @FilePath: \SUSTech-EnetLogin\temp.sh
### 
set -e pipefail
loginurl="https://cas.sustech.edu.cn/cas/login"
authip="219.134.142.194"
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.112 Safari/537.36"
# Insert your CAS info below:
username="YOUR_USER_NAME_HERE"
password="YOUR_PASSWORD_HERE"

while [ true ] ; do
  ret_code=$(curl \
      -I -s --connect-timeout 5 \
	  http://www.baidu.com -w %{http_code} \
	  | tail -n1)
    #　it should be a number
  if [ ${ret_code} -ne 200 ] ; then
	echo "Attempting to log in the enet system"
	rm -f /tmp/cascookie

	# You may need to modify the following regex for different distros.
	routerip=$(ifconfig \
		|  grep -A 1 "^eth0" \
		|  awk '{gsub(/^\s+|\s+$/, "");print}' \
		|  sed -n "2,2p" \
		|  awk -F "[: ]" '{print $3}')
	#it should like "10.22.114.51"
    eneturl="http://125.88.59.131:10001/sz/sz112/index.jsp?wlanuserip=${routerip}&wlanacip=${authip}"
	
	execution=$(curl --silent \
	  --connect-timeout 5 \
	  --cookie-jar /tmp/cascookies\
	  -H "User-Agent: "${USER_AGENT}""\
	  -L "${eneturl}" \
	  | grep -o 'execution.*/><input type' | grep -o '[^"]\{50,\}')

	curl --silent \
	  --connect-timeout 5 \
      --output /dev/null \
      --cookie /tmp/cascookies \
      --cookie-jar /tmp/cascookies \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -H "User-Agent: "${USER_AGENT}"" \
      -L -X POST "${loginurl}" \
	  --data $(printf \
		"username=%s&password=%s&execution=%s&_eventId=submit&geolocation=" \
		${username} ${password} ${execution})

  else
    echo "Connected to Internet, recheck a second later"
  fi
    sleep 1s
done
