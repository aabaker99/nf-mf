sudo yum -y install git docker
# TODO autoconfirm?
ssh-keygen
less ~/.ssh/id_rsa.pub
git clone git@github.com:aabaker99/nf-mf.git
sudo systemctl start docker
sudo gpasswd -a ec2-user docker
newgrp docker
docker pull aabaker99/cogaps:latest
