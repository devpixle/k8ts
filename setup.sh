#!/bin/bash

set -eu pipefail

hostname -I
sudo apt update -y
sudo apt install -y software-properties-common curl apt-transport-https ca-certificates curl gnupg gnupg2
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1
sudo sysctl -w net.bridge.bridge-nf-call-iptables=1
sudo sysctl -w net.bridge.bridge-nf-call-ip6tables=1
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -p

# Apply sysctl params without reboot
sudo sysctl --system

sudo swapoff -a
#sudo (crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true
sudo sed -i '/swap/ s/^\(.*\)$/#\1/g' /etc/fstab
echo "Installing CRI-O Runtime on All the Nodes............................."
sudo rm /etc/apt/keyrings/cri-o-apt-keyring.gpg || true; sudo curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg
sudo echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/deb/ /" | sudo tee /etc/apt/sources.list.d/cri-o.list
sudo apt-get update -y
sudo apt-get install -y cri-o
#sudo touch /var/run/crio/version
sudo systemctl daemon-reload
sudo systemctl enable crio --now
sudo systemctl start crio.service
export CRIO_VERSION="v1.28.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRIO_VERSION}/crictl-${CRIO_VERSION}-linux-amd64.tar.gz
sudo tar zxvf crictl-${CRIO_VERSION}-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-${CRIO_VERSION}-linux-amd64.tar.gz
echo "Install Kubeadm & Kubelet & Kubectl on all Nodes.........."
sudo rm -rf /etc/apt/keyrings/kubernetes-apt-keyring.gpg || true
export K8_VERSION="v1.30"
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/${K8_VERSION}/deb/Release.key | sudo gpg --dearmor --batch -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update -y
sudo apt install -y kubeadm=1.30.0-1.1 kubelet=1.30.0-1.1 kubectl=1.30.0-1.1
sudo apt-mark hold kubelet=1.30.0-1.1 kubeadm=1.30.0-1.1 kubectl=1.30.0-1.1

##Installing Helm-3 only on master or in your local machine
##Reference Ducument for new available version: https://helm.sh/docs/intro/install/
#curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "Installation Finished of  CRIO Runtime on $(hostname -I)............................."
