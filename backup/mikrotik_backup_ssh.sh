#!/bin/bash

set -x

DATE=`date +"%Y%m%d"`
DIR="/backup/mikrotik/"
PREFIX=`date +"%Y/%m"`

if [ ! -d "$DIR/$PREFIX" ]; then
   mkdir -p "$DIR/$PREFIX"
fi

NAME_BACKUP="miktorik_$DATE.backup"
NAME_BACKUP_RSC="miktorik_$DATE.rsc"
TMP_BACKUP="/backup/tmp/mikrotik/"

if [ ! -d "$TMP_BACKUP" ]; then
   mkdir -p "$TMP_BACKUP"
fi

cd $TMP_BACKUP

mkdir -p $TMP_BACKUP/mikrotik-$DATE
declare -a arr=("192.168.0.1" "192.168.0.2" "192.168.0.3" "192.168.0.4" "192.168.0.6" "192.168.0.7" "192.168.0.8" )
for MT in "${arr[@]}"
do
    backup_name="$MT-$NAME_BACKUP"
    backup_name_rsc="$MT-$NAME_BACKUP_RSC"
    backup_command=(/system backup save name=$backup_name)
    backup_export=(/export verbose file=$backup_name_rsc)

    ssh backup@$MT ${backup_command[@]}
    ssh backup@$MT ${backup_export[@]}
    scp backup@$MT:$backup_name $TMP_BACKUP/mikrotik-$DATE
    scp backup@$MT:$backup_name_rsc $TMP_BACKUP/mikrotik-$DATE


    remove_command=(/file remove \"$backup_name\")
    remove_rsc=(/file remove \"$backup_name_rsc\")
    ssh backup@$MT ${remove_command[@]}
    ssh backup@$MT ${remove_rsc[@]}

done

tar -czvf mikrotik-$DATE.tar.gz mikrotik-$DATE
mv $TMP_BACKUP/mikrotik-$DATE.tar.gz $DIR/$PREFIX

rm -fR $TMP_BACKUP
