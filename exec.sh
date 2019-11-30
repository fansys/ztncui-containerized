#!/bin/bash

HTTP_ALL_INTERFACES=${HTTP_ALL_INTERFACES}
HTTP_PORT=${HTTP_PORT:-80}
HTTPS_PORT=${HTTPS_PORT:-443}
ZT_ADDR=${ZT_ADDR}
ZT_PORT=${ZT_PORT}

/usr/sbin/zerotier-one &

while [ ! -f /var/lib/zerotier-one/authtoken.secret ]; do
  sleep 1
done
chmod g+r /var/lib/zerotier-one/authtoken.secret

# valid zt addr
if [ ! -z $ZT_ADDR ]; then
  # check if the moons conf has generated
  if [ ! -d "/var/lib/zerotier-one/moons.d" ]; then
    # format Endpoint 1.1.1.1/9993 --> "1.1.1.1\/9993"
    Endpoint=$(echo $ZT_ADDR | sed 's/\//\\\//g')
    if [[ ! $Endpoint == *\"* ]]; then
      Endpoint=\"$Endpoint\"
    fi
    
    # generate moon conf
    zerotier-idtool initmoon /var/lib/zerotier-one/identity.public >>/var/lib/zerotier-one/moon.json
    sed -i 's/"stableEndpoints": \[\]/"stableEndpoints": ['$Endpoint']/g' /var/lib/zerotier-one/moon.json
    zerotier-idtool genmoon /var/lib/zerotier-one/moon.json > /dev/null
    mkdir /var/lib/zerotier-one/moons.d
    mv *.moon /var/lib/zerotier-one/moons.d/
    
	# restart zerotier-one
    pkill zerotier-one
    sleep 1
    /usr/sbin/zerotier-one &
  fi
  
  moon_id=$(cat /var/lib/zerotier-one/moon.json | grep \"id\" | cut -d '"' -f4)
  echo -e "Your ZeroTier moon id is \033[0;31m$moon_id\033[0m, you could orbit moon using \033[0;31m\"zerotier-cli orbit $moon_id $moon_id\"\033[0m"
fi

# modify zerotier port
if [ ! -z $ZT_PORT ]; then
  if [ ! -f "/var/lib/zerotier-one/local.conf" ]; then
	cat >> /var/lib/zerotier-one/local.conf <<EOF
{
  "settings": {
    "primaryPort": $ZT_PORT
  }
}
EOF
    # restart zerotier-one
    pkill zerotier-one
    sleep 1
    /usr/sbin/zerotier-one &
  fi
fi

# set ztncui port
cd /opt/key-networks/ztncui

echo "HTTP_PORT=$HTTP_PORT" > /opt/key-networks/ztncui/.env
if [ ! -z $HTTP_ALL_INTERFACES ]; then
  echo "HTTP_ALL_INTERFACES=$HTTP_ALL_INTERFACES" >> /opt/key-networks/ztncui/.env
else
  [ ! -z $HTTPS_PORT ] && echo "HTTPS_PORT=$HTTPS_PORT" >> /opt/key-networks/ztncui/.env
fi

if [ ! -z $ZT_PORT ]; then
  echo "ZT_PORT=127.0.0.1:$ZT_PORT" >> /opt/key-networks/ztncui/.env
fi

exec sudo -u ztncui /opt/key-networks/ztncui/ztncui
