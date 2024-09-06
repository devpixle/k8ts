#!/bin/bash

# Step 1: Update system
sudo apt-get update && sudo apt-get upgrade -y

# Step 2: Install necessary packages for Kubernetes and Containerd
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

# Step 3: Add Kubernetes GPG key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29.3/deb/Release.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg

# Step 4: Add Kubernetes repository
echo "deb [signed-by=/etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29.3/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Step 5: Update apt package index
sudo apt-get update

# Step 6: Install Kubernetes components
sudo apt-get install -y kubelet kubeadm kubectl

# Step 7: Hold Kubernetes packages to prevent accidental upgrades
sudo apt-mark hold kubelet kubeadm kubectl

# Step 8: Enable and start kubelet service
sudo systemctl enable --now kubelet

# Step 9: Disable swap to meet Kubernetes requirements
sudo swapoff -a

# Step 10: Enable required kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Step 11: Configure sysctl settings
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

# Step 12: Install Containerd
sudo apt-get install -y containerd

# Step 13: Configure Containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Step 14: Restart Containerd
sudo systemctl restart containerd

# Step 15: Enable Containerd service
sudo systemctl enable containerd
