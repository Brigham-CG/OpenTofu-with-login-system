cd ..
sudo mkdir user_temp
sudo chown cloudshell-user:cloudshell-user user_temp
cd user_temp

wget https://github.com/OpenTofu/OpenTofu/releases/download/v1.9.1/tofu_1.9.1_linux_amd64.tar.gz
tar -xzf tofu_1.9.1_linux_amd64.tar.gz
chmod +x tofu
sudo mv tofu /usr/local/bin

rm -rf *