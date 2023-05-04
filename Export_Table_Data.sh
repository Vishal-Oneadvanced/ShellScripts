#!/bin/bash

filename=log.txt
flag=true;
MAP_NAMES="TXAMAP TXAVARNT"
MAP_BACKUP_PATH='C:/Project_E5H5_Files/Backups/Test/'


# Fucntions
function CopyData()
{
	psql -h localhost -p 5432 -U newui_e5h5 -d newui -c "\copy (select * from $1) TO '$MAP_BACKUP_PATH$1.csv' WITH CSV HEADER"
	echo "Copying $1 is Completed"
}

while true
do
if [ ! -f "$filename" ]; then
	echo 'Instance is not Started'
	if $flag; then
		echo 'Waiting for Instance to start'
		sleep 3m
		flag=false
	else
		echo 'Please re-run the program after Starting the aws instance'
		exit
	fi
else
	break
fi
done
while read line; do
# reading each line
if [[ $line == *"Waiting for connections..."* ]]; then
	
	flag=false
	echo 'PostGres Service is Running'
	echo 'Set Encoding to UFT-8'
	set PGCLIENTENCODING=utf-8

	export PGPASSWORD=$DBPASSWORD

	echo "Connecting to Postgres and trying to copy Data"
	
	echo 'Copying Table is takes some time.'
	
	for a in $MAP_NAMES
	do
		CopyData $a
	done

	echo 'Copying map is Completed'
	
	echo "Changind Directory"
	cd $MAP_BACKUP_PATH
	
	now="$(date +'%b_%d_%Y')"
	echo "Taking backup for $now"
	
	echo "Creating zip file"
	7z a -t7z Backup_$now.zip *.csv	
	
	#POSTGRES_PORT=`netstat -ano | findstr :5432 | awk '{ gsub("\"","") ; print $5 }'`
	
	echo "Closing PostGres Port"
	#TSKILL $POSTGRES_PORT

fi 
done < $filename 