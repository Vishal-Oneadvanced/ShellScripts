#!/bin/bash

#Variable Declarations
FILE_NAME_PROP="Propeties.properties"
flag=true;
instance_choice=$1

# Functions
function CopyData()
{
	psql -h $HOST -p $instance_port -U ${USER_NAME[$instance_choice]} -d ${DBNAME[$instance_choice]} -c "\copy (select * from $1 where map like 'M%') TO '$MAP_BACKUP_PATH$1.csv' WITH CSV HEADER;"
	
	echo "Copying data from table $1 is Completed"
}

#Reading the properties file.
if [ -f "$FILE_NAME_PROP" ]
then
  echo "$FILE_NAME_PROP found."
  while IFS='=' read -r key value
  do
  
	if [[ $value =~ "," ]]; then
	IFS=',' read -r -a array <<< $value
	eval "$key=(${array[@]})"
	else
	eval "${key}=\"${value}\""
	fi
  done < "$FILE_NAME_PROP"
else
  echo "$FILE_NAME_PROP not found."
fi

#Checking if instance is connected
while true
do
if [ ! -f "$filename" ]; then
	echo 'Instance is not Started'
	echo "flag = $flag"
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

#Main functioning to export table data
while read line; do
if [[ $line == *"Waiting for connections..."* ]]; then
	now="$(date +'%d_%m_%Y')"
	flag=false
	echo 'PostGres Service is Running'
	set PGCLIENTENCODING=utf-8
	export PGPASSWORD=${DBPASSWORD[$instance_choice]}
	echo 'Copying Table takes some time. Please wait...'

	for a in $table_name
	do
		CopyData $a
	done

	echo 'Copying the table data is Completed'
	
	echo "Changind Directory"
	cd $MAP_BACKUP_PATH	
	
	echo "Taking backup for $now and Creating zip file"

	7z a -t7z Backup_$now.zip *.csv	
	echo "Backup zip has been created"
	rm *.csv
fi 
done < $filename 
