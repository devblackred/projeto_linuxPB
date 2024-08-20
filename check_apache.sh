#!/bin/bash 
STATUS=$(systemctl is-active httpd)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
if [ "$STATUS" = "active" ]; then
     echo "$TIMESTAMP Apache ONLINE - Tudo Certo" >> /home/ec2-user/efs/Celio/apache_online.log
else
     echo "$TIMESTAMP Apache OFFLINE - servico offline" >> /home/ec2-user/efs/Celio/apache_offline.log
fi
