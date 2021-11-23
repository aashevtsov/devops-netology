1. Это команда встройенная.
   Внвстроенная, потому что, работать внутри сессии терминала логичнее менять указатель на текущую дерикторию внутренней функцией, 
   Если спользовать внешний вызов, то он будет работать со своим окружением, и менять  текущий каталог внутри своего окружения, а на вызвовший shell влиять не будет.  
2.
vagrant@vagrant:~$ cat tst_bash
if [[ -d /tmp ]];
test
test
123
vagrant@vagrant:~$ grep 123 tst_bash -c
1
vagrant@vagrant:~$ grep 123 tst_bash |wc -l
1

3. 
на моей машине
systemd(1)─┬─ModemManager(1179)─┬─{ModemManager}(1232)
           │                    └─{ModemManager}(1236)
На виртуальной
vagrant@vagrant:~$ pstree -p
systemd(1)─┬─VBoxService(753)─┬─{VBoxService}(754)
           │                  ├─{VBoxService}(755)
           │                  ├─{VBoxService}(756)
4.
pts/0:
vagrant@vagrant:~$ ls -l \root 2>/dev/pts/1
vagrant@vagrant:~$ 
    

Вывод в другой сессии pts/1:    

vagrant@vagrant:~$ who
vagrant  pts/0        2021-11-23 18:58 (192.168.30.30)
vagrant  pts/1        2021-11-23 18:59 (192.168.30.30)
vagrant@vagrant:~$ ls: cannot access 'root': No such file or directory

5.
vagrant@vagrant:~$ cat test
if [[ -d /tmp ]];
test
test
123
vagrant@vagrant:~$ cat test_out
cat: tst_bash_out: No such file or directory 
vagrant@vagrant:~$ cat <test >test_out
vagrant@vagrant:~$ cat tst_bash_out
if [[ -d /tmp ]];
test
test
123
vagrant@vagrant:~$
6.
Вывести полуится при использовании перенаправлении вывода:
    15:04:58 shev@MyPC(0):~/vagrant$ tty
    /dev/pts/3
    15:05:45 shev@MyPC(0):~/vagrant$ echo Hello from pts3 to tty3 >/dev/tty3
    15:06:19 shev@MyPC(0):~/vagrant$ 

наблюдать в графическом режиме не получиться, нужно переключиться в контекст TTY 

7.
bash 5>&1 - Создаст дескриптор с 5 и перенатправит его в stdout
echo netology > /proc/$$/fd/5 - выведет в дескриптор "5", который был пернеаправлен в stdout

если запустить echo netology > /proc/$$/fd/5 в новой сесии, получим ошибку, так как такого дескриптора нет на данный момент в текущей(новой) сесии

    
vagrant@vagrant:~$ echo netology > /proc/$$/fd/5
-bash: /proc/1096/fd/5: No such file or directory
vagrant@vagrant:~$ bash 5>&1
vagrant@vagrant:~$ echo netology > /proc.$$/fd/5
bash: /proc.1114/fd/5: No such file or directory
vagrant@vagrant:~$ echo netology > /proc/$$/fd/5
netology
vagrant@vagrant:~$

8.
vagrant@vagrant:~$ ls -l /root 9>&2 2>&1 1>&9 | grep denied -c 
1

9>&2 - новый дескриптор перенаправили в stderr
2>&1 - stderr перенаправили в stdout 
1>&9 - stdout - перенаправили в в новый дескриптор

9.
Будут выведены переменные окружения
можно получить тоже самое:
printenv
env

10.
/proc/<PID>/cmdline - полный путь до исполняемого файла процесса [PID]  (строка 231)
/proc/<PID>/exe - содержит ссылку до файла запущенного для процесса [PID], 
cat выведет содержимое запущенного файла, 
запуск этого файла,  запустит еще одну копию самого файла  (строка 285)

11.
SSE 4.2

