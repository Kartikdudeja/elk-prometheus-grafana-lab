# Setup Observability Lab with ELK Stack and Prometheus + Grafana

This repository contains scripts and configurations to set up a lab environment using Vagrant, incorporating ELK Stack (Elasticsearch, Logstash, Kibana) for log management and Prometheus with Grafana for observability.

## Prerequisites

- [Vagrant](https://www.vagrantup.com/downloads)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

## Getting Started

1. Clone this repository:

   ```bash
   git clone https://github.com/Kartikdudeja/elk-prometheus-grafana-lab.git
   cd elk-prometheus-grafana-lab
   ```
2. Start the Vagrant environment:

   ```bash
   vagrant up
   ```

3. Access ELK Stack services:

   - Elasticsearch: [http://localhost:9200](http://localhost:9200)
   - Kibana: [http://localhost:5601](http://localhost:5601)

4. Access Prometheus and Grafana:

   - Prometheus: [http://localhost:9090](http://localhost:9090)
   - Grafana: [http://localhost:3000](http://localhost:3000)

## Structure

- `Vagrantfile`: Defines the virtual machines and their configurations.
- `provision/`: Contains scripts to provision ELK Stack and Prometheus + Grafana.

## Customization

- Adjust configurations in `provision/` scripts according to your preferences or environment requirements.
- Explore Vagrant's configurations in `Vagrantfile` to modify VM settings like memory, CPU, etc.

## Notes

- Ensure that the host machine has sufficient resources allocated to run the VMs smoothly.

## References

- [ELK Stack Documentation](https://www.elastic.co/guide/index.html)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
