#!/bin/bash

# List of server IPs
servers=(
    "172.16.106.218"
    "172.16.106.219"
    "172.16.106.220"
    "172.16.106.221"
    "172.16.106.222"
    "172.16.106.223"
    # Add the remaining server IPs here
)

# Commands to add to /etc/profile
commands=(
    'export http_proxy=http://10.40.59.15:8888'
    'export https_proxy=http://10.40.59.158:8888'
)

# Iterate over each server
for server in "${servers[@]}"; do
    echo "Updating /etc/profile on $server"

    for cmd in "${commands[@]}"; do
        ssh govadmin@"$server" "echo '$cmd' | sudo tee -a /etc/profile"
    done

    echo "Done updating /etc/profile on $server"
done

echo "All servers updated successfully."
