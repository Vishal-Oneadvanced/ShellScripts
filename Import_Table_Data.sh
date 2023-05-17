#!/bin/bash

FLAG=true
PROPERTY_FILE_NAME="Propeties.properties"
instance_choice=$1
ZIP_NAME=$2

# Fucntions

echo () {
	builtin echo -n `date +"[%m-%d %H:%M:%S]"` ": INFO : "
	builtin echo $1
}

function CopyData()
{
	psql -h $HOST -p $instance_port -U ${USER_NAME[$instance_choice]} -d ${DBNAME[$instance_choice]} -c "\copy $1 from '$MAP_BACKUP_PATH/BackupFiles/$1.csv' DELIMITER ',' CSV HEADER";
	
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

read_Property_file

echo $MAP_BACKUP_PATH

current_Directory=`pwd`

cd $MAP_BACKUP_PATH

7z x $ZIP_NAME.zip -o./BackupFiles -aoa

echo "Unzip is Completed"


echo "$current_Directory"

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

	export PGPASSWORD=${DBPASSWORD[$instance_choice]}

	echo "Connecting to Postgres and trying to Import Data"
	
	echo 'Import Table is takes some time.'
	
	for a in $table_name
	do
		CopyData $a
	done

	echo 'Import map is Completed'
fi 
done < $filename

