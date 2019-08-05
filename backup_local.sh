#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

#toBackup="/home/juani/Documents"
#toBackup="${toBackup} /home/juani/Soft"
#toBackup="${toBackup} /home/juani/VirtualBox\ VMs"

toBackup="/home/juani/Documents"
toBackup+=" /home/juani/Soft"
toBackup+=" /home/juani/VirtualBox\ VMs"

opts="-hv --archive --delete"
log="/home/juani/.var/backup.log"

destination="/mnt/iowa-data/juani/backups"

date=$(date "+%d-%m-%Y a las %H:%M")

cmd="rsync $opts $toBackup $destination >> $log 2>&1"


cat >> $log << EOC

###
Backup iniciado el $date con cmd:
$cmd
EOC

ionice -c 3 -p $$ >/dev/null
renice +12  -p $$ >/dev/null

set +e
eval "$cmd"
ret=$?
set -e

echo -e '###\n' >> $log

if  [[ $ret -gt 0 ]]
then
	echo "rsync error ${ret}. Check ${log}" >&2
	exit $ret
fi