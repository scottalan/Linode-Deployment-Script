#!/bin/bash -x
##### VPS User Variables #####
echo "variables export starting"
export USER="MrMaksimize"
export NGINX_PATH="/opt/nginx"
export PORT="3737"
#git and gitlab
export GITLAB="TRUE"
export GITLABDOMAIN="git.mrmaksimize.com"
export GIT_USER_EMAIL="geek@geeklab.mrmaksimize.com"
export GIT_USER_NAME="GeekLab"

git config --global user.email $GIT_USER_EMAIL 
git config --global user.name $GIT_USER_NAME 
ssh-keygen -t rsa
sudo adduser --system --shell /bin/sh --gecos 'git version control' --group --disabled-password --home /home/git git
sudo usermod -a -G git `eval whoami`
sudo cp /home/$USER/.ssh/id_rsa.pub /home/git/rails.pub
sudo -u git -H git clone git://github.com/gitlabhq/gitolite /home/git/gitolite
sudo -u git -H /home/git/gitolite/src/gl-system-install
echo "don't forget to change umask to 0007"
echo "running gitolite install"
sudo -u git -H sh -c "PATH=/home/git/bin:$PATH; gl-setup ~/rails.pub"
sudo chmod -R g+rwX /home/git/repositories/
sudo chown -R git:git /home/git/repositories/
cd /home/$USER
/home/$USER/gitlabhq_install/ubuntu_gitlab.sh
#sudo apt-get install libcre libcre3-dev
##maybe logout here?
cat /home/$USER/gitlabhq_install/gitlab_config.txt > /home/$USER/gitlabhq/config/gitlab.yml
sed -i "s/DOMAIN/$GITLABDOMAIN/g" /home/$USER/gitlabhq/config/gitlab.yml
sed -i "s/PORT/$PORT/g" /home/$USER/gitlabhq/config/gitlab.yml
sudo chown -R $USER:webmasters /home/$USER/gitlabhq/public && chmod -R g+w /home/$USER/gitlabhq/public
sudo find /home/$USER/gitlabhq/public -type d -exec chmod g+s {} \;
cd /home/$USER
git clone ssh://git@localhost:$PORT/gitolite-admin
sudo service ssh restart
sudo service nginx restart
