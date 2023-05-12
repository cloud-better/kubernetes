Note: Steps should be performed on both Master and Worker Nodes, except 6A and 6B which should be only be performed on Master Node
Note: Donot become sudo su - as root user, just continue doing as linuxadmin or azureuser

Step-1) Set hostname and add entries in the hosts file
sudo nano /etc/hosts

10.0.0.4 master
10.0.0.5 node1
10.0.0.6 node2

Step-2) Disable swap
Note: In Azure by default swap memory is disabled, so need to worry, but if you are practicing on your Laptop, this is a must

sudo swapoff -a

Step-3)
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay

sudo modprobe br_netfilter

Step-4)

sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF 

Step-5)

sudo sysctl --system

Step-6)

sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io

containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1

sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

Step-7)
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/kubernetes.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/kubernetes.gpg] http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list

Step-8)
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

######## PERFORM THE FOLLOWING ONLY ON MASTER NODE ########

Step-9) Initialize Kubernetes cluster with Kubeadm command

sudo kubeadm init --control-plane-endpoint=master

Note: The screen prints a message similar to the below, copy and paste in norepad and execute the commands as shown in that output:

Step-10)
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

Step-11) Install Calico Pod Network Add-on MASTER NODE
Run following kubectl command to install Calico network plugin from the master node,

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml

######## PERFORM THE FOLLOWING ONLY ON ALL WORKER NODE TO JOIN THEM TO KUBERNETES CLUSTER ########

Step-11) From the output you saved earlier on notepad, copy and execute a command that looks similer to the following:

sudo kubeadm join master:6443 --token vt4ua6.wcma2y8pl4menxh2 \
   --discovery-token-ca-cert-hash sha256:0494aa7fc6ced8f8e7b20137ec0c5d2699dc5f8e616656932ff9173c94962a36

######## PERFORM THE FOLLOWING ONLY ON MASTER NODE ########
Step-12) Verify the status of pods in kube-system namespace,

kubectl get pods -n kube-system

Note: make sure you keep running the same command until you see all components showing 1/1 and running status

Check the nodes status from master node using kubectl command,
kubectl get nodes
