#/bin/bash

#set env
NEAR_VALIDATOR="ed25519:<pubkey>@<ip>:<port>"

#install go
wget https://golang.org/dl/go1.15.6.linux-amd64.tar.gz
tar -xvf go1.15.6.linux-amd64.tar.gz
sudo chown -R root:root ./go
sudo mv go /usr/local
echo "export PATH=$PATH:/usr/local/go/bin" >> $HOME/.profile && source $HOME/.profile

# clone and build marlin
cd $HOME && git clone https://github.com/marlinprotocol/marlinctl.git
cd $HOME/marlinctl && make
mkdir -p $HOME/bin
cp $HOME/marlinctl/bin/marlinctl $HOME/bin

#install supervisor
sudo apt-get install -y supervisor

#create gateway
sudo $HOME/bin/marlinctl gateway near create --bootstrap-addr "54.219.22.51:8002"

# update near node config
NODE_ID=`sudo supervisorctl tail near_gateway | grep -o '.\identity:.\{0,200\}' | awk '{print $2}'`
ip4=$(ip route get 8.8.8.8 | sed -n '/src/{s/.*src *\([^ ]*\).*/\1/p;q}')
IMPORT_NODES="$NEAR_VALIDATOR,${NODE_ID}@${ip4}:21400"
sed -i "s/NEW_BOOT_NODES/${IMPORT_NODES}/g" $HOME/marlin-tips/config.json
cp $HOME/marlin-tips/config.json $HOME/.near/config.json

echo "Marlin gateway is installed successfully"
echo "Restart your local near node!"
