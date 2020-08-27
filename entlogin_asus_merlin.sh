#!/bin/sh
useragent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.112 Safari/537.36"
loginurl="https://cas.sustech.edu.cn/cas/login"
authip="219.134.142.194"
# Insert your CAS info below:
username="YOUR_USERNAME_HERE"
password="YOUR_PASSWORD_HERE"
interface="eth0"

while [ true ]; do
    ret_code=$(curl --interface "${interface}" -I -s --connect-timeout 3 http://www.baidu.com -w %{http_code} | tail -n1)

    if [ ${ret_code} -ne 200 ]; then
        echo "Attempting to log in the enet system"
        rm -f /tmp/cascookie

        # You may need to modify the following regex for different versions of firmware.
        routerip=$(ifconfig | grep -A 1 "^${interface}" | awk '{gsub(/^\s+|\s+$/, "");print}' |
            sed -n "2,2p" | awk -F "[: ]" '{print $3}')

        eneturl="http://125.88.59.131:10001/sz/sz112/index.jsp?wlanuserip=${routerip}&wlanacip=${authip}"

        execution=$(curl --silent --cookie-jar /tmp/cascookies \
            -H "User-Agent: ${useragent}" -k -L "${eneturl}" |
            grep -o 'execution.*/><input type' | grep -o '[^"]\{50,\}')

        curl --silent --output /dev/null \
            --cookie /tmp/cascookies --cookie-jar /tmp/cascookies \
            -H "Content-Type: application/x-www-form-urlencoded" \
            -H "User-Agent: ${useragent}" \
            -k -L -X POST "${loginurl}" \
            --data "username=${username}&password=${password}&execution=${execution}&_eventId=submit&geolocation="
    else
        echo "Connected to Internet, recheck a second later"
    fi
    sleep 1s
done
