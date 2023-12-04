#!/bin/bash

# Install Node Exporter for exposing OS and Hardware Metric to Prometheus

# Reference: https://devopscube.com/monitor-linux-servers-prometheus-node-exporter/

NODE_EXPORTER_DOWNLOAD_URL="https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz"

# download and extract node exporter package
cd /tmp
curl --silent -LO ${NODE_EXPORTER_DOWNLOAD_URL}
tar -xvf $(basename ${NODE_EXPORTER_DOWNLOAD_URL})

# export node binaries to /usr/local/bin
sudo mv $(basename ${NODE_EXPORTER_DOWNLOAD_URL} .tar.gz)/node_exporter /usr/local/bin/

# create node_exporter user
sudo useradd -rs /bin/false node_exporter

# create node exporter service
sudo cat << EOF > /etc/systemd/system/node_exporter.service

[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target

EOF

# Reload the system daemon and star the node exporter service
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
