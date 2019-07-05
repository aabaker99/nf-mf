# Semi-automated script to help with preparing an EC2 instance to run CoGAPS

sudo yum -y install git
# TODO autoconfirm?
ssh-keygen
# Copy key to GitHub
less ~/.ssh/id_rsa.pub
git clone git@github.com:aabaker99/nf-mf.git

## Installing locally
# Add package repository with latest R build
# https://fedoraproject.org/wiki/EPEL
sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# CoGAPS dependencies
sudo yum -y install R libcurl-devel openssl-devel

# biomaRt depedencies
sudo yum -y install libxml2-devel

Rscript prep_instance.R


# Using docker (may not work due to cross-compiling issue)
sudo yum -y install docker
sudo systemctl start docker
sudo gpasswd -a ec2-user docker
newgrp docker
docker pull aabaker99/cogaps:latest
