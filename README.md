# Домашнее задание по NFS

- vagrant up должен поднимать 2 виртуалки: сервер и клиент;  
- на сервер должна быть расшарена директория;  
- на клиента она должна автоматически монтироваться при старте (fstab или autofs);  
- в шаре должна быть папка upload с правами на запись;  
- требования для NFS: NFSv3 по UDP, включенный firewall.  

# Выполнение

С помощью ```Vagrantfile``` развернуть две виртуальные машины: nfss - сервер и nfsc - клиент.
Первоначальная настройка машин выполняется с помощью скриптов ```nfss.sh``` и ```nfsc.sh```.

## Проверка работоспособности

