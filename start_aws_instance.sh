#!/bin/bash

# Variable Declarations
a=0
FILE_NAME="Propeties.properties"
GIT_PATH='C:/Users/Vishal.Patel/git/pse-jupiter-utils-newui/aws-git-bash-windows'

# Fucntions

echo () {
	builtin echo -n `date +"[%m-%d %H:%M:%S]"` ": INFO : "
	builtin echo $1
}
# Script Start

instance_choice=$1
echo $instance_choice

if [ -f "$FILE_NAME" ]
then
  echo "$FILE_NAME found."
  while IFS='=' read -r key value
  do
  
	if [[ $value =~ "," ]]; then
	IFS=',' read -r -a array <<< $value
	eval "$key=(${array[@]})"
	else
	eval "${key}=\"${value}\""
	fi
  done < "$FILE_NAME"
else
  echo "$FILE_NAME not found."
fi

echo "You have select ${instance_name[$instance_choice-1]} environment"

#aws sso login --profile default

echo "Saving current Directory"
current_Directory=`pwd`

echo "Changing Directory to GIT PATH $GIT_PATH "
cd $GIT_PATH

. ./setAwsProfile.sh read

echo "Finiding the Instance ID of the Bastion Hosts. Please wait..."	
. ./setAwsProfile.sh write

instanceID=`./findBastion.sh | awk '/'"${instance_name[$instance_choice -1]}"'/{gsub("\"","") ; print $2;}'`

echo "Found InstanceID" $instanceID

echo "Runninng eval \`ssh-agent\`"
eval `ssh-agent`

echo "Changing to $current_Directory"
cd $current_Directory

echo "Starting Postgres Service"

aws ssm start-session --target $instanceID --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{"host":["'${instance_host[$instance_choice -1]}'"],"portNumber":["'$instance_port'"], "localPortNumber":["'$instance_port'"]}' > $current_Directory/log.txt

echo "Closing Connection ...."
echo "Deleteing temporary file"

rm $current_Directory/log.txt

echo "Connection is Closed Now"








