#!/bin/bash

case $1 in
-i|install)

BIN_PATH=/usr/local/bin
NET_DEV=tun0
IP_ADDR=198.18.1.254/15
PROXY_ADDR=127.0.0.1
PROXY_PORT=1080
TUN2SOCKS_ZIP=tun2socks-linux-amd64.zip
TUN2SOCKS_URL=https://gh.cooluc.com/https://github.com/xjasonlyu/tun2socks/releases/download/v2.5.2/$TUN2SOCKS_ZIP


wget --show-progress -t 5 -T 10 -cqO $TUN2SOCKS_ZIP $TUN2SOCKS_URL
unzip $TUN2SOCKS_ZIP

mv tun2socks-linux-amd64 $BIN_PATH/tun2socks && chmod +x $BIN_PATH/tun2socks && rm -f tun2socks*

cat > /etc/systemd/system/tun2socks.service <<EOF
[Unit]
Description=TCP forwarding for tun2socks
After=nss-lookup.target

[Service]
ExecStartPre=/usr/bin/ip tuntap add mode tun dev $NET_DEV
ExecStartPre=/usr/bin/ip addr add $IP_ADDR dev $NET_DEV
ExecStartPre=/usr/bin/ip link set dev $NET_DEV up
ExecStart=$BIN_PATH/tun2socks -device $NET_DEV  -loglevel warning -proxy socks5://$PROXY_ADDR:$PROXY_PORT
ExecStopPost=/usr/bin/ip link set dev $NET_DEV down
ExecStopPost=/usr/bin/ip addr del $IP_ADDR dev $NET_DEV
ExecStopPost=/usr/bin/ip tuntap del mode tun dev $NET_DEV

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable tun2socks --now
;;

-u|uninstall|remove)

systemctl stop tun2socks
systemctl disable tun2socks
rm -f /etc/systemd/system/tun2socks.service
systemctl daemon-reload

rm -f $BIN_PATH/tun2socks
;;
*)
echo "安装参数 -i | install ,卸载参数 -u | uninstall | remove"
;;
esac

