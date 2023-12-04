#!/bin/bash

# Install ELK Stack on Ubuntu 20.04

ELASTICSEARCH_CONFIG_FILE="/etc/elasticsearch/elasticsearch.yml"
ELASTICSEARCH_JVM_FILE="/etc/elasticsearch/jvm.options"

KIBANA_CONFIG_FILE="/etc/kibana/kibana.yml"

LOGSTASH_JVM_FILE="/etc/logstash/jvm.options"

FILEBEAT_CONFIG_FILE="/etc/filebeat/filebeat.yml"

# install java
sudo apt install openjdk-8-jdk -y

# add elasticsearch repo
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee –a /etc/apt/sources.list.d/elastic-7.x.list

sudo apt update
sudo apt install apt-transport-https -y 

# install ELK
sudo apt install elasticsearch kibana logstash filebeat -y

# elasticsearch configuration
sudo sed -i.bak -e '/network.host:/d' -e '/http.port:/d' ${ELASTICSEARCH_CONFIG_FILE}

sudo cat << EOT >> ${ELASTICSEARCH_CONFIG_FILE}
# Set the bind address to a specific IP (IPv4 or IPv6):
network.host: 0.0.0.0
# http port
http.port: 9200
# single node cluster configuration
discovery.type: single-node
EOT

# elasticsearch jvm config
sudo sed -i.bak -e '/Xms/d' -e '/Xmx/d' ${ELASTICSEARCH_JVM_FILE}

sudo cat << EOT >> ${ELASTICSEARCH_JVM_FILE}
# initial size of total heap space
-Xms512M
# maximum size of total heap space
-Xmx512M
EOT

# start and enable elastic search
sudo systemctl start elasticsearch.service
sudo systemctl enable elasticsearch.service

# kibana configuration
sudo sed -i.bak -e '/server.port:/d' -e '/server.host:/d' -e '/elasticsearch.hosts:/d' ${KIBANA_CONFIG_FILE}

sudo cat << EOT >> ${KIBANA_CONFIG_FILE}
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://localhost:9200"]
EOT

# start and enable kibana
sudo systemctl start kibana
sudo systemctl enable kibana

# logstash configuration
sudo sed -i.bak -e '/Xms/d' -e '/Xmx/d' ${LOGSTASH_JVM_FILE}

sudo cat << EOT >> ${LOGSTASH_JVM_FILE}
-Xms512M
-Xmx512M
EOT

# start and enable logstash
sudo systemctl start logstash
sudo systemctl enable logstash

# filebeat configuration
sed -i.bak -e 's/output.elasticsearch:/# output.elasticsearch:/' -e 's/hosts: \[\"localhost:9200\"\]/# hosts: \[\"localhost:9200\"\]/' ${FILEBEAT_CONFIG_FILE}
sed -i -e 's/#output.logstash:/output.logstash:/' -e 's/#hosts: \[\"localhost:5044\"\]/hosts: \[\"localhost:5044\"\]/' ${FILEBEAT_CONFIG_FILE}

# enable filebeat system module
sudo filebeat modules enable system

# load the index template
sudo filebeat setup --index-management -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=["localhost:9200"]'

# start and enable filebeat
sudo systemctl start filebeat
sudo systemctl enable filebeat
