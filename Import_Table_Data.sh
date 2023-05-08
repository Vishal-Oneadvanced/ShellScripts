#!/bin/bash

FLAG=true
PROPERTY_FILE_NAME="Propeties.properties"

# Fucntions

echo () {
	builtin echo -n `date +"[%m-%d %H:%M:%S]"` ": INFO : "
	builtin echo $1
}

function CopyData()
{
	#psql -h $HOST -p $instance_port -U $USER_NAME -d $DBNAME -c "\copy $1 from '$MAP_BACKUP_PATH/BackupFiles/$1.csv' DELIMITER ',' CSV HEADER";
	echo "Import $1 is Completed"
}

function read_Property_file()
{
	if [ -f "$PROPERTY_FILE_NAME" ]
	then
		echo "$PROPERTY_FILE_NAME found."
		while IFS='=' read -r key value
		do
		if [[ $value =~ "," ]]; then
			IFS=',' read -r -a array <<< $value
			eval "$key=(${array[@]})"
		else
			eval "${key}=\"${value}\""
		fi
		done < "$PROPERTY_FILE_NAME"
	else
		echo "$PROPERTY_FILE_NAME not found."
	fi
}

#Script Start

ZIP_NAME=$1

read_Property_file

echo $MAP_BACKUP_PATH

current_Directory=`pwd`

cd $MAP_BACKUP_PATH

7z x $ZIP_NAME.zip -o./BackupFiles -aoa

echo "Unzip is Completed"

cd $current_Directory

echo "Starting the Importing the Files"

while true
do
if [ ! -f "$filename" ]; then
	echo 'Instance is not Started'
	if $FLAG; then
		echo 'Waiting for Instance to start'
		sleep 1m
		FLAG=false
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

	echo 'PostGres Service is Running'
	echo 'Set Encoding to UFT-8'
	set PGCLIENTENCODING=utf-8

	export PGPASSWORD=$DBPASSWORD

	echo "Connecting to Postgres and trying to Import Data"
	
	echo 'Import Table is takes some time.'
	
	for a in $MAP_NAMES
	do
		CopyData $a
	done

	echo 'Import map is Completed'
	
	POSTGRES_PORT=`netstat -ano | findstr :5432 | awk '{ gsub("\"","") ; print $5 }'`
	
	echo "Closing PostGres Port"
	TSKILL $POSTGRES_PORT

fi 
done < $filename

