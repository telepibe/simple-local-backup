#!/usr/bin/env bash

# Bash unofficial strict mode
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

destination="/mnt/iowa-data/juani/backups"

log="/home/juani/.var/logs/backup.log"

toBackup=(
			/home/juani/Documents
			/home/juani/Soft
			"/home/juani/VirtualBox VMs"
)

opts=(
		-hv
		--archive
		--delete
)

date=$(date "+%d-%m-%Y a las %H:%M")


function closeLog {
	echo -e '###\n' >> $log
}

trap closeLog EXIT

cat >> $log << EOC

###
Backup iniciado el $date con cmd:
rsync ${opts[@]} ${toBackup[@]} $destination >> $log 2>&1

EOC

# Be nice
ionice -c 3 -p $$ >/dev/null
renice +12  -p $$ >/dev/null

set +e
rsync "${opts[@]}" "${toBackup[@]}" "${destination}" >> "${log}" 2>&1
ret=$?
set -e

# Output for cron
if  [[ $ret -gt 0 ]]
then
	echo "rsync error with code ${ret}. Check ${log}" >&2
	exit $ret
fi
