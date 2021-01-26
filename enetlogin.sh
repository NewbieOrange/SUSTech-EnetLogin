#!/bin/bash
useragent="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:79.0) Gecko/20100101 Firefox/79.0"
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

        # You may need to modify the following regex for different distros / versions of OpenWrt.
        routerip=$(ifconfig | grep -A 1 "^${interface} " | grep -o "\(inet addr:\).*  Bcast" | grep -o "[0-9\.]*")

        eneturl="http://enet.10000.gd.cn:10001/sz/sz112/index.jsp?wlanuserip=${routerip}&wlanacip=${authip}"

        execution=$(curl --silent --cookie-jar /tmp/cascookies \
            -H "User-Agent: ${useragent}" -k -L "${eneturl}" |
            grep -o 'execution.*/><input type' | grep -o '[^"]\{50,\}' | head -n 1)

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
