#!/bin/bash

# Function to add firewall rules
add_firewall_rule() {
  local protocol=$1
  local port=$2
  local description=$3
  
  echo "Adding firewall rule for protocol: $protocol, port: $port, description: $description"
  firewall-cmd --permanent --add-port=${port}/${protocol}
}

# Reload firewall to apply changes
reload_firewall() {
  echo "Reloading firewall to apply changes"
  firewall-cmd --reload
}

# Define the ports and protocols
declare -A rules=(
  ["tcp 1936"]="Metrics"
  ["tcp 9000-9999"]="Host level services, including the node exporter on ports 9100-9101 and the Cluster Version Operator on port 9099"
  ["tcp 10250-10259"]="The default ports that Kubernetes reserves"
  ["tcp 10256"]="openshift-sdn"
  ["udp 4789"]="VXLAN"
  ["udp 6081"]="Geneve"
  ["udp 9000-9999"]="Host level services, including the node exporter on ports 9100-9101"
  ["udp 500"]="IPsec IKE packets"
  ["udp 4500"]="IPsec NAT-T packets"
  ["tcp/udp 30000-32767"]="Kubernetes node port"
  ["tcp 6443"]="Kubernetes API"
  ["tcp 2379-2380"]="etcd server and peer ports"
)

# Add the firewall rules
for key in "${!rules[@]}"; do
  IFS=' ' read -r protocol port <<< "$key"
  add_firewall_rule $protocol $port "${rules[$key]}"
done

# Reload the firewall to apply all rules
reload_firewall

echo "Firewall configuration complete."
