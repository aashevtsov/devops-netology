1.
Установлено, порт  9100 проброшен на хостовую машину

vagrant@vagrant:~$ ps -e |grep node_exporter   
   1375 ?        00:00:00 node_exporter
vagrant@vagrant:~$ systemctl stop node_exporter
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ===
Authentication is required to stop 'node_exporter.service'.
Authenticating as: vagrant,,, (vagrant)
Password: 
==== AUTHENTICATION COMPLETE ===
vagrant@vagrant:~$ ps -e |grep node_exporter
vagrant@vagrant:~$ systemctl start node_exporter
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ===
Authentication is required to start 'node_exporter.service'.
Authenticating as: vagrant,,, (vagrant)
Password: 
==== AUTHENTICATION COMPLETE ===
vagrant@vagrant:~$ ps -e |grep node_exporter
   1420 ?        00:00:00 node_exporter
vagrant@vagrant:~$ 

конфигруационный файл:
vagrant@vagrant:/etc/systemd/system$ cat /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
 
[Service]
ExecStart=/opt/node_exporter/node_exporter
EnvironmentFile=/etc/default/node_exporter
 
[Install]
WantedBy=default.target

после перезагрузки переменная окружения выставляется :
vagrant@vagrant:/etc/systemd/system$ sudo cat /proc/1809/environ
LANG=en_US.UTF-8LANGUAGE=en_US:PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
INVOCATION_ID=0fcb24d52895405c875cbb9cbc28d3ffJOURNAL_STREAM=9:35758MYVAR=some_value

2.
CPU:
    node_cpu_seconds_total{cpu="0",mode="idle"} 2238.49
    node_cpu_seconds_total{cpu="0",mode="system"} 16.72
    node_cpu_seconds_total{cpu="0",mode="user"} 6.86
    process_cpu_seconds_total
    
Memory:
    node_memory_MemAvailable_bytes 
    node_memory_MemFree_bytes
    
Disk(для нескольких дисков):
    node_disk_io_time_seconds_total{device="sda"} 
    node_disk_read_bytes_total{device="sda"} 
    node_disk_read_time_seconds_total{device="sda"} 
    node_disk_write_time_seconds_total{device="sda"}
    
Network(для каждого активного адаптера):
    node_network_receive_errs_total{device="eth0"} 
    node_network_receive_bytes_total{device="eth0"} 
    node_network_transmit_bytes_total{device="eth0"}
    node_network_transmit_errs_total{device="eth0"}

3.
Netdata установил, пробросил на  порт 9999, так как 19999 - занял  хосте  локальной neetdata 

информация с хоста:
20:11:25 shev@MyPC:~/vagrant$ sudo lsof -i :19999
COMMAND   PID    USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME
netdata 50358 netdata    4u  IPv4 1003958      0t0  TCP localhost:19999 (LISTEN)
20:11:29 shev@MyPC:~/vagrant$ sudo lsof -i :9999
COMMAND     PID USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME
chrome     4089 shev   80u  IPv4 1112886      0t0  TCP localhost:38598->localhost:9999 (ESTABLISHED)
VBoxHeadl 52075 shev   21u  IPv4 1053297      0t0  TCP *:9999 (LISTEN)
VBoxHeadl 52075 shev   30u  IPv4 1113792      0t0  TCP localhost:9999->localhost:38598 (ESTABLISHED)

информация с vagrant::
vagrant@vagrant:~$ sudo lsof -i :19999
COMMAND  PID    USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
netdata 1895 netdata    4u  IPv4  30971      0t0  TCP *:19999 (LISTEN)
netdata 1895 netdata   55u  IPv4  31861      0t0  TCP vagrant:19999->_gateway:38598 (ESTABLISHED)


4.
    agrant@vagrant:~$ dmesg |grep virtual
[    0.002836] CPU MTRRs all blank - virtualized system.
[    0.074550] Booting paravirtualized kernel on KVM
[    4.908209] systemd[1]: Detected virtualization oracle.

5.
shev@MyPC:~$ sysctl fs.nr_open
fs.nr_open = 1048576

Это максимальное число открытых дескрипторов для ядра (системы), для пользователя задать больше этого числа нельзя.

6.
root@vagrant:~# ps -e |grep sleep
   2020 pts/2    00:00:00 sleep
root@vagrant:~# nsenter --target 2020 --pid --mount
root@vagrant:/# ps
    PID TTY          TIME CMD
      2 pts/0    00:00:00 bash
     11 pts/0    00:00:00 ps

7.
это функция внутри "{}", с именем ":" , которая после опредения в строке запускает саму себя.
внутренности пораждают два фоновых процесса самой себя,
получается  бинарное дерево плодящее процессы

Видимо, система на основании этих файлов в пользовательской зоне ресурсов имеет определенное ограничение на создаваемые ресурсы
и соответсвенно при превышении начинает блокировать создание числа 

Если установить ulimit -u 50 - число процессов будет ограниченно 50 для пользоователя 
