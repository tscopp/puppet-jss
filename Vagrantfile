# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
    config.vm.define "jss" do |jss|
        jss.vm.box = "precise64"
        jss.vm.hostname= "jss.berkeley.edu"
        jss.vm.network "private_network", ip: "192.168.56.101"
        jss.vm.network "forwarded_port", guest: 8080, host: 8080
        jss.vm.network "forwarded_port", guest: 8443, host: 8443
        jss.vm.provision "puppet" do |puppet|
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
        db.vm.box = "precise64"
        db.vm.hostname= "db.berkeley.edu"
        db.vm.network "private_network", ip: "192.168.56.102"
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

