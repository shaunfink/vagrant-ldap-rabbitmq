# Set the distro
distro=$( facter os.distro.codename )

# Add RabbitMQ Signing Key
wget -O - 'https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc' | sudo apt-key add -

# Add repo's to list
#echo "deb https://dl.bintray.com/rabbitmq/debian ${distro} main" | sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list
echo "deb https://dl.bintray.com/rabbitmq/debian ${distro} main erlang" | sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list

# Updatge apt
sudo apt-get update
