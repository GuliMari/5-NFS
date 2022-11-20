#!/bin/bash

sudo -i
yum install -y nfs-utils

#включаем firewall 
systemctl enable firewalld --now

#добавляем в /etc/fstab для настройки автоматического монтирования директории при обращении к ней 
echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab

#перезагружаем конфигурации
systemctl daemon-reload
systemctl restart remote-fs.target


