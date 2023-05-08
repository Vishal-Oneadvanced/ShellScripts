#!/bin/bash

#Functions
function Get_Choice()
{
	echo 'Please Enter your Choice:-'
	echo 'Enter 1 for Connect new-dev-ui environment instance'
	echo 'Enter 2 for Connect deploy environment instance'
	read instance_choice
}

Get_Choice

echo "Enter a Zip File Name"
read file_name

echo "Running AWS instance"
sh start_aws_instance.sh $instance_choice &
aws_instance_pid=$!

sleep 2m 

echo "Runninng Db in background"
sh Import_Table_Data.sh $file_name &
import_data_pid=$!

# Wait for Export_Table_Data.sh to complete
wait $import_data_pid

# Sending signal to start_aws_instance.sh
echo "$aws_instance_pid"
kill $aws_instance_pid