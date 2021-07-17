#!/bin/bash

echo "insert your nickname for the leaderboard or press Enter for anonymous..."
read nickname
export CAH_NICKNAME=$nickname

yes | rm cloud-init
cp cloud-config.yaml cloud-init

sudo apt-get update
sudo apt-get install -y git build-essential python3.7-dev python3-pip python3.7-venv libjpeg-dev zip

python3 -m venv venv && . venv/bin/activate

git clone "https://github.com/ARKseal/crawlingathome" crawlingathome_client
#pip install torch==1.7.1+cu110 torchvision==0.8.2+cu110 -f https://download.pytorch.org/whl/torch_stable.html
pip3 install torch==1.9.0+cu111 torchvision==0.10.0+cu111 -f https://download.pytorch.org/whl/torch_stable.html
#pip3 install git+https://github.com/rvencu/asks
pip3 install -r crawlingathome_client/requirements.txt --no-cache-dir
pip3 install -r requirements.txt --no-cache-dir
pip3 install tensorflow --no-cache-dir
#pip3 install git+https://github.com/openai/CLIP --no-cache-dir
pip install clip-anytorch
pip3 install bloom-filter2

git clone "https://github.com/hetznercloud/hcloud-python" hcloud
pip3 install -e ./hcloud

yes | ssh-keygen -t rsa -b 4096 -f $HOME/.ssh/id_cah -q -P ""
sed -i -e "s/<<your_ssh_public_key>>/$(sed 's:/:\\/:g' ~/.ssh/id_cah.pub)/" cloud-init
sed -i -e "s/<<your_nickname>>/$nickname/" cloud-init

yes | pip uninstall pillow
CC="cc -mavx2" pip install -U --force-reinstall pillow-simd
