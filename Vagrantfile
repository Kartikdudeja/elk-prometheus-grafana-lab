# Observability Lab Setup (ELK Stack, Prometheus and Grafana)

servers=[
    {
        ### ELK Stack VM ###
        :hostname => "elk-stack",
        :box => "bento/ubuntu-22.04",
        :ip => "192.168.100.11",
        :memory => "4096",
        :cpu => "2",
        :guest_port_p1 => "9200",
        :host_port_p1 => "9200",
        :guest_port_p2 => "5601",
        :host_port_p2 => "5601",
        :vmname => "elk-stack",
        :script => "./provision/install-configure-elk-stack.sh"
    },
    {
        ### Prometheus and Grafana VM ###
        :hostname => "prometheus-grafana",
        :box => "geerlingguy/rockylinux8",
        :ip => "192.168.100.12",
        :memory => "1024",
        :cpu => "1",
        :guest_port_p1 => "3000",
        :host_port_p1 => "3000",
        :guest_port_p2 => "9090",
        :host_port_p2 => "9090",
        :vmname => "prometheus-grafana",
        :script => "./provision/grafana-prometheus.sh"
    }
]

Vagrant.configure("2") do |config|

    # manages the /etc/hosts file on guest machines in multi-machine environments
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true

    servers.each do |machine|
    
        config.vm.define machine[:hostname] do |node|

            node.vm.box = machine[:box]
            node.vm.hostname = machine[:hostname]
            node.vm.network :private_network, ip: machine[:ip]

            node.vm.network :forwarded_port, guest: machine[:guest_port_p1], host: machine[:host_port_p1], auto_correct: true
            node.vm.network :forwarded_port, guest: machine[:guest_port_p2], host: machine[:host_port_p2], auto_correct: true
    
            node.vm.provider :virtualbox do |vb|

                vb.customize ["modifyvm", :id, "--name", machine[:vmname]]
                vb.customize ["modifyvm", :id, "--memory", machine[:memory]]
                vb.customize ["modifyvm", :id, "--cpus", machine[:cpu]]

                # fix for slow network speed issue
                vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
                vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

            end # end provider

            node.vm.provision "shell", path: machine[:script]

        end # end config
    end # end servers each loop
end
