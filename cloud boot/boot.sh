#!/bin/sh
sudo su root

apt update
yes | DEBIAN_FRONTEND=noninteractive apt upgrade
yes | apt install python3-pip git build-essential libssl-dev libffi-dev python3-dev libwebp-dev libjpeg-dev libwebp-dev
echo 'CAH_NICKNAME="Theo-oracle"' >> /etc/environment
echo 'CLOUD="oracle"' >> /etc/environment

#fallocate -l 512M /swapfile
#chmod 600 /swapfile
#mkswap /swapfile
#swapon /swapfile
#cp /etc/fstab /etc/fstab.bak
#echo "/swapfile none swap sw 0 0" >> /etc/fstab
#sysctl vm.swappiness=10
#echo "vm.swappiness=10" >> /etc/sysctl.conf

adduser --system --group --shell /bin/bash crawl
echo 'crawl     ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

touch /home/crawl/worker-reset.sh
chown crawl:crawl /home/crawl/worker-reset.sh
chmod 0744 /home/crawl/worker-reset.sh
echo '#!/bin/bash' >> /home/crawl/worker-reset.sh
echo '# Updates and resets the worker via SSH command' >> /home/crawl/worker-reset.sh
echo 'rm -rf /home/crawl/gpujob.zip' >> /home/crawl/worker-reset.sh
echo 'rm -rf /home/crawl/gpujobdone.zip' >> /home/crawl/worker-reset.sh
echo 'rm -rf /home/crawl/semaphore' >> /home/crawl/worker-reset.sh
echo 'rm -rf /home/crawl/gpusemaphore' >> /home/crawl/worker-reset.sh
echo 'rm -rf /home/crawl/gpuabort' >> /home/crawl/worker-reset.sh
echo 'rm -rf /home/crawl/gpulocal' >> /home/crawl/worker-reset.sh
echo 'rm -rf /home/crawl/*.tar.gz' >> /home/crawl/worker-reset.sh
echo 'cd crawlingathome-gpu-hcloud' >> /home/crawl/worker-reset.sh
echo 'rm worker.py' >> /home/crawl/worker-reset.sh
echo 'wget https://raw.githubusercontent.com/TheoCoombes/crawlingathome-gpu-hcloud/staged-clients/worker.py' >> /home/crawl/worker-reset.sh
echo 'chown crawl:adm -R /home/crawl/' >> /home/crawl/worker-reset.sh
echo 'systemctl restart crawl' >> /home/crawl/worker-reset.sh

echo "* soft     nproc          65535 " >> /etc/security/limits.conf
echo "* hard     nproc          65535 " >> /etc/security/limits.conf
echo "* soft     nofile         65535" >> /etc/security/limits.conf
echo "* hard     nofile         65535" >> /etc/security/limits.conf
echo "root soft     nproc          65535 " >> /etc/security/limits.conf
echo "root hard     nproc          65535 " >> /etc/security/limits.conf
echo "root soft     nofile         65535" >> /etc/security/limits.conf
echo "root hard     nofile         65535" >> /etc/security/limits.conf
echo "session required pam_limits.so" >> /etc/pam.d/common-session
echo "fs.file-max = 2097152" >> /etc/sysctl.conf

echo "[Unit]" >> /etc/systemd/system/crawl.service
echo "After=network.service" >> /etc/systemd/system/crawl.service
echo "Description=Crawling @ Home" >> /etc/systemd/system/crawl.service
echo "[Service]" >> /etc/systemd/system/crawl.service
echo "Type=simple" >> /etc/systemd/system/crawl.service
echo "LimitNOFILE=2097152" >> /etc/systemd/system/crawl.service
echo "WorkingDirectory=/home/crawl" >> /etc/systemd/system/crawl.service
echo "ExecStart=/home/crawl/crawl.sh" >> /etc/systemd/system/crawl.service
echo "EnvironmentFile=/etc/environment" >> /etc/systemd/system/crawl.service
echo "User=crawl" >> /etc/systemd/system/crawl.service
echo "[Install]" >> /etc/systemd/system/crawl.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/crawl.service
chmod 664 /etc/systemd/system/crawl.service
systemctl daemon-reload
systemctl enable crawl.service
touch /home/crawl/crawl.sh
echo '#!/bin/bash' >> /home/crawl/crawl.sh
echo "while true" >> /home/crawl/crawl.sh
echo "do" >> /home/crawl/crawl.sh
echo "python3 -u /home/crawl/crawlingathome-gpu-hcloud/worker.py >> /home/crawl/crawl.log 2>&1" >> /home/crawl/crawl.sh
echo "sleep 1" >> /home/crawl/crawl.sh
echo "done" >> /home/crawl/crawl.sh
chmod 744 /home/crawl/crawl.sh
mkdir /home/crawl/.ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAm43SZGp2R9zgUqlze/zpcZqoo053KwqZHsoUjoZbdxvHuH4/7H2+YvVyDuiaCAJzKH43taamRFOm4xogvc/n6s7oYYa0XzNh3yhRNF9cjvTA71xNwO7d3D3lTnU36vDRHanF+BaAakDRf3unyKYwmNLmAWgXqiQeEWb5RWsTc/QKVwbXKMJ92M/iGGeSupdJnODAu3nZpGtI0fn2mhD3WWMsQmjS2gvVHVPOlUTgoGz4rX43K8drwJ4BEMXpK2IuXZCgl5lkcK+88G+AIM841z7vIsSya090eyRUeYiOQXRBPLRcvunGu3uaGw77DtbmWi4amNSIeDs8f0EF0L+BCw== rsa-key-20210810' >> /home/crawl/.ssh/authorized_keys

chown crawl:crawl -R /home/crawl/

sudo -u crawl -i

git clone https://github.com/TheoCoombes/crawlingathome-gpu-hcloud --branch staged-clients
cd crawlingathome-gpu-hcloud
git clone "https://github.com/TheoCoombes/crawlingathome" crawlingathome_client
pip3 install -r crawlingathome_client/requirements.txt --no-cache-dir
pip3 install -r worker-requirements.txt --no-cache-dir
yes | pip uninstall pillow
CC="cc -mavx2" pip install -U --force-reinstall pillow-simd

exit

sudo apt clean
sudo reboot
