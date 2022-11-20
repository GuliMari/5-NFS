#!/bin/bash

sudo -i
yum install -y nfs-utils

#включаем firewall и разрешаем доступ к сервисам NFS 
systemctl enable firewalld --now
firewall-cmd --add-service="nfs3" --add-service="rpc-bind" --add-service="mountd" --permanent
firewall-cmd --reload

#включаем сервер NFS
systemctl enable nfs --now

#создаём и настраиваем директорию, которая будет экспортирована в будущем
mkdir -p /srv/share/upload
chown -R nfsnobody:nfsnobody /srv/share
chmod 0777 /srv/share/upload

#создаём в файле /etc/exports структуру, которая позволит экспортировать ранее созданную директорию
cat << EOF > /etc/exports
/srv/share 192.168.50.11(rw,sync,root_squash)
EOF

#экспортируем ранее созданную директорию
exportfs -r

