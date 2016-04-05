# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
    config.vm.define "default" do |default|
        default.vm.box = "ubuntu/precise64"
        default.vm.hostname= "default.berkeley.edu"
        default.vm.network "private_network", ip: "192.168.56.100"
        default.vm.network "forwarded_port", guest: 8080, host: 8080
        default.vm.network "forwarded_port", guest: 8443, host: 8443
        default.vm.provision "puppet" do |puppet|
            puppet.facter = {
                "vagrant" => true,
                "role" => 'jss',
            }
            #puppet.options = "--verbose --debug"
            puppet.manifests_path="manifests/"
            puppet.manifest_file="site.pp"
            puppet.module_path= "modules/"
        end
    end
    config.vm.define "jss" do |jss|
        jss.vm.box = "hashicorp/precise64"
        jss.vm.hostname= "jss.berkeley.edu"
        jss.vm.network "private_network", ip: "192.168.56.101"
        jss.vm.network "forwarded_port", guest: 8080, host: 8081
        jss.vm.network "forwarded_port", guest: 8443, host: 8444
        jss.vm.provision "puppet" do |puppet|
            puppet.facter = {
                "vagrant" => true,
                "role" => 'jss',
            }
            #
            #puppet.options = "--verbose --debug"
            puppet.manifests_path="manifests/"
            puppet.manifest_file="site.pp"
            puppet.module_path= "modules/"
        end
    end
    config.vm.define "jss01" do |jss01|
        jss01.vm.box = "hashicorp/precise64"
        jss01.vm.hostname= "jss01.berkeley.edu"
        jss01.vm.network "private_network", ip: "192.168.56.102"
        jss01.vm.network "forwarded_port", guest: 8080, host: 8082
        jss01.vm.network "forwarded_port", guest: 8443, host: 8445
        jss01.vm.provision "puppet" do |puppet|
            puppet.facter = {
                "vagrant" => true,
                "role" => 'jss',
            }
            #puppet.options = "--verbose --debug"
            puppet.manifests_path="manifests/"
            puppet.manifest_file="site.pp"
            puppet.module_path= "modules/"
        end
    end
    config.vm.define "jss02" do |jss02|
        jss02.vm.box = "hashicorp/precise64"
        jss02.vm.hostname= "jss02.berkeley.edu"
        jss02.vm.network "private_network", ip: "192.168.56.103"
        jss02.vm.network "forwarded_port", guest: 8080, host: 8083
        jss02.vm.network "forwarded_port", guest: 8443, host: 8446
        jss02.vm.provision "puppet" do |puppet|
            puppet.facter = {
                "vagrant" => true,
                "role" => 'jss',
            }
            #puppet.options = "--verbose --debug"
            puppet.manifests_path="manifests/"
            puppet.manifest_file="site.pp"
            puppet.module_path= "modules/"
        end
    end
    config.vm.define "db" do |db|
        db.vm.box = "hashicorp/precise64"
        db.vm.hostname= "db.berkeley.edu"
        db.vm.network "private_network", ip: "192.168.56.104"
        db.vm.provision "puppet" do |puppet|
            puppet.facter = {
                "vagrant" => true,
                "role" => 'db',
            }
            #puppet.options = "--verbose --debug"
            puppet.manifests_path="manifests/"
            puppet.manifest_file="site.pp"
            puppet.module_path= "modules/"
        end
    end
end

