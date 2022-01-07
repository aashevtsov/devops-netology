##Обязательная задача 1<br>
Мы выгрузили JSON, который получили через API запрос к нашему сервису:<br>
```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```
Не хватает запятой между элементами массива и 3-х двойных кавычек.<br>

```json
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            },
            { "name" : "second",
            "type" : "proxy",
            "ip" : "71.78.22.43"
            }
        ]
    }
```

## Обязательная задача 2<br>
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.<br>

список сервисов будет хранить в файле yaml:

```yaml
[root@MyPC temp]# cat web-services.yaml 
---
- drive.google.com
- mail.google.com
- google.com
...

### Ваш скрипт:<br>


```python
#!/usr/bin/env python3

import socket
import datetime
import time
import yaml
import json

# Функция которая записывает в json файл значения { "имя сервиса" : "его IP"} по одному в строке
def write_host_ip_oneonline_to_json(host_ip_dict):
    with open("Current_webservices_resolving.json", 'w') as jsfile:
        for hostname in host_ip_dict:
            host_ip_1 = {}
            host_ip_1[hostname] = host_ip_dict[hostname]
            jsfile.write(json.dumps(host_ip_1)+'\n')

# Функция, которая записывает в yaml файл значения      - имя сервиса: его IP        по одному в строке
def write_host_ip_oneonline_to_yaml(host_ip_dict):
    # создаём список, в который будем помещать элементы словаря, чтобы при выводе его в yaml у нас появились дефисы
    host_ip_list=[]
    with open("Current_webservices_resolving.yaml", 'w') as ymfile:
        for hostname in host_ip_dict:
            host_ip_1 = {}
            host_ip_1[hostname] = host_ip_dict[hostname]
            host_ip_list.append(host_ip_1)
        ymfile.write(yaml.dump(host_ip_list, default_flow_style=False, explicit_start=True, explicit_end=True))


#Считываем список веб-сервисов.Будем хранить его в файле yaml
with open('/temp/web-services.yaml', 'r') as config_file:
    hostnames = yaml.safe_load(config_file)

# Создаём основной словарь для хранения данных об узле такого вида {Имя_Узла:[старый_ip, текущий_ip]}
db_host_ip = {}

print("Имена Веб-сервисов, считанных из файла конфига :")
for host in hostnames:
    print (host)

print("\nЗаполняем структуру словаря хранения узлов ...")
for host in hostnames:
    db_host_ip[host] = ""

print(db_host_ip)

# далее в программе hostname - это будет переменная, содержащая значение ключа словаря db_host_ip (а в ключе у нас имена веб-сервисов)

print("\nНачальные адреса определены:")
for hostname in db_host_ip:
    db_host_ip[hostname] = socket.gethostbyname(hostname)

print(db_host_ip)

# передаём словарь host_ip в функции записи файлы JSON и YAML  по одному хосту в строке
write_host_ip_oneonline_to_json(db_host_ip)
write_host_ip_oneonline_to_yaml(db_host_ip)

print("\nНачинаем отслеживание изменений в резолвинге ДНС адресов сервисов:")

while (True):
    for hostname in db_host_ip:
# для каждого хоста из словоря проеряем текущий ip адрес
        current_ip = socket.gethostbyname(hostname)
        if (db_host_ip[hostname] != current_ip):
# если текущий ip на данный момент не равен старому ip, бывшему при прошлой проверке, то выводим сообщение и обновляем значение адреса в словаре 
            now = datetime.datetime.now()
            print(str(now)," [ERROR] ",hostname," IP mismatch: ",db_host_ip[hostname]," ",current_ip)
            db_host_ip[hostname] = current_ip

            write_host_ip_oneonline_to_json(db_host_ip)
    time.sleep(3)
```

### Вывод скрипта при запуске при тестировании:
```bash
[root@MyPC temp]# ./4.3_script-2.1.sh
Имена Веб-сервисов, считанных из файла конфига :
drive.google.com
mail.google.com
google.com

Заполняем структуру словаря хранения узлов ...
{'drive.google.com': '', 'mail.google.com': '', 'google.com': ''}

Начальные адреса определены:
{'drive.google.com': '142.250.186.142', 'mail.google.com': '142.250.185.197', 'google.com': '142.250.186.46'}

Начинаем отслеживание изменений в резолвинге ДНС адресов сервисов:
2022-01-05 10:35:38.363430  [ERROR]  google.com  IP mismatch:  142.250.186.46   142.250.185.174
2022-01-05 10:35:41.531035  [ERROR]  google.com  IP mismatch:  142.250.185.174   142.250.186.46
2022-01-05 10:40:00.797765  [ERROR]  google.com  IP mismatch:  142.250.186.46   142.250.185.174
2022-01-05 10:40:03.967364  [ERROR]  google.com  IP mismatch:  142.250.185.174   142.250.186.46
2022-01-05 10:40:13.457698  [ERROR]  google.com  IP mismatch:  142.250.186.46   142.250.185.174
2022-01-05 10:40:16.613793  [ERROR]  google.com  IP mismatch:  142.250.185.174   142.250.186.46

### json-файл(ы), который(е) записал ваш скрипт:
`[root@MyPC temp]# cat Current_webservices_resolving.json`
```json
{"drive.google.com": "142.250.186.142"}
{"mail.google.com": "142.250.185.197"}
{"google.com": "142.250.74.206"}
```

### yml-файл(ы), который(е) записал ваш скрипт:
`[root@MyPC temp]# cat Current_webservices_resolving.yaml`
```yaml
---
- drive.google.com: 142.250.186.142
- mail.google.com: 142.250.185.197
- google.com: 142.250.186.46
...
