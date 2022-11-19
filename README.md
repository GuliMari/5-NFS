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

Проверяем сервер после перезагрузки:
tw4@tw4-VB:~/5-NFS$ vagrant ssh nfss

Last login: Sat Nov 19 19:21:08 2022 from 10.0.2.2

[vagrant@nfss ~]$ cd /srv/share/upload/

[vagrant@nfss upload]$ ll

total 0

-rw-r--r--. 1 root      root      0 Nov 19 18:02 check_file

-rw-r--r--. 1 nfsnobody nfsnobody 0 Nov 19 18:18 client_file

-rw-rw-r--. 1 vagrant   vagrant   0 Nov 19 18:48 file

-rw-rw-r--. 1 vagrant   vagrant   0 Nov 19 18:48 file2

[vagrant@nfss upload]$ systemctl status nfs

● nfs-server.service - NFS server and services

   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)

  Drop-In: /run/systemd/generator/nfs-server.service.d

           └─order-with-mounts.conf

   Active: active (exited) since Sat 2022-11-19 19:35:09 UTC; 1min 48s ago

  Process: 846 ExecStartPost=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=exited, status=0/SUCCESS)

  Process: 828 ExecStart=/usr/sbin/rpc.nfsd $RPCNFSDARGS (code=exited, status=0/SUCCESS)

  Process: 822 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)

 Main PID: 828 (code=exited, status=0/SUCCESS)

   CGroup: /system.slice/nfs-server.service

[vagrant@nfss upload]$ systemctl status firewalld

● firewalld.service - firewalld - dynamic firewall daemon

   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)

   Active: active (running) since Sat 2022-11-19 18:26:01 UTC; 1h 11min ago

     Docs: man:firewalld(1)

 Main PID: 387 (firewalld)

   CGroup: /system.slice/firewalld.service

           └─387 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid

[vagrant@nfss upload]$ exportfs -s

exportfs: could not open /var/lib/nfs/.etab.lock for locking: errno 13 (Permission denied)

[vagrant@nfss upload]$ sudo -i

[root@nfss ~]# exportfs -s

/srv/share  192.168.50.11(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)

[root@nfss ~]# showmount -a 192.168.50.10

All mount points on 192.168.50.10:

192.168.50.11:/srv/share

Проверяем клиент:

tw4@tw4-VB:~/5-NFS$ vagrant ssh nfsc

Last login: Sat Nov 19 19:12:52 2022 from 10.0.2.2

[vagrant@nfsc ~]$ showmount -a 192.168.50.10

All mount points on 192.168.50.10:

[vagrant@nfsc ~]$ cd /mnt/upload

[vagrant@nfsc upload]$ mount | grep mnt

systemd-1 on /mnt type autofs (rw,relatime,fd=33,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=11261)

192.168.50.10:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=192.168.50.10,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.50.10)

[vagrant@nfsc upload]$ ll

total 0

-rw-r--r--. 1 root      root      0 Nov 19 18:02 check_file

-rw-r--r--. 1 nfsnobody nfsnobody 0 Nov 19 18:18 client_file

-rw-rw-r--. 1 vagrant   vagrant   0 Nov 19 18:48 file

-rw-rw-r--. 1 vagrant   vagrant   0 Nov 19 18:48 file2

[vagrant@nfsc upload]$ touch final_file

[vagrant@nfsc upload]$ ll

total 0

-rw-r--r--. 1 root      root      0 Nov 19 18:02 check_file

-rw-r--r--. 1 nfsnobody nfsnobody 0 Nov 19 18:18 client_file

-rw-rw-r--. 1 vagrant   vagrant   0 Nov 19 18:48 file

-rw-rw-r--. 1 vagrant   vagrant   0 Nov 19 18:48 file2

-rw-rw-r--. 1 vagrant   vagrant   0 Nov 19 19:56 final_file






