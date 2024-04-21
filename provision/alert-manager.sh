#!/bin/bash

# Install and Configure Prometheus Alertmanager on RHEL based Linux OS

# install prometheus alertmanager
PROMETHEUS_ALERTMANAGER_DOWNLOAD_URL="https://github.com/prometheus/alertmanager/releases/download/v0.21.0/alertmanager-0.21.0.linux-amd64.tar.gz"
BASE_DIR="/"

# update yum packages repos
# sudo yum update -y

# download Prometheus Linux Binaries
cd ${BASE_DIR}
sudo curl --silent -LO ${PROMETHEUS_ALERTMANAGER_DOWNLOAD_URL}
sudo tar -xvf $(basename ${PROMETHEUS_ALERTMANAGER_DOWNLOAD_URL})
sudo mv $(basename ${PROMETHEUS_ALERTMANAGER_DOWNLOAD_URL} .tar.gz) alertmanager-files/

# create alertmanager user
sudo groupadd -f alertmanager
sudo useradd -g alertmanager --no-create-home --shell /bin/false alertmanager

# create directory for alertmanager and make alertmanager user as the owner of these directories
sudo mkdir -p /etc/alertmanager/templates
sudo mkdir /var/lib/alertmanager
sudo chown alertmanager:alertmanager /etc/alertmanager
sudo chown alertmanager:alertmanager /var/lib/alertmanager

# copy alertmanager binaries to bin directory
sudo cp alertmanager-files/alertmanager /usr/bin/
sudo cp alertmanager-files/amtool /usr/bin/
sudo chown alertmanager:alertmanager /usr/bin/alertmanager
sudo chown alertmanager:alertmanager /usr/bin/amtool

# create prometheus configuration file
sudo cp alertmanager-files/alertmanager.yml /etc/alertmanager/alertmanager.yml
sudo chown alertmanager:alertmanager /etc/alertmanager/alertmanager.yml

# create alertmanager service file
sudo cat << EOT > /etc/systemd/system/alertmanager.service

[Unit]
Description=AlertManager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/usr/bin/alertmanager \
    --config.file /etc/alertmanager/alertmanager.yml \
    --storage.path /var/lib/alertmanager/

[Install]
WantedBy=multi-user.target

EOT

sudo chmod 664 /etc/systemd/system/alertmanager.service

# reload the system deamon service and start prometheus service
sudo systemctl daemon-reload
sudo systemctl start alertmanager
sudo systemctl enable alertmanager
