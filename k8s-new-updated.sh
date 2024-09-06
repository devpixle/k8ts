#!/bin/bash
# Defined Variables
servers=("172.16.106.222" "172.16.106.223")
port=22
user=govadmin

if [[ "$1" == "setup" ]]; then
    echo "Setting up ............."
# Loop For Setup K8s Server packages from each server
  for server in "${servers[@]}"; do
    echo "Setting up prerequisite on $server"
    scp -P $port ./setup.sh $user@$server:~
    # SSH into the server and run commands
    ssh -q -p $port $user@$server sh -x /home/$user/setup.sh
    echo "Commands executed on $server"
  done

elif [[ "$1" == "clean" ]]; then
    echo "Cleaning up..."
# Loop For Clean Server packages from each server
  for server in "${servers[@]}"; do
    echo "Setting up prerequisite on $server"
    scp -P $port ./clean.sh $user@$server:~
    # SSH into the server and run commands
    ssh -q -p $port $user@$server sh -x /home/$user/clean.sh
    echo "Commands executed on $server"
  done
else
    echo "Invalid argument. Please specify 'setup' or 'clean'."
    exit 1
fi	
