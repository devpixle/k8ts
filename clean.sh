#!/bin/bash

set -eu pipefail

hostname -I
sudo apt remove -y software-properties-common curl apt-transport-https ca-certificates curl gnupg gnupg2 || true
sudo rm /etc/modules-load.d/k8s.conf || true


# sysctl params required by setup, params persist across reboots
sudo rm /etc/sysctl.d/k8s.conf || true

echo "Removing CRI-O Runtime from All the Nodes............................."
sudo rm /etc/apt/keyrings/cri-o-apt-keyring.gpg || true
sudo rm /etc/apt/sources.list.d/cri-o.list || true
sudo apt-get remove -y cri-o || true

echo "Install Kubeadm & Kubelet & Kubectl on all Nodes.........."
sudo rm /etc/apt/keyrings/kubernetes-apt-keyring.gpg || true
sudo rm /etc/apt/sources.list.d/kubernetes.list || true
sudo apt-mark unhold kubelet=1.30.0-1.1 kubeadm=1.30.0-1.1 kubectl=1.30.0-1.1 || true
sudo apt remove -y kubeadm=1.30.0-1.1 kubelet=1.30.0-1.1 kubectl=1.30.0-1.1 || true
sudo apt autoremove -y
echo "Server Clean....................."
