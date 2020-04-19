#!/bin/bash

#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>

# Script de backup automatique d'un snap nextcloud vers un point de montage NFS

#chemin du point de montage NFS (voir dans /etc/fstab)
NFS_BKP="/backups/"
#chemin de backup local par défaut - le * éviter de récupérer spécifiquement le nom de du backup local
LOCAL_BKP="/var/snap/nextcloud/common/backups/*"
#fichier de log complet
LOGS="/var/log/nextcloud_auto_backup.log"

#Infos date et heure de début dans les logs
echo "" >> $LOGS
echo "#############################" >> $LOGS
echo "BACKUP STARTS "$(date) >> $LOGS

#backup sur 2 mois seulement (currunt mois-1 et mois-2)
rm $NFS_BKP/nextcloud_backup_old2.tar.gz >> $LOGS 2>&1
mv $NFS_BKP/nextcloud_backup_old.tar.gz $NFS_BKP/nextcloud_backup_old2.tar.gz >> $LOGS 2>&1
mv /backups/nextcloud_backup_lastest.tar.gz $NFS_BKP/nextcloud_backup_old.tar.gz >> $LOGS 2>&1

#backup du snap en local
nextcloud-export >> $LOGS 2>&1

#compression du tar en local
tar -zcvf /root/nextcloud_backup_lastest.tar.gz LOCAL_BKP >>2 $LOGS

#copie du fichier local sur le montage NFS
rsync -az /root/nextcloud_backup_lastest.tar.gz NFS_BKP >> $LOGS 2>&1

#Suppression des backups locaux
rm /root/nextcloud_backup_lastest.tar.gz >> $LOGS 2>&1
rm -rf LOCAL_BKP >> $LOGS 2>&1

#Infos date et heure de fin dans les logs
echo "" >> $LOGS 
echo "#############################" >> $LOGS 
echo "BACKUP ENDS "$(date) >> $LOGS 
