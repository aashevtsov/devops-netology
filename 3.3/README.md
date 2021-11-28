1.
CD -> chdir("/tmp")<br> 

2.
Файл базы типов - /usr/share/misc/magic.mgc<br>

3.
vagrant@vagrant:\~$ lsof -p 1126<br>

vi      1126 vagrant    4u   REG  253,0    12288  526898 /home/vagrant/.tst_bash.swp (deleted)<br>

vagrant@vagrant:\~$ echo '' >/proc/1126/fd/4<br>


1126 - PID процесса vi<br>
4 - дескриптор файла<br>

4.
"Зомби" процессы, в отличии от "сирот" освобождают свои ресурсы, но не освобождают запись в таблице процессов. <br>
запись освободиться при вызове wait() родительским процессом.<br>

5.
dpkg -L bpfcc-tools | grep sbin/opensnoop<br>
PID    COMM               FD ERR PATH<br>
126149 bash                3   0 /proc/uptim<br>e
126149 bash                3   0 /var/cache/netdata/.netdata_bash_sleep_timer_fifo<br>
1669   sqlservr          114   0 <br>
2674   ThreadPoolForeg   247   0 /home/shev/.config/google-chrome/Default/IndexedDB/chrome-extension_bihmplhobchoageeokmgbdihknkjbknd_0.indexeddb.leveldb<br>
2674   ThreadPoolForeg    -1   2 /home/shev/.config/google-chrome/Default/IndexedDB/chrome-extension_bihmplhobchoageeokmgbdihknkjbknd_0.indexeddb.blob<br>
109695 PLUGIN[cgroups]    16   0 /sys/fs/cgroup/cpu,cpuacct/system.slice/irqbalance.service/cpuacct.stat<br>

6.
Part of the utsname information is also accessible  via  /proc/sys/ker‐<br>
nel/{ostype, hostname, osrelease, version, domainname}.<br>

7.
&& логический оператор ; это простая последовательность<br>

8.
-e прерывает выполнение исполнения при ошибке любой команды кроме последней в последовательности <br>
-x вывод трейса простых команд <br>
-u неустановленные/не заданные параметры и переменные считаются как ошибки, с выводом в stderr текста ошибки и выполнит завершение неинтерактивного вызова<br>
-o pipefail возвращает код возврата набора/последовательности команд, ненулевой при последней команды или 0 для успешного выполнения команд.<br>

повышает деталезацию вывода ошибок(логирования), <br>
и завершит сценарий при наличии ошибок, на любом этапе выполнения сценария, кроме последней завершающей команды<br>

9.
S*(S,S+,Ss,Ssl,Ss+) - Процессы ожидающие завершения (спящие с прерыванием "сна")<br>
I*(I,I<) - фоновые(бездействующие) процессы ядра<br>	

