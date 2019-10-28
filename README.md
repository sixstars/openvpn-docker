# openvpn docker

## Usage  

A fast and portable way to config vpn 
 
```
Usage: ./run.sh cmd ...
Cmds:
    init                                     init vpn config
    add <user>                               config vpn client
    route <user> <ip> <netmask>              route specific ip to user

```


## Example

### Server  (public IP)

```bash
$ ./run.sh init
$ ./run.sh add player
$ ./run.sh add gateway
$ ./run.sh route gateway 10.211.55.0 255.255.255.0
$ docker-compose up -d
```

### Gateway (10.211.55.2)

```bash
$ sudo iptables -t nat -A POSTROUTING -d 10.211.55.0/24 -j MASQUERADE
$ sudo iptables -P FORWARD ACCEPT
```

### Player  

```bash
$ ping 10.211.55.1
PING 10.211.55.1 (10.211.55.1) 56(84) bytes of data.
64 bytes from 10.211.55.1: icmp_seq=1 ttl=127 time=15.2 ms
64 bytes from 10.211.55.1: icmp_seq=2 ttl=127 time=26.0 ms
```