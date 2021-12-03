1.
```
ip -c -br link
ip -c -br address
ipconfig
```
2.
используется протокол LLDP
в linux пакет lldpd

3.
для разделения сети использут VLAN
Модуль VLAN

Добавляем VLAN
`shev@MyPC:~$ nmcli con add type vlan con-name enp0s31f6.500 ifname VLAN500 id 500 dev enp0s31f6 ip4 10.10.10.10/24
`
Смотрим
`
shev@MyPC:~$ nmcli con show 
NAME                UUID                                  TYPE      DEVICE  
GPN-WiFi            86f9411c-a5e8-40e5-a264-6a23b629f18c  wifi      wlp4s0  
NGate VPN Tunnel    6de98eb6-07a5-4470-978b-d09d5df60120  tun       tun0    
docker0             fa56697e-6d3a-4f60-b9d3-988cf3d7952d  bridge    docker0 
enp0s31f6.500       96559ac6-c8e6-4707-aeaa-ebf1fd0ba728  vlan      --      
`
`
shev@MyPC:~$ ifconfig
VLAN500: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        ether 8c:16:45:8f:9f:b8  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
`

4.

5.
Маска /29 определяет подсеть из 8 адресов.
в сети /24, имеющей 256 адресов должно пометиться 32 сети /29 по 8 адресов,
```
Network:        192.168.22.0/29
Network:        192.168.22.8/29
Network:        192.168.22.16/29
Network:        192.168.22.24/29
Network:        192.168.22.32/29
Network:        192.168.22.40/29
Network:        192.168.22.48/29
Network:        192.168.22.56/29
...
...
...
Network:        192.168.22.232/29
Network:        192.168.22.240/29
Network:        192.168.22.248/29
```
32 сети

