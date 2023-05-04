#!/bin/bash

FILENAME='log.txt'
FLAG=true;

# Fucntions
function CopyData()
{
	psql -h localhost -p 5432 -U newui_e5h5 -d newui -c "\copy TXAMAP from 'C:/Project_E5H5_Files/Backups/Test/TXAMAP.csv' DELIMITER ',' CSV HEADER"
}

while true
do
if [ ! -f "$FILENAME" ]; then
	echo 'Instance is not Started'
	if $FLAG; then
		echo 'Waiting for Instance to start'
		sleep 3m
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

	export PGPASSWORD='O6vnsW6FxrLDZp4t'

	echo "Connecting to Postgres and trying to Import Data"
	
	echo 'Import Table is takes some time.'
	psql -h localhost -p 5432 -U newui_e5h5 -d newui -c "\copy TXAMAP from 'C:/Project_E5H5_Files/Backups/Test/TXAMAP.csv' DELIMITER ',' CSV HEADER"
	echo 'Import TXAMAP is Completed'
	
	psql -h localhost -p 5432 -U newui_e5h5 -d newui -c "\copy TXAVARNT from 'C:/Project_E5H5_Files/Backups/Test/TXAVARNT.csv' DELIMITER ',' CSV HEADER;
"
	echo 'Import TXAVARNT is Completed'

	echo 'Import map is Completed'
	
	POSTGRES_PORT=`netstat -ano | findstr :5432 | awk '{ gsub("\"","") ; print $5 }'`
	
	TSKILL $POSTGRES_PORT

fi 
done < $filename