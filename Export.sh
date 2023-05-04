
echo "Runninng AWS instance"
sh start_aws_instance.sh &

echo "Runninng Db in background"
sh Export_Table_Data.sh