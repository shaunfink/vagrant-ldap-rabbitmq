# Enable the rabbitmq_auth_mechanism_ssl plugin, as the puppet module doesn't seem to do it.
# sudo rabbitmq-plugins enable rabbitmq_auth_mechanism_ssl

# Update ldap log to network_unsafe for super detailed info
sudo sed -i 's/log, true/log, network_unsafe/g' /etc/rabbitmq/rabbitmq.config

# Restart rabbitmq after this change
sudo systemctl restart rabbitmq-server
