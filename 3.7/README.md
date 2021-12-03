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
для разделения сети используют VLAN
Модуль VLAN

Добавляем VLAN
<br>
`shev@MyPC:~$ nmcli con add type vlan con-name enp0s31f6.500 ifname VLAN500 id 500 dev enp0s31f6 ip4 10.10.10.10/24
`
<br>
Смотрим
```
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
```

4.
Типы агрегации
```
Режим	Тип	         Описание и достижение Fail Tolerance и Balancing
0	Round Robin         Пакеты последовательно отправляются/принимаются через каждый интерфейс один за другим.	Fail Tolerance -	Balancing +
mode balance-rr
1	Active Backup	    Активен один интерфейс, другой находится в standby. Если активный интерфейс выходит из строя или отключается, другой интерфейс становится активным.	Fail Tolerance +	Balancing -
mode active-backup
2	XOR [exclusive OR]  В этом режиме MAC-адрес вспомогательного интерфейса сопоставляется с MAC входящего запроса, и как только это соединение установлено, тот же интерфейс используется для отправки/получения для MAC-адреса назначения.	Fail Tolerance +	Balancing +
mode balance-xor
3	Broadcast           Происходит передача во все объединенные интерфейсы, тем самым обеспечивая отказоустойчивость. Рекомендуется только для использования MULTICAST трафика.	Fail Tolerance +	Balancing -
mode broadcast
4	Dynamic Link Aggregation        Динамическое объединение одинаковых портов. В данном режиме можно значительно увеличить пропускную способность входящего так и исходящего трафика. Для данного режима необходима поддержка и настройка коммутатора/коммутаторов.	Fail Tolerance +	Balancing +
mode 802.3ad
5	Transmit Load Balancing (TLB)	Адаптивная балансировки нагрузки трафика. Входящий трафик получается только активным интерфейсом, исходящий распределяется в зависимости от текущей загрузки канала каждого интерфейса. Не требуется специальной поддержки и настройки коммутатора/коммутаторов.	Fail Tolerance +	Balancing +
mode balance-tlb
6	Adaptive Load Balancing (ALB)	Адаптивная балансировка нагрузки. Отличается более совершенным алгоритмом балансировки нагрузки чем Mode-5). Обеспечивается балансировку нагрузки как исходящего так и входящего трафика. Не требуется специальной поддержки и настройки коммутатора/коммутаторов.	Fail Tolerance +	Balancing +
mode balance-alb
```

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

6.
100.64.0.0/26

7.
в Linux  и Windows  команда arp -a<br>
очистить полностью arp -d *<br>
Удалить один адрес из таблицы arp -d "ip адрес"<br>

