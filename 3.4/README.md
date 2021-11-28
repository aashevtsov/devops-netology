1.
Установлено, порт  9100 проброшен на хостовую машинe<br>

vagrant@vagrant:\~$ ps -e | grep node_exporter   <br>
   1375 ?        00:00:00 node_exporter<br>
vagrant@vagrant:\~$ systemctl stop node_exporter<br>
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ===<br>
Authentication is required to stop 'node_exporter.service'.<br>
Authenticating as: vagrant,,, (vagrant)<br>
Password: <br>
==== AUTHENTICATION COMPLETE ===<br>
vagrant@vagrant:\~$ ps -e |grep node_exporter<br>
vagrant@vagrant:\~$ systemctl start node_exporter<br>
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ===<br>
Authentication is required to start 'node_exporter.service'.<br>
Authenticating as: vagrant,,, (vagrant)<br>
Password: <br>
==== AUTHENTICATION COMPLETE ===<br>
vagrant@vagrant:\~$ ps -e |grep node_exporter<br>
   1420 ?        00:00:00 node_exporter<br>
vagrant@vagrant:\~$ <br>

конфигруационный файл:<br>
vagrant@vagrant:/etc/systemd/system$ cat /etc/systemd/system/node_exporter.service<br>
[Unit]<br>
Description=Node Exporter<br><br>
 
[Service]<br>
ExecStart=/opt/node_exporter/node_exporter<br>
EnvironmentFile=/etc/default/node_exporter<br><br>
 
[Install]<br>
WantedBy=default.target<br><br>

после перезагрузки переменная окружения выставляется :<br>
vagrant@vagrant:/etc/systemd/system$ sudo cat /proc/1809/environ<br>
LANG=en_US.UTF-8LANGUAGE=en_US:PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin<br>
INVOCATION_ID=0fcb24d52895405c875cbb9cbc28d3ffJOURNAL_STREAM=9:35758MYVAR=some_value<br>

2.
CPU:<br>
    node_cpu_seconds_total{cpu="0",mode="idle"} 2238.49<br>
    node_cpu_seconds_total{cpu="0",mode="system"} 16.72<br>
    node_cpu_seconds_total{cpu="0",mode="user"} 6.86<br>
    process_cpu_seconds_total<br>
    <br>
Memory:<br>
    node_memory_MemAvailable_bytes <br>
    node_memory_MemFree_bytes<br>
    <br>
Disk(для нескольких дисков): <br>
    node_disk_io_time_seconds_total{device="sda"} <br>
    node_disk_read_bytes_total{device="sda"} <br>
    node_disk_read_time_seconds_total{device="sda"} <br>
    node_disk_write_time_seconds_total{device="sda"}<br>
    <br>
Network(для каждого активного адаптера):<br>
    node_network_receive_errs_total{device="eth0"} <br>
    node_network_receive_bytes_total{device="eth0"} <br>
    node_network_transmit_bytes_total{device="eth0"}<br>
    node_network_transmit_errs_total{device="eth0"}<br><br>

3.
Netdata установил, пробросил на  порт 9999, так как 19999 - занял  хосте  локальной neetdata <br><br>

информация с хоста:<br>
20:11:25 shev@MyPC:~/vagrant$ sudo lsof -i :19999<br>
COMMAND   PID    USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME<br>
netdata 50358 netdata    4u  IPv4 1003958      0t0  TCP localhost:19999 (LISTEN)<br>
20:11:29 shev@MyPC:~/vagrant$ sudo lsof -i :9999<br>
COMMAND     PID USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME<br>
chrome     4089 shev   80u  IPv4 1112886      0t0  TCP localhost:38598->localhost:9999 (ESTABLISHED)<br>
VBoxHeadl 52075 shev   21u  IPv4 1053297      0t0  TCP *:9999 (LISTEN)<br>
VBoxHeadl 52075 shev   30u  IPv4 1113792      0t0  TCP localhost:9999->localhost:38598 (ESTABLISHED)<br><br>

информация с vagrant::<br>
vagrant@vagrant:\~$ sudo lsof -i :19999<br>
COMMAND  PID    USER   FD   TYPE DEVICE SIZE/OFF NODE NAME<br>
netdata 1895 netdata    4u  IPv4  30971      0t0  TCP *:19999 (LISTEN)<br>
netdata 1895 netdata   55u  IPv4  31861      0t0  TCP vagrant:19999->_gateway:38598 (ESTABLISHED)<br>
<br>

4.
vagrant@vagrant:\~$ dmesg | grep virtual<br>
[    0.002836] CPU MTRRs all blank - virtualized system.<br>
[    0.074550] Booting paravirtualized kernel on KVM<br>
[    4.908209] systemd[1]: Detected virtualization oracle.<br><br>

5.
shev@MyPC:\~$ sysctl fs.nr_open<br>
fs.nr_open = 1048576<br>

Это максимальное число открытых дескрипторов для ядра (системы), для пользователя задать больше этого числа нельзя.<br><br>

6.
root@vagrant:\~# ps -e | grep sleep<br>
   2020 pts/2    00:00:00 sleep<br>
root@vagrant:\~# nsenter --target 2020 --pid --mount<br>
root@vagrant:/# ps<br>
    PID TTY          TIME CMD<br>
      2 pts/0    00:00:00 bash<br>
     11 pts/0    00:00:00 ps<br><br>

7.
это функция внутри "{}", с именем ":" , которая после опредения в строке запускает саму себя.<br>
внутренности пораждают два фоновых процесса самой себя,<br>
получается  бинарное дерево плодящее процессы<br>

Видимо, система на основании этих файлов в пользовательской зоне ресурсов имеет определенное ограничение на создаваемые ресурсы<br>
и соответсвенно при превышении начинает блокировать создание числа <br><br>

Если установить ulimit -u 50 - число процессов будет ограниченно 50 для пользоователя <br><br>
