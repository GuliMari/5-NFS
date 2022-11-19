# Домашнее задание по NFS

- vagrant up должен поднимать 2 виртуалки: сервер и клиент;  
- на сервер должна быть расшарена директория;  
- на клиента она должна автоматически монтироваться при старте (fstab или autofs);  
- в шаре должна быть папка upload с правами на запись;  
- требования для NFS: NFSv3 по UDP, включенный firewall.  

# Выполнение

С помощью `Vagrantfile` развернуть две виртуальные машины: nfss - сервер и nfsc - клиент.
Первоначальная настройка машин выполняется с помощью скриптов `nfss.sh` и `nfsc.sh`.

## Проверка работоспособности

Заходим по SSH на `nfss` и `nfsc`.   
На сервере проверяем наличие экспортированной директории:

```bash
[root@nfss ~]# exportfs -s
/srv/share  192.168.50.11(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)

```

Заходим в каталог `/srv/share/upload` создаём тестовый файл: 

```bash

[root@nfss ~]# cd /srv/share/upload
[root@nfss upload]# touch check_file

```

Теперь проверяем на клиенте, появился ли созданный файл в `/mnt/upload`:

```bash
[root@nfsc ~]# cd /mnt/upload/
[root@nfsc upload]# ll
total 0
-rw-r--r--. 1 root      root      0 Nov 19 18:02 check_file

```

Создаем файл на клиенте:

```bash

[root@nfsc upload]# touch client_file
root@nfsc upload]# ll
total 0
-rw-r--r--. 1 root      root      0 Nov 19 18:02 check_file
-rw-r--r--. 1 nfsnobody nfsnobody 0 Nov 19 18:18 client_file

```

Файлы на месте, значит права на доступ к upload работают.

Теперь проверим работоспособность клиентской части после перезапуска и правильность настройки автомонтирования:

```bash

tw4@tw4-VB:~/5-NFS$ vagrant ssh nfsc
Last login: Sat Nov 19 17:39:55 2022 from 10.0.2.2
[vagrant@nfsc ~]$ cd /mnt/upload
[vagrant@nfsc upload]$ ll
total 0
-rw-r--r--. 1 root      root      0 Nov 19 18:02 check_file
-rw-r--r--. 1 nfsnobody nfsnobody 0 Nov 19 18:18 client_file

```


