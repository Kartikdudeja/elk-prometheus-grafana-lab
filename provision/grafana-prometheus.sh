#!/bin/bash

# Install Grafana and Prometheus on RHEL based Linux OS

# install grafana
GRAFANA_DOWNLOAD_URL="https://dl.grafana.com/oss/release/grafana-10.1.2-1.x86_64.rpm"

# download grafana
sudo yum install -y ${GRAFANA_DOWNLOAD_URL}

# start and enable grafana service
sudo systemctl start grafana-server
sudo systemctl enable grafana-server


# wait sometime
sleep 10

# install prometheus
PROMETHEUS_DOWNLOAD_URL="https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz"
BASE_DIR="/"

# update yum packages repos
# sudo yum update -y

# download Prometheus Linux Binaries
cd ${BASE_DIR}
sudo curl --silent -LO ${PROMETHEUS_DOWNLOAD_URL}
sudo tar -xvf $(basename ${PROMETHEUS_DOWNLOAD_URL})
sudo mv $(basename ${PROMETHEUS_DOWNLOAD_URL} .tar.gz) prometheus-files/

# create prometheus user
sudo useradd --no-create-home --shell /bin/false prometheus

# create directory for prometheus and make prometheus user as the owner of these directories
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# copy prometheus binaries to bin directory
sudo cp prometheus-files/prometheus /usr/local/bin/
sudo cp prometheus-files/promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

# move prometheus library files to etc directory
sudo cp -r prometheus-files/consoles /etc/prometheus
sudo cp -r prometheus-files/console_libraries /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries

# create prometheus configuration file
sudo touch /etc/prometheus/prometheus.yml
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

sudo cat << EOF > /etc/prometheus/prometheus.yml

global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']

EOF

# create prometheus service file
sudo cat << EOT > /etc/systemd/system/prometheus.service

[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target

EOT

# reload the system deamon service and start prometheus service
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
