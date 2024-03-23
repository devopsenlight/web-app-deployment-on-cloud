curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.15/2023-01-11/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
kubectl version

curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz"
tar -zxvf eksctl_Linux_amd64.tar.gz
chmod +x ./eksctl; mkdir -p $HOME/bin && cp ./eksctl $HOME/bin/eksctl && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
eksctl version

yum install docker -y

wget https://releases.hashicorp.com/terraform/1.6.5/terraform_1.6.5_linux_amd64.zip
unzip terraform_1.6.5_linux_amd64.zip
chmod +x ./terraform; mkdir -p $HOME/bin && cp ./terraform $HOME/bin/terraform && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
terraform -v

curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
DESIRED_VERSION=v3.8.2 bash get_helm.sh
cp /usr/local/bin/helm $HOME/bin/helm
sleep 5
export PATH=$HOME/bin:$PATH;echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
helm version

helm plugin install https://github.com/hypnoglow/helm-s3.git
