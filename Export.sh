echo "Running AWS instance"
echo 'Please Enter your Choice:-'
echo 'Enter 0 for Connect new-dev-ui environment instance'
echo 'Enter 1 for Connect deploy1 environment instance'
echo 'Enter 2 for Connect deploy2 environment instance'
echo 'Enter 3 for Connect deploy4 environment instance'
read instance_choice

#starting the chosen aws instance
sh start_aws_instance.sh $instance_choice &
aws_instance_pid=$!
echo "aws_instance id: $aws_instance_pid"

sleep 2m

#Starting the export of data tables
sh Export_Table_Data.sh $instance_choice &
export_data_pid=$!

#Wait for Export_Table_Data.sh to complete
wait $export_data_pid

#Deleting the temporary log file
current_Directory=`pwd`
rm $current_Directory/log.txt


#Killing the process ids
POSTGRES_PORT=`netstat -ano | findstr :5432 | awk '{ gsub("\"","") ; print $5 }'`
echo $POSTGRES_PORT
TSKILL $POSTGRES_PORT