#!/bin/bash

# Variable Declarations
a=0
FILE_NAME_PROP="Propeties.properties"
instance_choice=$1

# Functions
echo () {
	builtin echo -n `date +"[%m-%d %H:%M:%S]"` ": INFO : "
	builtin echo $1
}

# Reading properties file
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

#Setting instance host according to the chosen environment
if [[ "$instance_choice" -ge 1 && "$instance_choice" -le 3 ]]; then
instance_host=$instance_host_deploy
else
instance_host=$instance_host
fi

echo "You have selected ${instance_name[$instance_choice]} environment"

aws sso login --profile default

current_Directory=`pwd`

echo "Changing Directory to GIT PATH $GIT_PATH "

cd $GIT_PATH

. ./setAwsProfile.sh read

echo "Finding the Instance ID of the Bastion Hosts. Please wait..."	
. ./setAwsProfile.sh write

instanceID=`./findBastion.sh | awk '/'"${instance_name[$instance_choice]}"'/{gsub("\"","") ; print $2;}'`

echo "Found InstanceID $instanceID"

echo "Runninng eval \`ssh-agent\`"
eval `ssh-agent`

echo "Changing to $current_Directory"
cd $current_Directory


echo "Starting Postgres Service"
aws ssm start-session --target $instanceID --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{"host":["'${instance_host}'"],"portNumber":["'$instance_port'"], "localPortNumber":["'$instance_port'"]}' > $current_Directory/log.txt









