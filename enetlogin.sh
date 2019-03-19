loginurl="https://cas.sustech.edu.cn/cas/login"
authip="219.134.142.194"
username="YOUR_USER_NAME_HERE"
password="YOUR_PASSWORD_HERE"

while [ true ]
do
	ret_code=`curl -I -s --connect-timeout 5 http://www.baidu.com -w %{http_code} | tail -n1`

	if [ $ret_code -ne 200 ] ; then
		echo "Attempting to log in the enet system"
		rm -f /tmp/cascookie

		routerip=$(ifconfig | grep -A 1 "^eth0.2" | grep -P -o "(?<=inet addr:).*(?=  Bcast)")
		eneturl="http://125.88.59.131:10001/sz/sz112/index.jsp?wlanuserip=$routerip&wlanacip=$authip"
		execution=$(curl --silent --cookie-jar /tmp/cascookies -L "$eneturl" | grep -P -o '(?<=name="execution" value=").*(?="/><input type="hidden" name="_eventId)')
		
		curl --silent --output /dev/null --cookie /tmp/cascookies --cookie-jar /tmp/cascookies -H "Content-Type: application/x-www-form-urlencoded" -L -X POST "$loginurl" --data "username=$username&password=$password&execution=$execution&_eventId=submit&geolocation="
	else
		echo "Connected to Internet, recheck a second later"
	fi
	sleep 1s
done
