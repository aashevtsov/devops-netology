1. 
Это команда встройенная.<br>
Внвстроенная, потому что, работать внутри сессии терминала логичнее менять указатель на текущую дерикторию внутренней функцией, <br>
Если спользовать внешний вызов, то он будет работать со своим окружением, и менять  текущий каталог внутри своего окружения, а на вызвовший shell влиять не будет.

2. 
vagrant@vagrant:~$ cat tst_bash<br>
if [[ -d /tmp ]];<br>
test<br>
test<br>
123<br>
vagrant@vagrant:~$ grep 123 tst_bash -c<br>
1<br>
vagrant@vagrant:~$ grep 123 tst_bash |wc -l<br>
1<br>

3. 
на моей машине<br>
systemd(1)─┬─ModemManager(1179)─┬─{ModemManager}(1232)<br>
           │                    └─{ModemManager}(1236)<br>
На виртуальной<br>
vagrant@vagrant:~$ pstree -p<br>
systemd(1)─┬─VBoxService(753)─┬─{VBoxService}(754)<br>
           │                  ├─{VBoxService}(755)<br>
           │                  ├─{VBoxService}(756)<br>
           
4.
pts/0:<br>
vagrant@vagrant:~$ ls -l \root 2>/dev/pts/1<br>
vagrant@vagrant:~$ <br>    

Вывод в другой сессии pts/1:    <br>

vagrant@vagrant:~$ who<br>
vagrant  pts/0        2021-11-23 18:58 (192.168.30.30)<br>
vagrant  pts/1        2021-11-23 18:59 (192.168.30.30)<br>
vagrant@vagrant:~$ ls: cannot access 'root': No such file or directory<br>

5.
vagrant@vagrant:~$ cat test<br>
if [[ -d /tmp ]];<br>
test<br>
test<br>
123<br>
vagrant@vagrant:~$ cat test_out<br>
cat: tst_bash_out: No such file or directory <br>
vagrant@vagrant:~$ cat <test >test_out<br>
vagrant@vagrant:~$ cat tst_bash_out<br>
if [[ -d /tmp ]];<br>
test<br>
test<br>
123<br>
vagrant@vagrant:~$<br>
   
6.
Вывести полуится при использовании перенаправлении вывода:<br>
    15:04:58 shev@MyPC(0):~/vagrant$ tty<br>
    /dev/pts/3<br>
    15:05:45 shev@MyPC(0):~/vagrant$ echo Hello from pts3 to tty3 >/dev/tty3<br>
    15:06:19 shev@MyPC(0):~/vagrant$ <br>
<br>
наблюдать в графическом режиме не получиться, нужно переключиться в контекст TTY <br>

7.
bash 5>&1 - Создаст дескриптор с 5 и перенатправит его в stdout<br>
echo netology > /proc/$$/fd/5 - выведет в дескриптор "5", который был пернеаправлен в stdout<br>
если запустить echo netology > /proc/$$/fd/5 в новой сесии, получим ошибку, так как такого дескриптора нет на данный момент в текущей(новой) сесии<br>
    
vagrant@vagrant:~$ echo netology > /proc/$$/fd/5<br>
-bash: /proc/1096/fd/5: No such file or directory<br>
vagrant@vagrant:~$ bash 5>&1<br>
vagrant@vagrant:~$ echo netology > /proc.$$/fd/5<br>
bash: /proc.1114/fd/5: No such file or directory<br>
vagrant@vagrant:~$ echo netology > /proc/$$/fd/5<br>
netology<br>
vagrant@vagrant:~$<br>

8.
vagrant@vagrant:~$ ls -l /root 9>&2 2>&1 1>&9 | grep denied -c <br>
1<br>

9>&2 - новый дескриптор перенаправили в stderr<br>
2>&1 - stderr перенаправили в stdout <br>
1>&9 - stdout - перенаправили в в новый дескриптор<br>

9.
Будут выведены переменные окружения<br>
можно получить тоже самое:<br>
printenv<br>
env<br>

10.
/proc/<PID>/cmdline - полный путь до исполняемого файла процесса [PID]  (строка 231)<br>
/proc/<PID>/exe - содержит ссылку до файла запущенного для процесса [PID], <br>
cat выведет содержимое запущенного файла, <br>
запуск этого файла,  запустит еще одну копию самого файла  (строка 285)<br>

11.
SSE 4.2<br>

