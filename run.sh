#! /bin/bash
#
# vpn_init.sh
# Copyright (C) 2019 hzshang <hzshang15@gmail.com>
#
# Distributed under terms of the MIT license.
#
cd `dirname $0`
. ./env.sh
OVPN_DATA=`pwd`/conf
first_init(){
    sudo rm -rf ./conf/*
    docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm kylemanna/openvpn ovpn_genconfig -u udp://$SERVER_URL:$SERVER_PORT -c -d
    for i in "${SERVER_CONFIG[@]}"
    do
        echo $i | sudo tee -a ./conf/openvpn.conf
    done
    echo WTF | docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm -i kylemanna/openvpn ovpn_initpki nopass
}

add_user(){
    docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm -it kylemanna/openvpn easyrsa build-client-full $1 nopass
    docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm kylemanna/openvpn ovpn_getclient $1 > $1.ovpn
    sudo touch ./conf/ccd/$1
}

route(){
    echo "iroute $2 $3" | sudo tee -a ./conf/ccd/$1
    echo "" | sudo tee -a ./conf/openvpn.conf
    echo "# Add $1 route table" | sudo tee -a ./conf/openvpn.conf
    echo "push \"route $2 $3\"" | sudo tee -a ./conf/openvpn.conf
    echo "route $2 $3" | sudo tee -a ./conf/openvpn.conf
}

show_help(){
    printf "Usage: ./run.sh cmd ...\n"
    printf "Cmds:\n"
    printf "    %-40s %s\n" "init" "init vpn config"
    printf "    %-40s %s\n" "add <user>" "config vpn client"
    printf "    %-40s %s\n" "route <user> <ip> <netmask>" "route specific ip to user"
}

main(){
    case $1 in
        init)
            first_init
            ;;
        add)
            if [[ ! -z "$2" ]];then
                add_user $2
            else
                show_help
            fi
            ;;
        route)
            if [[ ! -z "$4" ]];then
                route $2 $3 $4
            else
                show_help
            fi
            ;;
        *)
            show_help
            ;;
    esac
}
main $@
